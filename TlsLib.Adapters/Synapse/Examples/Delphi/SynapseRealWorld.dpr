program SynapseRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  SynapseRealWorldExample in '..\src\SynapseRealWorldExample.pas';

begin
  Halt(TSynapseRealWorldExample.Run);
end.
