unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Menus, ActnList, EditBtn,
  Buttons, VirtualTrees;

type

  PTaskTreeData = ^TTaskTreeData;
  TTaskTreeData = record
    FID: integer;
    FRoleID: integer;
    FRoleName: string;
    FTaskName: string;
    FFormName: string;
  end;


  { TfrmUserManager }

  TfrmUserManager = class(TForm)
    actTaskfilter: TAction;
    actTaskFilterClear: TAction;
    actTaskRefresh: TAction;
    actTaskAdd: TAction;
    actTaskDelete: TAction;
    actUserActivate: TAction;
    actUserDeactivate: TAction;
    actRoleAdd: TAction;
    actRoleDelete: TAction;
    actTabUsers: TAction;
    actTabRoles: TAction;
    actTabTasks: TAction;
    actUserRoleAdd: TAction;
    actUserRoleDelete: TAction;
    actUserAdd: TAction;
    actUserDelete: TAction;
    ActionList1: TActionList;
    Bevel2: TBevel;
    Button4: TButton;
    edtTaskFilter: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lvRolesAssigned: TListView;
    lvUsers: TListView;
    lvRoles: TListView;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    PopupMenu1: TPopupMenu;
    spbTaskClear: TSpeedButton;
    tabUsers: TTabSheet;
    tabRoles: TTabSheet;
    tabTasks: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolBar4: TToolBar;
    ToolBar5: TToolBar;
    ToolBar6: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    vstAssignedTasks: TVirtualStringTree;
    vstTasks: TVirtualStringTree;
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure actRoleAddExecute(Sender: TObject);
    procedure actRoleDeleteExecute(Sender: TObject);
    procedure actTabRolesExecute(Sender: TObject);
    procedure actTabTasksExecute(Sender: TObject);
    procedure actTabUsersExecute(Sender: TObject);
    procedure actTaskAddExecute(Sender: TObject);
    //procedure actTaskAddExecute(Sender: TObject);
    procedure actTaskDeleteExecute(Sender: TObject);
    procedure actTaskFilterClearExecute(Sender: TObject);
    procedure actTaskfilterExecute(Sender: TObject);
    procedure actTaskRefreshExecute(Sender: TObject);
    procedure actUserActivateExecute(Sender: TObject);
    procedure actUserDeactivateExecute(Sender: TObject);
    procedure actUserRoleAddExecute(Sender: TObject);
    procedure actUserAddExecute(Sender: TObject);
    procedure actUserDeleteExecute(Sender: TObject);
    procedure actUserRoleDeleteExecute(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure edtTaskFilterChange(Sender: TObject);
    procedure edtTaskFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvRolesAssignedData(Sender: TObject; Item: TListItem);
    procedure lvRolesData(Sender: TObject; Item: TListItem);
    procedure lvRolesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
    procedure lvUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure vstAssignedTasksFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstAssignedTasksGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstTasksFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstTasksGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    procedure LoadUserList;
    procedure LoadRoles;
    procedure LoadTasks;
    procedure ListViewUpdate( lv: TListView; ItemCount: integer; SelectedIndex: integer );
    procedure TaskFilterReset;
    procedure PopulateVSTTask;
    procedure FilterVSTAssignedTask( role: string );
  public

  end;




implementation

uses usermanager_bom, HiLoGeneratorU, usermanager_add_userroleform, ResourcesDM,
  UserManager_Add_Tasks, LCLType;

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
  Data^.FID:=ARecord.FID;
  Data^.FRoleID:=ARecord.FRoleID;
  Data^.FRoleName:=ARecord.FRoleName;
  Data^.FTaskName:=ARecord.FTaskName;
  Data^.FFormName:=ARecord.FFormName;
end;

{ TfrmUserManager }

procedure TfrmUserManager.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmUserManager.edtTaskFilterChange(Sender: TObject);
begin
  if edtTaskFilter.Text <> '' then
    actTaskfilter.Execute
  else
    TaskFilterReset;
end;

procedure TfrmUserManager.edtTaskFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node: PVirtualNode;
begin
  if not Assigned(vstTasks.FocusedNode) then
    Node:= vstTasks.GetFirst
  else
    Node:= vstTasks.FocusedNode;
  if key = VK_DOWN then
    vstTasks.FocusedNode:= vstTasks.GetNextVisible(Node)
  else if key = VK_UP then
    vstTasks.FocusedNode:= vstTasks.GetPreviousVisible(Node);
  vstTasks.Selected[vstTasks.FocusedNode] := True;
  if key in [VK_DOWN,VK_UP] then key := 0;
end;


procedure TfrmUserManager.actUserAddExecute(Sender: TObject);
var
  s: String;
  u: TUser;
begin
  //user add
  s := InputBox('New User','User name:','');
  if s <> '' then
    begin
      if not UserList.NotInList(s) then
        begin
          showmessage('Duplicate user name found.');
          exit;
        end;
      u := TUser.create(UserList);
      u.id := AppHiloGenerator.GetNextID;
      u.UserName:= s;
      u.IsActive:= 1;
      UserList.add(u);
      lvUsers.Items.count := userlist.count;
      lvUsers.ItemIndex:= userlist.count-1;  //end of list
      UserList.DBAdd(u);
    end;
end;

procedure TfrmUserManager.ActionList1Update(AAction: TBasicAction;
  var Handled: Boolean);
begin
  if AAction = actUserDelete then
    actUserDelete.Enabled:= (lvUsers.Selected <> nil) //and (UserList.items[lvUsers.ItemIndex].IsActive<>1)
  else if aaction = actUserRoleDelete then
    actUserRoleDelete.Enabled:= (lvRolesAssigned.Selected <> nil)
  else if aaction = actUserRoleAdd then
    actUserRoleAdd.enabled := (lvUsers.Selected <> nil)
  else if aaction = actRoleDelete then
    actRoleDelete.enabled := (lvroles.selected <> nil)
  else if aaction = actTaskFilterClear then
    actTaskFilterClear.Enabled:= edtTaskFilter.Text <> ''
    ;
end;

procedure TfrmUserManager.actRoleAddExecute(Sender: TObject);
var
  s: String;
  r: TRole;
begin
  //role add
  s := InputBox('New Role','Role name:','');
  if s <> '' then
    begin
      if not RoleList.NotInList(s) then
        begin
          showmessage('Duplicate role name found.');
          exit;
        end;
      r := TRole.create(RoleList);
      r.id := AppHiloGenerator.GetNextID;
      r.Rolename:= s;
      RoleList.add(r);

      lvRoles.Items.count := RoleList.count;
      lvRoles.ItemIndex:= RoleList.count-1;  //end of list
      RoleList.DBAdd(r);
    end;
end;

procedure TfrmUserManager.actRoleDeleteExecute(Sender: TObject);
begin
  if RoleList.DBDelete(lvRoles.ItemIndex) then
    ListViewUpdate(lvRoles, RoleList.Count, lvRoles.ItemIndex)
  else
    Showmessage('This Role cannot be deleted.'#13#10'Users are assigned to it.');
end;

procedure TfrmUserManager.actTabRolesExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabRoles;
end;

procedure TfrmUserManager.actTabTasksExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabTasks;
  edtTaskFilter.SetFocus;
end;

procedure TfrmUserManager.actTabUsersExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabUsers;
end;

procedure TfrmUserManager.actTaskAddExecute(Sender: TObject);
begin
  if TfrmAddTasksToRoles.Execute then
    // add to USR_ROLETASK
    ;
end;

//procedure TfrmUserManager.actTaskAddExecute(Sender: TObject);
//var
//  frm: TfrmAddTask;
//begin
//  frm := TfrmAddTask.Create(Self);
//  try
//    if frm.showmodal = mrOk then begin
//      //lvTasks.items.Count:= TaskList.Count;
//      //ListViewUpdate(lvTasks,TaskList.Count,0);
//    end;
//  finally
//    frm.free;
//  end;
//end;

procedure TfrmUserManager.actTaskDeleteExecute(Sender: TObject);
begin
  //delete task
end;

procedure TfrmUserManager.actTaskFilterClearExecute(Sender: TObject);
begin
  //task filter clear
  TaskFilterReset;
end;

procedure TfrmUserManager.actTaskfilterExecute(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PTaskTreeData;
  Str: String;
begin
  // filter tasks
  Node := vstTasks.GetFirst;
  while Assigned(Node) do
  begin
    Data := vstTasks.GetNodeData(Node);
    Str := Data^.FFormName+'```'+Data^.FTaskName;
    vstTasks.IsVisible[Node] := Pos(UpperCase(edtTaskFilter.Text), UpperCase(Str)) > 0;
    Node := vstTasks.GetNext(Node);
  end;
end;

procedure TfrmUserManager.actTaskRefreshExecute(Sender: TObject);
var
  i, j: Integer;
  c: TComponent;
  t: TTask;
  L: TTaskList;
  matched: Boolean;
begin
  //task refresh
  actTaskFilterClear.Execute;

  TaskList.Clear;
  TaskList.ReadList;

  L := TTaskList.Create;
  try
    // build temporary task list
    for i := 0 to Screen.FormCount-1 do
    begin
      for j := 0 to Screen.Forms[i].ComponentCount-1 do
      begin
        c := Screen.Forms[i].Components[j];
        if c is TAction then begin
          t := TTask.Create(nil); //t := TTask.Create(L);
          t.ID:= 0;
          t.TaskName:= c.Name;
          t.FormName:= c.Owner.Name;
          L.Add(t);
        end;
      end;
    end;

    // validate existing task list
    for i := 0 to TaskList.Count-1 do
    begin
      for j := 0 to L.Count-1 do
      begin
        matched :=  SameText(TaskList.Items[i].FormName, L.Items[j].FormName)
           and SameText(TaskList.Items[i].TaskName, L.Items[j].TaskName);
        if matched then
        begin
          L.Items[j].TaskName:= '* '+L.Items[j].TaskName;
          break;
        end
      end;
      if matched then matched := false
      else
        TaskList.Items[i].TaskName:= '* '+TaskList.Items[i].TaskName;
    end;

    // incorporate new tasks from app
    for i := 0 to L.Count-1 do
      if Copy( L.Items[i].TaskName, 1, 2 ) <> '* ' then
      begin
        t := TTask.Create(TaskList);
        t.ID:= L.Items[i].ID;
        //todo: t.ID:= AppHiloGenerator.GetNextID;
        t.TaskName:= L.Items[i].TaskName;
        t.FormName:= L.Items[i].FormName;
        TaskList.Add(t);
      end;

  finally
    L.Free;
  end;

  LoadTasks;
end;

procedure TfrmUserManager.actUserActivateExecute(Sender: TObject);
begin
  if UserList.DBSetActive(lvUsers.ItemIndex,1) then
  begin
    UserList.items[lvUsers.ItemIndex].IsActive:= 1;
    lvUsers.Refresh;
  end;
end;

procedure TfrmUserManager.actUserDeactivateExecute(Sender: TObject);
begin
  if UserList.DBSetActive(lvUsers.ItemIndex,0) then
  begin
    UserList.items[lvUsers.ItemIndex].IsActive:= 0;
    lvUsers.Refresh;
  end;
end;

procedure TfrmUserManager.actUserRoleAddExecute(Sender: TObject);
var
  ar: TAssignedRole;
  indSelected: Integer;
  u: tuser;
begin
  //user role add
  indSelected := TfrmUserRole.SelectRole;
  if indSelected <> -1 then
    begin
      if not UserList.items[lvUsers.ItemIndex].Roles.NotInList(RoleList.items[indSelected].Rolename) then
        begin
          showmessage(Quotedstr(RoleList.items[indSelected].Rolename)+' role already assigned to current user.');
          exit;
        end;
      ar := TAssignedRole.create(UserList);
      ar.id := AppHiloGenerator.GetNextID;
      ar.RoleID:= RoleList.items[indSelected].ID;
      ar.Rolename:= RoleList.items[indSelected].Rolename;

      u := UserList.Items[lvUsers.ItemIndex];
      u.roles.add(ar);
      lvRolesAssigned.Items.count := u.roles.count;
      lvRolesAssigned.ItemIndex:= u.roles.count -1;
      u.roles.DBAdd(ar, u.ID);
    end;
end;

procedure TfrmUserManager.actUserDeleteExecute(Sender: TObject);
var
  ra: TAssignedRoleList;
begin
  if UserList.items[lvusers.itemindex].IsActive = 1 then
    begin
      showmessage('Only inactive users can be deleted.');
      exit;
    end;

  if UserList.DBDelete(lvUsers.ItemIndex) then
    begin
      //Update the lv so that itemindex is properly set
      ListViewUpdate(lvUsers, UserList.Count, lvUsers.ItemIndex);
      ra := UserList.items[lvUsers.ItemIndex].Roles;
      ListViewUpdate(lvRolesAssigned,ra.Count,0);
    end;
end;

procedure TfrmUserManager.actUserRoleDeleteExecute(Sender: TObject);
var
  u: TUser;
  ItemIndex: integer;
begin
  u := UserList.Items[lvUsers.ItemIndex];
  if u.Roles.DBDelete(lvRolesAssigned.ItemIndex, lvUsers.itemindex) then
    begin
      ItemIndex := lvRolesAssigned.ItemIndex;
      ListViewUpdate(lvRolesAssigned, u.roles.count, ItemIndex);
    end;
end;

procedure TfrmUserManager.FormCreate(Sender: TObject);
begin
  LoadUserList;
  LoadRoles;
  LoadTasks;

  //ImageList1.GetBitmap(4,spbTaskClear.Glyph);
  dmResources.ImageList1.GetBitmap(4,spbTaskClear.Glyph);
  PageControl1.ActivePage := tabUsers;
  PageControl1.ShowTabs:= False;
end;

procedure TfrmUserManager.FormShow(Sender: TObject);
begin
  ListViewUpdate(lvUsers, UserList.Count, 0);
  ListViewUpdate(lvRoles, RoleList.Count, 0);
end;



procedure TfrmUserManager.lvRolesAssignedData(Sender: TObject; Item: TListItem);
var
  ar: TAssignedRole;
  u : tuser;
begin
  u := UserList.Items[lvUsers.ItemIndex] ;
  if u = nil then exit;

  ar := u.Roles.items[Item.Index];
  item.caption := ar.Rolename;
end;

procedure TfrmUserManager.lvRolesData(Sender: TObject; Item: TListItem);
var
  ob: TRole;
begin
  ob := RoleList.Items[Item.Index];
  //Item.Caption := inttostr(ob.ID);
  //Item.SubItems.Add(ob.Rolename);
  Item.Caption := ob.Rolename;
end;

procedure TfrmUserManager.lvRolesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FilterVSTAssignedTask(Item.Caption);
end;

procedure TfrmUserManager.lvUsersData(Sender: TObject; Item: TListItem);
var
  ob: TUser;
begin
  ob := TUser(UserList.Items[Item.Index]);
  //Item.Caption := inttostr(ob.ID);
  //if ob.IsActive <> 1 then
  //  Item.SubItems.Add('* '+ob.UserName)
  //else
  //  Item.SubItems.Add(ob.UserName);
  if ob.IsActive <> 1 then
    Item.Caption := '* '+ob.UserName
  else
    Item.Caption := ob.UserName;

end;

procedure TfrmUserManager.lvUsersSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  u: TUser;
begin
  u := UserList.Items[item.index];
  lvRolesAssigned.Items.Count:= u.roles.count;
  ListViewUpdate(lvRolesAssigned,u.roles.Count,0);
end;

procedure TfrmUserManager.vstAssignedTasksFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTaskTreeData;
begin
  Data:=vstAssignedTasks.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.FID:= 0;
    Data^.FRoleID:=0;
    Data^.FRoleName:= '';
    Data^.FFormName:= '';
    Data^.FTaskName:= '';
  end;
end;

procedure TfrmUserManager.vstAssignedTasksGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PTaskTreeData;
begin
  Data:=vstAssignedTasks.GetNodeData(Node);
  case Column of
    0: CellText:= IntToStr(Data^.FID);
    1: CellText:= Data^.FTaskName;
    2: CellText:= Data^.FFormName;
  end;
end;
procedure TfrmUserManager.vstTasksFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTaskTreeData;
begin
  Data:=vstTasks.GetNodeData(Node);
  if Assigned(Data) then
  begin
    Data^.FID:= 0;
    Data^.FFormName:= '';
    Data^.FTaskName:= '';
  end;
end;

procedure TfrmUserManager.vstTasksGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PTaskTreeData;
begin
  Data:=vstTasks.GetNodeData(Node);
  case Column of
    0: CellText:= IntToStr(Data^.FID);
    1: CellText:= Data^.FTaskName;
    2: CellText:= Data^.FFormName;
  end;
end;

procedure TfrmUserManager.LoadUserList;
var
  c: TListColumn;
begin
  //User columns
  //c := lvUsers.Columns.Add;
  //c.Caption:= 'ID';
  //C.Width:= 50;

  c := lvUsers.Columns.Add;
  c.caption := 'User Name';
  c.width := 150;

  UserList.ReadList;
  lvUsers.Items.Count:= UserList.Count;

  //roles assigned
  c := lvRolesAssigned.Columns.Add;
  c.caption := 'Role name';
  c.width := 150;

  lvRolesAssigned.Items.Count:= UserList.Items[0].Roles.Count;
end;

procedure TfrmUserManager.LoadRoles;
var
  c: TListColumn;
begin
  //User columns
  //c := lvRoles.Columns.Add;
  //c.Caption:= 'ID';
  //C.Width:= 50;

  c := lvRoles.Columns.Add;
  c.caption := 'Role Name';
  c.width := 150;

  RoleList.ReadList;
  lvRoles.Items.Count:= RoleList.Count;
end;

procedure TfrmUserManager.LoadTasks;
var
  I: Integer;
  TreeData: TTaskTreeData;
  Node: PVirtualNode;
begin
  if TaskList.Count = 0 then
    TaskList.ReadList;

  vstAssignedTasks.Clear;
  vstAssignedTasks.NodeDataSize:= SizeOf(TTaskTreeData);

  vstAssignedTasks.BeginUpdate;
  for i := 0 to TaskList.Count-1 do
  begin
    Treedata.FID:= TaskList.Items[i].ID;
    Treedata.FRoleID:= TaskList.Items[i].RoleID;
    Treedata.FRoleName:= TaskList.Items[i].RoleName;
    TreeData.FTaskName:= TaskList.Items[i].TaskName;
    TreeData.FFormName:= TaskList.Items[i].FormName;
    Node := AddVSTTaskStructure(vstAssignedTasks, nil, TreeData);
    vstAssignedTasks.IsVisible[Node] := False;
  end;
  vstAssignedTasks.EndUpdate;
end;

procedure TfrmUserManager.ListViewUpdate(lv: TListView;
  ItemCount: integer; SelectedIndex: integer);
var
  newIndex: Integer;
begin
  lv.Items.Count:= ItemCount;
  newIndex := SelectedIndex;
  if newIndex >= ItemCount then
    newIndex := ItemCount -1;
  if newIndex >= 0 then
    lv.ItemIndex := newIndex;
  if newIndex >= 0 then
    lv.Items[newIndex].MakeVisible(true);
  lv.Repaint;
end;

procedure TfrmUserManager.TaskFilterReset;
var
  Node: PVirtualNode;
begin
  edtTaskFilter.Clear;
  Node := vstTasks.GetFirst;
  while Assigned(Node) do
  begin
    vstTasks.IsVisible[Node] := True;
    Node := vstTasks.GetNext(Node);
  end;
end;

procedure TfrmUserManager.PopulateVSTTask;

begin

end;

procedure TfrmUserManager.FilterVSTAssignedTask(role: string);
var
  Node: PVirtualNode;
  Data: PTaskTreeData;
begin
  Node := vstAssignedTasks.GetFirst;
  while Assigned(Node) do
  begin
    Data := vstAssignedTasks.GetNodeData(Node);
    vstAssignedTasks.IsVisible[Node] := (role=Data^.FRoleName);
    Node := vstAssignedTasks.GetNext(Node);
  end;
end;

end.

