unit AppUserU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

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
  published
    property UserName: string read FUserName write FUserName;
    property Roles: TStrings read FRoles write FRoles;
    property Loggedin: Boolean read FLoggedin;
  end;


  var
    AppUser: TAppUser;

implementation

uses LoginForm;


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
  Result := TfrmLogin.Execute;
  FLoggedin:= Result;
end;

initialization
  AppUser := TAppUser.Create;

finalization
  AppUser.Free;

end.

