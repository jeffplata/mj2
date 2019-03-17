unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

uses mainDM
, CryptU
  ;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  if dmMain.SetDatabase
  then
    label1.Caption := 'connected'
  else begin
    label1.caption := 'not connected';
    //ShowMessage( gConnection.ErrorMessage );
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  e,d : string;
begin
  e := CryptU.Encrypt('sysdba');
  d := CryptU.Decrypt(e);
  memo1.lines.add(e);
  memo1.lines.add(d);
  e := CryptU.Encrypt('masterkey');
  d := CryptU.Decrypt(e);
  memo1.lines.add(e);
  memo1.lines.add(d);
end;

end.

