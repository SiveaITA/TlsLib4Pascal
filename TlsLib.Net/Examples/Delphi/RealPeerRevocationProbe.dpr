program RealPeerRevocationProbe;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  RealPeerRevocationProbeExample in '..\src\RealPeerRevocationProbeExample.pas';

begin
  Halt(TRealPeerRevocationProbeExample.Run);
end.
