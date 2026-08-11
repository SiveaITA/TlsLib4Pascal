program IndyLoopback;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  IndyLoopbackExample in '..\src\IndyLoopbackExample.pas';

begin
  Halt(TIndyLoopbackExample.Run);
end.
