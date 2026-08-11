{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTlsConnectionInfo;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpTlsVersion;

type
  /// <summary>
  /// The read-only summary of an established connection a Tier-2 stream surfaces: the
  /// negotiated protocol version, the selected ALPN protocol (empty when none), the
  /// server name the endpoint used for SNI / verification, the peer's stapled OCSP
  /// response (DER, empty when none), the validated peer certificate chain (leaf first,
  /// DER; empty when the peer presented none, e.g. a resumed handshake), the negotiated
  /// cipher suite and named group (IANA codes; the group is 0 for a non-(EC)DHE key
  /// exchange), and whether the handshake was resumed. It is a snapshot taken after the
  /// handshake; reading it before the handshake completes yields the zero values.
  /// </summary>
  TTlsConnectionInfo = record
    NegotiatedVersion: TTlsVersion;
    AlpnProtocol: string;
    ServerName: string;
    PeerOcspStaple: TBytes;
    PeerCertificates: TArray<TBytes>;
    CipherSuite: UInt16;
    NamedGroup: UInt16;
    Resumed: Boolean;
  end;

implementation

end.
