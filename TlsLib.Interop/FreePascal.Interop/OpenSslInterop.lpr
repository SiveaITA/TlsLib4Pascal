program OpenSslInterop;

{$MODE DELPHI}{$H+}

// The always-on lighter interop driver: our engine vs an openssl s_client/s_server
// peer. Role and port come from the command line; the matrix script pairs this with
// openssl in the opposite role. All logic lives in OpenSslInteropRunner.

uses
  SysUtils,
  OpenSslInteropRunner;

begin
  ExitCode := TOpenSslInteropRunner.Run;
end.
