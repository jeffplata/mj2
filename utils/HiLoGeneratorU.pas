unit HiLoGeneratorU;

//2019-03-23  9:12 PM JeffPlata
//Changes:
//Rewritten for Lazarus
//Remove dependenty on PropertySaveU

//2016-05-07  5:51 PM JeffPlata
//Changes:
//Remove dependency on appsettings
//Set the following properties instead on first dm (usually dmsecurity or dmmain):
//-- HighIDGenerator (string, usually 'GEN_HIGHID', check db)
//-- SQLConnection (usually from AppConnection)
//-- FileName (use appsetting.userconfigfile)

interface

uses
  Classes, SysUtils, gConnectionu;

type

  { TMyHiLoGenerator }
  TSaveOperation = (soLoad, soSave);
  TSaveOperations = set of TSaveOperation;

  TMyHiLoGenerator = class(TComponent)
  private
    FHighIDGenerator: string;
    FIDHigh: Integer;
    FIDLow: Integer;
    FSQLConnection: TgConnection;
    procedure I_SaveLoad(operation: TSaveOperation);
  public
    constructor Create(const AOwner: TComponent);
    destructor Destroy; override;
    function GetNextID(const SaveAfterFetch: Boolean = True): Integer;
    procedure Save;
    procedure Load;
  published
    property HighIDGenerator: string read FHighIDGenerator write FHighIDGenerator;
    property SQLConnection: TgConnection read FSQLConnection write FSQLConnection;
    property IDHigh: Integer read FIDHigh write FIDHigh;
    property IDLow: Integer read FIDLow write FIDLow;

  end;

const
  MAXLOWID : Integer = 99999;
  MAXHIGHID : Integer = 21473;

  {
  http://firebirdsql.org/manual/migration-mssql-data-types.html
  INTEGER : Integer (whole number) data from
  (-2,147,483,648) through (2,147,483,647).
  }
var
  AppHiloGenerator : TMyHiLoGenerator;

implementation

uses
  Forms, IniFiles, sqldb;


constructor TMyHiLoGenerator.Create(const AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TMyHiLoGenerator.Destroy;
begin
  Save;
  inherited;
end;

function TMyHiLoGenerator.GetNextID(const SaveAfterFetch: Boolean = True):
    Integer;
var
  LowID: integer;
  HighID: Integer;
const
  SQL_HI_ID = 'select GEN_ID( %s,1) from RDB$DATABASE';


  function GetNextHighFromDB: Integer;
  {
    Notes on Firebird 1.5:
    2147483647    Integer type max value
    21474/83647
    21473  99999  21,473 high values starting from 1 (server generator)
                  99,999 max low id (maintain locally)
  }
  var
    HighIDGen: string;
    sql : string;
    //rs: TCustomSQLDataSet;
    t: TSQLTransaction;
    q: TSQLQuery;
  begin
    Result := -1;
    HighIDGen := FHighIDGenerator;

    sql := Format(SQL_HI_ID,[HighIDGen]);
    //SQLConnection.Execute(sql,nil,@rs);
    //Result := rs.Fields[0].AsInteger;

    t := TSQLTransaction.create(gConnection);
    t.DataBase := gConnection;
    q := TSQLQuery.create(nil);
    q.DataBase := gConnection;
    q.Transaction := t;
    q.SQL.Add(sql);
    try
      q.Open;
      Result := q.Fields[0].AsInteger;
    finally
      q.free;
      t.free;
    end;
  end;

begin
  HighID := FIDHigh;
  LowID := FIDLow + 1;
  if ((LowID = 0) OR (LowID > MAXLOWID) OR (HighID = 0)) then begin
    HighID := GetNextHighFromDB;
    if HighID = -1 then
      raise Exception.Create('[HighID] Unable to obtain key from database.');
    if HighID > MAXHIGHID then
      raise Exception.Create('[HighID] System overrun.');
    LowID := 1;
    FIDHigh := HighID;
  end;
  FIDLow := LowID;
  Result := HighID * (MAXLOWID +1) + LowID;
  if SaveAfterFetch then Save; // disable when fetching PKs in succession

end;

procedure TMyHiLoGenerator.Save;
begin
  I_SaveLoad(soSave);
end;

procedure TMyHiLoGenerator.Load;
begin
  I_SaveLoad(soLoad);
end;

procedure TMyHiLoGenerator.I_SaveLoad(operation: TSaveOperation);
var
  ini: TIniFile;
  fn: String;
begin
  fn := GetAppConfigFile(true);
  ini := TIniFile.Create(fn);
  try
    case operation of
      soSave:
        begin
          ini.WriteInteger('HILOPK','IDHigh',FIDHigh);
          ini.WriteInteger('HILOPK','IDLow',FIDLow);
        end;
      soLoad:
        begin
          FIDHigh := ini.ReadInteger('HILOPK','IDHigh',0);
          FIDLow := ini.ReadInteger('HILOPK','IDLow',0);
        end;
    end;
  finally
    ini.free;
  end;
end;


initialization
  AppHiloGenerator := TMyHiLoGenerator.Create(Application);
  AppHiloGenerator.Name := 'AppHiloGenerator';
  AppHiloGenerator.HighIDGenerator:= 'GEN_HIGHID';
  AppHiloGenerator.Load;

finalization
  AppHiloGenerator.Free;

end.
