{ *********************************************************************************** }
{ *                                 TlsLib Library                                  * }
{ *                          Author - Ugochukwu Mmaduekwe                           * }
{ *                  Github Repository <https://github.com/Xor-el>                  * }
{ *                                                                                 * }
{ *  Distributed under the MIT software license, see the accompanying file LICENSE  * }
{ *          or visit http://www.opensource.org/licenses/mit-license.php.           * }
{ * ******************************************************************************* * }

(* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& *)

unit TlpTlsLib;

{$I ..\Include\TlsLib.inc}

interface

uses
  SysUtils,
  TlpICryptoProvider,
  TlpDefaultCryptoProvider,
  TlpICertificateTrust,
  TlpTlsCredential,
  TlpITlsConfig,
  TlpITlsEngine,
  TlpITlsConfigBuilder,
  TlpTlsPresets,
  TlpTlsEngineFactory;

type
  /// <summary>
  /// The one-call entry point. It wires the default CryptoLib provider and the
  /// Compatible preset into a frozen client or server config, or straight into a
  /// ready engine. There is deliberately no Provider accessor: to use a different
  /// backend, drive TTlsConfigBuilder yourself with your own provider.
  /// </summary>
  TTlsLib = class sealed(TObject)
  public
    /// <summary>A frozen client config (default provider, Compatible preset, given trust).</summary>
    class function NewClientConfig(const ATrustStore: ITrustAnchorStore)
      : ITlsClientConfig; overload; static;
    /// <summary>As above, with trust anchors from a PEM block/bundle or a DER certificate.</summary>
    class function NewClientConfig(const ATrustAnchorsData: TBytes)
      : ITlsClientConfig; overload; static;
    /// <summary>A frozen server config (default provider, Compatible preset, given credential).</summary>
    class function NewServerConfig(const ACredential: TTlsCredential)
      : ITlsServerConfig; overload; static;
    /// <summary>As above, from a certificate chain and an unencrypted private key, each a
    /// PEM block or DER.</summary>
    class function NewServerConfig(const ACertificateChainData,
      APrivateKeyData: TBytes): ITlsServerConfig; overload; static;
    /// <summary>A client engine ready for StartHandshake, connecting to AHost.</summary>
    class function NewClientEngine(const AHost: string;
      const ATrustStore: ITrustAnchorStore): ITlsEngine; overload; static;
    /// <summary>As above, with trust anchors from a PEM block/bundle or a DER certificate.</summary>
    class function NewClientEngine(const AHost: string;
      const ATrustAnchorsData: TBytes): ITlsEngine; overload; static;
    /// <summary>A server engine that starts on the first ClientHello.</summary>
    class function NewServerEngine(const ACredential: TTlsCredential)
      : ITlsEngine; overload; static;
    /// <summary>As above, from a certificate chain and an unencrypted private key, each a
    /// PEM block or DER.</summary>
    class function NewServerEngine(const ACertificateChainData,
      APrivateKeyData: TBytes): ITlsEngine; overload; static;
  end;

implementation

{ TTlsLib }

class function TTlsLib.NewClientConfig(
  const ATrustStore: ITrustAnchorStore): ITlsClientConfig;
begin
  Result := TTlsPresets.Compatible(TDefaultCryptoProvider.Create as ICryptoProvider)
    .Client.WithTrustStore(ATrustStore).Build;
end;

class function TTlsLib.NewClientConfig(
  const ATrustAnchorsData: TBytes): ITlsClientConfig;
begin
  Result := TTlsPresets.Compatible(TDefaultCryptoProvider.Create as ICryptoProvider)
    .Client.WithTrustAnchors(ATrustAnchorsData).Build;
end;

class function TTlsLib.NewServerConfig(
  const ACredential: TTlsCredential): ITlsServerConfig;
begin
  Result := TTlsPresets.Compatible(TDefaultCryptoProvider.Create as ICryptoProvider)
    .Server.WithCredential(ACredential).Build;
end;

class function TTlsLib.NewServerConfig(const ACertificateChainData,
  APrivateKeyData: TBytes): ITlsServerConfig;
begin
  Result := TTlsPresets.Compatible(TDefaultCryptoProvider.Create as ICryptoProvider)
    .Server.WithCredential(ACertificateChainData, APrivateKeyData).Build;
end;

class function TTlsLib.NewClientEngine(const AHost: string;
  const ATrustStore: ITrustAnchorStore): ITlsEngine;
begin
  Result := TTlsEngineFactory.CreateClientEngine(NewClientConfig(ATrustStore), AHost);
end;

class function TTlsLib.NewClientEngine(const AHost: string;
  const ATrustAnchorsData: TBytes): ITlsEngine;
begin
  Result := TTlsEngineFactory.CreateClientEngine(
    NewClientConfig(ATrustAnchorsData), AHost);
end;

class function TTlsLib.NewServerEngine(
  const ACredential: TTlsCredential): ITlsEngine;
begin
  Result := TTlsEngineFactory.CreateServerEngine(NewServerConfig(ACredential));
end;

class function TTlsLib.NewServerEngine(const ACertificateChainData,
  APrivateKeyData: TBytes): ITlsEngine;
begin
  Result := TTlsEngineFactory.CreateServerEngine(
    NewServerConfig(ACertificateChainData, APrivateKeyData));
end;

end.
