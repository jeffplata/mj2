unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actManageUser: TAction;
    ActionList1: TActionList;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  if dmMain.OpenDatabase
  then
    label1.Caption := 'connected'
  else begin
    label1.caption := 'not connected';
  end;

  dmMain.Login;

  if dmMain.CurrentUser.Loggedin then
    label2.Caption:= 'Logged in'
  else
    label2.caption := 'Not logged in';

  memo1.lines.add(GetAppConfigDir(true))
end;

end.
