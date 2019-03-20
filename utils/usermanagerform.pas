unit UserManagerForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls;

type

  { TfrmUserManager }

  TfrmUserManager = class(TForm)
    Bevel2: TBevel;
    Button4: TButton;
    ListView1: TListView;
    ListView2: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

//var
  //frmUserManager: TfrmUserManager;

implementation

{$R *.lfm}

{ TfrmUserManager }

procedure TfrmUserManager.Button4Click(Sender: TObject);
begin
  Close;
end;

end.

