program SynapseLoopback;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  SynapseLoopbackExample in '..\src\SynapseLoopbackExample.pas';

begin
  Halt(TSynapseLoopbackExample.Run);
end.
