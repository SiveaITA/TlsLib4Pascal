program BoGoShim;

{$MODE DELPHI}{$H+}

// The BoringSSL "BoGo" conformance shim. BoGo spawns this once per test with a
// per-test flag set; it dials the runner over loopback TCP and drives the sans-IO
// engine through the handshake and the runner's echo protocol. All logic is in
// BoGoShimRunner.

uses
  SysUtils,
  BoGoShimRunner;

begin
  ExitCode := TBoGoShimRunner.Run;
end.
