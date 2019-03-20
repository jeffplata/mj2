unit AppUserU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs;

type

  TTask = class;
  TTaskList = class;

  { TTask }

  TTask = class(TObject)
  private
    FAction: string;
    FForm: string;
    FRole: string;
  protected
  public
  published
    property Form: string read FForm write FForm;
    property Action: string read FAction write FAction;
    property Role: string read FRole write FRole;
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
  end;

  { TAppUser }

  TAppUser = class(TObject)

  private
    FLoggedin: Boolean;
    FPassWord: string;
    FRoles: TStrings;
    FUserName: string;
  public
    constructor Create;
    destructor Destroy; override;
    function Login: Boolean;
    function LoginByForm: Boolean;
    function I_Login(const UserName, Password: string; remember: Boolean): Boolean;
    procedure Logout;
    procedure ApplyRoles(Form: TComponent);
    procedure ReadValues;
    procedure SaveValues(UserName, Password: string; remember: boolean);
  published
    property UserName: string read FUserName write FUserName;
    property PassWord: string read FPassWord write FPassWord;
    property Roles: TStrings read FRoles write FRoles;
    property Loggedin: Boolean read FLoggedin;
  end;

  function GetTasks: TTaskList;


  var
    AppUser: TAppUser;
    TaskList: TTaskList;

implementation

uses LoginForm, gConnectionu, CryptU, strutils, IniFiles, ActnList, sqldb;

function GetTasks: TTaskList;
var
  Query : TSQLQuery;
  Trans : TSQLTransaction;
  ATask: TTask;
begin
  TaskList.Clear;

  Trans := TSQLTransaction.Create(nil);
  Query := TSQLQuery.Create(nil);
  Trans.DataBase := gConnection;
  Query.DataBase := gConnection;
  Query.Transaction := Trans;
  Query.SQL.Add('select t.form_name, t.action, r.rolename from usr_task t ');
  Query.SQL.Add('join usr_role r on r.id=t.role_id ');
  Query.SQL.Add('order by t.form_name');
  try
     Query.Open;
     while not Query.Eof do
     begin
       ATask := TTask.Create;
       ATask.FForm:= Query.FieldByName('form_name').AsString;
       ATask.FAction:= Query.FieldByName('action').AsString;
       ATask.FRole:= Query.FieldByName('rolename').AsString;
       TaskList.Add(ATask);
       Query.Next;
     end;
  finally
    Query.Free;
    Trans.Free;
  end;
  Result := TaskList;
end;

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

{ TAppUser }

constructor TAppUser.Create;
begin
  inherited Create;
  FRoles := TStringList.Create;
  FLoggedin:= False;
end;

destructor TAppUser.Destroy;
begin
  FRoles.Free;
  inherited Destroy;
end;

function TAppUser.Login: Boolean;
begin
  Result := False;
  ReadValues;
  if UserName='' then
    Result := LoginByForm
  else
    Result := I_Login(UserName, PassWord, True);
end;

function TAppUser.LoginByForm: Boolean;
begin
  ReadValues;
  if UserName<>'' then
    I_Login(UserName, PassWord, true);
  if not FLoggedin then
    TfrmLogin.Execute;
  Result := FLoggedin;
end;

function TAppUser.I_Login(const UserName, Password: string; remember: Boolean
  ): Boolean;
var
  Query : TSQLQuery;
  Trans : TSQLTransaction;
begin
  FLoggedin:= False;
  FRoles.Clear;

  Trans := TSQLTransaction.Create(nil);
  Query := TSQLQuery.Create(nil);
  Trans.DataBase := gConnection;
  Query.DataBase := gConnection;
  Query.Transaction := Trans;
  Query.SQL.Add('select username, password from usr_user where username=:username and password=:password');
  Query.Params.ParamByName('USERNAME').AsString:= UserName;
  Query.Params.ParamByName('PASSWORD').AsString:= Password;
  try
     //get user
     Query.Open;
     FLoggedin := (Query.RecordCount > 0);

     //get roles
     Query.Close;
     Query.SQL.Clear;
     Query.SQL.Add('select ur.user_id, r.rolename from usr_userrole ur ');
     Query.SQL.Add('join usr_user u on u.id=ur.user_id ');
     Query.SQL.Add('join usr_role r on r.id=ur.role_id ');
     Query.SQL.Add('  where u.username=:username');
     Query.Params.ParamByName('USERNAME').AsString:= UserName;
     Query.Open;
     while not Query.Eof do
     begin
       AppUser.Roles.Add(Query.FieldByName('rolename').AsString);
       Query.Next;
     end;
  finally
    Query.Free;
    Trans.Free;
  end;

  //get tasks
  if FLoggedin then GetTasks;

  //save values
  SaveValues(UserName,Password,remember);

  Result := Floggedin;
end;

procedure TAppUser.Logout;
var
  fn: String;
  ini: TIniFile;
begin
  FLoggedin:= false;
  UserName:= '';
  PassWord:= '';
  FRoles.Clear;
  TaskList.Clear;

  fn := GetAppConfigFile(true);
  ini := TIniFile.Create(fn);
  try
    ini.EraseSection('user');
  finally
    ini.free;
  end;
end;

procedure TAppUser.ApplyRoles(Form: TComponent);
var
  i, j: Integer;
begin
  for i := 0 to form.ComponentCount-1 do
    if (form.Components[i] is TAction) then
      begin
        //traverse tasklist table
        for j := 0 to TaskList.Count -1 do
          begin
            if (TTask(TaskList[j]).Action = form.Components[i].Name) and
               (TTask(TaskList[j]).Form = form.Name) then
                 (form.Components[i] as TAction).Enabled:=
                   (AppUser.Roles.IndexOf(TTask(TaskList[j]).Role) >= 0 );
          end;
      end;
end;

procedure TAppUser.ReadValues;
var
  fn , tk, us, pa: string;
  ini : TIniFile;
const
  DELIM = '"';
begin
  UserName:='';
  PassWord:='';

  fn := GetAppConfigFile(true);
  ini := TIniFile.Create(fn);
  try
    tk := ini.ReadString('user','token','');
    if tk <> '' then
      begin
        tk := Decrypt(tk);
        pa := ExtractDelimited(1,tk,[DELIM]);
        us := ExtractDelimited(2,tk,[DELIM]);
        pa := StringReplace(pa,'kirk;0;=',DELIM,[rfReplaceAll]);
        us := StringReplace(us,'kirk;0;=',DELIM,[rfReplaceAll]);
        if (us<>'') and (pa<>'') then
        begin
          UserName:= us;
          PassWord:= pa;
        end;
      end;
  finally
    ini.free;
  end;
end;

procedure TAppUser.SaveValues(UserName, Password: string; remember: boolean);
var
  fn , token: string;
  ini : TIniFile;
const
  DELIM = '"';
begin
  UserName:= StringReplace(UserName,DELIM,'kirk;0;=',[rfReplaceAll]);;
  Password:= StringReplace(Password,DELIM,'kirk;0;=',[rfReplaceAll]);
  token := Encrypt(Password+DELIM+UserName);
  fn := GetAppConfigFile(true);
  ini := TIniFile.Create(fn);
  try
    if remember then
      ini.WriteString('user','token',token)
    else
      ini.EraseSection('user');
  finally
    ini.free;
  end;
end;

initialization
  AppUser := TAppUser.Create;
  TaskList := TTaskList.Create;

finalization
  AppUser.Free;
  TaskList.Free;

end.

