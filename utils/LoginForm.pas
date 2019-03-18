unit LoginForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    actOk: TAction;
    ActionList1: TActionList;
    btnOk: TButton;
    btnCancel: TButton;
    edtUserName: TEdit;
    edtPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure actOkExecute(Sender: TObject);
  private

  public
    class function Execute: Boolean;
  end;

implementation

uses gConnectionu;

{$R *.lfm}

{ TfrmLogin }


procedure TfrmLogin.actOkExecute(Sender: TObject);
var

begin
  oldHost:= gConnection.HostName;
  oldDB:= gConnection.DatabaseName;
  gConnection.HostName:= edtUserName.Text;
  gConnection.DatabaseName:= edtPassword.Text;

  Screen.Cursor:= crHourGlass;
  try
    goodConnect:= gConnection.I_OpenDB;
  finally
    Screen.Cursor:= crDefault;
  end;

  if goodConnect then
    ModalResult:= mrOk
  else begin
    MessageDlg('Connection Error','Failed to connect to database.',mtInformation,[mbOk],0);
    gConnection.HostName:= oldHost;
    gConnection.DatabaseName:= oldDB;
  end;
end;

procedure TfrmLogin.ActionList1Update(AAction: TBasicAction;
  var Handled: Boolean);
begin
  actOk.Enabled:= (edtUserName.Text <> '') and (edtPassword.Text <> '');
end;


class function TfrmLogin.Execute: Boolean;
var
  frm: TfrmLogin;
begin
  Result := False;
  frm := TfrmLogin.Create(nil);
  try
    frm.ShowModal;
    //if frm.ShowModal = mrOk then
      //Result := gConnection.Connected;
  finally
    frm.Free;
  end;
end;

end.

