unit UserManager_bom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, HiLoGeneratorU, contnrs
  , sqldb
  ;

type
  TUser = class;
  TUserList = class;

  TAssignedRole = class;
  TAssignedRoleList = class;

  TRole = class;
  TRoleList = class;

  TRole = class(TObject)
  private
    FID: integer;
    FRolename: string;
  published
    property ID: integer read FID write FID;
    property Rolename: string read FRolename write FRolename;
  end;

  { TRoleList }

  TRoleList = class(TObjectList)
  private
  protected
    function  GetItems(i: integer): TRole; reintroduce;
    procedure SetItems(i: integer; const Value: TRole); reintroduce;
  public
    property  Items[i:integer]: TRole read GetItems write SetItems;
    procedure Add(AObject:TRole); reintroduce;
    function DBAdd(index:integer): boolean;
    function ReadList: TRoleList;
  end;

  { TAssignedRole }

  TAssignedRole = class(TObject)
  private
    FID: integer;
    FOwnerList: TUserList;
    FRoleID: integer;
    FRolename: string;
  public
    constructor Create(AOwnerList:TUserList);
    property OwnerList: TUserList read FOwnerList write FOwnerList;
    procedure Select(index:integer);
  published
    property ID: integer read FID write FID;
    property Rolename: string read FRolename write FRolename;
    property RoleID: integer read FRoleID write FRoleID;
  end;

  { TUser }

  TUser = class(TObject)
  private
    FID: integer;
    FOwnerList: TUserList;
    FRoles: TAssignedRoleList;
    FUserName: string;
  public
    constructor Create(AOwner: TObjectList);
    destructor Destroy; override;
    procedure Select(index:integer);
    property OwnerList: TUserList read FOwnerList write FOwnerList;
  published
    property ID: integer read FID write FID;
    property UserName: string read FUserName write FUserName;
    property Roles: TAssignedRoleList read FRoles write FRoles;
  end;

  { TAssignedRoleList }

  TAssignedRoleList = class(TObjectList)
  private
  protected
    function  GetItems(i: integer): TAssignedRole; reintroduce;
    procedure SetItems(i: integer; const Value: TAssignedRole); reintroduce;
  public
    property  Items[i:integer]: TAssignedRole read GetItems write SetItems;
    procedure Add(AObject:TAssignedRole); reintroduce;
    function DBAdd(ar: TAssignedRole; UserID: integer): boolean;
    function DBDelete(index, userIndex: integer): boolean;
  end;

  { TUserList }

  TUserList = class(TObjectList)
  private
    FSelectedUser: TUser;
    FSelectedRole: TAssignedRole;
    FSelectedUserIndex: integer;
    FSelectedRoleIndex: Integer;
  protected
    function  GetItems(i: integer): TUser; reintroduce;
    procedure SetItems(i: integer; const Value: TUser); reintroduce;
  public
    property  Items[i:integer]: TUser read GetItems write SetItems;
    procedure Add(AObject:TUser); reintroduce;
    function ReadList: TUserList;
    function DBAdd(u:TUser): boolean;
    function DBDelete(index:integer): Boolean;
    property SelectedUser: TUser read FSelectedUser write FSelectedUser;
    property SelectedRole: TAssignedRole read FSelectedRole write FSelectedRole;
    property SelectedUserIndex: integer read FSelectedUserIndex write FSelectedUserIndex;
    property SelectedRoleIndex: Integer read FSelectedRoleIndex write FSelectedRoleIndex;
  end;

  var
    UserList: TUserList;
    RoleList: TRoleList;

implementation

uses gConnectionu;

{ TAssignedRole }

constructor TAssignedRole.Create(AOwnerList: TUserList);
begin
  inherited Create;
  FOwnerList := TUserList(AOwnerList);
end;

procedure TAssignedRole.Select(index: integer);
begin
  FOwnerList.SelectedRole := Self;
  FOwnerList.SelectedRoleIndex:= index;
end;

{ TRoleList }

function TRoleList.GetItems(i: integer): TRole;
begin
  Result := TRole(inherited Items[i]);
end;

procedure TRoleList.SetItems(i: integer; const Value: TRole);
begin
  inherited Items[i] := Value;
end;

procedure TRoleList.Add(AObject: TRole);
begin
  inherited Add(AObject);
end;

function TRoleList.DBAdd(index: integer): boolean;
begin
  //add role
end;

function TRoleList.ReadList: TRoleList;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  o: TRole;

begin
  RoleList.Clear;

  t := TSQLTransaction.Create(gConnection);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('select id, rolename from usr_role ');

  try
    q.Open;
    while not q.eof do
    begin
      o := trole.Create;
      o.id        := q.fields[0].asinteger;
      o.rolename  := q.fields[1].asstring;

      RoleList.Add(o);
      q.next;
    end;
  finally
    q.Free;
    t.Free;
  end;
  Result := RoleList;
end;

{ TUser }

constructor TUser.Create(AOwner: TObjectList);
begin
  inherited create;
  FRoles := TAssignedRoleList.Create;
  FOwnerList := TUserList(AOwner);
end;

destructor TUser.Destroy;
begin
  FRoles.Free;
  inherited Destroy;
end;

procedure TUser.Select(index: integer);
begin
  OwnerList.SelectedUser := Self;
  OwnerList.SelectedUserIndex:= index;
end;

{ TAssignedRoleList }

function TAssignedRoleList.GetItems(i: integer): TAssignedRole;
begin
  Result := TAssignedRole(inherited Items[i]);
end;

procedure TAssignedRoleList.SetItems(i: integer; const Value: TAssignedRole);
begin
  inherited Items[i] := Value;
end;

procedure TAssignedRoleList.Add(AObject: TAssignedRole);
begin
  inherited Add(AObject);
end;

function TAssignedRoleList.DBAdd(ar: TAssignedRole; UserID: integer): boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
begin
  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('insert into usr_userrole(id, user_id, role_id) values (:id,:user_id,:role_id)');
  try
    //q.params.ParamByName('id').AsInteger:= UserList.SelectedRole.ID;
    //q.params.ParamByName('user_id').Asinteger:= UserList.SelectedUser.ID;
    //q.params.ParamByName('role_id').Asinteger:= UserList.SelectedRole.RoleID;
    q.params.ParamByName('id').AsInteger:= ar.ID;
    q.params.ParamByName('user_id').Asinteger:= UserID;
    q.params.ParamByName('role_id').Asinteger:= ar.RoleID;
    q.ExecSQL;
    t.Commit;
    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

function TAssignedRoleList.DBDelete(index, userIndex: integer): boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  u: tuser;
begin
  u := UserList.Items[userIndex];

  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('delete from usr_userrole where id=:id');
  try
    //q.params.ParamByName('id').AsInteger:= UserList.SelectedRole.ID;
    q.params.ParamByName('id').AsInteger:= u.roles.Items[index].ID;
    q.ExecSQL;
    t.Commit;

    Delete(index);

    Result := True;
  finally
    q.free;
    t.free;
  end;
end;


{ TUserList }

function TUserList.GetItems(i: integer): TUser;
begin
  Result := TUser(inherited Items[i]);
end;

procedure TUserList.SetItems(i: integer; const Value: TUser);
begin
  inherited Items[i] := Value;
end;

procedure TUserList.Add(AObject: TUser);
begin
  inherited Add(AObject);
end;

function TUserList.ReadList: TUserList;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  u: TUser;

  sl: TStringList;
  r: TAssignedRole;
  cnt: Integer;

begin
  UserList.Clear;

  sl := TStringList.Create;

  t := TSQLTransaction.Create(gConnection);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('select u.id, u.username, ');
  q.SQL.Add('  (select list(ur.id||'',''||r.rolename) from usr_role r ');
  q.SQL.Add('   join USR_USERROLE ur on ur.ROLE_ID=r.ID ');
  q.SQL.Add('   where ur.USER_ID=u.ID) roles ');
  q.SQL.Add('from usr_user u order by u.id ');

  try
    q.Open;
    while not q.eof do
    begin
      u := tuser.Create(UserList);
      //optiimize field access
      //0 = id; 1 = username; 2 = roles
      u.id        := q.fields[0].asinteger;
      u.username  := q.fields[1].asstring;
      sl.CommaText:= q.fields[2].AsString;

      cnt := 0;
      while cnt < sl.Count do
      begin
        r := TAssignedRole.Create(UserList);
        r.ID:= strtoint(sl.strings[cnt]); Inc(cnt);
        r.Rolename:= sl.strings[cnt]; Inc(cnt);
        u.FRoles.Add(r);
      end;

      UserList.Add(u);
      q.next;
    end;
  finally
    q.Free;
    t.Free;
    sl.free;
  end;
  Result := UserList;
end;

function TUserList.DBAdd(u: TUser): boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  //u: tuser;
begin
  //u := UserList.Items[index];

  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('insert into usr_user(id, username, password) values (:id,:username,:password)');
  try
    q.params.ParamByName('id').AsInteger:= u.ID;
    q.params.ParamByName('username').AsString:= u.UserName;
    q.params.ParamByName('password').AsString:= 'password';
    q.ExecSQL;
    t.Commit;
    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

function TUserList.DBDelete(index: integer): Boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  user: TUser;
begin
  //UserList.Items[index].Select(index);
  //if SelectedUser = nil then exit;

  //user := tuser.create(userlist);
  user := userlist.Items[index];

  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('delete from usr_user where id=:id');
  try
    //q.params.ParamByName('id').AsInteger:= UserList.Items[index].ID;
    q.params.ParamByName('id').AsInteger:= user.ID; // Items[index].ID;
    q.ExecSQL;
    t.Commit;

    //list update
    Delete(index);
    //if SelectedUserIndex >= Count then
    //  SelectedUserIndex := SelectedUserIndex - 1;
    //if SelectedUserIndex = -1 then
    //  SelectedUser := nil
    //else
    //  SelectedUser := Items[SelectedUserIndex];
    //SelectedRoleIndex:= -1;
    //SelectedRole := nil;

    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

initialization
  UserList := TUserList.Create;
  RoleList := TRoleList.create;

finalization
  UserList.Free;
  RoleList.Free;

end.

