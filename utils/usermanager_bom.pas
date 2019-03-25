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

  //trole
  TRole = class(TObject)
  private
    FID: integer;
    FOwnerList: TRoleList;
    FRolename: string;
  public
    constructor Create(AOwnerList:TRoleList);
    property OwnerList: TRoleList read FOwnerList write FOwnerList;
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
    function DBAdd(role:TRole): boolean;
    function DBDelete(index:integer): boolean;
    function ReadList: TRoleList;
    function UniqueItem(s:string): boolean;
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
    property OwnerList: TUserList read FOwnerList write FOwnerList;
  published
    property ID: integer read FID write FID;
    property UserName: string read FUserName write FUserName;
    property Roles: TAssignedRoleList read FRoles write FRoles;
    //todo: tuser: include an active/inactive status
    //when deleting make sure only inactive can be deleted
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

  protected
    function  GetItems(i: integer): TUser; reintroduce;
    procedure SetItems(i: integer; const Value: TUser); reintroduce;
  public
    property  Items[i:integer]: TUser read GetItems write SetItems;
    procedure Add(AObject:TUser); reintroduce;
    function ReadList: TUserList;
    function DBAdd(u:TUser): boolean;
    function DBDelete(index:integer): Boolean;
  end;

  var
    UserList: TUserList;
    RoleList: TRoleList;

implementation

uses gConnectionu;

{ TRole }

constructor TRole.Create(AOwnerList: TRoleList);
begin
  inherited Create;
  FOwnerList := AOwnerList;
end;


{ TAssignedRole }

constructor TAssignedRole.Create(AOwnerList: TUserList);
begin
  inherited Create;
  FOwnerList := TUserList(AOwnerList);
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

function TRoleList.DBAdd(role: TRole): boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
begin
  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('insert into usr_role(id, rolename) values (:id,:rolename)');
  try
    q.params.ParamByName('id').AsInteger:= role.ID;
    q.params.ParamByName('rolename').AsString:= role.RoleName;
    q.ExecSQL;
    t.Commit;
    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

function TRoleList.DBDelete(index: integer): boolean;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  role: TRole;
begin
  Result := False;
  role := RoleList.Items[index];

  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  try
    q.sql.add('select first 1 role_id from usr_userrole where role_id=:role_id');
    q.params.parambyname('role_id').asinteger := role.ID;
    q.Open;
    if q.RecordCount > 0 then exit;

    q.close;
    q.SQL.clear;
    q.SQL.Add('delete from usr_role where id=:id');
    q.params.ParamByName('id').AsInteger:= role.ID;
    q.ExecSQL;
    t.Commit;

    //list update
    Delete(index);

    Result := True;
  finally
    q.free;
    t.free;
  end;
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
  q.SQL.Add('select id, rolename from usr_role order by id');

  try
    q.Open;
    while not q.eof do
    begin
      o := trole.Create(RoleList);
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

function TRoleList.UniqueItem(s: string): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count-1 do
    if Items[i].Rolename = s then
      exit;
  Result := True;
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
begin
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
const
  SQL_DEL_ROLES = 'delete from usr_userrole where user_id=:user_id';
  SQL_DEL_USERS = 'delete from usr_user where id=:id';
var
  q: TSQLQuery;
  t: TSQLTransaction;
  user: TUser;
begin
  user := userlist.Items[index];

  t := TSQLTransaction.Create(nil);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;

  try
    //delete child data from usr_userrole
    q.SQL.Add(SQL_DEL_ROLES);
    q.params.ParamByName('user_id').AsInteger:= user.ID;
    q.ExecSQL;

    //delete user
    q.SQL.Clear;
    q.SQL.Add(SQL_DEL_USERS);
    q.params.ParamByName('id').AsInteger:= user.ID;
    q.ExecSQL;
    t.Commit;

    //list update
    Delete(index);      //todo:error after this line

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

