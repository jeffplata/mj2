unit UserManager_Add_Tasks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, ActnList, Menus, VirtualTrees;

type

  PTaskTreeData = ^TTaskTreeData;
  TTaskTreeData = record
    FTaskName: string;
    FFormName: string;
  end;

  { TfrmAddTasksToRoles }

  TfrmAddTasksToRoles = class(TForm)
    actClearEdit: TAction;
    ActionList1: TActionList;
    edtTaskFilter: TEdit;
    Panel8: TPanel;
    spbTaskClear: TSpeedButton;
    ToolBar5: TToolBar;
    vstTasks: TVirtualStringTree;
    procedure actClearEditExecute(Sender: TObject);
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure vstTasksGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstTasksInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  private
    procedure PopulateList;
  public
    class function Execute: Boolean;
  end;

//var
//  frmAddTasksToRoles: TfrmAddTasksToRoles;

implementation

uses ResourcesDM;

{$R *.lfm}

function AddVSTTaskStructure(AVST: TCustomVirtualStringTree; ANode:
  PVirtualNode;
  ARecord: TTaskTreeData): PVirtualNode;
var
  Data: PTaskTreeData;
begin
  Result:=AVST.AddChild(ANode);
  Data:=AVST.GetNodeData(Result);
  Avst.ValidateNode(Result, False);
  Data^.FTaskName:=ARecord.FTaskName;
  Data^.FFormName:=ARecord.FFormName;
end;

{ TfrmAddTasksToRoles }

procedure TfrmAddTasksToRoles.FormCreate(Sender: TObject);
begin
  dmResources.ImageList1.GetBitmap(4,spbTaskClear.Glyph);

  PopulateList;
end;

procedure TfrmAddTasksToRoles.vstTasksGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PTaskTreeData;
begin
  Data:=vstTasks.GetNodeData(Node);
  case Column of
    0: CellText:= Data^.FTaskName;
    1: CellText:= Data^.FFormName;
  end;
end;

procedure TfrmAddTasksToRoles.vstTasksInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  vstTasks.CheckType[Node] := ctCheckBox;
end;

procedure TfrmAddTasksToRoles.PopulateList;
var
  i, j: Integer;
  t: TTaskTreeData;
begin
  vstTasks.NodeDataSize:= SizeOf(TTaskTreeData);

  vstTasks.BeginUpdate;
  try
    for i := 0 to screen.FormCount-1 do
    begin
      for j := 0 to screen.Forms[i].ComponentCount-1 do
        if screen.forms[i].Components[j] is TAction then
        begin
          t.FFormName:= screen.forms[i].name ;
          t.FTaskName:= screen.forms[i].Components[j].Name;
          AddVSTTaskStructure(vstTasks,nil,t);
        end;
    end;
  finally
    vstTasks.EndUpdate;
  end;

end;

procedure TfrmAddTasksToRoles.actClearEditExecute(Sender: TObject);
begin
  edtTaskFilter.Clear;
end;

procedure TfrmAddTasksToRoles.ActionList1Update(AAction: TBasicAction;
  var Handled: Boolean);
begin
  if aaction = actClearEdit then
    actClearEdit.Enabled:= edtTaskFilter.text <> '';
end;

class function TfrmAddTasksToRoles.Execute: Boolean;
var
  frm: TfrmAddTasksToRoles;
begin
  Result := false;
  frm := TfrmAddTasksToRoles.Create(nil);
  try
    if frm.showmodal = mrOk then
      Result := true;
  finally
    frm.free;
  end;
end;

end.

