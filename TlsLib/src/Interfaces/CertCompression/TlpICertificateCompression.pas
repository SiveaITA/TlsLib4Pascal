{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpICertificateCompression;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  SysUtils;

type
  /// <summary>
  /// A certificate-compression algorithm's compress direction (RFC 8879): one
  /// injectable unit per algorithm (zlib ships built in; brotli/zstd or a custom
  /// backend drop in the same way). The sender compresses its Certificate message
  /// body with this; it is not on the security-sensitive path.
  /// </summary>
  ICertificateCompressor = interface(IInterface)
    ['{6F1B9E20-3C74-4A58-9D61-8E2A0C7B4415}']
    /// <summary>The RFC 8879 algorithm codepoint this compresses for.</summary>
    function Algorithm: UInt16;
    /// <summary>Compresses a Certificate message body.</summary>
    function Compress(const AData: TBytes): TBytes;
  end;

  /// <summary>
  /// A certificate-compression algorithm's decompress direction (RFC 8879). This is
  /// the security-sensitive direction: the receiver bounds output to AMaxLength and
  /// MUST raise (rather than allocate past it) if the stream would exceed it, so a
  /// decompression bomb cannot exhaust memory. The declared-length ceiling and ratio
  /// guard are applied by the caller before dispatch, so every algorithm - built in
  /// or injected - inherits the same bomb defense.
  /// </summary>
  ICertificateDecompressor = interface(IInterface)
    ['{A83D5C14-7E90-4B62-8F17-2C6E0A5F9D48}']
    /// <summary>The RFC 8879 algorithm codepoint this decompresses.</summary>
    function Algorithm: UInt16;
    /// <summary>Decompresses to at most AMaxLength bytes; raises rather than produce more.</summary>
    function Decompress(const ACompressed: TBytes; AMaxLength: Int32): TBytes;
  end;

implementation

end.
