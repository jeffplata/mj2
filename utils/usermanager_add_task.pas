unit Usermanager_Add_Task;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs, FileUtil, ListFilterEdit, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, CheckLst
  , UserManager_bom
  ;

type

  TMyTask = class;
  TMyTaskList = class;

  { TMyTask }

  TMyTask = class(TObject)
  private
    FFormName: string;
    FSelected: Boolean;
    FTaskName: string;
  public
    property FormName: string read FFormName write FFormName;
    property TaskName: string read FTaskName write FTaskName;
    property Selected: Boolean read FSelected write FSelected;
  end;

  { TMyTaskList }

  TMyTaskList = class(TObjectList)
  private
  protected
    function  GetItems(i: integer): TMyTask; reintroduce;
    procedure SetItems(i: integer; const Value: TMyTask); reintroduce;
  public
    property  Items[i:integer]: TMyTask read GetItems write SetItems;
    procedure Add(AObject:TMyTask); reintroduce;
  end;

  { TfrmAddTask }

  TfrmAddTask = class(TForm)
    Bevel1: TBevel;
    btnCancel: TButton;
    btnOk: TButton;
    Button1: TButton;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    ListBox1: TListBox;
    ListFilterEdit1: TListFilterEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1SelectionChange(Sender: TObject; User: boolean);
  private
    FFormIndex: integer;
    FMyTaskList: TMyTaskList;
    procedure UpdateChecked(index:integer);
  public

  end;

implementation

uses ActnList;

{$R *.lfm}

{ TMyTaskList }

function TMyTaskList.GetItems(i: integer): TMyTask;
begin
  Result := TMyTask(inherited Items[i]);
end;

procedure TMyTaskList.SetItems(i: integer; const Value: TMyTask);
begin
  inherited Items[i] := Value;
end;

procedure TMyTaskList.Add(AObject: TMyTask);
begin
  inherited Add(AObject);
end;

{ TfrmAddTask }

procedure TfrmAddTask.FormCreate(Sender: TObject);
var
  i, j: Integer;
  t: TMyTask;
begin
  for i := 0 to screen.FormCount-1 do
  begin
    ListBox1.Items.Add(screen.Forms[i].Name);
  end;
  ListFilterEdit1.FilteredListbox := ListBox1;

  FMyTaskList := TMyTaskList.Create;
  for i := 0 to screen.FormCount-1 do
  begin
    for j := 0 to screen.Forms[i].ComponentCount-1 do
      if screen.forms[i].Components[j] is TAction then
      begin
        t := TMyTask.Create;
        t.FormName:= screen.forms[i].name ;
        t.TaskName:= screen.forms[i].Components[j].Name;
        FMyTaskList.Add(t);
      end;
  end;

  FFormIndex:= -1;
end;


procedure TfrmAddTask.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  i: Integer;
  t: TTask;
begin
  if ModalResult = mrOk then
  begin
    UpdateChecked(FFormIndex);
    for i := 0 to FMyTaskList.Count-1 do
      if FMyTaskList.Items[i].Selected then
      begin
        t := TTask.Create(TaskList);
        t.id := 0;
        t.FormName:= FMyTaskList.Items[i].FormName;
        t.TaskName:= FMyTaskList.Items[i].TaskName;
        TaskList.Add(t);
      end;
  end;
end;

procedure TfrmAddTask.FormDestroy(Sender: TObject);
begin
  FMyTaskList.Free;
end;


procedure TfrmAddTask.ListBox1SelectionChange(Sender: TObject; User: boolean);
var
  i: Integer;
begin
  UpdateChecked(FFormIndex);
  CheckListBox1.Clear;
  for i := 0  to FMyTaskList.count-1 do
    if FMyTaskList.Items[i].FormName = ListBox1.items[ListBox1.ItemIndex] then
    begin
      CheckListBox1.Items.Add(FMyTaskList.Items[i].TaskName);
      CheckListBox1.Checked[CheckListBox1.Count-1] := FMyTaskList.Items[i].Selected;
    end;
  FFormIndex:= ListBox1.ItemIndex;
end;

procedure TfrmAddTask.UpdateChecked(index: integer);
var
  i, j: Integer;
  currentFormName: String;
begin
  if index = -1 then exit;
  //currentFormName := ListBox1.items[ListBox1.ItemIndex];
  currentFormName:= ListBox1.Items[index];
  for i := 0 to CheckListBox1.Count-1 do
    for j := 0 to FMyTaskList.Count -1 do
      begin
        if (FMyTaskList.Items[j].FormName=currentFormName) and
           (FMyTaskList.Items[j].TaskName=CheckListBox1.Items[i]) then
        FMyTaskList.Items[j].Selected:= CheckListBox1.Checked[i];
      end;
end;


end.

