program TlsLib.BenchmarkConsole;

{$MODE DELPHI}
{$APPTYPE CONSOLE}

// Console runner for the TlsLib benchmarks. Aggregates the TLS-layer benchmarks (the
// handshake-throughput and record-throughput comparisons against OpenSSL) and prints each
// as an ASCII table over the TlsLib benchmark harness (BenchmarkCommon) for timing/format.

uses
  SysUtils,
  BenchmarkCommon,
  OpenSslBenchSupport,
  TlsHandshakeBenchmark,
  TlsRecordThroughputBenchmark;

procedure ConsoleLog(const AMessage: String);
begin
  WriteLn(AMessage);
end;

begin
  try
    // record which OpenSSL produced the reference figures (empty when it did not load)
    if TOpenSslBench.Available then
      ConsoleLog(TOpenSslBench.VersionString);
    ConsoleLog('');
    TTlsHandshakeBenchmark.Run(ConsoleLog);
    ConsoleLog('');
    TTlsRecordThroughputBenchmark.Run(ConsoleLog);
    ConsoleLog('');
    TBenchmarkReport.WriteRunSummary(ConsoleLog);
  except
    on E: Exception do
    begin
      WriteLn('Benchmark error: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
