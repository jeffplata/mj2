unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList, ComCtrls, Menus;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actExit: TAction;
    actLogin: TAction;
    actLogout: TAction;
    actManageUser: TAction;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    StatusBar1: TStatusBar;
    procedure actExitExecute(Sender: TObject);
    procedure actLogoutExecute(Sender: TObject);
    procedure actManageUserExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

uses mainDM, UserManagerForm
  ;

{$R *.lfm}

{ TfrmMain }


procedure TfrmMain.actManageUserExecute(Sender: TObject);
var
  frm: TfrmUserManager;
begin
  frm := TfrmUserManager.Create(nil);
  frm.showmodal;
  frm.free;
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.actLogoutExecute(Sender: TObject);
begin
  //logout
  dmMain.Logout;
  dmMain.Login;
  if not dmMain.Loggedin then actExit.Execute;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if dmMain.Loggedin then
    StatusBar1.SimpleText:='Logged in'
  else
    StatusBar1.SimpleText:='Not logged in';

  dmMain.ApplyRoles(self);
end;


end.

