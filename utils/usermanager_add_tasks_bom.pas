unit UserManager_Add_Tasks_BOM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UserManager_bom, Forms;

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

