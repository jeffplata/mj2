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
    function GetCurrentUser: TAppUser;
    procedure SetCurrentUser(AValue: TAppUser);
  public
    property CurrentUser: TAppUser read GetCurrentUser write SetCurrentUser;
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
  if CurrentUser = nil then
    CurrentUser := AppUser;
  Result := CurrentUser;
end;

procedure TdmMain.SetCurrentUser(AValue: TAppUser);
begin
  if AValue <> CurrentUser then
    CurrentUser := AValue;
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
    //show login form
end;

end.

