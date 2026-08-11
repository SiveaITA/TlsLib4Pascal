{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpEndpointIdentity;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpArrayUtilities,
  TlpBinaryPrimitives;

type
  /// <summary>
  /// RFC 6125 endpoint identity matching. A DNS host is matched against the
  /// certificate's dNSName SANs (a single left-most wildcard label is honored:
  /// <c>*.example.com</c> matches <c>a.example.com</c> but not <c>example.com</c>
  /// or <c>a.b.example.com</c>; matching is case-insensitive). An IP-literal host
  /// is matched only against iPAddress SANs, never against dNSName/wildcards.
  /// </summary>
  TEndpointIdentity = class sealed(TObject)
  strict private
    class function MatchesOneDns(const AHostName, ADnsName: string): Boolean; static;
    class function MatchesDns(const AHostName: string;
      const ADnsNames: TArray<string>): Boolean; static;
    class function MatchesIp(const AHostIp: TBytes;
      const AIpAddresses: TArray<TBytes>): Boolean; static;
    class function TryParseIPv4(const AHost: string; out ABytes: TBytes): Boolean; static;
    class function TryParseIPv6(const AHost: string; out ABytes: TBytes): Boolean; static;
    class function TryParseIpLiteral(const AHost: string;
      out ABytes: TBytes): Boolean; static;
  public
    /// <summary>True if AHostName matches the certificate's SANs: an IP-literal host
    /// against AIpAddresses (raw 4- or 16-byte octets), otherwise a DNS host against
    /// ADnsNames.</summary>
    class function Matches(const AHostName: string; const ADnsNames: TArray<string>;
      const AIpAddresses: TArray<TBytes>): Boolean; static;
  end;

implementation

{ TEndpointIdentity }

class function TEndpointIdentity.MatchesOneDns(const AHostName,
  ADnsName: string): Boolean;
var
  LHost, LName, LSuffix: string;
  LDot: Int32;
begin
  LHost := LowerCase(AHostName);
  LName := LowerCase(ADnsName);
  if (LHost = '') or (LName = '') then
    Exit(False);

  if LName = LHost then
    Exit(True);

  // a single leftmost "*." wildcard matches exactly one non-empty label
  if (System.Length(LName) > 2) and (LName[1] = '*') and (LName[2] = '.') then
  begin
    LSuffix := System.Copy(LName, 2, System.Length(LName) - 1); // ".example.com"
    LDot := Pos('.', LHost);
    // the host must have a non-empty first label, and the remainder must equal the
    // wildcard suffix exactly (so the wildcard spans a single label only)
    Result := (LDot > 1) and
      (System.Copy(LHost, LDot, System.Length(LHost) - LDot + 1) = LSuffix);
    Exit;
  end;

  Result := False;
end;

class function TEndpointIdentity.MatchesDns(const AHostName: string;
  const ADnsNames: TArray<string>): Boolean;
var
  LI: Int32;
begin
  Result := False;
  for LI := 0 to High(ADnsNames) do
    if MatchesOneDns(AHostName, ADnsNames[LI]) then
      Exit(True);
end;

class function TEndpointIdentity.MatchesIp(const AHostIp: TBytes;
  const AIpAddresses: TArray<TBytes>): Boolean;
var
  LI: Int32;
begin
  Result := False;
  for LI := 0 to High(AIpAddresses) do
    if TArrayUtilities.AreEqual(AHostIp, AIpAddresses[LI]) then
      Exit(True);
end;

class function TEndpointIdentity.TryParseIPv4(const AHost: string;
  out ABytes: TBytes): Boolean;
var
  LParts: TArray<string>;
  LPart: string;
  LI, LValue, LDigit: Int32;
begin
  ABytes := nil;
  Result := False;
  LParts := AHost.Split(['.']);
  if System.Length(LParts) <> 4 then
    Exit;
  SetLength(ABytes, 4);
  for LI := 0 to 3 do
  begin
    LPart := LParts[LI];
    // 1..3 digits, no other characters, value 0..255
    if (System.Length(LPart) < 1) or (System.Length(LPart) > 3) then
      Exit;
    LValue := 0;
    for LDigit := 1 to System.Length(LPart) do
    begin
      if (LPart[LDigit] < '0') or (LPart[LDigit] > '9') then
        Exit;
      LValue := (LValue * 10) + (Ord(LPart[LDigit]) - Ord('0'));
    end;
    if LValue > 255 then
      Exit;
    ABytes[LI] := Byte(LValue);
  end;
  Result := True;
end;

class function TEndpointIdentity.TryParseIPv6(const AHost: string;
  out ABytes: TBytes): Boolean;
var
  LHead, LTail: TArray<UInt16>;
  LDoubleColon: Int32;
  LEmbedded: TBytes;

  function ParseGroups(const AText: string; out AValues: TArray<UInt16>): Boolean;
  var
    LParts: TArray<string>;
    LI, LJ, LV, LCount: Int32;
    LPart: string;
  begin
    AValues := nil;
    Result := False;
    if AText = '' then
      Exit(True); // an empty side of "::" contributes no groups
    LParts := AText.Split([':']);
    LCount := 0;
    for LI := 0 to High(LParts) do
    begin
      LPart := LParts[LI];
      // a trailing embedded IPv4 (e.g. ::ffff:1.2.3.4) only in the final group
      if (LI = High(LParts)) and (Pos('.', LPart) > 0) then
      begin
        if not TryParseIPv4(LPart, LEmbedded) then
          Exit;
        SetLength(AValues, LCount + 2);
        AValues[LCount] := TBinaryPrimitives.ReadUInt16BigEndian(LEmbedded, 0);
        AValues[LCount + 1] := TBinaryPrimitives.ReadUInt16BigEndian(LEmbedded, 2);
        Inc(LCount, 2);
        Continue;
      end;
      if (System.Length(LPart) < 1) or (System.Length(LPart) > 4) then
        Exit;
      LV := 0;
      for LJ := 1 to System.Length(LPart) do
      begin
        case LPart[LJ] of
          '0' .. '9':
            LV := (LV shl 4) or (Ord(LPart[LJ]) - Ord('0'));
          'a' .. 'f':
            LV := (LV shl 4) or (Ord(LPart[LJ]) - Ord('a') + 10);
          'A' .. 'F':
            LV := (LV shl 4) or (Ord(LPart[LJ]) - Ord('A') + 10);
        else
          Exit;
        end;
      end;
      SetLength(AValues, LCount + 1);
      AValues[LCount] := UInt16(LV);
      Inc(LCount);
    end;
    Result := True;
  end;

var
  LAll: TArray<UInt16>;
  LI, LPos, LFill: Int32;
begin
  ABytes := nil;
  Result := False;
  if Pos(':', AHost) = 0 then
    Exit;
  // at most one "::" abbreviation
  LDoubleColon := Pos('::', AHost);
  if LDoubleColon > 0 then
  begin
    if Pos('::', System.Copy(AHost, LDoubleColon + 1, MaxInt)) > 0 then
      Exit;
    if not ParseGroups(System.Copy(AHost, 1, LDoubleColon - 1), LHead) then
      Exit;
    if not ParseGroups(System.Copy(AHost, LDoubleColon + 2, MaxInt), LTail) then
      Exit;
    if System.Length(LHead) + System.Length(LTail) >= 8 then
      Exit; // "::" must stand for at least one zero group
    SetLength(LAll, 8);
    for LI := 0 to High(LHead) do
      LAll[LI] := LHead[LI];
    LFill := 8 - System.Length(LTail);
    for LI := 0 to High(LTail) do
      LAll[LFill + LI] := LTail[LI];
  end
  else
  begin
    if not ParseGroups(AHost, LAll) then
      Exit;
    if System.Length(LAll) <> 8 then
      Exit;
  end;
  SetLength(ABytes, 16);
  LPos := 0;
  for LI := 0 to 7 do
  begin
    TBinaryPrimitives.WriteUInt16BigEndian(ABytes, LPos, LAll[LI]);
    Inc(LPos, 2);
  end;
  Result := True;
end;

class function TEndpointIdentity.TryParseIpLiteral(const AHost: string;
  out ABytes: TBytes): Boolean;
begin
  Result := TryParseIPv4(AHost, ABytes) or TryParseIPv6(AHost, ABytes);
end;

class function TEndpointIdentity.Matches(const AHostName: string;
  const ADnsNames: TArray<string>; const AIpAddresses: TArray<TBytes>): Boolean;
var
  LHostIp: TBytes;
begin
  if TryParseIpLiteral(AHostName, LHostIp) then
    // an IP-literal host matches only iPAddress SANs (RFC 6125 forbids wildcard/dNSName)
    Result := MatchesIp(LHostIp, AIpAddresses)
  else if Pos(':', AHostName) > 0 then
    // an IPv6-shaped string that did not parse is never a valid DNS name
    Result := False
  else
    Result := MatchesDns(AHostName, ADnsNames);
end;

end.
