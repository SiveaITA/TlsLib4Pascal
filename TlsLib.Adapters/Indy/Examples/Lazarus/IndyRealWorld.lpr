program IndyRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  IndyRealWorldExample in '..\src\IndyRealWorldExample.pas';

begin
  Halt(TIndyRealWorldExample.Run);
end.
