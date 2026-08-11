program SynapseLoopback;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  SynapseLoopbackExample in '..\src\SynapseLoopbackExample.pas';

begin
  Halt(TSynapseLoopbackExample.Run);
end.
