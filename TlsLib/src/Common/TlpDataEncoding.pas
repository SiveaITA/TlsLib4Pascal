{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpDataEncoding;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpTlsLibExceptions;

type
  /// <summary>The letter case a hex encoding emits.</summary>
  THexCase = (Lower, Upper);

  /// <summary>
  /// Byte-to-text data encodings (RFC 4648): a lossless, encoding-independent
  /// text form for arbitrary bytes, where a character-set encoding would be lossy
  /// or reject non-UTF-8 input.
  /// </summary>
  TDataEncoding = class sealed(TObject)
  strict private
    class function NibbleValue(AChar: Char): Int32; static;
  public
    /// <summary>The Base16 (hex) encoding of AData, lowercase by default.</summary>
    class function HexEncode(const AData: TBytes;
      ACase: THexCase = THexCase.Lower): string; static;
    /// <summary>
    /// The bytes of a Base16 (hex) string (either case). Raises
    /// EArgumentTlsLibException on an odd length or a non-hex character.
    /// </summary>
    class function HexDecode(const AHex: string): TBytes; static;
  end;

implementation

const
  LowerHexDigits: array [0 .. 15] of Char = ('0', '1', '2', '3', '4', '5', '6',
    '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f');
  UpperHexDigits: array [0 .. 15] of Char = ('0', '1', '2', '3', '4', '5', '6',
    '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

resourcestring
  SOddHexLength = 'a hex string must have an even number of digits';
  SNonHexCharacter = 'the hex string contains a non-hex character';

{ TDataEncoding }

class function TDataEncoding.HexEncode(const AData: TBytes;
  ACase: THexCase): string;
var
  LI: Int32;
  LHi, LLo: Char;
begin
  Result := '';
  SetLength(Result, System.Length(AData) * 2);
  for LI := 0 to System.Length(AData) - 1 do
  begin
    if ACase = THexCase.Upper then
    begin
      LHi := UpperHexDigits[AData[LI] shr 4];
      LLo := UpperHexDigits[AData[LI] and $0F];
    end
    else
    begin
      LHi := LowerHexDigits[AData[LI] shr 4];
      LLo := LowerHexDigits[AData[LI] and $0F];
    end;
    Result[(LI * 2) + 1] := LHi;
    Result[(LI * 2) + 2] := LLo;
  end;
end;

class function TDataEncoding.NibbleValue(AChar: Char): Int32;
begin
  case AChar of
    '0' .. '9':
      Result := Ord(AChar) - Ord('0');
    'a' .. 'f':
      Result := 10 + Ord(AChar) - Ord('a');
    'A' .. 'F':
      Result := 10 + Ord(AChar) - Ord('A');
  else
    Result := -1;
  end;
end;

class function TDataEncoding.HexDecode(const AHex: string): TBytes;
var
  LI, LHi, LLo: Int32;
begin
  Result := nil;
  if System.Length(AHex) mod 2 <> 0 then
    raise EArgumentTlsLibException.CreateRes(@SOddHexLength);
  SetLength(Result, System.Length(AHex) div 2);
  for LI := 0 to System.Length(Result) - 1 do
  begin
    LHi := NibbleValue(AHex[(LI * 2) + 1]);
    LLo := NibbleValue(AHex[(LI * 2) + 2]);
    if (LHi < 0) or (LLo < 0) then
      raise EArgumentTlsLibException.CreateRes(@SNonHexCharacter);
    Result[LI] := Byte((LHi shl 4) or LLo);
  end;
end;

end.
