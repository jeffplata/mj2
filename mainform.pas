unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList, DBGrids, Grids;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actDummy: TAction;
    actManageUser: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    procedure actDummyExecute(Sender: TObject);
    procedure actManageUserExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

uses mainDM
//, CryptU
  ;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
begin

end;

procedure TfrmMain.actManageUserExecute(Sender: TObject);
begin
  ShowMessage('manage users');
end;

procedure TfrmMain.actDummyExecute(Sender: TObject);
begin
  showmessage('Dummy');
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if dmMain.OpenDatabase
  then
    label1.Caption := 'Connected'
  else begin
    label1.caption := 'Not connected';
  end;

  dmMain.Login;

  if dmMain.CurrentUser.Loggedin then
    label2.Caption:= 'Logged in'
  else
    label2.caption := 'Not logged in';

  memo1.lines.Assign(dmMain.CurrentUser.Roles);

  dmMain.CurrentUser.ApplyRoles(self);
end;

end.

