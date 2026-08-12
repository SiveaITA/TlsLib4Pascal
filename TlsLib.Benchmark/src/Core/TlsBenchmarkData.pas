{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlsBenchmarkData;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
  Classes;

type
  /// <summary>A handshake-benchmark setup or run failure (missing data, unavailable
  /// OpenSSL, a non-completing handshake).</summary>
  ETlsBenchmarkError = class(Exception);

  /// <summary>The EC P-256 test credential shared by both handshake peers: a leaf
  /// certificate + its PKCS#8 private key (server side) and the issuing root (the
  /// TlsLib client's trust anchor). DER bytes, decoded from the interop test vector.</summary>
  TTlsBenchmarkCredential = record
    LeafCertDer: TBytes;
    LeafKeyDer: TBytes;
    RootCertDer: TBytes;
  end;

  /// <summary>Locates and decodes the shared EC P-256 chain used by the handshake
  /// benchmarks. Self-contained (no interop-harness dependency) so the benchmark's
  /// only real dependencies are the TlsLib package and mORMot's OpenSSL binding.</summary>
  TTlsBenchmarkData = class sealed(TObject)
  strict private
    class function DecodeHex(const AHex: string): TBytes; static;
    class function LocateChainFile: string; static;
  public
    class function LoadEcP256: TTlsBenchmarkCredential; static;
  end;

implementation

resourcestring
  SChainFileNotFound =
    'benchmark: could not locate EcP256Chain.txt (searched up from the executable)';
  SMissingField = 'benchmark: EcP256Chain.txt is missing the "%s" field';

const
  // relative to a repository root; the first that resolves wins
  CChainCandidates: array [0 .. 1] of string = (
    'TlsLib.Interop' + PathDelim + 'Data' + PathDelim + 'Certs' + PathDelim + 'EcP256Chain.txt',
    'TlsLib.Tests' + PathDelim + 'Data' + PathDelim + 'Certs' + PathDelim + 'EcP256Chain.txt');

class function TTlsBenchmarkData.DecodeHex(const AHex: string): TBytes;
var
  LClean: string;
  LI, LN: Int32;

  function NibbleOf(AC: Char): Int32;
  begin
    case AC of
      '0' .. '9': Result := Ord(AC) - Ord('0');
      'a' .. 'f': Result := Ord(AC) - Ord('a') + 10;
      'A' .. 'F': Result := Ord(AC) - Ord('A') + 10;
    else
      Result := -1;
    end;
  end;

begin
  // tolerate embedded whitespace so a wrapped or space-grouped hex field still decodes
  LClean := '';
  for LI := 1 to System.Length(AHex) do
    if NibbleOf(AHex[LI]) >= 0 then
      LClean := LClean + AHex[LI];

  LN := System.Length(LClean) div 2;
  Result := nil;
  SetLength(Result, LN);
  for LI := 0 to LN - 1 do
    Result[LI] := Byte((NibbleOf(LClean[LI * 2 + 1]) shl 4)
      or NibbleOf(LClean[LI * 2 + 2]));
end;

class function TTlsBenchmarkData.LocateChainFile: string;
var
  LDir, LCandidate: string;
  LDepth, LI: Int32;
begin
  LDir := ExtractFilePath(ExpandFileName(ParamStr(0)));
  for LDepth := 0 to 9 do
  begin
    for LI := System.Low(CChainCandidates) to System.High(CChainCandidates) do
    begin
      LCandidate := IncludeTrailingPathDelimiter(LDir) + CChainCandidates[LI];
      if FileExists(LCandidate) then
        Exit(LCandidate);
    end;
    LDir := ExtractFileDir(ExcludeTrailingPathDelimiter(LDir));
    if LDir = '' then
      Break;
  end;
  raise EFileNotFoundException.Create(SChainFileNotFound);
end;

class function TTlsBenchmarkData.LoadEcP256: TTlsBenchmarkCredential;
var
  LFields: TStringList;

  function Field(const AName: string): TBytes;
  var
    LHex: string;
  begin
    if LFields.IndexOfName(AName) < 0 then
      raise EArgumentException.CreateFmt(SMissingField, [AName]);
    LHex := LFields.Values[AName];
    Result := DecodeHex(LHex);
  end;

begin
  LFields := TStringList.Create;
  try
    LFields.NameValueSeparator := '=';
    LFields.LoadFromFile(LocateChainFile);
    Result.LeafCertDer := Field('leaf_cert');
    Result.LeafKeyDer := Field('leaf_key');
    Result.RootCertDer := Field('root_cert');
  finally
    LFields.Free;
  end;
end;

end.
