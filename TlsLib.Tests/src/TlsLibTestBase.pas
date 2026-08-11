{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlsLibTestBase;

interface

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

uses
  SysUtils,
  Classes,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  TlpArrayUtilities,
  TlpDataEncoding,
  TlpICryptoProvider,
  TlpDefaultCryptoProvider,
  TlsLibTestResourceLoader;

type
  /// <summary>Shared base fixture</summary>
  TTlsLibTestCase = class abstract(TTestCase)
  end;

  /// <summary>Adds hex / comparison / resource helpers used across the suites.</summary>
  TTlsLibAlgorithmTestCase = class abstract(TTlsLibTestCase)
  strict private
    FProvider: ICryptoProvider;
    function GetProvider: ICryptoProvider;
  strict protected
    // Overridable so a fixture can supply a different provider (e.g. a mock).
    function CreateProvider: ICryptoProvider; virtual;
  protected
    // The crypto provider, created once per test on first use.
    property Provider: ICryptoProvider read GetProvider;
    function DecodeHex(const AData: String): TBytes;
    function EncodeHex(const AData: TBytes): String;
    function AreEqual(const AA, AB: TBytes): Boolean;
    // A fresh array holding AA followed by AB.
    function ConcatBytes(const AA, AB: TBytes): TBytes;
    // Fail with a hex diff unless AActual equals AExpected.
    procedure CheckEqualBytes(const AName: string; const AExpected, AActual: TBytes);
    function LoadResourceBytes(const ARelativePath: string): TBytes;
    function LoadResourceString(const ARelativePath: string): string;
    // Loads a "name=hexvalue" vector file; read fields via Result.Values['name'].
    function LoadVectorFields(const ARelativePath: string): TStringList;
  end;

implementation

{ TTlsLibAlgorithmTestCase }

function TTlsLibAlgorithmTestCase.CreateProvider: ICryptoProvider;
begin
  Result := TDefaultCryptoProvider.Create;
end;

function TTlsLibAlgorithmTestCase.GetProvider: ICryptoProvider;
begin
  if FProvider = nil then
    FProvider := CreateProvider;
  Result := FProvider;
end;

function TTlsLibAlgorithmTestCase.DecodeHex(const AData: String): TBytes;
begin
  // vector files may space-separate bytes; strip whitespace, then decode strictly
  Result := TDataEncoding.HexDecode(StringReplace(AData, ' ', '', [rfReplaceAll]));
end;

function TTlsLibAlgorithmTestCase.EncodeHex(const AData: TBytes): String;
begin
  Result := TDataEncoding.HexEncode(AData, THexCase.Upper);
end;

function TTlsLibAlgorithmTestCase.AreEqual(const AA, AB: TBytes): Boolean;
var
  LI: Int32;
begin
  Result := System.Length(AA) = System.Length(AB);
  if not Result then
    Exit;
  for LI := 0 to System.Length(AA) - 1 do
    if AA[LI] <> AB[LI] then
      Exit(False);
end;

function TTlsLibAlgorithmTestCase.ConcatBytes(const AA, AB: TBytes): TBytes;
begin
  Result := TArrayUtilities.Concat(AA, AB);
end;

procedure TTlsLibAlgorithmTestCase.CheckEqualBytes(const AName: string;
  const AExpected, AActual: TBytes);
begin
  if not AreEqual(AExpected, AActual) then
    Fail(Format('%s failed - expected %s got %s',
      [AName, EncodeHex(AExpected), EncodeHex(AActual)]));
end;

function TTlsLibAlgorithmTestCase.LoadResourceBytes(const ARelativePath: string): TBytes;
begin
  Result := TTlsLibTestResourceLoader.LoadBytes(ARelativePath);
end;

function TTlsLibAlgorithmTestCase.LoadResourceString(const ARelativePath: string): string;
begin
  Result := TTlsLibTestResourceLoader.LoadString(ARelativePath);
end;

function TTlsLibAlgorithmTestCase.LoadVectorFields(const ARelativePath: string): TStringList;
begin
  Result := TStringList.Create;
  try
    Result.LoadFromFile(TTlsLibTestResourceLoader.ResourcePath(ARelativePath));
  except
    Result.Free;
    raise;
  end;
end;

end.
