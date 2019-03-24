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
    procedure FormShow(Sender: TObject);
    procedure lvRolesAssignedData(Sender: TObject; Item: TListItem);
    procedure lvRolesAssignedSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
    procedure lvUsersSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    //SelectedUserIndex : integer;
    //SelectedRoleIndex : integer;
    procedure LoadUserList;
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
      UserList.DBAdd(u); //(userlist.count-1);  //<==
      //UserList.SelectedUser := u;
      //u.Select(userlist.count-1);
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
end;

procedure TfrmUserManager.actUserRoleAddExecute(Sender: TObject);
var
  s: String;
  ar: TAssignedRole;
  indSelected: Integer;
  u: tuser;
begin
  //user role add
  //s := InputBox('Add User Role','Role Name:','');
  indSelected := TfrmUserRole.SelectRole;
  //if s <> '' then
  if indSelected <> -1 then
    begin
      ar := TAssignedRole.create(UserList);
      ar.id := AppHiloGenerator.GetNextID;
      //ar.rolename:= s;
      ar.RoleID:= RoleList.items[indSelected].ID;
      ar.Rolename:= RoleList.items[indSelected].Rolename;

      u := UserList.Items[lvUsers.ItemIndex];
      u.roles.add(ar);
      lvRolesAssigned.Items.count := u.roles.count;
      lvRolesAssigned.ItemIndex:= u.roles.count -1;
      u.roles.DBAdd(ar, u.ID);

      //ListViewUpdate(lvRolesAssigned, u.roles.Count, lvRolesAssigned.ItemIndex);
      //
      //
      ////UserList.items[SelectedUserIndex].roles.add(ar);
      //UserList.SelectedUser.Roles.Add(ar);
      //lvRolesAssigned.Items.count := UserList.SelectedUser.Roles.Count;// UserList.items[SelectedUserIndex].roles.count;
      //lvRolesAssigned.ItemIndex:= lvRolesAssigned.Items.count -1;
      ////UserList.items[SelectedUserIndex].roles.DBAdd(
      //  //UserList.items[SelectedUserIndex].roles.count-1);  //<==
      //if UserList.SelectedUser.Roles.DBAdd( UserList.SelectedUser.Roles.Count-1 ) then
      //  UserList.SelectedRole := ar;
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

  //if UserList.DBDelete(SelectedUserIndex) then  //<==
  //begin
  //  UserList.Delete(SelectedUserIndex);
  //  ListViewUpdate(lvUsers, UserList.Count, SelectedUserIndex);
  //
  //  if UserList.Count = 0 then
  //    lvRolesAssigned.items.count := 0
  //  else
  //    lvRolesAssigned.items.count := UserList.items[SelectedUserIndex].Roles.Count;
  //  SelectedRoleIndex:= -1;
  //end;
end;

procedure TfrmUserManager.actUserRoleDeleteExecute(Sender: TObject);
var
  u: TUser;
  ItemIndex: integer;
begin
  //user role delete
  //if UserList.SelectedUser.Roles.DBDelete(0) then
  //begin
  //  u := UserList.Items[SelectedUserIndex];
  //  u.roles.delete(SelectedRoleIndex);
  //  ListViewUpdate(lvRolesAssigned, u.roles.count, SelectedRoleIndex);
  //end;
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
  //u := UserList.Items[SelectedUserIndex] ;
  u := UserList.Items[lvUsers.ItemIndex] ;
  if u = nil then exit;

  ar := u.Roles.items[Item.Index];
  item.caption := ar.Rolename;
end;

procedure TfrmUserManager.lvRolesAssignedSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  //SelectedRoleIndex := Item.Index;
  //UserList.SelectedRole := UserList.SelectedUser.Roles.Items[SelectedRoleIndex];
  //UserList.SelectedUser.Roles.Items[Item.Index].Select(Item.Index);
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
  //UserList.SelectedUser := TUser(UserList.Items[Item.Index]);
  //UserList.Items[Item.Index].Select(Item.Index);

  //SelectedUserIndex := Item.Index;
  //u := TUser(UserList.Items[Item.Index]);
  //lvRolesAssigned.Items.Count:= u.roles.count;
  u := UserList.Items[item.index];
  lvRolesAssigned.Items.Count:= u.roles.count;
  ListViewUpdate(lvRolesAssigned,u.roles.Count,0);
  //lvRolesAssigned.Repaint;
  //SelectedRoleIndex:= -1 ;
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

  RoleList.ReadList;
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

