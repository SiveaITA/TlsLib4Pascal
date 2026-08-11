program MormotRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  MormotRealWorldExample in '..\src\MormotRealWorldExample.pas';

begin
  Halt(TMormotRealWorldExample.Run);
end.
