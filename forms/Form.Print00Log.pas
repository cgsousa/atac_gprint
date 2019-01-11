{***
* Serviço para capturar pedidos & direciona-los conforme definições
* Atac Sistemas
* Todos os direitos reservados
* Autor: Carlos Gonzaga
* Data: 02.10.2017
*}
unit Form.Print00Log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus,
  JvExStdCtrls, JvButton, JvCtrls, JvFooter, ExtCtrls,
  JvExExtCtrls, JvExtComponent, JvExControls, JvGradient, JvMemo, JvRichEdit,
  JvComponentBase, JvTrayIcon, JvAppInst, JvTimer,
  uclass, ulog, uTaskDlg
  ;


type
  Tfrm_Print00Log = class(TForm)
    pnl_Footer: TJvFooter;
    btn_Start: TJvFooterBtn;
    btn_Close: TJvFooterBtn;
    btn_Stop: TJvFooterBtn;
    JvGradient1: TJvGradient;
    mmo_Log: TJvRichEdit;
    btn_Printers: TJvFooterBtn;
    btn_PProd: TJvFooterBtn;
    JvTrayIcon1: TJvTrayIcon;
    JvAppInstances1: TJvAppInstances;
    JvTimer1: TJvTimer;
    procedure btn_StartClick(Sender: TObject);
    procedure btn_StopClick(Sender: TObject);
    procedure btn_PrintersClick(Sender: TObject);
    procedure btn_PProdClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    { Private declarations }
    terminal_id: string;
    procedure OnINI(Sender: TObject);
    procedure OnEND(Sender: TObject);
    procedure OnLOG(Sender: TObject; const StrLog: string);

    procedure DoRun() ;

  protected
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    CRec       : TCThreadProcRec;
    CStop      : Boolean;
    procedure DoStart();
    procedure DoStop;

    class procedure DoShow();
  end;

var
  frm_Print00Log: Tfrm_Print00Log;

implementation

{$R *.dfm}

uses IOUtils, DateUtils, DB ,
  uadodb,
  uprinter,
  Form.Print00List, Form.PrinterPP00
  ,Form.Etiqueta
  ;


{ Tfrm_Print00Log }

procedure Tfrm_Print00Log.btn_CloseClick(Sender: TObject);
begin
//    Self.Close ;
//    Application.Minimize ;
    JvTrayIcon1.HideApplication ;
end;

procedure Tfrm_Print00Log.btn_PProdClick(Sender: TObject);
begin
    Tfrm_PrinterPP00.DoShow()
    ;
end;

procedure Tfrm_Print00Log.btn_PrintersClick(Sender: TObject);
begin
//    Tfrm_ConfigEtq.DoShow(0);
    Tfrm_Print00List.DoShow;

end;

procedure Tfrm_Print00Log.btn_StartClick(Sender: TObject);
begin
    if not Assigned(CRec.CExec) then
    begin
        DoStart;
    end
    else
    begin
        DoStop;
    end;
    Sleep(1000);
end;

procedure Tfrm_Print00Log.btn_StopClick(Sender: TObject);
begin
    if CMsgDlg.Warning('Deseja parar o serviço do Gerenciador de Impressão?', True) then
    begin
        btn_StartClick(btn_Stop);
    end;
end;

procedure Tfrm_Print00Log.DoRun;
var
  p00List: TCPrinter00List; //Lista de impressoras
  p00: TCPrinter00 ;
  p01List: TCPrinter01List;
  p1,p2: TCPrinter01;
  pp00: TCPrinterPP00 ; //Ponto produção
  pp01: TCPrinterPP01 ; //Porta do PP / terminal
var
  doc,err: string ;
begin

    pp00 :=TCPrinterPP00.Create ;
    p00List :=TCPrinter00List.Create ;

    try
      //
      // Carrega impressoras...
      if p00List.Load() then
      begin
        //
        // cria lista vazia
        p01List :=TCPrinter01List.Create ;
        while not CStop do
        begin
            //
            // carrega pedidos por terminal
            if p01List.Load(terminal_id) then
            begin
                //
                // processamento de cada pedido
                for p1 in p01List do
                begin
                    //
                    // valida ponto de produção
                    if p1.Items = nil then
                    begin
                       Continue;
                    end;
                    //
                    // processamento de cada ponto de produção
                    for p2 in p1.Items do
                    begin
                        TSWLog.Add('%s|Iniciando impressão',[p2.descri]);

                        //
                        // carrega portas
                        //
                        pp00.pp0_codseq :=p2.codseq;
                        pp00.pp0_descri :=p2.descri;
                        pp00.pp0_codptr :=p2.codseq;
                        pp00.DoLoadItems(pp00.pp0_codseq);

                        //
                        // ler porta padrão do ponto por terminal
                        //
                        pp01 :=pp00.IndexOf(terminal_id) ;
                        if pp01 <> nil then
                        begin
                            //
                            // check tentativas
                            if(pp01.pp1_maxttv > 0)and(pp01.pp1_numttv >= pp01.pp1_maxttv)then
                            begin
                                Continue;
                            end;

                            //
                            // Configura impressora
                            //
                            p00 :=p00List.IndexOf(pp01.pp1_codptr);
                            if p00 <> nil then
                            begin
                                TSWLog.Add('%s|Imprimindo...',[p2.descri]);
                                p00.pr0_nporta:=pp01.pp1_terminalport ;
                                if pp01.pp1_terminalport=TCPrinterPP01.PORT_REMOTE_COMP then
                                begin
                                    p00.pr0_nporta:=pp01.pp1_xhost ;
                                end
                                else
                                if pp01.pp1_terminalport=TCPrinterPP01.PORT_REMOTE_TCP then
                                begin
                                    p00.pr0_nporta:='TCP:'+pp01.pp1_xhost ;
                                end;

                                p00.pr0_xhost :=pp01.pp1_xhost ;
                                p00.NumCop    :=pp01.pp1_numcop ;

                                p2.DoPreparePrint(doc, p00) ;
                                if p00.Execute(doc) then
                                begin
                                    p2.setPrintStatus ;
                                    TSWLog.Add('%s|Terminou impressão.',[p2.descri]);
                                end

                                //
                                // erro/adv impressão
                                //
                                else begin
                                    TSWLog.Add('%s|Erro %s!',[p2.descri, p00.ErrMsg]);
                                    //
                                    // erro comunicação
                                    // check tentativas
                                    if(p00.ErrCod =-2)and(pp01.pp1_maxttv > 0)then
                                    begin
                                        //
                                        // inc. tentativa
                                        pp01.pp1_numttv :=pp01.pp1_numttv +1;
                                        pp00.DoMerge(pp01);
                                    end;
                                end;
                            end
                            else
                                TSWLog.Add('%s|Impressora não definida!',[p2.descri]);
                        end
                        else begin
                            //
                            // mostra erro com respectivo terminal
                            TSWLog.Add('Nenhuma porta configurada neste terminal[%s]!',[terminal_id]);
                        end;
                    end;
                end;
            end;
            Sleep(1000);
        end;
      end
      else
        TSWLog.Add('Nenhuma impressora cadastrada!');

    finally
      if Assigned(p01List)then
      begin
          p01List.Free ;
      end;
      p00List.Free ;
    end;

end;

class procedure Tfrm_Print00Log.DoShow;
var
  F: Tfrm_Print00Log;
begin
    F :=Tfrm_Print00Log.Create(Application);
    try
        F.ShowModal ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_Print00Log.DoStart;
begin

    ulog.CLog.OnSWLogChange :=Self.OnLOG;
    if not ConnectionADO.Connected then
    try
        ConnectionADO.Connected :=True;
    except
        on E:EDatabaseError do
        begin
            TSWLog.Add('Banco de dados|Erro %s',[E.Message]);
        end;
    end;

    if ConnectionADO.Connected then
    begin
        if Empresa = nil then
        begin
            Empresa :=TCEmpresa.Instance ;
            Empresa.DoLoad(1);
        end;

        CRec.OnIni :=Self.OnINI;
        CRec.OnEnd :=Self.OnEND;
        CRec.CProc :=Self.DoRun;
        CRec.CExec :=TCThreadProc.Create(CRec);
        CStop :=False ;
    end;

end;

procedure Tfrm_Print00Log.DoStop;
begin
    CRec.CExec :=nil ;
    CStop :=True ;
end;

procedure Tfrm_Print00Log.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Y, M, D: Word;
  pass: string;
  csum: Word ;
begin
//    if CMsgDlg.Warning('Deseja sair do Gerenciador de Impressão?', True) then
//    begin
        DoStop ;
//    end
//    else
//        CanClose :=False ;
    {if InputQuery('Confirmar senha','Informe a senha:',pass) then
    begin
        DecodeDate(Date, Y, M, D);
        Y :=StrToInt(Copy(IntToStr(Y), 3, 2));
        csum :=(Y + M + D)*9 ;
        CanClose :=csum =StrToIntDef(pass, 0);
        if not CanClose then
        begin
            CMsgDlg.Info('Senha não confere!');
        end;
    end
    else
        CMsgDlg.Info('Senha não informada!');
    }
end;

procedure Tfrm_Print00Log.FormCreate(Sender: TObject);
begin
    if ParamCount > 0 then
        Self.WindowState :=wsMinimized
    else
        Self.WindowState :=wsNormal;

    //ConnectionADO :=TADOConnection.getInstance ;
//    ConnectionADO :=NewADOConnFromIniFile('Configuracoes.ini') ;
//    ConnectionADO.Connected :=True;
//    Empresa :=TCEmpresa.Instance ;
//    Empresa.DoLoad(1);

    terminal_id :=Tfrm_PrinterPP00.getTerminalId ;
end;

procedure Tfrm_Print00Log.JvTimer1Timer(Sender: TObject);
begin
    JvTimer1.Enabled :=False ;
    btn_StartClick(nil);
end;

procedure Tfrm_Print00Log.KeyDown(var Key: Word; Shift: TShiftState);
begin
    if ssCtrl in Shift then
    begin
      if (Key =Ord('P'))or(Key =Ord('p'))then
      begin
          btn_Stop.Visible :=True ;
      end
    end;
    inherited ;
end;

procedure Tfrm_Print00Log.Loaded;
begin
    inherited;
    //KeyPreview:=True;
    JvAppInstances1.Active :=True;
    JvTrayIcon1.Active :=True;
    JvTimer1.Enabled :=True;
    mmo_Log.Clear ;
end;

procedure Tfrm_Print00Log.OnEND(Sender: TObject);
begin
    btn_Start.Enabled:=True;
    btn_Stop.Enabled :=False;
//    btn_Stop.Visible :=False ;
    btn_Printers.Enabled:=True;
    btn_PProd.Enabled:=True;
    TSWLog.Add('Parou serviço do Gerenciador de Impressão');
    ConnectionADO.Close;
end;

procedure Tfrm_Print00Log.OnINI(Sender: TObject);
begin
    mmo_Log.Clear ;
    btn_Start.Enabled:=False;
    btn_Stop.Enabled :=True;
//    btn_Stop.Visible :=False ;
    btn_Printers.Enabled:=False;
    btn_PProd.Enabled:=False;
    TSWLog.Add('Iniciou serviço do Gerenciador de Impressão');
end;

procedure Tfrm_Print00Log.OnLOG(Sender: TObject; const StrLog: string);
begin
    if Pos('Erro', StrLog) > 0 then
    begin
        mmo_Log.AddFormatText(StrLog, [fsBold,fsItalic], 'Arial', clRed) ;
        mmo_Log.AddFormatText(#13#10, []) ;
    end
    else
        mmo_Log.Lines.Add(StrLog);
//    mmo_Log.ScrollBy();
    mmo_Log.SelLength := 0;
    mmo_Log.SelStart:=mmo_Log.GetTextLen; //mmo_Log.Perform(EM_LINEINDEX, mmo_Log.Lines.Count -1, 0);
    mmo_Log.Perform( EM_SCROLLCARET, 0, 0 ); {::garantir a exibição é correto}
end;


end.
