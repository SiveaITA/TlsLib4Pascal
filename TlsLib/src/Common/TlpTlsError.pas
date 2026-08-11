{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTlsError;

{$I ..\Include\TlsLib.inc}

interface

uses
  TlpTlsAlert;

type
  /// <summary>
  /// The structured, public-facing error surfaced to callers: the alert that
  /// was (or would be) sent and a human-readable message that must not leak
  /// internal state.
  /// </summary>
  TTlsError = record
  strict private
    FAlert: TTlsAlert;
    FMessage: string;
  public
    class function Create(const AAlert: TTlsAlert;
      const AMessage: string): TTlsError; static;
    /// <summary>A fatal error carrying the given alert description and message.</summary>
    class function CreateFatal(ADescription: TTlsAlertDescription;
      const AMessage: string): TTlsError; static;
    property Alert: TTlsAlert read FAlert;
    property Message: string read FMessage;
  end;

implementation

{ TTlsError }

class function TTlsError.Create(const AAlert: TTlsAlert;
  const AMessage: string): TTlsError;
begin
  Result.FAlert := AAlert;
  Result.FMessage := AMessage;
end;

class function TTlsError.CreateFatal(ADescription: TTlsAlertDescription;
  const AMessage: string): TTlsError;
begin
  Result := TTlsError.Create(TTlsAlert.CreateFatal(ADescription), AMessage);
end;

end.
