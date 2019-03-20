program mj2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainForm, SetDBForm, mainDM, fortes324forlaz, lazcontrols,
  UserManagerForm, _TemplateForm;

{$R *.res}

begin
  Application.Title:='MJ2';
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  if dmMain.Loggedin then
  begin
    Application.Run;
  end;
end.

