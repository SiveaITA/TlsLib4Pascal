program MormotLoopback;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  MormotLoopbackExample in '..\src\MormotLoopbackExample.pas';

begin
  Halt(TMormotLoopbackExample.Run);
end.
