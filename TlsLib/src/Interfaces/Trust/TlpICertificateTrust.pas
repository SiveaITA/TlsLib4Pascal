{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpICertificateTrust;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpTlsAlert;

type
  /// <summary>
  /// The set of trusted root certificates (DER), kept behind an interface so the
  /// PKIX backend's certificate types never reach the public surface.
  /// </summary>
  ITrustAnchorStore = interface(IInterface)
    ['{6F1D2A54-9C83-4E70-B1A6-3D7E0C5B94F2}']
    /// <summary>The trusted root CA certificates, DER-encoded.</summary>
    function RootCertificates: TArray<TBytes>;
  end;

  /// <summary>
  /// Decides whether a peer certificate chain is trusted for a host. Fail-closed:
  /// the handshake proceeds only on an explicit positive verdict. On rejection it
  /// returns the fatal alert the caller must send (unknown_ca / certificate_expired
  /// / bad_certificate).
  /// </summary>
  ICertificateVerifier = interface(IInterface)
    ['{2A9E6C14-5D73-4B80-A1F8-6C3E0D5B92A7}']
    /// <summary>True if AChain (leaf first, DER) is trusted for AHostName; else
    /// False with AAlert set to the reason. AOcspStaple is the stapled OCSP response
    /// delivered in the handshake (empty when none), fed to the revocation step.</summary>
    function Verify(const AChain: TArray<TBytes>; const AHostName: string;
      const AOcspStaple: TBytes; out AAlert: TTlsAlertDescription): Boolean;
  end;

implementation

end.
