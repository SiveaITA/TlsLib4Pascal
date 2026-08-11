program IndyRealWorld;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  IndyRealWorldExample in '..\src\IndyRealWorldExample.pas';

begin
  Halt(TIndyRealWorldExample.Run);
end.
