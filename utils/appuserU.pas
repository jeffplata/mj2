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
    //function  GetOwner: TTaskList; reintroduce;
    //procedure SetOwner(const Value: TTaskList); reintroduce;
  public
    //property  Owner: TTaskList read GetOwner write SetOwner;
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
    //constructor Create; override;
    //destructor Destroy; override;
  end;

  { TAppUser }

  TAppUser = class(TObject)

  private
    FLoggedin: Boolean;
    FRoles: TStrings;
    FUserName: string;
  public
    constructor Create;
    destructor Destroy; override;
    function LoginByForm: Boolean;
    function Login(const UserName, Password: string): Boolean;
    procedure ApplyRoles(Form: TComponent);
  published
    property UserName: string read FUserName write FUserName;
    property Roles: TStrings read FRoles write FRoles;
    property Loggedin: Boolean read FLoggedin;
  end;

  function GetTasks: TTaskList;


  var
    AppUser: TAppUser;
    TaskList: TTaskList;

implementation

uses LoginForm, gConnectionu, ActnList, sqldb;

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
       //write(TTask(TaskList[TaskList.Count-1]).Form+ '  ');
       //write(TTask(TaskList[TaskList.Count-1]).Action+ '  ');
       //write(TTask(TaskList[TaskList.Count-1]).Role+ '  ');
       //writeln();
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

//constructor TTaskList.Create;
//begin
//  inherited Create;
//end;

//destructor TTaskList.Destroy;
//begin
//  inherited Destroy;
//end;

{ TTask }

//function TTask.GetOwner: TTaskList;
//begin
//  result := TTaskList(inherited GetOwner);
//end;

//procedure TTask.SetOwner(const Value: TTaskList);
//begin
//  inherited SetOwner(Value);
//end;


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

function TAppUser.LoginByForm: Boolean;
begin
  TfrmLogin.Execute;
  Result := FLoggedin;
end;

function TAppUser.Login(const UserName, Password: string): Boolean;
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

  Result := Floggedin;
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

initialization
  AppUser := TAppUser.Create;
  TaskList := TTaskList.Create;

finalization
  AppUser.Free;
  TaskList.Free;

end.

