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

  { TUser }

  TUser = class(TObject)
  private
    FID: integer;
    FUserName: string;
  published
    property ID: integer read FID write FID;
    property UserName: string read FUserName write FUserName;
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
begin
  t := TSQLTransaction.Create(gConnection);
  t.DataBase := gConnection;
  q := TSQLQuery.Create(nil);
  q.DataBase := gConnection;
  q.Transaction := t;
  q.SQL.Add('select id, username from usr_user');
  try
    q.Open;
    while not q.eof do
    begin
      u := tuser.Create;
      u.id := q.fieldbyname('id').asinteger;
      u.username := q.fieldbyname('username').asstring;
      UserList.Add(u);
      q.next;
    end;
  finally
    q.Free;
    t.Free;
  end;
  Result := UserList;
end;

initialization
  UserList := TUserList.Create;
  Transaction := TSQLTransaction.Create(gConnection);
  Transaction.DataBase := gConnection;
  QryUsers := TSQLQuery.Create(nil);
  QryUsers.DataBase := gConnection;
  QryUsers.Transaction := Transaction;
  QryUserRoles  := TSQLQuery.Create(nil);
  QryUserRoles.DataBase := gConnection;
  QryUserRoles.Transaction := Transaction;

finalization
  UserList.Free;
  QryUsers.Free;
  QryUserRoles.Free;
  Transaction.Free;

end.

