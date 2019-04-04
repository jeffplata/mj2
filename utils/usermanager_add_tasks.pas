unit UserManager_Add_Tasks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Buttons, ActnList, VirtualTrees;

type

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
    procedure vstTasksInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  private
  public
    class function Execute: Boolean;
  end;

//var
//  frmAddTasksToRoles: TfrmAddTasksToRoles;

implementation

uses ResourcesDM;

{$R *.lfm}

{ TfrmAddTasksToRoles }

procedure TfrmAddTasksToRoles.FormCreate(Sender: TObject);
begin
  dmResources.ImageList1.GetBitmap(4,spbTaskClear.Glyph);

  vstTasks.AddChild(nil);
  vstTasks.AddChild(nil);
end;

procedure TfrmAddTasksToRoles.vstTasksInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  vstTasks.CheckType[Node] := ctCheckBox;
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

