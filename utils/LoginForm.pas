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
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private

  public
    class function Execute: Boolean;
  end;

implementation

uses gConnectionu, AppUserU;

{$R *.lfm}

{ TfrmLogin }


procedure TfrmLogin.actOkExecute(Sender: TObject);
var
  goodLogin : Boolean;
begin
  Screen.Cursor:= crHourGlass;
  try
    goodLogin:= AppUser.Login(edtUserName.Text, edtPassword.Text)
  finally
    Screen.Cursor:= crDefault;
  end;

  if goodLogin then
    ModalResult:= mrOk
  else
    MessageDlg('Login failed','Username/password is incorrect.',mtInformation,[mbOk],0);
end;

procedure TfrmLogin.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled:= (edtUserName.Text <> '') and (edtPassword.Text <>'');
end;

class function TfrmLogin.Execute: Boolean;
var
  frm: TfrmLogin;
begin
  Result := False;
  frm := TfrmLogin.Create(nil);
  try
    if frm.ShowModal = mrOk then
      Result := AppUser.Loggedin;
  finally
    frm.Free;
  end;
end;

end.

