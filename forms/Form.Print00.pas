unit Form.Print00;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  JvExStdCtrls, JvButton, JvCtrls, JvFooter, ExtCtrls,
  JvExExtCtrls, JvExtComponent,
  JvExControls, JvGradient,
  AdvGroupBox, AdvEdit, AdvCombo, AdvOfficeButtons,
  FormBase, uprinter,
  ACBrBase, ACBrPosPrinter;

type
  Tfrm_Print00 = class(TBaseForm)
    pnl_Footer: TJvFooter;
    btn_Close: TJvFooterBtn;
    btn_Apply: TJvFooterBtn;
    JvGradient1: TJvGradient;
    gbx_Active: TAdvGroupBox;
    cbx_Modelo: TAdvComboBox;
    cbx_NPorta: TAdvComboBox;
    cbx_Avanc: TAdvComboBox;
    cbx_Tenta: TAdvComboBox;
    cbx_Corte: TAdvComboBox;
    chk_Check: TAdvOfficeCheckBox;
    chk_Expand: TAdvOfficeCheckBox;
    edt_Host: TAdvEdit;
    btn_Print: TJvFooterBtn;
    cbx_DefCol: TAdvComboBox;
    ACBrPosPrinter1: TACBrPosPrinter;
    edt_Descri: TAdvEdit;
    procedure btn_CloseClick(Sender: TObject);
    procedure btn_ApplyClick(Sender: TObject);
    procedure gbx_ActiveCheckBoxClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbx_NPortaSelect(Sender: TObject);
    procedure btn_PrintClick(Sender: TObject);
  private
    { Private declarations }
    p00: TCPrinter00 ;
  public
    { Public declarations }
    procedure DoResetForm(); override ;
    class function Execute(APrinter: TCPrinter00): Boolean ;
  end;


implementation

{$R *.dfm}

uses StrUtils, TypInfo, Printers, DB,
  uTaskDlg, uadodb ;


{ Tfrm_Print00 }

procedure Tfrm_Print00.btn_ApplyClick(Sender: TObject);
begin
    if edt_Descri.IsEmpty() then
    begin
        CMsgDlg.Warning('O modelo da impressora deve ser informado!');
        edt_Descri.SetFocus ;
        Exit ;
    end;

    if cbx_Modelo.ItemIndex < 0 then
    begin
        CMsgDlg.Warning('O modo de impressão deve ser informado!');
        cbx_Modelo.SetFocus ;
        Exit ;
    end ;

    if cbx_DefCol.ItemIndex < 0 then
    begin
        CMsgDlg.Warning('O numero de colunas deve ser informado!');
        cbx_DefCol.SetFocus ;
        Exit ;
    end ;


    p00.pr0_modelo :=cbx_Modelo.Text ;
//    p00.pr0_nporta :=cbx_NPorta.Text ;
//    p00.pr0_xhost :=edt_Host.Text ;
    p00.pr0_descri:=edt_Descri.Text ;
    p00.pr0_avanco:=StrToIntDef(cbx_Avanc.Text, 0);
//    p00.pr0_tenttv:=StrToIntDef(cbx_Tenta.Text, 0);
    p00.pr0_defcol:=StrToIntDef(cbx_DefCol.Text, 0);
    p00.pr0_corte :=cbx_Corte.ItemIndex = 0;
    p00.pr0_checki :=chk_Check.Checked;
    p00.pr0_expand :=chk_Expand.Checked;

    try
        p00.DoMerge ;
        CMsgDlg.Info('Dados da impressora gravados com sucesso.');
        ModalResult :=mrOk;
    except
        on E:EDatabaseError do
        begin
            CMsgDlg.Info('Erro ao gravar dados da impressora! %s.',[E.Message]);
        end;
    end;
end;

procedure Tfrm_Print00.btn_CloseClick(Sender: TObject);
begin
    Self.Close ;

end;

procedure Tfrm_Print00.btn_PrintClick(Sender: TObject);
var
  S:  TStringWriter;
begin
    S :=TStringWriter.Create();
    try
        S.WriteLine(Empresa.xFant);
        S.WriteLine('Ped.: 999999        Data/Hora: 26/09/2017 09:30');
        S.WriteLine('Mesa: 999           Atend.: LOGIN              ');
        S.WriteLine('***********************************************');
        S.WriteLine('PONTO DE IMPRESSÃO                             ');
        S.WriteLine('-----------------------------------------------');
        S.WriteLine('Codigo  Descrição                              ');
        S.WriteLine('-----------------------------------------------');
        S.WriteLine('1       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
        S.WriteLine('        Qtde: 1                                ');
        S.WriteLine('Obs:    OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
        S.WriteLine('-----------------------------------------------');
        p00.DoPrint(S.ToString);
    finally
        S.Free;
    end;
end;

procedure Tfrm_Print00.cbx_NPortaSelect(Sender: TObject);
begin
//    case True of
//    end;
end;

procedure Tfrm_Print00.DoResetForm;
var
  M: TACBrPosPrinterModelo;
  I: Integer;
begin
    //
    DoClear(Self);
    //
    for M :=Low(TACBrPosPrinterModelo) to High(TACBrPosPrinterModelo) do
    begin
        cbx_Modelo.Items.Add(
                  GetEnumName(TypeInfo(TACBrPosPrinterModelo), Integer(M))
                  ) ;
    end;

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
    cbx_NPorta.Items.Add('Compartilhamento');
    cbx_NPorta.Items.Add('TCP');


    if Assigned(p00) then
    begin
        Self.Caption :=Format('[Id:%.2d]-%s',[p00.pr0_codseq,p00.pr0_modelo]);
        cbx_Modelo.ItemIndex:=cbx_Modelo.Items.IndexOf(p00.pr0_modelo) ;
        //cbx_Modelo.Enabled :=False;
        cbx_NPorta.ItemIndex:=cbx_NPorta.Items.IndexOf(p00.pr0_nporta) ;
        if cbx_NPorta.ItemIndex < 0 then
        begin
            cbx_NPorta.Items.Add(p00.pr0_nporta) ;
        end;
        cbx_NPorta.ItemIndex:=cbx_NPorta.Items.IndexOf(p00.pr0_nporta) ;
        edt_Host.Text       :=p00.pr0_xhost ;
        edt_Descri.Text     :=p00.pr0_descri;
        cbx_Avanc.ItemIndex :=cbx_Avanc.Items.IndexOf(IntToStr(p00.pr0_avanco));
        cbx_Tenta.ItemIndex :=cbx_Tenta.Items.IndexOf(IntToStr(p00.pr0_tenttv));
        cbx_DefCol.ItemIndex :=cbx_DefCol.Items.IndexOf(IntToStr(p00.pr0_defcol));
        if p00.pr0_corte then cbx_Corte.ItemIndex :=0
        else                  cbx_Corte.ItemIndex :=1;
        chk_Check.Checked :=p00.pr0_checki;
        chk_Expand.Checked:=p00.pr0_expand;
        gbx_Active.CheckBox.Checked :=p00.pr0_active ;
        //gbx_Active.Caption :=ifthen(p00.pr0_active, '', '');
        ActiveControl :=edt_Descri;
    end
    else begin
        Self.Caption :='Nova impressora';
        gbx_Active.CheckBox.Visible :=False;
        gbx_Active.Enabled:=True;
        gbx_Active.Caption :='Impressora padrão';
        btn_Print.Enabled :=False;
        p00 :=TCPrinter00.Create ;
        cbx_DefCol.ItemIndex :=0;
        ActiveControl :=cbx_Modelo;
    end;
    btn_Apply.Enabled :=False ;
end;

class function Tfrm_Print00.Execute(APrinter: TCPrinter00): Boolean;
var
  F: Tfrm_Print00;
begin
    F :=Tfrm_Print00.Create(Application);
    try
        F.p00 :=APrinter ;
        Result:=F.ShowModal = mrOk ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_Print00.FormShow(Sender: TObject);
begin
    DoResetForm ;

end;

procedure Tfrm_Print00.gbx_ActiveCheckBoxClick(Sender: TObject);
begin
    btn_Apply.Enabled :=True ;
    gbx_Active.Caption:=ifthen(gbx_Active.CheckBox.Checked,'Inativar','Ativar');
end;

end.
