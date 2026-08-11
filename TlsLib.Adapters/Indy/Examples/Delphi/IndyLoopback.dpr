program IndyLoopback;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  IndyLoopbackExample in '..\src\IndyLoopbackExample.pas';

begin
  Halt(TIndyLoopbackExample.Run);
end.
