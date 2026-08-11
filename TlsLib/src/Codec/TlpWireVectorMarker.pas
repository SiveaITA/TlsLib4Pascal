{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpWireVectorMarker;

{$I ..\Include\TlsLib.inc}

interface

type
  /// <summary>
  /// A handle to an open length-prefixed vector, returned by
  /// <see cref="IWireWriter.OpenVector" /> and passed to
  /// <see cref="IWireWriter.CloseVector" /> to back-patch the prefix.
  /// </summary>
  TWireVectorMarker = record
  strict private
    FPos: Int32;
    FLenBytes: Int32;
  public
    class function Create(APos, ALenBytes: Int32): TWireVectorMarker; static;
    property Pos: Int32 read FPos;
    property LenBytes: Int32 read FLenBytes;
  end;

implementation

{ TWireVectorMarker }

class function TWireVectorMarker.Create(APos, ALenBytes: Int32): TWireVectorMarker;
begin
  Result.FPos := APos;
  Result.FLenBytes := ALenBytes;
end;

end.
