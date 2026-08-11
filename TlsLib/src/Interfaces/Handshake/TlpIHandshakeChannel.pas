{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpIHandshakeChannel;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpHandshakeMessage;

type
  /// <summary>
  /// The byte conduit for handshake messages, decoupling the handshake state
  /// machine from the transport that carries it: over TCP a concrete channel wraps
  /// the record layer and the handshake reassembler, and a future QUIC channel
  /// carries the same messages in CRYPTO frames. Outbound, a framed message is
  /// handed down for transmission; inbound, reassembled messages are pulled up.
  /// Sans-IO and single-threaded (the caller serializes).
  /// </summary>
  IHandshakeChannel = interface(IInterface)
    ['{8C3F1A26-5D74-4B90-A1E8-2F6B0D5C94A7}']
    /// <summary>Hands a fully framed handshake message down to the transport.</summary>
    procedure SendHandshake(const AMessage: TBytes);
    /// <summary>Emits the legacy change_cipher_spec for middlebox compatibility.</summary>
    procedure SendChangeCipherSpec;
    /// <summary>Feeds decrypted inbound handshake bytes to the reassembler.</summary>
    procedure AppendInbound(const AData: TBytes; AOffset, ALength: Int32);
    /// <summary>Pulls the next reassembled inbound message; False when none is ready.</summary>
    function ReceiveHandshake(out AMessage: TTlsHandshakeMessage): Boolean;
    /// <summary>Whether inbound bytes remain buffered that do not yet form a whole message -
    /// a partial handshake message. At an end-of-flight boundary this is excess data.</summary>
    function HasPartialInbound: Boolean;
  end;

implementation

end.
