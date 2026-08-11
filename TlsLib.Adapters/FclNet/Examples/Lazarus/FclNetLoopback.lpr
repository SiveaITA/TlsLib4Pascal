program FclNetLoopback;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  FclNetLoopbackExample in '..\src\FclNetLoopbackExample.pas';

begin
  Halt(TFclNetLoopbackExample.Run);
end.
