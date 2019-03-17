unit mainDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil;

type

  { TdmMain }

  TdmMain = class(TDataModule)
  private

  public
    function SetDatabase(const hostname, dbname, username, pwd: string): boolean;
  end;

var
  dmMain: TdmMain;

implementation

uses gConnectionu, SetDB;

{$R *.lfm}

{ TdmMain }

function TdmMain.SetDatabase: boolean;
begin
  gConnection.OpenDatabase;
  //('localhost','c:\projects\mj2\data\database.fdb','sysdba','masterkey')
  result := setdb.SetDatabase(hostname, dbname, username, pwd);
end;

end.

