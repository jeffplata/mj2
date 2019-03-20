unit _TemplateForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    btnOk: TButton;
    btnCancel: TButton;
    btnClose: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

