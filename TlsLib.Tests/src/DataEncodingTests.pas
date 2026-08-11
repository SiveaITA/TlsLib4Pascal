{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit DataEncodingTests;

interface

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

uses
  SysUtils,
{$IFDEF FPC}
  fpcunit,
  testregistry,
{$ELSE}
  TestFramework,
{$ENDIF FPC}
  TlpTlsLibExceptions,
  TlpDataEncoding,
  TlsLibTestBase;

type
  TTestDataEncoding = class(TTlsLibAlgorithmTestCase)
  published
    procedure TestHexEncodeLowerAndUpper;
    procedure TestHexDecodeRoundTripEitherCase;
    procedure TestHexDecodeOddLengthRaises;
    procedure TestHexDecodeNonHexRaises;
  end;

implementation

{ TTestDataEncoding }

procedure TTestDataEncoding.TestHexEncodeLowerAndUpper;
var
  LData: TBytes;
begin
  LData := TBytes.Create($00, $0F, $A5, $FF);
  CheckEquals('000fa5ff', TDataEncoding.HexEncode(LData), 'lowercase is the default');
  CheckEquals('000FA5FF', TDataEncoding.HexEncode(LData, THexCase.Upper),
    'uppercase when requested');
  CheckEquals('', TDataEncoding.HexEncode(nil), 'empty input encodes to empty');
end;

procedure TTestDataEncoding.TestHexDecodeRoundTripEitherCase;
var
  LData: TBytes;
begin
  LData := TBytes.Create($DE, $AD, $BE, $EF, $00, $10);
  CheckEqualBytes('lowercase round-trips', LData,
    TDataEncoding.HexDecode(TDataEncoding.HexEncode(LData)));
  CheckEqualBytes('uppercase decodes too', LData,
    TDataEncoding.HexDecode(TDataEncoding.HexEncode(LData, THexCase.Upper)));
  // mixed case is accepted
  CheckEqualBytes('mixed case decodes', TBytes.Create($AB, $CD),
    TDataEncoding.HexDecode('aBcD'));
end;

procedure TTestDataEncoding.TestHexDecodeOddLengthRaises;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TDataEncoding.HexDecode('abc');
  except
    on E: EArgumentTlsLibException do
      LRaised := True;
  end;
  CheckTrue(LRaised, 'an odd-length hex string is rejected');
end;

procedure TTestDataEncoding.TestHexDecodeNonHexRaises;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TDataEncoding.HexDecode('00zz');
  except
    on E: EArgumentTlsLibException do
      LRaised := True;
  end;
  CheckTrue(LRaised, 'a non-hex character is rejected');
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestDataEncoding);
{$ELSE}
  RegisterTest(TTestDataEncoding.Suite);
{$ENDIF FPC}

end.
