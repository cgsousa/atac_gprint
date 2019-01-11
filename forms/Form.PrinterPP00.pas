unit Form.PrinterPP00;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  FormBase,

  JvExStdCtrls, JvButton, JvCtrls, JvFooter, JvExExtCtrls, JvExtComponent,
  JvExControls, JvGradient, AdvCombo,
  AdvGroupBox ,
  ACBrBase, ACBrPosPrinter,

  uprinter, DCPcrypt2, DCPsha1, JvSpeedButton, Mask, AdvSpin, AdvGlowButton,
  TaskDialog

  ;

type
  Tfrm_PrinterPP00 = class(TBaseForm)
    JvGradient1: TJvGradient;
    pnl_Footer: TJvFooter;
    btn_Apply: TJvFooterBtn;
    btn_Close: TJvFooterBtn;
    cbx_PPro: TAdvComboBox;
    gbx_PrintDef: TAdvGroupBox;
    cbx_Modelo: TAdvComboBox;
    cbx_NPorta: TAdvComboBox;
    cbx_Host: TAdvComboBox;
    ACBrPosPrinter1: TACBrPosPrinter;
    DCP_sha11: TDCP_sha1;
    btn_Print: TJvSpeedButton;
    btn_Remove: TJvSpeedButton;
    cbx_HostList: TAdvComboBox;
    btn_ClearHost: TJvSpeedButton;
    btn_ClearPrint: TJvSpeedButton;
    edt_MaxTenta: TAdvSpinEdit;
    edt_NumCopy: TAdvSpinEdit;
    btn_NumTenta: TAdvGlowButton;
    cbx_PPGrupo: TAdvComboBox;
    lbl_Alert: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbx_NPortaSelect(Sender: TObject);
    procedure btn_ApplyClick(Sender: TObject);
    procedure cbx_PProChange(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
    procedure btn_PrintClick(Sender: TObject);
    procedure btn_RemoveClick(Sender: TObject);
    procedure btn_ClearHostClick(Sender: TObject);
    procedure btn_ClearPrintClick(Sender: TObject);
    procedure btn_NumTentaClick(Sender: TObject);
    procedure cbx_PProKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbx_PProEnter(Sender: TObject);
    procedure cbx_PProExit(Sender: TObject);
  private
//    const PORT_REMOTE_COMP = 'COMP';
//    const PORT_REMOTE_TCP = 'TCP';
    var IND_REMOTE_COMP: Integer ;
    var IND_REMOTE_TCP: Integer ;
    var TERMINAL_ID: string ;
  private
    { Private declarations }
    p00List: TCPrinter00List ; //Lista de impressoras
    pp00List: TCPrinterPP00List ; // Lista de ponto produção
    pp00: TCPrinterPP00 ; //Ponto produção selecionado
    pp01: TCPrinterPP01 ; //Porta do ponto produção por terminal
    terminal_nm: string ;
    function ValidInput(): Boolean;
  public
    { Public declarations }
    property TerminalId: string read terminal_id ;
    property TerminalName: string read terminal_nm ;
    procedure DoResetForm(); override ;
    class procedure DoShow();
    class function getTerminalId: string ;
  end;


implementation

{$R *.dfm}

uses StrUtils, TypInfo, Printers, DB,
  JclSysInfo ,
  uTaskDlg, uadodb;


function TiraPontos(const Str: string): string;
var
  i, Count: Integer;
begin
  SetLength(Result, Length(str));
  Count := 0;
  for i := 1 to Length(str) do
  begin
    if not CharInSet(str[i], [ '/',',','-','.',')','(',' ' ]) then
    begin
      inc(Count);
      Result[Count] := str[i];
    end;
  end;
  SetLength(Result, Count);
end;


{ Tfrm_PrinterPP00 }

procedure Tfrm_PrinterPP00.btn_ApplyClick(Sender: TObject);
var
  p00: TCPrinter00 ;
  ppg: TCPrinterPP00;
begin

    if not ValidInput() then
    begin
        Exit ;
    end;

    p00 :=p00List.Items[cbx_Modelo.ItemIndex] ;

    pp01.pp1_codppr :=pp00.pp0_codseq ;
    pp01.pp1_codptr :=p00.pr0_codseq ;
    pp01.pp1_terminalname :=terminal_nm;
    pp01.pp1_terminalport :=cbx_NPorta.Text;
    pp01.pp1_xhost :=cbx_Host.Text;
    pp01.pp1_numcop :=edt_NumCopy.Value ;
    pp01.pp1_maxttv :=edt_MaxTenta.Value ;
    pp00.pp0_codptr:=p00.pr0_codseq;
    try
        pp00.pp0_descri :=cbx_PPro.Text ;
        //
        // check agrupamento
        //
        if(cbx_PPGrupo.ItemIndex > -1)and(cbx_PPGrupo.ItemIndex <=pp00List.Count -1) then
        begin
            ppg :=pp00List.Items[cbx_PPGrupo.ItemIndex] ;
            pp00.pp0_codppr :=ppg.pp0_codseq ;
        end
        else
            pp00.pp0_codppr :=-1 ;

        pp00.DoMerge(pp01) ;
        CMsgDlg.Info('Configuração da Porta gravada gravada com sucesso.');
        if cbx_HostList.Items.IndexOf(terminal_nm) < 0 then
        begin
            cbx_HostList.AddItem(terminal_nm, nil);
            cbx_HostList.ItemIndex :=0;
            btn_ClearHost.Enabled :=cbx_HostList.ItemIndex  > -1;
            btn_ClearPrint.Enabled :=cbx_HostList.ItemIndex  > -1;
        end;
    except
        on E:EDatabaseError do
        begin
            CMsgDlg.Error('Erro na gravação dos dados! %s',[E.Message]);
        end;
    end ;
end;

procedure Tfrm_PrinterPP00.btn_RemoveClick(Sender: TObject);
begin
    if CMsgDlg.Warning('Deseja remover esta configuração?', True)then
    begin
        pp01.UpdateStatus :=usDeleted;
        try
            pp00.DoMerge(pp01) ;
            CMsgDlg.Info('Configuração removida com sucesso.');
            DoResetForm;
            btn_Print.Enabled :=False;
        except
            on E:EDatabaseError do
            begin
                CMsgDlg.Error('Erro remoção da configuração! %s',[E.Message]);
            end;
        end ;
    end;
end;

procedure Tfrm_PrinterPP00.btn_ClearHostClick(Sender: TObject);
var
  msg: string;
begin
    msg :=Format('Deseja limpar as portas configuradas do terminal[%s]?',[cbx_HostList.Text]);
    if CMsgDlg.Warning(msg, True)then
    begin
        pp00List.DoRemoveTerminal(cbx_HostList.Text);
        DoResetForm;
        btn_Print.Enabled :=False;
    end;
end;

procedure Tfrm_PrinterPP00.btn_CloseClick(Sender: TObject);
begin
    Self.Close ;

end;

procedure Tfrm_PrinterPP00.btn_NumTentaClick(Sender: TObject);
begin
    pp01.pp1_numttv :=0;
    CMsgDlg.Info('Re-inicio de tentativas ativado.');
    btn_NumTenta.Visible :=False ;
end;

procedure Tfrm_PrinterPP00.btn_PrintClick(Sender: TObject);
var
  p00: TCPrinter00 ;
  S:  TStringWriter;
  p0,p1,p2: TCPrinter01 ;
  doc,err: string;
begin
    if not ValidInput() then
    begin
        Exit ;
    end;

    p00 :=p00List.Items[cbx_Modelo.ItemIndex] ;
    p00.pr0_nporta:=cbx_NPorta.Text;
    if pp01.pp1_terminalport=TCPrinterPP01.PORT_REMOTE_COMP then
    begin
        p00.pr0_nporta:=cbx_Host.Text ;
    end
    else
    if pp01.pp1_terminalport=TCPrinterPP01.PORT_REMOTE_TCP then
    begin
        p00.pr0_nporta:='TCP:'+cbx_Host.Text ;
    end;
    p00.pr0_xhost :=cbx_Host.Text ;

    //cria pedido virtual
    p0 :=TCPrinter01.Create ;
    p0.ptrtyp :=ptPed ;
    p0.codseq :=99999;
    p0.codmsa :=999;
    p0.xhost :=TerminalName ;
    p0.datsys :=Now ;

    //p.produção
    p1 :=p0.AddNew(ptPPtr) ;
    p1.codseq :=pp00.pp0_codseq ;
    p1.descri :=pp00.pp0_descri ;
    p1.codptr :=p00.pr0_codseq ;

    //item
    p2 :=p1.AddNew(ptItem) ;
    p2.codseq:=1;
    p2.codpro:=1;
    p2.quanti:=1;
    p2.vlunit:=1;
    p2.descri:='TESTE DE '+cbx_Modelo.Text ;
    p2.unidad:='UN';
    p2.codbar:='1234567890123' ;
    p2.observ:='TESTE REALIZADO COM SUCESSO.' ;
    p2.openom:='SISTEMA' ;
    p2.status:=psNoPrint;

    p1.DoPreparePrint(doc, p00);
    if doc <> '' then
    begin
        if not p00.Execute(doc) then
        begin
            CMsgDlg.Error(p00.ErrMsg);
        end;
    end;

end;

procedure Tfrm_PrinterPP00.cbx_NPortaSelect(Sender: TObject);
begin
    if cbx_NPorta.ItemIndex = IND_REMOTE_COMP then
        cbx_Host.LabelCaption :='Compartilhamento: (\\computador\comp...)'
    else
        if cbx_NPorta.ItemIndex = IND_REMOTE_TCP then
            cbx_Host.LabelCaption :='IP:'
        else
            cbx_Host.LabelCaption :='Computador:';
end;

procedure Tfrm_PrinterPP00.cbx_PProChange(Sender: TObject);
var
  p00: TCPrinter00 ;
  ppg: TCPrinterPP00;
begin
    pp00 :=TCPrinterPP00(cbx_PPro.Items.Objects[cbx_PPro.ItemIndex]) ;
    if pp00 <> nil then
    begin
        pp00.DoLoadItems(pp00.pp0_codseq);
        //Busca a porta pelo terminal id
        pp01 :=pp00.IndexOf(terminal_id) ;
        if pp01 <> nil then
        begin
            //busca impressora padrão
            p00 :=p00List.IndexOf(pp01.pp1_codptr) ;
            if p00 <> nil then
            begin
                cbx_Modelo.ItemIndex :=p00.ItemIndex;
                cbx_NPorta.ItemIndex :=cbx_NPorta.Items.IndexOf(pp01.pp1_terminalport) ;
                cbx_Host.Text :=pp01.pp1_xhost ;
                edt_NumCopy.Value :=pp01.pp1_numcop ;
                edt_MaxTenta.Value:=pp01.pp1_maxttv ;
                if edt_MaxTenta.Value > 0 then
                begin
                    btn_NumTenta.Visible :=True;
                    if pp01.pp1_numttv >= pp01.pp1_maxttv then
                    begin
                        btn_NumTenta.Font.Color :=clRed;
                        btn_NumTenta.Caption :='O número de tentativas ja foi atingido! Deseja resetar?';
                    end
                    else begin
                        btn_NumTenta.Font.Color :=clWindowText;
                        btn_NumTenta.Caption :=Format('%d tentativa(s) restante!',[pp01.pp1_maxttv -pp01.pp1_numttv]);
                    end;
                end
                else
                    btn_NumTenta.Visible :=False;
            end
            else
                cbx_Modelo.ItemIndex :=-1;
        end
        else begin
            //inicializa a porta com o terminal
            pp01 :=pp00.AddItem();
            pp01.pp1_codseq :=0;
            pp01.pp1_codppr :=pp00.pp0_codseq;
            pp01.pp1_codptr :=0;
            pp01.pp1_terminalid  :=terminal_id ;
            pp01.pp1_terminalname:=terminal_nm;
            pp01.pp1_terminalport:='' ;
            pp01.pp1_xhost :='' ;
            pp01.pp1_princ :=True;

            cbx_Modelo.ItemIndex :=-1 ;
            cbx_NPorta.ItemIndex :=-1 ;
            cbx_Host.Text :='';
            edt_MaxTenta.Value:=3;
            edt_NumCopy.Value :=1;
        end;

        //
        // pp de agrupamento
        //
        ppg :=pp00List.IndexOf(pp00.pp0_codppr) ;
        if ppg <> nil then
        begin
            cbx_PPGrupo.ItemIndex :=ppg.ItemIndex;
        end
        else begin
            cbx_PPGrupo.ItemIndex :=-1;
        end;

    end;
end;

procedure Tfrm_PrinterPP00.cbx_PProEnter(Sender: TObject);
begin
    lbl_Alert.Visible :=True;

end;

procedure Tfrm_PrinterPP00.cbx_PProExit(Sender: TObject);
begin
    lbl_Alert.Visible :=False;
end;

procedure Tfrm_PrinterPP00.cbx_PProKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  dlg: TAdvInputTaskDialog;
  I: Integer;
begin
    if key = VK_F2 then
    begin
        dlg :=TAdvInputTaskDialog.Create(nil);
        try
          dlg.CommonButtons :=[cbOK,cbCancel];
//          dlg.CustomButtons.Add('OK');
//          dlg.CustomButtons.Add('Cancelar');
          dlg.DefaultButton :=1;
          dlg.Icon :=tiWarning ;
          //dlg.Footer :='Footer';
          dlg.Content :='Informe um novo descritivo:';
          dlg.InputText :=cbx_PPro.Text;
          dlg.Instruction :='Esta operação altera a descrição do ponto!'#13'Se não foi esta a intenção, é so clicar no butão <cancel>.';
          dlg.Title :='.:Alterar Ponto de Produção:.';
          if dlg.Execute = mrOk then
          begin
              I :=cbx_PPro.ItemIndex ;
              cbx_PPro.Items.Strings[cbx_PPro.ItemIndex] :=dlg.InputText;
              cbx_PPro.ItemIndex :=I;
          end;
        finally
          dlg.Free ;
        end;
    end;
end;

procedure Tfrm_PrinterPP00.DoResetForm;
var
  Digest: array[0..19] of byte;
  pp00: TCPrinterPP00 ;
  p00: TCPrinter00 ;
  M: TACBrPosPrinterModelo;
  I: Integer;
begin
    //
    DoClear(Self);
    //

    pp00List.DoLoad ;
    for pp00 in pp00List do
    begin
        cbx_PPro.AddItem(pp00.pp0_descri, pp00);
        cbx_PPGrupo.AddItem(pp00.pp0_descri, pp00);
    end;
    cbx_PPGrupo.AddItem('', nil);

    p00List.Load(0, cbx_Modelo.Items);

    //Portas Seriais
    ACBrPosPrinter1.Device.AcharPortasSeriais( cbx_NPorta.Items );
    cbx_NPorta.Items.Add('LPT1') ;

//    cbxPorta.Items.Add('/dev/ttyS0') ;
//    cbxPorta.Items.Add('/dev/ttyS1') ;
//    cbxPorta.Items.Add('/dev/ttyUSB0') ;
//    cbxPorta.Items.Add('/dev/ttyUSB1') ;
//    cbxPorta.Items.Add('\\localhost\Epson') ;
//    cbxPorta.Items.Add('c:\temp\ecf.txt') ;
//    cbxPorta.Items.Add('TCP:192.168.0.31:9100') ;

    //Gerenciador do windows
    for I :=0 to Printer.Printers.Count-1 do
    begin
        cbx_NPorta.Items.Add('RAW:'+Printer.Printers[I]);
    end;

    //Portas remotas
    cbx_NPorta.Items.Add(TCPrinterPP01.PORT_REMOTE_COMP);
    cbx_NPorta.Items.Add(TCPrinterPP01.PORT_REMOTE_TCP);

    IND_REMOTE_COMP :=cbx_NPorta.Items.IndexOf(TCPrinterPP01.PORT_REMOTE_COMP) ;
    IND_REMOTE_TCP :=cbx_NPorta.Items.IndexOf(TCPrinterPP01.PORT_REMOTE_TCP) ;

    cbx_Host.AddItem(terminal_nm, nil);
    cbx_HostList.Items.AddStrings(pp00List.Hosts);
    cbx_HostList.ItemIndex :=0;

    btn_ClearHost.Enabled :=cbx_HostList.ItemIndex  > -1;
    btn_ClearPrint.Enabled :=cbx_HostList.ItemIndex  > -1;

    cbx_PPro.ItemIndex :=0;
    cbx_PProChange(cbx_PPro);

end;

class procedure Tfrm_PrinterPP00.DoShow;
var
  F: Tfrm_PrinterPP00;
begin
    F :=Tfrm_PrinterPP00.Create(Application);
    try
        F.ShowModal ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_PrinterPP00.FormCreate(Sender: TObject);
var
  Digest: array[0..19] of byte;
  I: Integer;
begin
    pp00List:=TCPrinterPP00List.Create ;
    p00List :=TCPrinter00List.Create ;

    //gera terminal id
    if TERMINAL_ID = '' then
    begin
        terminal_id :='';
        terminal_nm :=JclSysInfo.GetLocalComputerName;
        terminal_id :=terminal_nm;
        {DCP_sha11.Init ;
        DCP_sha11.UpdateStr(terminal_nm);
        DCP_sha11.Final(Digest);
        for I :=0 to 19 do
        begin
            terminal_id:=terminal_id + IntToHex(Digest[I],2);
        end;}
    end;
end;

procedure Tfrm_PrinterPP00.FormShow(Sender: TObject);
begin
    DoResetForm ;

end;

class function Tfrm_PrinterPP00.getTerminalId: string;
var
  F: Tfrm_PrinterPP00;
begin
    F :=Tfrm_PrinterPP00.Create(Application);
    try
        Result :=F.TERMINAL_ID ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_PrinterPP00.btn_ClearPrintClick(Sender: TObject);
var
  Y, M, D: Word;
  pwd,msg: string;
  csum: Word ;
var
  p01List: TCPrinter01List;
begin
    msg :=Format('Todas as impressões ativas do terminal[%s] serão removidas. Deseja continuar?',[cbx_HostList.Text]);
    if CMsgDlg.Warning(msg, True) then
    if InputQuery('Confirmar senha','Informe a senha:',pwd) then
    begin
        DecodeDate(Date, Y, M, D);
        Y :=StrToInt(Copy(IntToStr(Y), 3, 2));
        csum :=(Y + M + D)*9 ;
        if csum =StrToIntDef(pwd, 0) then
        begin

            p01List :=TCPrinter01List.Create;
            try
                p01List.DoClear(cbx_HostList.Text);
            finally
                p01List.Free ;
            end;

        end
        else
            CMsgDlg.Info('Senha não confere!');
    end;
end;

function Tfrm_PrinterPP00.ValidInput: Boolean;
begin
    Result :=True;
    if cbx_Modelo.ItemIndex < 0 then
    begin
        CMsgDlg.Warning('O modelo da impressora deve ser informado!');
        cbx_Modelo.SetFocus ;
        Result :=False;
    end
    else
      if cbx_NPorta.ItemIndex < 0 then
      begin
          CMsgDlg.Warning('A porta deve ser informada!');
          cbx_NPorta.SetFocus ;
      end
      else
        if(Trim(cbx_Host.Text)='')and(cbx_NPorta.ItemIndex in[IND_REMOTE_COMP,IND_REMOTE_TCP])then
        begin
            if cbx_NPorta.ItemIndex = IND_REMOTE_COMP then
                CMsgDlg.Warning('O compartilhamento deve ser informado!');
            if cbx_NPorta.ItemIndex = IND_REMOTE_TCP  then
                CMsgDlg.Warning('O TCP/IP deve ser informado!');
                cbx_Host.SetFocus ;
        end;
end;

end.
