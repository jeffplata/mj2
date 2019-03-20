unit SetDBForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList;

type

  { TfrmSetDB }

  TfrmSetDB = class(TForm)
    actBrowse: TAction;
    actOk: TAction;
    ActionList1: TActionList;
    btnBrowse: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    edtHost: TEdit;
    edtDatabase: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure actBrowseExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private

  public
    class function Execute: Boolean;
  end;

implementation

uses gConnectionu;

{$R *.lfm}

{ TfrmSetDB }


procedure TfrmSetDB.actOkExecute(Sender: TObject);
var
  goodConnect: boolean;
  oldHost, oldDB: string;
begin
  oldHost:= gConnection.HostName;
  oldDB:= gConnection.DatabaseName;
  gConnection.HostName:= edtHost.Text;
  gConnection.DatabaseName:= edtDatabase.Text;

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

procedure TfrmSetDB.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled:= (edtHost.Text <> '') and (edtDatabase.Text <> '');
end;

procedure TfrmSetDB.actBrowseExecute(Sender: TObject);
var
  dlgOpenFile: TOpenDialog;
begin
  dlgOpenFile := TOpenDialog.Create(self);
  dlgOpenFile.Filter:= 'Databases|*.fdb|All files|*.*;';
  if dlgOpenFile.Execute then
    edtDatabase.Text:= dlgOpenFile.FileName;
  dlgOpenFile.Free;
end;


class function TfrmSetDB.Execute: Boolean;
var
  frm: TfrmSetDB;
begin
  Result := False;
  frm := TfrmSetDB.Create(nil);
  frm.caption := Application.title +' '+ frm.caption;
  try
    if frm.ShowModal = mrOk then
      Result := gConnection.Connected;
  finally
    frm.Free;
  end;
end;

end.

