{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpCertificateLimits;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils;

type
  /// <summary>
  /// The certificate-chain resource caps (anti-DoS), bundled so a caller tunes them
  /// as one frozen config value rather than several loose knobs. Loosening them only
  /// relaxes the caller's own resource budget - the chain still faces full PKIX
  /// validation - so this is a tuning input, not a trust bypass. The defaults are a
  /// conservative web-PKI profile; a large post-quantum chain is the usual reason to
  /// raise them.
  /// </summary>
  TCertificateChainLimits = record
    /// <summary>The most certificates a chain may carry.</summary>
    MaxChainLength: Int32;
    /// <summary>The largest single certificate, in bytes.</summary>
    MaxCertificateLength: Int32;
    /// <summary>The largest total chain, in bytes.</summary>
    MaxTotalChainLength: Int32;
    /// <summary>The conservative web-PKI defaults (short chain, sub-64 KiB certs).</summary>
    class function Defaults: TCertificateChainLimits; static;
  end;

implementation

{ TCertificateChainLimits }

class function TCertificateChainLimits.Defaults: TCertificateChainLimits;
begin
  Result.MaxChainLength := 10;
  Result.MaxCertificateLength := 1 shl 16;
  Result.MaxTotalChainLength := 1 shl 18;
end;

end.
