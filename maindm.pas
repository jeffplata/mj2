unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil
  , AppUserU
  ;

type

  { TdmMain }

  TdmMain = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    FCurrentUser: TAppUser;
    function GetCurrentUser: TAppUser;
    property CurrentUser: TAppUser read GetCurrentUser write FCurrentUser;
  public
    function OpenDatabase: Boolean;
    function Login: Boolean;
    procedure LogOut;
    function Loggedin: Boolean;
    procedure ApplyRoles(Form: TComponent);
  end;

var
  dmMain: TdmMain;

implementation

uses gConnectionu
  ;

{$R *.lfm}

{ TdmMain }

procedure TdmMain.DataModuleCreate(Sender: TObject);
begin
  OpenDatabase;
  if gConnection.Connected then
    Login;
end;

function TdmMain.GetCurrentUser: TAppUser;
begin
  if FCurrentUser = nil then
    FCurrentUser := AppUser;
  Result := FCurrentUser;
end;

function TdmMain.OpenDatabase: Boolean;
begin
  Result :=  gConnection.OpenDatabase;
  //('localhost','c:\projects\mj2\data\database.fdb','sysdba','masterkey')
end;

function TdmMain.Login: Boolean;
begin
  Result := False;
  if not CurrentUser.Loggedin then
    Result := CurrentUser.LoginByForm;
end;

procedure TdmMain.LogOut;
begin
  CurrentUser.Logout;
end;

function TdmMain.Loggedin: Boolean;
begin
  result := CurrentUser.Loggedin;
end;

procedure TdmMain.ApplyRoles(Form: TComponent);
begin
  CurrentUser.ApplyRoles(Form);
end;

end.

