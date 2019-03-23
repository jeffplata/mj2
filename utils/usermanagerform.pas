unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Menus, ActnList;

type

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
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
    lvRolesAssigned: TListView;
    lvUsers: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    procedure ActionList1Update(AAction: TBasicAction; var Handled: Boolean);
    procedure actUserRoleAddExecute(Sender: TObject);
    procedure actUserAddExecute(Sender: TObject);
    procedure actUserDeleteExecute(Sender: TObject);
    procedure actUserRoleDeleteExecute(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvRolesAssignedData(Sender: TObject; Item: TListItem);
    procedure lvRolesAssignedSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
    procedure lvUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    SelectedUserIndex : integer;
    SelectedUserRoleIndex : integer;
    procedure LoadUserList;
  public

  end;

  procedure ListViewUpdateSelected( lv: TListView; ItemCount: integer; var SelectedIndex: integer );

implementation

uses usermanager_bom, HiLoGeneratorU;

procedure ListViewUpdateSelected(lv: TListView; ItemCount: integer;
  var SelectedIndex: integer);
begin
  lv.Items.Count:= ItemCount;
  if SelectedIndex >= ItemCount then
    SelectedIndex:= ItemCount -1;
  if SelectedIndex <> -1 then
    lv.ItemIndex := SelectedIndex;
  //lv.Refresh;
  lv.Items[SelectedIndex].MakeVisible(true);
end;


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
      u := TUser.create;
      u.id := AppHiloGenerator.GetNextID;
      u.UserName:= s;
      UserList.add(u);
      lvUsers.Items.count := userlist.count;
      UserList.DBAdd(userlist.count-1);
    end;
end;

procedure TfrmUserManager.ActionList1Update(AAction: TBasicAction;
  var Handled: Boolean);
begin
  if AAction = actUserDelete then
    actUserDelete.Enabled:= lvUsers.ItemIndex <> -1
  else if aaction =actUserRoleDelete then
    actUserRoleDelete.Enabled:= lvRolesAssigned.ItemIndex <> -1;
end;

procedure TfrmUserManager.actUserRoleAddExecute(Sender: TObject);
var
  s: String;
  u: TUserRole;
begin
  //user role add
  s := InputBox('Add User Role','Role Name:','');
  if s <> '' then
    begin
      u := TUserRole.create;
      u.id := AppHiloGenerator.GetNextID;
      u.rolename:= s;
      UserList.items[SelectedUserIndex].roles.add(u);
      lvRolesAssigned.Items.count := UserList.items[SelectedUserIndex].roles.count;
      lvRolesAssigned.ItemIndex:= lvRolesAssigned.Items.count -1;
    end;
end;

procedure TfrmUserManager.actUserDeleteExecute(Sender: TObject);
begin
  //user delete
  if UserList.DBDelete(SelectedUserIndex) then
  begin
    UserList.Delete(SelectedUserIndex);
    ListViewUpdateSelected(lvUsers, UserList.Count, SelectedUserIndex);

    if UserList.Count = 0 then
      lvRolesAssigned.items.count := 0
    else
      lvRolesAssigned.items.count := UserList.items[SelectedUserIndex].Roles.Count;
    SelectedUserRoleIndex:= -1;
  end;
end;

procedure TfrmUserManager.actUserRoleDeleteExecute(Sender: TObject);
var
  u: TUser;
begin
  //user role delete
  u := UserList.Items[SelectedUserIndex];
  u.roles.delete(SelectedUserRoleIndex);
  ListViewUpdateSelected(lvRolesAssigned, u.roles.count, SelectedUserRoleIndex);
end;

procedure TfrmUserManager.FormCreate(Sender: TObject);
begin
  LoadUserList;
end;

procedure TfrmUserManager.lvRolesAssignedData(Sender: TObject; Item: TListItem);
var
  ob: TUserRole;
  u : tuser;
begin
  u := TUser(UserList.Items[SelectedUserIndex]) ;
  if u = nil then exit;

  ob := TUserRole(u.Roles[Item.Index]);
  item.caption := ob.Rolename;
end;

procedure TfrmUserManager.lvRolesAssignedSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  SelectedUserRoleIndex := Item.Index;
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
  SelectedUserIndex := Item.Index;
  u := TUser(UserList.Items[Item.Index]);
  lvRolesAssigned.Items.Count:= u.roles.count;
  lvRolesAssigned.Repaint;
  SelectedUserRoleIndex:= -1 ;
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
  c.caption := 'User Name';
  c.width := 150;

  UserList.ReadList;
  lvUsers.Items.Count:= UserList.Count;

  //roles columns
  //c := lvRolesAssigned.Columns.Add;
  //c.Caption:= 'ID';
  //c.Width:= 50;

  c := lvRolesAssigned.Columns.Add;
  c.caption := 'Role name';
  c.width := 150;

  lvRolesAssigned.Items.Count:= UserList.Items[0].Roles.Count;
end;

end.

