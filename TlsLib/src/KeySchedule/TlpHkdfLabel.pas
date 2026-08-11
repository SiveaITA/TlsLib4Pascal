{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpHkdfLabel;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpISecretBuffer,
  TlpICryptoProvider,
  TlpTlsLibExceptions,
  TlpWireVectorMarker,
  TlpIWireWriter,
  TlpWireWriter;

type
  /// <summary>
  /// The TLS 1.3 label wrapper over the raw HKDF: HKDF-Expand-Label and
  /// Derive-Secret (RFC 8446 7.1), built on the provider's IHkdf. Stateless - the
  /// hash is carried by the supplied IHkdf and the transcript hash is passed in.
  /// </summary>
  THkdfLabel = class sealed(TObject)
  public
    /// <summary>
    /// The serialized HkdfLabel struct: uint16 length, opaque label &lt;7..255&gt;
    /// = "tls13 " + ALabel, opaque context &lt;0..255&gt;. Over-length raises.
    /// </summary>
    class function BuildHkdfLabel(const ALabel: string; const AContext: TBytes;
      ALength: Int32): TBytes; static;
    /// <summary>HKDF-Expand-Label(ASecret, ALabel, AContext, ALength).</summary>
    class function HkdfExpandLabel(const AHkdf: IHkdf; const ASecret: ISecretBuffer;
      const ALabel: string; const AContext: TBytes; ALength: Int32): ISecretBuffer; static;
    /// <summary>
    /// Derive-Secret(ASecret, ALabel, Messages): HKDF-Expand-Label with the
    /// transcript hash as context and the hash length as the output length. The
    /// caller supplies the already-computed transcript hash.
    /// </summary>
    class function DeriveSecret(const AHkdf: IHkdf; const ASecret: ISecretBuffer;
      const ALabel: string; const ATranscriptHash: TBytes): ISecretBuffer; static;
  end;

implementation

const
  Tls13LabelPrefix = 'tls13 ';
  MinFullLabelLength = Int32(7);
  MaxFullLabelLength = Int32(255);
  MaxContextLength = Int32(255);

resourcestring
  SLabelLength = 'HKDF-Expand-Label label length %d is outside the 7..255 range';
  SContextLength = 'HKDF-Expand-Label context length %d exceeds 255';

{ THkdfLabel }

class function THkdfLabel.BuildHkdfLabel(const ALabel: string;
  const AContext: TBytes; ALength: Int32): TBytes;
var
  LWriter: IWireWriter;
  LFullLabel: TBytes;
  LMarker: TWireVectorMarker;
begin
  Result := nil;
  LFullLabel := TEncoding.ASCII.GetBytes(Tls13LabelPrefix + ALabel);
  if (System.Length(LFullLabel) < MinFullLabelLength) or
    (System.Length(LFullLabel) > MaxFullLabelLength) then
    raise EArgumentTlsLibException.CreateResFmt(@SLabelLength,
      [System.Length(LFullLabel)]);
  if System.Length(AContext) > MaxContextLength then
    raise EArgumentTlsLibException.CreateResFmt(@SContextLength,
      [System.Length(AContext)]);
  LWriter := TWireWriter.Create;
  LWriter.WriteUInt16(UInt16(ALength));
  LMarker := LWriter.OpenVector(1);
  LWriter.WriteBytes(LFullLabel);
  LWriter.CloseVector(LMarker);
  LMarker := LWriter.OpenVector(1);
  LWriter.WriteBytes(AContext);
  LWriter.CloseVector(LMarker);
  Result := LWriter.ToBytes;
end;

class function THkdfLabel.HkdfExpandLabel(const AHkdf: IHkdf;
  const ASecret: ISecretBuffer; const ALabel: string; const AContext: TBytes;
  ALength: Int32): ISecretBuffer;
begin
  // the HkdfLabel is public (label + transcript hash), not secret material
  Result := AHkdf.Expand(ASecret, BuildHkdfLabel(ALabel, AContext, ALength), ALength);
end;

class function THkdfLabel.DeriveSecret(const AHkdf: IHkdf;
  const ASecret: ISecretBuffer; const ALabel: string;
  const ATranscriptHash: TBytes): ISecretBuffer;
begin
  Result := HkdfExpandLabel(AHkdf, ASecret, ALabel, ATranscriptHash,
    System.Length(ATranscriptHash));
end;

end.
