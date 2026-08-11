program TlsFuzzer;

{$MODE DELPHI}{$H+}

// No-network structure-aware fuzzer over the record / handshake / extension / cert-
// compression parsers. Per-push: replay the regression corpus + a fixed-seed smoke.
// Usage: TlsFuzzer [--iterations N] [--seed S] [--timeout-ms MS] [--discovery [--max-seconds S]].

uses
  {$IFDEF UNIX}cthreads,{$ENDIF} // the hang watchdog runs on a background thread
  SysUtils,
  TlsFuzzerRunner;

begin
  ExitCode := TTlsFuzzerRunner.Run;
end.
