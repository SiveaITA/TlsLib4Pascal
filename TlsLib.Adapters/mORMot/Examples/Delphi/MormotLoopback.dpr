program MormotLoopback;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  MormotLoopbackExample in '..\src\MormotLoopbackExample.pas';

begin
  Halt(TMormotLoopbackExample.Run);
end.
