program RealPeerRevocationProbe;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  RealPeerRevocationProbeExample in '..\src\RealPeerRevocationProbeExample.pas';

begin
  Halt(TRealPeerRevocationProbeExample.Run);
end.
