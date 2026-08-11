{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpIWireWriter;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpWireVectorMarker;

type
  /// <summary>
  /// Builds a TLS wire structure into a growable buffer. Big-endian integers,
  /// and length-prefixed vectors written as an OpenVector/CloseVector pair that
  /// emits a length placeholder, appends the body, then back-patches the prefix
  /// (so nested structures need no size pre-computation).
  /// </summary>
  IWireWriter = interface(IInterface)
    ['{2D9E4A71-6C38-4B05-9F1A-8E7C0D5B3A62}']
    procedure WriteUInt8(AValue: Byte);
    procedure WriteUInt16(AValue: UInt16);
    procedure WriteUInt24(AValue: UInt32);
    procedure WriteUInt32(AValue: UInt32);

    procedure WriteBytes(const AData: TBytes); overload;
    procedure WriteBytes(const AData: TBytes; AOffset, ACount: Int32); overload;

    /// <summary>Emits an ALenBytes-wide (1..4) length placeholder and returns a
    /// marker for the matching <see cref="CloseVector" />.</summary>
    function OpenVector(ALenBytes: Int32): TWireVectorMarker;
    /// <summary>Back-patches the vector prefix with the body length; raises if
    /// the body exceeds what the prefix width can encode.</summary>
    procedure CloseVector(const AMarker: TWireVectorMarker);

    /// <summary>Bytes written so far.</summary>
    function Length: Int32;
    /// <summary>A fresh copy of the written bytes.</summary>
    function ToBytes: TBytes;
  end;

implementation

end.
