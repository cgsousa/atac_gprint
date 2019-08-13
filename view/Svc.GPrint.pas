unit Svc.GPrint;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  Tsvc_GPrint = class(TService)
  private
    { Private declarations }
    procedure ServiceStopShutdown;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  svc_GPrint: Tsvc_GPrint;

implementation

{$R *.DFM}

uses Registry;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
    svc_GPrint.Controller(CtrlCode);
end;

function Tsvc_GPrint.GetServiceController: TServiceController;
begin
    Result :=ServiceController;
end;

procedure Tsvc_GPrint.ServiceStopShutdown;
begin

end;

end.
