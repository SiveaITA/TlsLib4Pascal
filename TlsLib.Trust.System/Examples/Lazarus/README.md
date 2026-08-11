# System-trust demo (Free Pascal, console)

A minimal console app that verifies a live HTTPS server chain against the **host OS trust
store** with no manual trust config: an unmodified `TFPHTTPClient` does a GET with its TLS
carried by the **FclNet adapter**, and the peer is verified against the OS system-trust store
(Windows crypt32 / macOS SecTrust / Unix `/etc/ssl` bundle) that TlsLib4Pascal harvests and
validates itself — no pinned root, no OpenSSL.

This is the **Free Pascal counterpart to the Delphi FMX/Indy trust demo** in
`../Delphi`. They are deliberately separate: the trust *system* is shared (the same
`TlsLib.Trust.System` package renders the anchors/verdict on every platform), only the
**transport/host differs per platform** — `TFPHTTPClient` over the FclNet adapter here, Indy
`TIdHTTP` on FMX/Android there.

## Zero-config trust

There is nothing to call on a desktop OS. The demo sets `UseSystemTrust := True` on the FclNet
handler through `TFPHTTPClient.OnGetSocketHandler` and the OS anchors do the rest. (A GUI
variant on **Android** would additionally need `TlsLibAndroidInitTrust(vm)` once at startup —
see `docs/system-trust.md` — but this console demo targets the desktop.)

## Files here

| File | Role |
|---|---|
| `src/SystemTrustExample.pas` | The neutral `class function Run: Integer` logic (0 PASS / 1 FAIL / 2 SKIP). |
| `SystemTrustDemo.lpr` / `.lpi` | The console program. |

## Building + running

```bash
lazbuild --add-package-link TlsLib/src/Packages/FPC/TlsLib4PascalPackage.lpk
lazbuild --add-package-link TlsLib.Trust.System/Packages/FPC/TlsLib.Trust.System.lpk
lazbuild --add-package-link TlsLib.Adapters/FclNet/Packages/FPC/TlsLib.Adapter.FclNet.lpk
lazbuild --cpu=x86_64 --os=win64 TlsLib.Trust.System/Examples/Lazarus/SystemTrustDemo.lpi
./bin/SystemTrustDemo
```

It is a **network-gated demo, not a test gate**: it needs outbound HTTPS and exits 0 (PASS) /
2 (SKIP, offline) / 1 (FAIL).

## What to look for

- Default `https://postman-echo.com/get` → **PASS**: the public chain verified against the
  machine's system roots with zero manual trust config, entirely inside TlsLib4Pascal.
- Point it at a host with an untrusted/self-signed chain → verification **fails closed**
  (system trust is never implicit).
