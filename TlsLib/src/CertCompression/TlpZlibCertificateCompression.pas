{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpZlibCertificateCompression;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  Classes,
{$IFDEF FPC}
  ZStream,
{$ELSE}
  System.ZLib,
{$ENDIF FPC}
  TlpTlsAlert,
  TlpTlsLibExceptions,
  TlpCertificateCompression,
  TlpICertificateCompression;

type
  /// <summary>The built-in zlib (RFC 1950) compressor, over the runtime's deflate.</summary>
  TZlibCertificateCompressor = class sealed(TInterfacedObject, ICertificateCompressor)
  public
    function Algorithm: UInt16;
    function Compress(const AData: TBytes): TBytes;
  end;

  /// <summary>
  /// The built-in zlib decompressor: inflates bounded to AMaxLength and refuses to
  /// produce more, so a bomb cannot exhaust memory here (the declared-length ceiling
  /// and ratio guard are applied by TCertificateCompression before dispatch).
  /// </summary>
  TZlibCertificateDecompressor = class sealed(TInterfacedObject, ICertificateDecompressor)
  public
    function Algorithm: UInt16;
    function Decompress(const ACompressed: TBytes; AMaxLength: Int32): TBytes;
  end;

  /// <summary>
  /// The built-in zlib backend, packaged as the ready-made compressor/decompressor
  /// sets an endpoint uses out of the box. An application that wants another algorithm
  /// implements ICertificateCompressor/ICertificateDecompressor and registers it with
  /// the config builder, optionally alongside these (see WithCertificateCompressors).
  /// </summary>
  TZlibCertificateCompression = class sealed(TObject)
  public
    /// <summary>The zlib compressor set, for a sender.</summary>
    class function DefaultCompressors: TArray<ICertificateCompressor>; static;
    /// <summary>The zlib decompressor set, for a receiver.</summary>
    class function DefaultDecompressors: TArray<ICertificateDecompressor>; static;
  end;

implementation

resourcestring
  SOutputTooLarge = 'decompressed output exceeds the declared length';
  SInflateFailed = 'certificate decompression failed';

{ TZlibCertificateCompressor }

function TZlibCertificateCompressor.Algorithm: UInt16;
begin
  Result := TCertificateCompressionAlgorithms.Zlib;
end;

function TZlibCertificateCompressor.Compress(const AData: TBytes): TBytes;
var
  LOutput: TMemoryStream;
  LDeflate: {$IFDEF FPC}TCompressionStream{$ELSE}TZCompressionStream{$ENDIF};
begin
  Result := nil;
  LOutput := TMemoryStream.Create;
  try
{$IFDEF FPC}
    LDeflate := TCompressionStream.Create(clDefault, LOutput);
{$ELSE}
    LDeflate := TZCompressionStream.Create(LOutput); // default compression level
{$ENDIF}
    try
      if System.Length(AData) > 0 then
        LDeflate.WriteBuffer(AData[0], System.Length(AData));
    finally
      LDeflate.Free; // flush on free
    end;
    SetLength(Result, LOutput.Size);
    if LOutput.Size > 0 then
      Move(LOutput.Memory^, Result[0], LOutput.Size);
  finally
    LOutput.Free;
  end;
end;

{ TZlibCertificateDecompressor }

function TZlibCertificateDecompressor.Algorithm: UInt16;
begin
  Result := TCertificateCompressionAlgorithms.Zlib;
end;

function TZlibCertificateDecompressor.Decompress(const ACompressed: TBytes;
  AMaxLength: Int32): TBytes;
var
  LInput: TMemoryStream;
  LInflate: {$IFDEF FPC}TDecompressionStream{$ELSE}TZDecompressionStream{$ENDIF};
  LChunk: TBytes;
  LRead, LTotal: Int32;
begin
  Result := nil;
  LInput := TMemoryStream.Create;
  try
    if System.Length(ACompressed) > 0 then
      LInput.WriteBuffer(ACompressed[0], System.Length(ACompressed));
    LInput.Position := 0;
{$IFDEF FPC}
    LInflate := TDecompressionStream.Create(LInput);
{$ELSE}
    LInflate := TZDecompressionStream.Create(LInput);
{$ENDIF}
    try
      SetLength(Result, AMaxLength);
      SetLength(LChunk, 4096);
      LTotal := 0;
      try
        repeat
          LRead := LInflate.Read(LChunk[0], System.Length(LChunk));
          if LRead > 0 then
          begin
            // never let the inflated output pass the bound (bomb guard)
            if LTotal + LRead > AMaxLength then
              raise EFatalAlertTlsLibException.CreateRes(
                TTlsAlertDescription.BadCertificate, @SOutputTooLarge);
            Move(LChunk[0], Result[LTotal], LRead);
            Inc(LTotal, LRead);
          end;
        until LRead = 0;
      except
        on E: EFatalAlertTlsLibException do
          raise;
        on E: Exception do
          raise EFatalAlertTlsLibException.CreateRes(
            TTlsAlertDescription.BadCertificate, @SInflateFailed);
      end;
      SetLength(Result, LTotal);
    finally
      LInflate.Free;
    end;
  finally
    LInput.Free;
  end;
end;

{ TZlibCertificateCompression }

class function TZlibCertificateCompression.DefaultCompressors: TArray<ICertificateCompressor>;
begin
  Result := TArray<ICertificateCompressor>.Create(
    TZlibCertificateCompressor.Create as ICertificateCompressor);
end;

class function TZlibCertificateCompression.DefaultDecompressors: TArray<ICertificateDecompressor>;
begin
  Result := TArray<ICertificateDecompressor>.Create(
    TZlibCertificateDecompressor.Create as ICertificateDecompressor);
end;

end.
