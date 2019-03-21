unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls;

type

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
    Bevel2: TBevel;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lvUsers: TListView;
    ListView2: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvUsersData(Sender: TObject; Item: TListItem);
  private
    procedure LoadUserList;
  public

  end;

implementation

uses usermanager_bom;

{$R *.lfm}

{ TfrmUserManager }

procedure TfrmUserManager.Button4Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmUserManager.FormCreate(Sender: TObject);
begin
  LoadUserList;
end;

procedure TfrmUserManager.lvUsersData(Sender: TObject; Item: TListItem);
//var
//  ob: TUser;
//begin
//  ob := TUser(UserList.Items[Item.Index]);
//  Item.Caption := inttostr(ob.ID);
//  Item.SubItems.Add(ob.UserName);
//end;
begin
  Item.Caption:= QryUsers.FieldByName('id').AsString;
  item.SubItems.Add(QryUsers.FieldByName('username').asstring);
end;

procedure TfrmUserManager.LoadUserList;
var
  c: TListColumn;
begin
  c := lvUsers.Columns.Add;
  c.Caption:= 'ID';
  C.Width:= 50;

  c := lvUsers.Columns.Add;
  c.caption := 'User Name';
  c.width := 150;

  //UserList.ReadList;
  //lvUsers.Items.Count:= UserList.Count;

  OpenUsers;
  lvUsers.Items.Count:= 3;
end;

end.

