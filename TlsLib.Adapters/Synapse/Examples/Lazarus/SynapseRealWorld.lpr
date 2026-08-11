program SynapseRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  SynapseRealWorldExample in '..\src\SynapseRealWorldExample.pas';

begin
  Halt(TSynapseRealWorldExample.Run);
end.
