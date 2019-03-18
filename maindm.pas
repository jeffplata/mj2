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
  private
    FCurrentUser: TAppUser;
    function GetCurrentUser: TAppUser;
  public
    property CurrentUser: TAppUser read GetCurrentUser write FCurrentUser;
    function OpenDatabase: Boolean;
    function Login: Boolean;
  end;

var
  dmMain: TdmMain;

implementation

uses gConnectionu
  ;

{$R *.lfm}

{ TdmMain }

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
  if not AppUser.Loggedin then
    Result := AppUser.LoginByForm;
end;

end.

