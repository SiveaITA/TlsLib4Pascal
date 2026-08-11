{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpSocketHttpFetcher;

{ A reference IHttpFetcher over the RTL HTTP client - deliberately OUTSIDE the sans-IO core
  package (the core references only the IHttpFetcher interface and never a socket). A host
  can use this to drive the live-revocation checker, or supply its own fetcher built on its
  framework's HTTP stack. It is fail-closed by contract: any transport error, a non-2xx
  status, a timeout, or an empty body is reported as a False result with no body, never a
  raised exception. }

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

interface

uses
  SysUtils,
  Classes,
{$IFDEF FPC}
  fphttpclient,
{$ELSE}
  System.Net.HttpClient,
  System.Net.URLClient,
{$ENDIF FPC}
  TlpIHttpFetcher;

type
  /// <summary>A blocking IHttpFetcher backed by the RTL HTTP client (FPC fphttpclient /
  /// Delphi System.Net.HttpClient). Suitable for live OCSP (POST) and CRL (GET) retrieval.
  /// Never raises; a failed exchange yields False with an empty response.</summary>
  TSocketHttpFetcher = class sealed(TInterfacedObject, IHttpFetcher)
  strict private
    class function ReadStreamBytes(const AStream: TStream): TBytes; static;
  public
    function Get(const AUrl: string; ATimeoutMs: Cardinal;
      out AResponse: TBytes): Boolean;
    function Post(const AUrl, AContentType: string; const ABody: TBytes;
      ATimeoutMs: Cardinal; out AResponse: TBytes): Boolean;
  end;

implementation

{ TSocketHttpFetcher }

class function TSocketHttpFetcher.ReadStreamBytes(const AStream: TStream): TBytes;
var
  LLen: Int64;
begin
  Result := nil;
  if AStream = nil then
    Exit;
  AStream.Position := 0;
  LLen := AStream.Size;
  if LLen <= 0 then
    Exit;
  SetLength(Result, LLen);
  AStream.ReadBuffer(Result[0], LLen);
end;

{$IFDEF FPC}

function TSocketHttpFetcher.Get(const AUrl: string; ATimeoutMs: Cardinal;
  out AResponse: TBytes): Boolean;
var
  LClient: TFPHTTPClient;
  LResponse: TMemoryStream;
begin
  Result := False;
  AResponse := nil;
  LResponse := TMemoryStream.Create;
  try
    LClient := TFPHTTPClient.Create(nil);
    try
      if ATimeoutMs > 0 then
      begin
        LClient.ConnectTimeout := ATimeoutMs;
        LClient.IOTimeout := ATimeoutMs;
      end;
      LClient.Get(AUrl, LResponse);
      if (LClient.ResponseStatusCode >= 200) and (LClient.ResponseStatusCode < 300)
      then
      begin
        AResponse := ReadStreamBytes(LResponse);
        Result := System.Length(AResponse) > 0;
      end;
    finally
      LClient.Free;
    end;
  except
    // fail-closed: any transport/HTTP error is a failed fetch, never a raise
    Result := False;
    AResponse := nil;
  end;
  LResponse.Free;
end;

function TSocketHttpFetcher.Post(const AUrl, AContentType: string;
  const ABody: TBytes; ATimeoutMs: Cardinal; out AResponse: TBytes): Boolean;
var
  LClient: TFPHTTPClient;
  LRequest, LResponse: TMemoryStream;
begin
  Result := False;
  AResponse := nil;
  LRequest := TMemoryStream.Create;
  LResponse := TMemoryStream.Create;
  try
    if System.Length(ABody) > 0 then
      LRequest.WriteBuffer(ABody[0], System.Length(ABody));
    LRequest.Position := 0;
    LClient := TFPHTTPClient.Create(nil);
    try
      if ATimeoutMs > 0 then
      begin
        LClient.ConnectTimeout := ATimeoutMs;
        LClient.IOTimeout := ATimeoutMs;
      end;
      LClient.AddHeader('Content-Type', AContentType);
      LClient.RequestBody := LRequest;
      LClient.Post(AUrl, LResponse);
      if (LClient.ResponseStatusCode >= 200) and (LClient.ResponseStatusCode < 300)
      then
      begin
        AResponse := ReadStreamBytes(LResponse);
        Result := System.Length(AResponse) > 0;
      end;
    finally
      LClient.Free;
    end;
  except
    Result := False;
    AResponse := nil;
  end;
  LRequest.Free;
  LResponse.Free;
end;

{$ELSE}

function TSocketHttpFetcher.Get(const AUrl: string; ATimeoutMs: Cardinal;
  out AResponse: TBytes): Boolean;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
begin
  Result := False;
  AResponse := nil;
  try
    LClient := THTTPClient.Create;
    try
      if ATimeoutMs > 0 then
      begin
        LClient.ConnectionTimeout := ATimeoutMs;
        LClient.ResponseTimeout := ATimeoutMs;
      end;
      LResponse := LClient.Get(AUrl);
      if (LResponse.StatusCode >= 200) and (LResponse.StatusCode < 300) then
      begin
        AResponse := ReadStreamBytes(LResponse.ContentStream);
        Result := System.Length(AResponse) > 0;
      end;
    finally
      LClient.Free;
    end;
  except
    Result := False;
    AResponse := nil;
  end;
end;

function TSocketHttpFetcher.Post(const AUrl, AContentType: string;
  const ABody: TBytes; ATimeoutMs: Cardinal; out AResponse: TBytes): Boolean;
var
  LClient: THTTPClient;
  LResponse: IHTTPResponse;
  LRequest: TMemoryStream;
  LHeaders: TNetHeaders;
begin
  Result := False;
  AResponse := nil;
  LRequest := TMemoryStream.Create;
  try
    if System.Length(ABody) > 0 then
      LRequest.WriteBuffer(ABody[0], System.Length(ABody));
    LRequest.Position := 0;
    LClient := THTTPClient.Create;
    try
      if ATimeoutMs > 0 then
      begin
        LClient.ConnectionTimeout := ATimeoutMs;
        LClient.ResponseTimeout := ATimeoutMs;
      end;
      SetLength(LHeaders, 1);
      LHeaders[0] := TNetHeader.Create('Content-Type', AContentType);
      LResponse := LClient.Post(AUrl, LRequest, nil, LHeaders);
      if (LResponse.StatusCode >= 200) and (LResponse.StatusCode < 300) then
      begin
        AResponse := ReadStreamBytes(LResponse.ContentStream);
        Result := System.Length(AResponse) > 0;
      end;
    finally
      LClient.Free;
    end;
  except
    Result := False;
    AResponse := nil;
  end;
  LRequest.Free;
end;

{$ENDIF FPC}

end.
