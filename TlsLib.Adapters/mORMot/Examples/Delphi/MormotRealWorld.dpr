program MormotRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  SysUtils,
  MormotRealWorldExample in '..\src\MormotRealWorldExample.pas';

begin
  Halt(TMormotRealWorldExample.Run);
end.
