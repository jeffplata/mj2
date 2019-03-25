unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Menus, ActnList;

type

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
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
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lvRolesAssigned: TListView;
    lvUsers: TListView;
    lvRoles: TListView;
    lvUsers2: TListView;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    tabUsers: TTabSheet;
    tabRoles: TTabSheet;
    tabTasks: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolBar4: TToolBar;
    ToolBar5: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure actRoleAddExecute(Sender: TObject);
    procedure actRoleDeleteExecute(Sender: TObject);
    procedure actTabRolesExecute(Sender: TObject);
    procedure actTabTasksExecute(Sender: TObject);
    procedure actTabUsersExecute(Sender: TObject);
    procedure actUserRoleAddExecute(Sender: TObject);
    procedure actUserAddExecute(Sender: TObject);
    procedure actUserDeleteExecute(Sender: TObject);
    procedure actUserRoleDeleteExecute(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvRolesAssignedData(Sender: TObject; Item: TListItem);
    procedure lvRolesData(Sender: TObject; Item: TListItem);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
    procedure lvUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    procedure LoadUserList;
    procedure LoadRoles;
    procedure ListViewUpdate( lv: TListView; ItemCount: integer; SelectedIndex: integer );
  public

  end;


implementation

uses usermanager_bom, HiLoGeneratorU, usermanager_add_userroleform;

{$R *.lfm}

{ TfrmUserManager }

procedure TfrmUserManager.Button4Click(Sender: TObject);
begin
  Close;
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
      u := TUser.create(UserList);
      u.id := AppHiloGenerator.GetNextID;
      u.UserName:= s;
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
    actUserDelete.Enabled:= (lvUsers.Selected <> nil)
  else if aaction =actUserRoleDelete then
    actUserRoleDelete.Enabled:= (lvRolesAssigned.Selected <> nil)
  else if aaction = actUserRoleAdd then
    actUserRoleAdd.enabled := (lvUsers.Selected <> nil)
  else if aaction = actRoleDelete then
    actRoleDelete.enabled := (lvroles.selected <> nil)
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
      if not RoleList.UniqueItem(s) then
        begin
          showmessage('Duplicate item found.');
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
var
  ItemIndex: Integer;
begin
  //role delete
  if RoleList.DBDelete(lvRoles.ItemIndex) then
    begin
      ItemIndex := lvRoles.ItemIndex;
      ListViewUpdate(lvRoles, RoleList.Count, ItemIndex);
    end;
end;

procedure TfrmUserManager.actTabRolesExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabRoles;
end;

procedure TfrmUserManager.actTabTasksExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabTasks;
end;

procedure TfrmUserManager.actTabUsersExecute(Sender: TObject);
begin
  PageControl1.ActivePage := tabUsers;
end;

procedure TfrmUserManager.actUserRoleAddExecute(Sender: TObject);
var
  s: String;
  ar: TAssignedRole;
  indSelected: Integer;
  u: tuser;
begin
  //user role add
  indSelected := TfrmUserRole.SelectRole;
  if indSelected <> -1 then
    begin
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
  ItemIndex: Integer;
  ra: TAssignedRoleList;
begin
  //user delete
  if UserList.DBDelete(lvUsers.ItemIndex) then
    begin
      ItemIndex := lvUsers.ItemIndex;
      ra := UserList.items[ItemIndex].Roles;
      ListViewUpdate(lvUsers, UserList.Count, ItemIndex);
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

  PageControl1.ActivePage := tabUsers;
  PageControl1.ShowTabs:= False;
end;

procedure TfrmUserManager.FormShow(Sender: TObject);
begin
  ListViewUpdate(lvUsers, UserList.Count, 0);
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
  Item.Caption := inttostr(ob.ID);
  Item.SubItems.Add(ob.Rolename);
end;

procedure TfrmUserManager.lvUsersData(Sender: TObject; Item: TListItem);
var
  ob: TUser;
begin
  ob := TUser(UserList.Items[Item.Index]);
  Item.Caption := inttostr(ob.ID);
  Item.SubItems.Add(ob.UserName);
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

procedure TfrmUserManager.LoadUserList;
var
  c: TListColumn;
begin
  //User columns
  c := lvUsers.Columns.Add;
  c.Caption:= 'ID';
  C.Width:= 50;

  c := lvUsers.Columns.Add;
  c.caption := 'Role Name';
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
  c := lvRoles.Columns.Add;
  c.Caption:= 'ID';
  C.Width:= 50;

  c := lvRoles.Columns.Add;
  c.caption := 'User Name';
  c.width := 150;

  RoleList.ReadList;
  lvRoles.Items.Count:= RoleList.Count;
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


end.

