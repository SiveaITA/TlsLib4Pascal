program SystemTrustDemo;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF FPC}

{$APPTYPE CONSOLE}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  SystemTrustExample in 'src\SystemTrustExample.pas';

begin
  Halt(TSystemTrustExample.Run);
end.
