unit UserManager_Add_Tasks_BOM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UserManager_bom, Forms;

type
  PTaskTreeData = ^TTaskTreeData;
  TTaskTreeData = record
    FTaskName: string;
    FFormName: string;
  end;

var
  MyTaskList: TTaskList;

procedure GetTasksFromApp;

implementation

procedure GetTasksFromApp;
begin

end;


initialization
  MyTaskList := TTaskList.Create;

finalization
  MyTaskList.Free;

end.

