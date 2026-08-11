{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTrustPolicy;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils;

type
  /// <summary>
  /// The revocation-checking posture for the stapled OCSP response (RFC 6960),
  /// consumed in-band from the handshake - no network. The posture governs only how an
  /// unknown/indeterminate outcome is treated; a definitive, authenticated Revoked in
  /// hand is always honored (the certificate is rejected) under every posture. Soft (the
  /// default) accepts a missing or indeterminate staple; Hard rejects anything short of a
  /// current Good staple (bad_certificate_status_response); Off does not require a stapled
  /// OCSP response (a missing or indeterminate staple is accepted), but still rejects a
  /// definitive Revoked. Must-staple (RFC 7633) is enforced at the TLS layer regardless
  /// of this setting.
  /// </summary>
  TRevocationPosture = (Soft, Hard, Off);

  /// <summary>
  /// An augment-only peer-certificate check the caller supplies: it runs after the
  /// built-in pipeline (PKIX, revocation, endpoint identity, pinning) has already
  /// passed and can only additionally reject (return False) - it can never turn a
  /// rejected chain into an accepted one. AChain is the peer chain (leaf first, DER);
  /// AHostName is the expected host (empty on the server side). This is how a host
  /// framework's own verify hook is bridged without loosening our trust decision.
  /// </summary>
  TTlsCertificateVerifyCallback = function(const AChain: TArray<TBytes>;
    const AHostName: string): Boolean of object;

  /// <summary>
  /// The escape hatches that deliberately weaken or extend trust, grouped so they read
  /// as one loud, opt-in surface. InsecureSkipVerify makes an otherwise-untrusted chain
  /// pass (it bypasses PKIX, revocation, endpoint identity, and pinning) and must never
  /// ship in production - it exists for tests and pinned/self-signed development peers.
  /// VerifyCallback is the augment-only hook (it can only additionally reject). When both
  /// are set the callback still runs, so a caller can skip the built-in pipeline yet keep
  /// a bespoke reject rule.
  /// </summary>
  TDangerousTrust = record
    InsecureSkipVerify: Boolean;
    VerifyCallback: TTlsCertificateVerifyCallback;
    // zero the unmanaged method pointer so no construction path leaves it garbage
    class operator Initialize({$IFDEF FPC}var{$ELSE}out{$ENDIF}
      AOptions: TDangerousTrust);
  end;

  /// <summary>
  /// The asynchronous certificate-verdict setting. When Enabled, the engine runs its
  /// built-in trust pipeline synchronously (as always) and, only if that pipeline
  /// accepts the peer chain, parks the handshake and raises a CertificateReceived event
  /// so a host can decide out-of-band (e.g. live OCSP/CRL, an operator prompt) and resume
  /// with SetCertificateVerdict. This is augment-only: the host verdict can only
  /// additionally reject, never resurrect a chain the pipeline already rejected. The park
  /// is fail-closed - no verdict, a rejection, or an expired deadline aborts the handshake.
  /// DeadlineMs is advisory to the driver (the sans-IO engine owns no timer); 0 means the
  /// host imposes no engine-suggested deadline. Disabled (the default) keeps the verdict
  /// inline.
  /// </summary>
  TAsyncCertificateVerdict = record
    Enabled: Boolean;
    DeadlineMs: Cardinal;
  end;

implementation

class operator TDangerousTrust.Initialize({$IFDEF FPC}var{$ELSE}out{$ENDIF}
  AOptions: TDangerousTrust);
begin
  AOptions.InsecureSkipVerify := False;
  AOptions.VerifyCallback := nil;
end;

end.
