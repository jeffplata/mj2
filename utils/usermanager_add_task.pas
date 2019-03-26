unit Usermanager_Add_Task;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ListFilterEdit, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, CheckLst;

type

  { TfrmAddTask }

  TfrmAddTask = class(TForm)
    Bevel1: TBevel;
    btnCancel: TButton;
    btnOk: TButton;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    ListBox1: TListBox;
    ListFilterEdit1: TListFilterEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

implementation

uses UserManager_bom;

{$R *.lfm}

{ TfrmAddTask }

procedure TfrmAddTask.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to screen.FormCount-0 do
  begin
    ListBox1.Items.Add(screen.Forms[i].Name);
  end;
  //todo: error here
end;


end.

