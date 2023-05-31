program AutoBackup;

uses
  Vcl.Forms,
  UnitFormMain in 'UnitFormMain.pas' {FormMain},
  Windows;

{$R *.res}

begin
  CreateMutex(nil, True, 'OMDAutoBackup');
  if GetLastError = ERROR_ALREADY_EXISTS then
    Application.Terminate
  else
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := true;
    Application.ShowMainForm := false;
    Application.CreateForm(TFormMain, FormMain);
    Application.Run;
  end;
end.
