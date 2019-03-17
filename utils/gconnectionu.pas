unit gConnectionu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IBConnection;

type

  { TgConnection }

  TgConnection = class(TIBConnection)
  private
    FErrorMessage: string;
  public
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    function OpenDatabase: Boolean;
    procedure ReadValues;
  end;

var
  gConnection: TgConnection;

implementation

uses IniFiles
  , CryptU
  ;

{ TgConnection }

function TgConnection.OpenDatabase: Boolean;
begin
  Result := False;
  gConnection.ReadValues;
  try
    try
      gConnection.open;
      Result := gConnection.Connected;
    except
      on e: Exception do
        gConnection.ErrorMessage:= e.Message;
    end;
  finally
  end;
end;

procedure TgConnection.ReadValues;
var
  fn : string;
  ini : TIniFile;
  edbusr, edbpwd: string;
begin
  //hz4aN8Zv
  //mRF8SjLLBAbd
  edbusr:= Decrypt('hz4aN8Zv');
  edbpwd:= Decrypt('mRF8SjLLBAbd');

  fn := GetAppConfigFile(true);
  if FileExists(fn) then
  begin
    ini := TIniFile.Create(fn);
    try
      HostName := ini.ReadString('database','hostname','');
      DatabaseName := ini.ReadString('database','databasename','');
      //UserName:= ini.ReadString('database','username','');
      //Password:= ini.ReadString('database','password','');
    finally
      ini.free;
    end;
  end;
  if (HostName = '') or (DatabaseName = '') then
    //read from user;
  UserName:= edbusr;
  Password:= edbpwd;
end;

initialization
  gConnection := TgConnection.Create(nil);

finalization
  gConnection.Free;

end.

