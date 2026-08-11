{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTlsLibExceptions;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpTlsAlert;

type
  /// <summary>Root of the TlsLib exception hierarchy.</summary>
  EBaseTlsLibException = class(Exception);

  /// <summary>An argument supplied to a public API was invalid.</summary>
  EArgumentTlsLibException = class(EBaseTlsLibException);

  /// <summary>A peer-supplied value (key share, ciphertext, public point) was
  /// invalid; the engine boundary turns it into an illegal_parameter alert.</summary>
  EPeerInputTlsLibException = class(EArgumentTlsLibException);

  /// <summary>An operation was attempted while in an invalid state.</summary>
  EInvalidOperationTlsLibException = class(EBaseTlsLibException);

  /// <summary>A requested capability is not supported.</summary>
  ENotSupportedTlsLibException = class(EBaseTlsLibException);

  /// <summary>
  /// Carries a <see cref="TTlsAlertDescription" /> so the engine boundary can
  /// turn a raised alert into a fatal outcome with a queued alert. The field is
  /// protected so specialized descendants can pin a fixed description.
  /// </summary>
  EFatalAlertTlsLibException = class(EBaseTlsLibException)
  protected
  var
    FAlertDescription: TTlsAlertDescription;
  public
    constructor CreateRes(ADescription: TTlsAlertDescription;
      AResStringRec: PResStringRec); overload;
    constructor CreateResFmt(ADescription: TTlsAlertDescription;
      AResStringRec: PResStringRec; const AArgs: array of const); overload;
    property AlertDescription: TTlsAlertDescription read FAlertDescription;
  end;

  /// <summary>
  /// A wire-parsing failure; always maps to the decode_error alert. Raised by
  /// the bounds-checked codec on any malformed input.
  /// </summary>
  EDecodeErrorTlsLibException = class(EFatalAlertTlsLibException)
  public
    constructor CreateRes(AResStringRec: PResStringRec); reintroduce; overload;
    constructor CreateResFmt(AResStringRec: PResStringRec;
      const AArgs: array of const); reintroduce; overload;
  end;

implementation

{ EFatalAlertTlsLibException }

constructor EFatalAlertTlsLibException.CreateRes(ADescription: TTlsAlertDescription;
  AResStringRec: PResStringRec);
begin
  inherited CreateRes(AResStringRec);
  FAlertDescription := ADescription;
end;

constructor EFatalAlertTlsLibException.CreateResFmt(ADescription: TTlsAlertDescription;
  AResStringRec: PResStringRec; const AArgs: array of const);
begin
  inherited CreateResFmt(AResStringRec, AArgs);
  FAlertDescription := ADescription;
end;

{ EDecodeErrorTlsLibException }

constructor EDecodeErrorTlsLibException.CreateRes(AResStringRec: PResStringRec);
begin
  inherited CreateRes(TTlsAlertDescription.DecodeError, AResStringRec);
end;

constructor EDecodeErrorTlsLibException.CreateResFmt(AResStringRec: PResStringRec;
  const AArgs: array of const);
begin
  inherited CreateResFmt(TTlsAlertDescription.DecodeError, AResStringRec, AArgs);
end;

end.
