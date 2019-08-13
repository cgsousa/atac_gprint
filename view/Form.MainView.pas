unit Form.MainView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls,
  FormBase, uStatusBar, Thread.Printer,
  //
  JvAppInst, JvTrayIcon, JvTimer, JvComponentBase, JvExExtCtrls, JvBevel,
  //
  AdvOfficeStatusBar, AdvOfficeStatusBarStylers, AdvPanel, AdvGlowButton,
  AdvSplitter, StdCtrls, AdvCombo, AdvGroupBox;

type
  Tfrm_MainView = class(TBaseForm)
    AdvOfficeStatusBar1: TAdvOfficeStatusBar;
    AdvOfficeStatusBarOfficeStyler1: TAdvOfficeStatusBarOfficeStyler;
    AdvPanelStyler1: TAdvPanelStyler;
    JvTimer1: TJvTimer;
    JvTrayIcon1: TJvTrayIcon;
    JvAppInstances1: TJvAppInstances;
    AdvPanel1: TAdvPanel;
    JvBevel1: TJvBevel;
    JvBevel2: TJvBevel;
    JvBevel3: TJvBevel;
    JvBevel4: TJvBevel;
    JvBevel5: TJvBevel;
    JvBevel6: TJvBevel;
    btn_Start: TAdvGlowButton;
    btn_Stop: TAdvGlowButton;
    btn_Config: TAdvGlowButton;
    btn_Printers: TAdvGlowButton;
    btn_PProd: TAdvGlowButton;
    btn_Log: TAdvGlowButton;
    btn_Close: TAdvGlowButton;
    Timer1: TTimer;
    procedure btn_StartClick(Sender: TObject);
    procedure btn_StopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn_LogClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn_ConfigClick(Sender: TObject);
    procedure btn_PrintersClick(Sender: TObject);
    procedure btn_PProdClick(Sender: TObject);

  private
    { Private declarations }
    m_MySvc: TCSvcPrinter;
    procedure doStart();
    procedure doStop();
    procedure OnINI(Sender: TObject);
    procedure OnEND(Sender: TObject);
  private
    { Private StatusBar Widget }
    m_StatusBar: TCStatusBarWidget;
    m_StatusText: TAdvOfficeStatusPanel ;
    m_TerminalName: string ;
  protected
    procedure Loaded; override;
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses JclSysInfo ,
  uTaskDlg, ulog,
  Form.LogView,
  Form.ParametroList,
  Form.Print00List,
  Form.PrinterPP00 ;

var
  frm_Log: Tfrm_LogView ;


{ Tfrm_MainView }

procedure Tfrm_MainView.btn_CloseClick(Sender: TObject);
begin
    JvTrayIcon1.HideApplication ;

end;

procedure Tfrm_MainView.btn_ConfigClick(Sender: TObject);
var
  pwd: string ;
begin
    if not InputQueryDlg('.:Parâmetros do sistema/GPrint:.','Informe a senha:', pwd) then
    begin
        Exit;
    end;
    if not ChkPwd(pwd) then
    begin
        CMsgDlg.Warning('Senha inválida!') ;
        Exit;
    end;
    //
    // load parms nfe
    Tfrm_ParametroList.lp_Show('GPRINT') ;
end;

procedure Tfrm_MainView.btn_LogClick(Sender: TObject);
begin
    if frm_Log.Visible then
    begin
        frm_Log.Close ;
        btn_Log.Caption :='Vizualizar Atividades';
    end
    else begin
        frm_Log.Show ;
        btn_Log.Caption :='Fechar Atividades';
    end;
end;

procedure Tfrm_MainView.btn_PProdClick(Sender: TObject);
begin
    Tfrm_PrinterPP00.DoShow() ;

end;

procedure Tfrm_MainView.btn_PrintersClick(Sender: TObject);
begin
    Tfrm_Print00List.DoShow;

end;

procedure Tfrm_MainView.btn_StartClick(Sender: TObject);
begin
    //
    if Assigned(m_MySvc) then
    begin
        doStop ;
    end ;
    //
    // start manual
    doStart ;
end;

procedure Tfrm_MainView.btn_StopClick(Sender: TObject);
begin
    if Assigned(m_MySvc) then
    begin
        if(not m_MySvc.Terminated)and CMsgDlg.Warning('Deseja parar a tarefa?',True)then
        begin
            //
            // stop manual
            DoStop ;
        end;
    end ;
end;

procedure Tfrm_MainView.doStart;
begin
    //
    // cria uma unica vez
    if not Assigned(frm_log) then
    begin
        frm_Log :=Tfrm_LogView.Create(Application) ;
        frm_Log.OnCloseQuery :=FormCloseQuery ;
    end;
    frm_Log.txt_Log.Clear ;

    //
    // prepare e start a tarefa
    m_MySvc :=TCSvcPrinter.Create(m_TerminalName) ;
    m_MySvc.OnBeforeExecute :=OnINI;
    m_MySvc.OnTerminate :=OnEND;
    m_MySvc.OnStrProc :=frm_Log.OnUpdateStr;

    m_MySvc.Start  ;

end;

procedure Tfrm_MainView.doStop;
begin
    m_MySvc.Terminate;
    if not m_MySvc.Finished then
      m_MySvc.WaitFor;
    FreeAndNil(m_MySvc);
end;

procedure Tfrm_MainView.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if Sender =Self then
    begin
        if Assigned(m_MySvc)then DoStop ;
    end
    else begin
        btn_Log.Caption :='Vizualizar Atividades';
    end;
end;

procedure Tfrm_MainView.FormCreate(Sender: TObject);
begin
    WindowState :=wsMinimized ;
    //
    // version
    TCExeInfo.getInstance.GetVersionInfoOfApp(Application.ExeName);
    Caption :=Format('%s(Ver.:%d.%d.%d%d)',[Caption,
                                            TCExeInfo.getInstance.MajorVersion ,
                                            TCExeInfo.getInstance.MinorVersion ,
                                            TCExeInfo.getInstance.ReleaseNumber,
                                            TCExeInfo.getInstance.BuildNumber
                                            ]);
    //
    // statusBar
    m_TerminalName :=UpperCase(GetLocalComputerName) ;
    AdvPanel1.Caption.Text :=Format('<p>Terminal: <b>%s</b></p>',[m_TerminalName]);
    m_StatusBar :=TCStatusBarWidget.Create(AdvOfficeStatusBar1, False);
    m_StatusText:=m_StatusBar.AddPanel(psHTML,'');

    //JvTrayIcon1.Active :=True;
    JvTimer1.Enabled :=True;
end;

procedure Tfrm_MainView.FormShow(Sender: TObject);
begin
    //
    // position
    Left :=Monitor.Width -Self.Width ;
    Top :=Monitor.Height -Self.Height;
end;

procedure Tfrm_MainView.JvTimer1Timer(Sender: TObject);
begin
    JvTimer1.Enabled :=False ;
    btn_Start.Click;
end;

procedure Tfrm_MainView.Loaded;
begin
    DefaultMonitor :=dmDesktop;
	  Position  :=poScreenCenter;
    JvAppInstances1.Active :=True;
    JvTrayIcon1.Active :=True;
end;

procedure Tfrm_MainView.OnEND(Sender: TObject);
begin
    btn_Start.Enabled :=True;
    btn_Stop.Enabled  :=False;
    btn_Config.Enabled:=True;
    btn_Printers.Enabled:=True;
    btn_PProd.Enabled:=True;
    m_StatusText.Text :='<font color="#ff0000">Tarefa <b>Parada!</b></font>';
    frm_Log.OnUpdateStr('Serviço de impressão parado!');
    //
    // fecha log
    //btn_Log.Click ;
end;

procedure Tfrm_MainView.OnINI(Sender: TObject);
begin
    //
    // disabed buttons
    btn_Start.Enabled :=False;
    btn_Stop.Enabled  :=True ;
    btn_Config.Enabled:=False;
    btn_Printers.Enabled:=False;
    btn_PProd.Enabled:=False;
    //
    // status
    m_StatusText.Text :='<font color="#3cb371">Tarefa em <b>Operação</b></font>';
    frm_Log.OnUpdateStr('Serviço de impressão iniciado');
end;


end.
