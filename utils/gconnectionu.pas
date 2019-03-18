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
    procedure ReadValues;
    procedure SaveValues;
  public
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
    function OpenDatabase: Boolean;
    function I_OpenDB: Boolean;
  end;

var
  gConnection: TgConnection;

implementation

uses IniFiles
  , CryptU
  , SetDBForm
  ;

{ TgConnection }

function TgConnection.I_OpenDB: Boolean;
begin
  Result := False;
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

function TgConnection.OpenDatabase: Boolean;
begin
  Result := False;
  gConnection.ReadValues;

  Result := gConnection.I_OpenDB;
  if not Result then
    Result := TfrmSetDB.Execute;

  if Result then gConnection.SaveValues;
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
    finally
      ini.free;
    end;
  end;
  UserName:= edbusr;
  Password:= edbpwd;
end;

procedure TgConnection.SaveValues;
var
  fn : string;
  ini : TIniFile;
begin
  fn := GetAppConfigFile(true);
  ini := TIniFile.Create(fn);
  try
    ini.WriteString('database','hostname',gConnection.HostName);
    ini.WriteString('database','databasename',gConnection.DatabaseName);
  finally
    ini.free;
  end;
end;

initialization
  gConnection := TgConnection.Create(nil);

finalization
  gConnection.Free;

end.

