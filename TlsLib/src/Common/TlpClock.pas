{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpClock;

{$I ..\Include\TlsLib.inc}

interface

uses
  TlpDateTimeUtilities,
  TlpIClock;

type
  /// <summary>The default <see cref="ITlsClock" />: reads the real system clock.</summary>
  TSystemClock = class sealed(TInterfacedObject, ITlsClock)
  public
    function NowUnixMillis: UInt64;
  end;

implementation

{ TSystemClock }

function TSystemClock.NowUnixMillis: UInt64;
begin
  Result := UInt64(TDateTimeUtilities.CurrentUnixMs);
end;

end.
