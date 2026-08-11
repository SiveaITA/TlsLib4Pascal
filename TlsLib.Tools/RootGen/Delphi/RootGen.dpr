program RootGen;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  TlpRootGen in '..\src\TlpRootGen.pas';

var
  LUnitName: string;

begin
  if ParamCount < 2 then
  begin
    WriteLn('usage: RootGen <certdata.txt> <output.pas> [UnitName]');
    ExitCode := 1;
  end
  else
  begin
    if ParamCount >= 3 then
      LUnitName := ParamStr(3)
    else
      LUnitName := 'GeneratedRoots';
    try
      ExitCode := TRootGenerator.Run(ParamStr(1), ParamStr(2), LUnitName);
    except
      on E: Exception do
      begin
        WriteLn('error: ', E.Message);
        ExitCode := 4;
      end;
    end;
  end;
end.
