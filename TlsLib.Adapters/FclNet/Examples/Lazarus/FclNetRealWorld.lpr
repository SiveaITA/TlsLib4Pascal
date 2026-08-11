program FclNetRealWorld;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  FclNetRealWorldExample in '..\src\FclNetRealWorldExample.pas';

begin
  Halt(TFclNetRealWorldExample.Run);
end.
