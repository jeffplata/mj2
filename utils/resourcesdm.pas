unit ResourcesDM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Controls;

type

  { TdmResources }

  TdmResources = class(TDataModule)
    ImageList1: TImageList;
  private

  public

  end;

var
  dmResources: TdmResources;

implementation

{$R *.lfm}

initialization
  dmResources := TdmResources.Create(nil);

finalization
  dmResources.Free;

end.

