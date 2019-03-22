unit UserManager_bom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs
  , sqldb
  ;

type
  TUser = class;
  TUserList = class;

  TUserRole = class;
  TUserRoleList = class;

  { TUserRole }

  TUserRole = class(TObject)
  private
    FID: integer;
    FRolename: string;
  published
    property ID: integer read FID write FID;
    property Rolename: string read FRolename write FRolename;
  end;

  { TUser }

  TUser = class(TObject)
  private
    FID: integer;
    FRoles: TUserRoleList;
    FUserName: string;
  public
    constructor create;
    destructor Destroy; override;
  published
    property ID: integer read FID write FID;
    property UserName: string read FUserName write FUserName;
    property Roles: TUserRoleList read FRoles write FRoles;
  end;

  { TUserRoleList }

  TUserRoleList = class(TObjectList)
  private
  protected
    function  GetItems(i: integer): TUserRole; reintroduce;
    procedure SetItems(i: integer; const Value: TUserRole); reintroduce;
  public
    property  Items[i:integer]: TUserRole read GetItems write SetItems;
    procedure Add(AObject:TUserRole); reintroduce;
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
  end;

  var
    UserList: TUserList;
    //UserRoleList: TUserRoleList;

    QryUsers: TSQLQuery;
    QryUserRoles: TSQLQuery;
    Transaction: TSQLTransaction;

function OpenUsers: boolean;

implementation

uses gConnectionu;

function OpenUsers: boolean;
begin
  QryUsers.SQL.Add('select id, username from usr_user');
  try
    QryUsers.Open;
    Result := True;
  finally
  end;
end;

{ TUser }

constructor TUser.create;
begin
  inherited create;
  FRoles := TUserRoleList.Create;
end;

destructor TUser.Destroy;
begin
  FRoles.Free;
  inherited Destroy;
end;

{ TUserRoleList }

function TUserRoleList.GetItems(i: integer): TUserRole;
begin
  Result := TUserRole(inherited Items[i]);
end;

procedure TUserRoleList.SetItems(i: integer; const Value: TUserRole);
begin
  inherited Items[i] := Value;
end;

procedure TUserRoleList.Add(AObject: TUserRole);
begin
  inherited Add(AObject);
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
  r: TUserRole;
  cnt: Integer;

begin
  UserList.Clear;
  //UserRoleList.Clear;

  sl := TStringList.Create;

  t := TSQLTransaction.Create(gConnection);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  //q.SQL.Add('select id, username from usr_user');
  q.SQL.Add('select u.id, u.username, ');
  q.SQL.Add('  (select list(r.id||'',''||r.rolename) from usr_role r ');
  q.SQL.Add('   join USR_USERROLE ur on ur.ROLE_ID=r.ID ');
  q.SQL.Add('   where ur.USER_ID=u.ID) roles ');
  q.SQL.Add('from usr_user u ');

  try
    q.Open;
    while not q.eof do
    begin
      u := tuser.Create;
      //optiimize field access
      //0 = id; 1 = username; 2 = roles
      u.id        := q.fields[0].asinteger;
      u.username  := q.fields[1].asstring;
      sl.CommaText:= q.fields[2].AsString;

      cnt := 0;
      while cnt < sl.Count do
      begin
        r := TUserRole.Create;
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

initialization
  UserList := TUserList.Create;
  //UserRoleList := TUserRoleList.create;

  //Transaction := TSQLTransaction.Create(gConnection);
  //Transaction.DataBase := gConnection;
  //QryUsers := TSQLQuery.Create(nil);
  //QryUsers.DataBase := gConnection;
  //QryUsers.Transaction := Transaction;
  //QryUserRoles  := TSQLQuery.Create(nil);
  //QryUserRoles.DataBase := gConnection;
  //QryUserRoles.Transaction := Transaction;

finalization
  UserList.Free;
  //UserRoleList.free;

  //QryUsers.Free;
  //QryUserRoles.Free;
  //Transaction.Free;

end.

