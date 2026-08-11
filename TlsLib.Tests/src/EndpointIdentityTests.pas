{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit EndpointIdentityTests;

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
  TlpEndpointIdentity;

type
  TTestEndpointIdentity = class(TTestCase)
  private
    function Matches(const AHost: string; const ANames: array of string): Boolean;
    function MatchesIp(const AHost: string; const AIps: array of TBytes): Boolean;
  published
    procedure TestExactMatch;
    procedure TestExactMatchCaseInsensitive;
    procedure TestNoMatch;
    procedure TestWildcardMatchesOneLabel;
    procedure TestWildcardDoesNotMatchBareDomain;
    procedure TestWildcardDoesNotMatchMultipleLabels;
    procedure TestFirstOfSeveralNamesMatches;
    procedure TestIpLiteralDoesNotMatchWildcardDns;
    procedure TestIpLiteralMatchesIpSan;
    procedure TestIpLiteralRejectsDifferentIpSan;
    procedure TestIpv6LiteralMatchesIpSan;
    procedure TestIpv6LiteralDoesNotMatchDns;
  end;

implementation

{ TTestEndpointIdentity }

function TTestEndpointIdentity.Matches(const AHost: string;
  const ANames: array of string): Boolean;
var
  LNames: TArray<string>;
  LI: Int32;
begin
  SetLength(LNames, System.Length(ANames));
  for LI := 0 to High(ANames) do
    LNames[LI] := ANames[LI];
  Result := TEndpointIdentity.Matches(AHost, LNames, nil);
end;

function TTestEndpointIdentity.MatchesIp(const AHost: string;
  const AIps: array of TBytes): Boolean;
var
  LIps: TArray<TBytes>;
  LI: Int32;
begin
  SetLength(LIps, System.Length(AIps));
  for LI := 0 to High(AIps) do
    LIps[LI] := AIps[LI];
  Result := TEndpointIdentity.Matches(AHost, nil, LIps);
end;

procedure TTestEndpointIdentity.TestExactMatch;
begin
  CheckTrue(Matches('example.com', ['example.com']));
end;

procedure TTestEndpointIdentity.TestExactMatchCaseInsensitive;
begin
  CheckTrue(Matches('WWW.Example.COM', ['www.example.com']));
end;

procedure TTestEndpointIdentity.TestNoMatch;
begin
  CheckFalse(Matches('example.com', ['example.org', 'other.com']));
end;

procedure TTestEndpointIdentity.TestWildcardMatchesOneLabel;
begin
  CheckTrue(Matches('a.example.com', ['*.example.com']));
end;

procedure TTestEndpointIdentity.TestWildcardDoesNotMatchBareDomain;
begin
  CheckFalse(Matches('example.com', ['*.example.com']));
end;

procedure TTestEndpointIdentity.TestWildcardDoesNotMatchMultipleLabels;
begin
  CheckFalse(Matches('a.b.example.com', ['*.example.com']));
end;

procedure TTestEndpointIdentity.TestFirstOfSeveralNamesMatches;
begin
  CheckTrue(Matches('localhost', ['other.example', 'localhost', '*.test']));
end;

procedure TTestEndpointIdentity.TestIpLiteralDoesNotMatchWildcardDns;
begin
  // RFC 6125: an IP-literal host must never match a dNSName/wildcard
  CheckFalse(Matches('127.0.0.1', ['*.0.0.1']));
  CheckFalse(Matches('127.0.0.1', ['127.0.0.1']));
end;

procedure TTestEndpointIdentity.TestIpLiteralMatchesIpSan;
begin
  CheckTrue(MatchesIp('127.0.0.1', [TBytes.Create(127, 0, 0, 1)]));
end;

procedure TTestEndpointIdentity.TestIpLiteralRejectsDifferentIpSan;
begin
  CheckFalse(MatchesIp('127.0.0.1', [TBytes.Create(8, 8, 8, 8)]));
end;

procedure TTestEndpointIdentity.TestIpv6LiteralMatchesIpSan;
var
  LLoopback: TBytes;
begin
  LLoopback := nil;
  SetLength(LLoopback, 16);
  LLoopback[15] := 1; // ::1
  CheckTrue(MatchesIp('::1', [LLoopback]));
end;

procedure TTestEndpointIdentity.TestIpv6LiteralDoesNotMatchDns;
begin
  // an IPv6-literal host is never matched against dNSName entries
  CheckFalse(Matches('::1', ['*.1', '1']));
end;

initialization

{$IFDEF FPC}
  RegisterTest(TTestEndpointIdentity);
{$ELSE}
  RegisterTest(TTestEndpointIdentity.Suite);
{$ENDIF FPC}

end.
