{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpICertificateCompressionCache;

{$I ..\..\Include\TlsLib.inc}

interface

uses
  SysUtils;

type
  /// <summary>
  /// A bytes-to-bytes memo for the sender's RFC 8879 Certificate compression: it
  /// stores a compressed Certificate body under a key the caller derives from the
  /// exact bytes handed to Compress. It is a dumb map - key derivation and the
  /// "did it get smaller?" decision belong to the policy layer, never here - so
  /// swapping a backend cannot change the wire output. An implementation is expected
  /// to be safe to share across connections and threads.
  /// </summary>
  ICertificateCompressionCache = interface(IInterface)
    ['{5D8C1A73-6E24-4F09-B317-2A4C0E9F5B62}']
    /// <summary>Returns a previously stored compressed body for AKey, or False.</summary>
    function TryGet(const AKey: TBytes; out ACompressed: TBytes): Boolean;
    /// <summary>Stores ACompressed under AKey (bounded; oldest evicted at capacity).</summary>
    procedure Put(const AKey: TBytes; const ACompressed: TBytes);
    procedure Clear;
    function Count: Int32;
  end;

implementation

end.
