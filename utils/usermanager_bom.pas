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

  TTask = class;
  TTaskList = class;

  { TTask }

  TTask = class(TObject)
  private
    FFormName: string;
    FID: integer;
    FOwnerList: TTaskList;
    FRoleID: integer;
    FRoleName: string;
    FTaskName: string;
  public
    constructor Create(AOwnerList:TTaskList);
    property OwnerList: TTaskList read FOwnerList write FOwnerList;
  published
    property ID: integer read FID write FID;
    property RoleID: integer read FRoleID write FRoleID;
    property RoleName: string read FRoleName write FRoleName;
    property TaskName: string read FTaskName write FTaskName;
    property FormName: string read FFormName write FFormName;
  end;

  { TTaskList }

  TTaskList = class(TObjectList)
  private
  protected
    function  GetItems(i: integer): TTask; reintroduce;
    procedure SetItems(i: integer; const Value: TTask); reintroduce;
  public
    property  Items[i:integer]: TTask read GetItems write SetItems;
    procedure Add(AObject:TTask); reintroduce;
    //function DBAdd(role:TTask): boolean;
    //function DBDelete(index:integer): boolean;
    function ReadList: TTaskList;
    //function NotInList(s:string): boolean;
  end;

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
    function NotInList(s:string): boolean;
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
    FIsActive: integer;
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
    property IsActive: integer read FIsActive write FIsActive;
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
    function NotInList(s:string): boolean;
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
    function DBSetActive(index:integer; isactive: integer): boolean;
    function NotInList(s:string):Boolean;
  end;

  var
    UserList: TUserList;
    RoleList: TRoleList;
    TaskList: TTaskList;

implementation

uses gConnectionu;

{ TTaskList }

function TTaskList.GetItems(i: integer): TTask;
begin
  Result := TTask(inherited Items[i]);
end;

procedure TTaskList.SetItems(i: integer; const Value: TTask);
begin
  inherited Items[i] := Value;
end;

procedure TTaskList.Add(AObject: TTask);
begin
  inherited Add(AObject);
end;

function TTaskList.ReadList: TTaskList;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  o: TTask;

begin
  TaskList.Clear;

  t := TSQLTransaction.Create(gConnection);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  //q.SQL.Add('select id, action, form_name from usr_task order by form_name, action');
  //q.SQL.Add('select id, role_id, task_name, form_name from usr_roletask order by form_name, task_name ');

  q.SQL.Add('SELECT rt.ID, rt.ROLE_ID, r.ROLENAME, rt.TASK_NAME, rt.FORM_NAME ');
  q.SQL.Add('FROM USR_ROLETASK rt ');
  q.SQL.Add('join USR_ROLE r on r.ID=rt.ROLE_ID ');

  try
    q.Open;
    while not q.eof do
    begin
      o := TTask.Create(TaskList);
      o.id        := q.fields[0].asinteger;
      o.RoleID    := q.fields[1].AsInteger;
      o.RoleName  := q.fields[2].AsString;
      o.TaskName  := q.fields[3].asstring;
      o.FormName  := q.fields[4].asstring;

      TaskList.Add(o);
      q.next;
    end;
  finally
    q.Free;
    t.Free;
  end;
  Result := TaskList;
end;

{ TTask }

constructor TTask.Create(AOwnerList: TTaskList);
begin
  inherited create;
  FOwnerList:= AOwnerList;
end;

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

function TRoleList.NotInList(s: string): boolean;
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

function TAssignedRoleList.NotInList(s: string): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count-1 do
    if Items[i].Rolename = s then
      exit;
  Result := True;
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
  q.SQL.Add('select u.id, u.username, u.isactive, ');
  q.SQL.Add('  (select list(ur.id||'',''||r.rolename) from usr_role r ');
  q.SQL.Add('   join USR_USERROLE ur on ur.ROLE_ID=r.ID ');
  q.SQL.Add('   where ur.USER_ID=u.ID) roles ');
  q.SQL.Add('from usr_user u order by u.id ');

  try
    q.Open;
    while not q.eof do
    begin
      u := tuser.Create(UserList);
      //0 = id; 1 = username; 2 = isactive; 3 = roles
      u.id        := q.fields[0].asinteger;
      u.username  := q.fields[1].asstring;
      u.IsActive  := q.fields[2].AsInteger;
      sl.CommaText:= q.fields[3].AsString;

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
  q.SQL.Add('insert into usr_user(id, username, password, isactive) ');
  q.SQL.Add('values (:id,:username,:password, :isactive)');
  try
    q.params.ParamByName('id').AsInteger:= u.ID;
    q.params.ParamByName('username').AsString:= u.UserName;
    q.params.ParamByName('password').AsString:= 'password';
    q.params.ParamByName('isactive').AsInteger:= u.IsActive;
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
    Delete(index);

    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

function TUserList.DBSetActive(index: integer; isactive: integer): boolean;
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
    q.SQL.Add('update usr_user set isactive=:isactive where id=:id');
    q.params.ParamByName('id').AsInteger:= user.ID;
    q.params.ParamByName('isactive').AsInteger:= IsActive;
    q.ExecSQL;
    t.Commit;

    Result := True;
  finally
    q.free;
    t.free;
  end;
end;

function TUserList.NotInList(s: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count-1 do
    if Items[i].UserName = s then
      exit;
  Result := True;
end;

initialization
  UserList := TUserList.Create;
  RoleList := TRoleList.create;
  TaskList := TTaskList.create;

finalization
  UserList.Free;
  RoleList.Free;
  TaskList.Free;

end.

