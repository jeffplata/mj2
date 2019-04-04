program mj2;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainForm, SetDBForm, mainDM, lazcontrols, UserManagerForm,
  _TemplateForm, usermanager_bom, HiLoGeneratorU, usermanager_add_userroleform,
  UserManager_Add_Tasks, ResourcesDM, UserManager_Add_Tasks_BOM;

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

