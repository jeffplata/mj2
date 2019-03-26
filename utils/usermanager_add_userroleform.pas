unit usermanager_add_userroleform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DbCtrls;

type

  { TfrmUserRole }

  TfrmUserRole = class(TForm)
    Bevel1: TBevel;
    btnCancel: TButton;
    btnOk: TButton;
    ListBox1: TListBox;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private

  public
    class function SelectRole: Integer;
  end;


implementation

uses
UserManager_bom;

{$R *.lfm}

{ TfrmUserRole }

procedure TfrmUserRole.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to RoleList.count -1 do
    ListBox1.Items.Add(RoleList.Items[i].Rolename);
  ListBox1.ItemIndex:= 0;

end;

procedure TfrmUserRole.ListBox1DblClick(Sender: TObject);
begin
  btnOk.Click;
end;

class function TfrmUserRole.SelectRole: Integer;
var
  frm: TfrmUserRole;
begin
  result := -1;
  frm := TfrmUserRole.Create(nil);
  try
    if frm.showmodal = mrOk then
      Result := frm.ListBox1.ItemIndex;
  finally
    frm.free;
  end;
end;

end.

