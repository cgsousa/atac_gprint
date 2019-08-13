program ATAC_SVC_GPRINT;

uses
  SvcMgr,
  WinSvc,
  SysUtils,
  Windows,
  Forms,
  Svc.GPrint in 'view\Svc.GPrint.pas' {svc_GPrint: TService},
  Thread.Printer in 'units\Thread.Printer.pas',
  uprinter in 'units\uprinter.pas',
  Form.MainView in 'view\Form.MainView.pas' {frm_MainView},
  Form.LogView in 'view\Form.LogView.pas' {frm_LogView},
  Form.Print00 in 'forms\Form.Print00.pas' {frm_Print00},
  Form.Print00List in 'forms\Form.Print00List.pas' {frm_Print00List},
  Form.PrinterPP00 in 'forms\Form.PrinterPP00.pas' {frm_PrinterPP00};

{$R *.RES}

const
  SERVICE_NAME = 'Svc_GPrinter';

function IsServiceInstalled(const srv_name: string): Boolean;
const
  //
  // assume that the total number of
  // services is less than 4096.
  // increase if necessary
  cnMaxServices = 4096;

type
  TSvcA = array[0..cnMaxServices]
          of TEnumServiceStatus;
  PSvcA = ^TSvcA;

var
  //
  // temp. use
  j: Integer;

  //
  // service control
  // manager handle
  schm: SC_Handle;

  //
  // bytes needed for the
  // next buffer, if any
  nBytesNeeded,

  //
  // number of services
  nServices,

  //
  // pointer to the
  // next unread service entry
  nResumeHandle: DWord;

  //
  // service status array
  ssa : PSvcA;

begin
    Result :=False ;

    // connect to the service
    // control manager
    schm :=OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if schm > 0 then
    begin
        nResumeHandle :=0;

        New(ssa);

        EnumServicesStatus(
          schm,
          SERVICE_WIN32,
          SERVICE_STATE_ALL,
          ssa^[0],
          SizeOf(ssa^),
          nBytesNeeded,
          nServices,
          nResumeHandle );


        //
        // assume that our initial array
        // was large enough to hold all
        // entries. add code to enumerate
        // if necessary.
        //

        for j := 0 to nServices-1 do
        begin
            if StrPas(
              ssa^[j].lpServiceName ) =srv_name then
            begin
                Result :=True;
                Break ;
            end;
        end;

        Dispose(ssa);

        // close service control
        // manager handle
        CloseServiceHandle(schm);

    end;
end;

var
  LAppForm: Tfrm_MainView;


begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //


  //
  // executa
  // como serviço
  if(not(FindCmdLineSwitch('app', ['-', '\', '/'], true))) then
  begin
    if not SvcMgr.Application.DelayInitialize or SvcMgr.Application.Installing then
      SvcMgr.Application.Initialize;
    SvcMgr.Application.CreateForm(Tsvc_GPrint, svc_GPrint);
  SvcMgr.Application.Run;
  end

  //
  // executa
  // como app
  else begin
      Forms.Application.Initialize;
      Forms.Application.MainFormOnTaskbar :=False;
      Forms.Application.Title := 'Atac Serviço de Impressão';
      Forms.Application.CreateForm(Tfrm_MainView, LAppForm);
      Forms.Application.Run ;
  end;

end.
