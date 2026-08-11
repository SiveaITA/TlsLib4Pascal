{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTrafficKeys;

{$I ..\Include\TlsLib.inc}

interface

uses
  TlpISecretBuffer,
  TlpIKeySchedule;

type
  /// <summary>The (key, iv) a schedule derived for one epoch and direction.</summary>
  TTrafficKeys = class sealed(TInterfacedObject, ITrafficKeys)
  strict private
  var
    FKey: ISecretBuffer;
    FIv: ISecretBuffer;
  public
    constructor Create(const AKey, AIv: ISecretBuffer);
    function Key: ISecretBuffer;
    function Iv: ISecretBuffer;
  end;

implementation

{ TTrafficKeys }

constructor TTrafficKeys.Create(const AKey, AIv: ISecretBuffer);
begin
  inherited Create;
  FKey := AKey;
  FIv := AIv;
end;

function TTrafficKeys.Key: ISecretBuffer;
begin
  Result := FKey;
end;

function TTrafficKeys.Iv: ISecretBuffer;
begin
  Result := FIv;
end;

end.
