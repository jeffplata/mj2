unit SetDB;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils
  , gConnectionu
  //, CryptU
  ;

function SetDatabase(const hostname, dbname, username, pwd: string): boolean;


implementation

function SetDatabase(const hostname, dbname, username, pwd: string): boolean;
begin

  Result := False;

  gConnection.Connected:= False;
  gConnection.HostName := hostname;
  gConnection.DatabaseName:= dbname;
  gConnection.UserName:= username;
  gConnection.Password:= pwd;

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



end.

