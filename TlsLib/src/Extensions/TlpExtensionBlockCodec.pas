{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpExtensionBlockCodec;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpArrayUtilities,
  TlpCodeKeyedRegistry,
  TlpTlsAlert,
  TlpTlsLibExceptions,
  TlpWireReader,
  TlpWireVectorMarker,
  TlpIWireWriter,
  TlpWireWriter,
  TlpExtensionContext,
  TlpITlsExtension;

type
  /// <summary>The default injectable registry: a registration-ordered list of extensions.</summary>
  TExtensionRegistry = class sealed(TCodeKeyedRegistry<ITlsExtension>,
    IExtensionRegistry)
  strict private
    class function CodeOf(const AExtension: ITlsExtension): UInt16; static;
  public
    constructor Create;
  end;

  /// <summary>
  /// Owns all extension-block wire framing and the cross-extension rules of RFC 8446
  /// 4.2: the outer extensions vector, duplicate detection (decode_error), the
  /// unknown-extension skip (which also tolerates GREASE), per-message context
  /// enforcement (wrong context -> unsupported_extension), and the response-only
  /// rule that an extension the ClientHello did not offer is fatal
  /// (unsupported_extension). Individual extensions never see these concerns.
  /// </summary>
  TExtensionBlockCodec = class sealed(TInterfacedObject, IExtensionBlockCodec)
  strict private
  var
    FRegistry: IExtensionRegistry;
    class function IsResponseContext(AKind: TTlsExtensionContextKind): Boolean; static;
  public
    constructor Create(const ARegistry: IExtensionRegistry);
    /// <summary>Serializes the extensions vector for AKind from the shared context.</summary>
    function ProduceBlock(const AContext: TExtensionContext;
      AKind: TTlsExtensionContextKind): TBytes;
    /// <summary>Parses an extensions vector for AKind, applying the 4.2 rules.</summary>
    procedure ConsumeBlock(const AContext: TExtensionContext;
      AKind: TTlsExtensionContextKind; const ABlock: TBytes);
  end;

implementation

const
  // a hello never legitimately carries this many extensions; a larger block is abuse
  MaxExtensionsPerBlock = Int32(64);

resourcestring
  SDuplicateExtension = 'a duplicate extension type appears in the block';
  SWrongContextExtension = 'an extension appears in a message it is not allowed in';
  SUnsolicitedExtension = 'the peer sent an extension that was not offered';
  STooManyExtensions = 'the extension block carries too many extensions';

{ TExtensionRegistry }

constructor TExtensionRegistry.Create;
begin
  inherited Create(CodeOf);
end;

class function TExtensionRegistry.CodeOf(const AExtension: ITlsExtension): UInt16;
begin
  Result := AExtension.ExtensionType;
end;

{ TExtensionBlockCodec }

constructor TExtensionBlockCodec.Create(const ARegistry: IExtensionRegistry);
begin
  inherited Create;
  FRegistry := ARegistry;
end;

class function TExtensionBlockCodec.IsResponseContext(
  AKind: TTlsExtensionContextKind): Boolean;
begin
  // ServerHello/EncryptedExtensions/Certificate/HelloRetryRequest are responses to the
  // ClientHello and may carry only extensions it offered. ClientHello is unprompted;
  // NewSessionTicket is server-originated post-handshake; and a CertificateRequest carries
  // the server's own constraints (signature_algorithms, certificate_authorities, oid_filters
  // per RFC 8446 4.3.2), which are not gated by client offers - only by each extension's
  // ValidContexts. None of those three is bound by the offered rule.
  Result := (AKind <> TTlsExtensionContextKind.ClientHello) and
    (AKind <> TTlsExtensionContextKind.NewSessionTicket) and
    (AKind <> TTlsExtensionContextKind.CertificateRequest);
end;

function TExtensionBlockCodec.ProduceBlock(const AContext: TExtensionContext;
  AKind: TTlsExtensionContextKind): TBytes;
var
  LWriter: IWireWriter;
  LOuter, LInner: TWireVectorMarker;
  LAll: TArray<ITlsExtension>;
  LExt: ITlsExtension;
  LBody: TBytes;
  LI: Int32;
begin
  Result := nil;
  AContext.MessageContext := AKind;
  LWriter := TWireWriter.Create;
  LOuter := LWriter.OpenVector(2);
  LAll := FRegistry.Items;
  for LI := 0 to High(LAll) do
  begin
    LExt := LAll[LI];
    if not (AKind in LExt.ValidContexts) then
      Continue;
    if not LExt.Produce(AContext, LBody) then
      Continue;
    LWriter.WriteUInt16(LExt.ExtensionType);
    LInner := LWriter.OpenVector(2);
    LWriter.WriteBytes(LBody);
    LWriter.CloseVector(LInner);
    if AKind = TTlsExtensionContextKind.ClientHello then
      AContext.MarkOffered(LExt.ExtensionType);
  end;
  LWriter.CloseVector(LOuter);
  Result := LWriter.ToBytes;
end;

procedure TExtensionBlockCodec.ConsumeBlock(const AContext: TExtensionContext;
  AKind: TTlsExtensionContextKind; const ABlock: TBytes);
var
  LOuter, LEntries, LData: TWireReader;
  LType: UInt16;
  LTypes: TArray<UInt16>;
  LBodies: TArray<TBytes>;
  LExt: ITlsExtension;
  LI: Int32;
begin
  AContext.MessageContext := AKind;
  // an omitted extensions field (no bytes at all, distinct from a present-but-empty
  // extensions<0..> vector) carries no extensions; only a TLS 1.2 ClientHello/ServerHello may
  // end after compression_method (RFC 5246 7.4.1) - accept it there as the empty offer it is.
  // Every other message (EncryptedExtensions, Certificate, ...) carries a mandatory extensions
  // vector, so an absent one falls through to the reader below and is a decode_error
  if (System.Length(ABlock) = 0) and
    (AKind in [TTlsExtensionContextKind.ClientHello,
    TTlsExtensionContextKind.ServerHello]) then
    Exit;
  LOuter := TWireReader.Create(ABlock);
  LEntries := LOuter.OpenVector(2);
  LOuter.ExpectEnd; // nothing may follow the extensions vector

  // structural pass: collect every entry, rejecting a repeated type (illegal_parameter, RFC
  // 8446 4.2 forbids it but leaves the alert unspecified) and bounding the count. The duplicate
  // check runs here, before any semantic rule such as the unsolicited-extension check below, so
  // a duplicated type - even an unoffered/bogus one - is reported as the duplicate it is rather
  // than as an unsolicited extension.
  LTypes := nil;
  LBodies := nil;
  while not LEntries.EndReached do
  begin
    LType := LEntries.ReadUInt16;
    LData := LEntries.OpenVector(2);
    if TArrayUtilities.Contains<UInt16>(LTypes, LType) then
      raise EFatalAlertTlsLibException.CreateRes(
        TTlsAlertDescription.IllegalParameter, @SDuplicateExtension);
    if System.Length(LTypes) >= MaxExtensionsPerBlock then
      raise EDecodeErrorTlsLibException.CreateRes(@STooManyExtensions);
    TArrayUtilities.Append<UInt16>(LTypes, LType);
    TArrayUtilities.Append<TBytes>(LBodies, LData.ReadBytes(LData.Remaining));
  end;

  // semantic pass: record which types an inbound ClientHello carried (symmetric with the
  // produce path, so the server can enforce presence rules such as RFC 8446 9.2's mutually-
  // required extensions), reject a response extension the ClientHello never offered, and
  // dispatch each known type to its handler (an unknown type, incl. GREASE, is skipped)
  for LI := 0 to High(LTypes) do
  begin
    LType := LTypes[LI];
    if AKind = TTlsExtensionContextKind.ClientHello then
      AContext.MarkOffered(LType);

    if IsResponseContext(AKind) and not AContext.WasOffered(LType) then
      raise EFatalAlertTlsLibException.CreateRes(
        TTlsAlertDescription.UnsupportedExtension, @SUnsolicitedExtension);

    if FRegistry.TryGet(LType, LExt) then
    begin
      if not (AKind in LExt.ValidContexts) then
        raise EFatalAlertTlsLibException.CreateRes(
          TTlsAlertDescription.UnsupportedExtension, @SWrongContextExtension);
      LExt.Consume(AContext, LBodies[LI]);
    end;
  end;
end;

end.
