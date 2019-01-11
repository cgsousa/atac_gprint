unit Form.Etiqueta;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask,
  Generics.Collections,
  FormBase,

  JvExStdCtrls, JvButton, JvCtrls, JvFooter, JvExExtCtrls, JvExtComponent,
  JvExControls, JvGradient, AdvGroupBox, AdvSpin, AdvOfficeButtons, AdvCombo,

  RpDefine, RpBase,
  uravecodbase;


type
//    edt_EtqW.FloatValue :=10.5;
//    edt_EtqH.FloatValue :=5.8;

  TCReportEtqItem = class
  private
  public
    codpro: Integer;
    descri: string;
    codbar: string;
    unidad: string;
    vlunit: Currency;
    coddetgrade: Integer;
    grade1: string;
    grade2: string;
    qts: Integer;
    pcomin: Currency;
    qtsata: Integer;
  end;
                   //ett3X33X22
  TCReportEtqTyp = (ett105X58mm, ett111X22mm, ett110X30mm, ett30X15mm, ett90X30mm) ;
  TCReportEtq = class(TCReportBase)
  private
    _items: TList<TCReportEtqItem>;
    _labelW, _labelH: Double ;
    _pagerows, _pagecols: Integer;
    _space: Double;
    _logo: TBitmap;
    _etqtyp: TCReportEtqTyp;
    _rotation: Integer ;
    procedure DoPrintEtq01() ;
  protected
//    procedure DoInit(Sender: TObject); override;
    procedure DoPrint(Sender: TObject); override;
  public
    property Items: TList<TCReportEtqItem> read _items;

//    property LabelW: Double read _labelW write _labelW;
//    property LabelH: Double read _labelH write _labelH;
    property PageRows: Integer read _pagerows write _pagerows;
    property PageCols: Integer read _pagecols write _pagecols;
//    property Space: Double read _space write _space ;

    constructor Create (AEtqtyp: TCReportEtqTyp); reintroduce ;
    destructor Destroy; override ;
    function AddItem(): TCReportEtqItem;
    procedure Load();
    procedure setPage(const aW, aH, aSpace, aLimit: Double;
      const aRotation: Integer =0) ;
  end;

type
  Tfrm_ConfigEtq = class(TBaseForm)
    pnl_Footer: TJvFooter;
    btn_Close: TJvFooterBtn;
    gbx_Etq: TAdvGroupBox;
    edt_MLeft: TAdvSpinEdit;
    edt_MTop: TAdvSpinEdit;
    edt_EtqW: TAdvSpinEdit;
    edt_EtqH: TAdvSpinEdit;
    edt_PagRows: TAdvSpinEdit;
    edt_PagCols: TAdvSpinEdit;
    gbx_Opt: TAdvGroupBox;
    cbx_Printers: TAdvComboBox;
    cbx_Forms: TAdvComboBox;
    rg_Orient: TAdvOfficeRadioGroup;
    btn_Print: TJvFooterBtn;
    edt_Space: TAdvSpinEdit;
    cbx_Layout: TAdvComboBox;
    edt_PageW: TAdvSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure btn_PrintClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);
    procedure cbx_PrintersSelect(Sender: TObject);
    procedure cbx_LayoutSelect(Sender: TObject);
  private
    { Private declarations }
    _layout: Integer;
  public
    { Public declarations }
    procedure DoResetForm; override ;
    class procedure DoShow(const Layout: Integer);
  end;


implementation

{$R *.dfm}

uses uadodb, uTaskDlg ,
  RpDevice, RpMemo, rpBars,
  ACBrUtil
//  ,RLPrinters, Form.BaseEtqRL
  ;


{ TCReportEtq }

function TCReportEtq.AddItem: TCReportEtqItem;
begin
    Result :=TCReportEtqItem.Create ;
    Items.Add(Result) ;
end;

constructor TCReportEtq.Create(AEtqtyp: TCReportEtqTyp);
begin
    inherited Create(poPortrait);
    _items :=TList<TCReportEtqItem>.Create ;
    _etqtyp:=AEtqtyp ;
end;

destructor TCReportEtq.Destroy;
begin
    _items.Destroy ;
    if Assigned(_logo)then
    begin
        _logo.Destroy;
    end;
    inherited;
end;

procedure TCReportEtq.DoPrint(Sender: TObject);
const
  BAR_WIDE_FACTOR = 2;
  BAR_HEIGHT = 0.70 ;
  BAR_WIDTH = 0.030;
var
  Item: TCReportEtqItem ;

var
  EtqImpress: Integer;
  LinImpress: Integer;
  Row, Col: Double;
  Factor,W: Double ;
var
  M: TMemoBuf;
  B: TRPBarsBase ;
  C: Integer;
var
  codbar: string ;
  //
  procedure PrintEtq01();
  begin
      //
      // linha #1, logo
      if _logo <> nil then
      begin
          Report.PrintBitmapRect(Col, Row, Col +3.0, Row +2.5*Report.LineHeight, _logo);
          Report.YPos :=Report.YPos +3.5*Report.LineHeight;
      end;

      //
      // linha #2, descricao com quebra
      if Report.TextWidth(Item.descri) < W then
      begin
          Report.PrintLeft(Item.descri, Col);
          Report.NewLine;
      end
      else begin
          M :=TMemoBuf.Create;
          try
            M.BaseReport  :=Self.Report;
            M.Text        :=Item.descri;
            M.Justify     :=pjLeft;
            M.PrintStart  :=Col;
            M.PrintEnd    :=Col +W;
            M.PrintHeight(2 *Report.LineHeight, False);
          finally
            M.Free;
          end;
          Report.YPos :=Report.YPos -Report.LineHeight;
      end;

      //
      // linha #3, codbar 01
      Report.YPos :=Report.YPos +Report.LineHeight/4;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      //
      // linha #4, codbar 02
      Report.SetFont(FONT_ARIAL, 8); Report.AdjustLine;
      Report.YPos :=Report.SectionBottom -Report.LineHeight;
      B.PrintReadable:=False;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      //
      // linha #5, preco
      Report.SetFont(FONT_ARIAL, 10); Report.AdjustLine;
      Report.YPos :=Report.YPos +2.75*Report.LineHeight;
      Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);
  end;
  //
  procedure PrintEtq02();
  begin
      //etq. linha 01, xFant
      Report.PrintLeft(Empresa.xFant, Col);
      Report.NewLine;

      //etq. linha 02, descricao
      if Report.TextWidth(Item.descri) < W then
      begin
          Report.PrintLeft(Item.descri, Col);
          //Report.NewLine;
      end
      else begin
          M :=TMemoBuf.Create;
          try
            M.BaseReport  :=Self.Report;
            M.Text        :=Item.descri;
            M.Justify     :=pjLeft;
            M.PrintStart  :=Col;
            M.PrintEnd    :=Col +W;
            M.PrintHeight(2 *Report.LineHeight, False);
          finally
            M.Free;
          end;
          Report.YPos :=Report.YPos -Report.LineHeight;
      end;

      //etq.linha 03, cod.barras.01
      Report.YPos :=Report.YPos +Report.LineHeight/2;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      //etq.linha 04, preco
      Report.YPos :=Report.YPos +Report.LineHeight;
      Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);
  end;
  //

  procedure PrintEtq05();
  begin
      //etq. linha 01, xFant
      //Report.PrintLeft(Empresa.xFant, Col);
      //Report.NewLine;

      //etq. linha 02, descricao
      if Report.TextWidth(Item.descri) < W then
      begin
          Report.PrintLeft(Item.descri, Col);
          //Report.NewLine;
      end
      else begin
          M :=TMemoBuf.Create;
          try
            M.BaseReport  :=Self.Report;
            M.Text        :=Item.descri;
            M.Justify     :=pjLeft;
            M.PrintStart  :=Col;
            M.PrintEnd    :=Col +W;
            M.PrintHeight(2 *Report.LineHeight, False);
          finally
            M.Free;
          end;
          Report.YPos :=Report.YPos -Report.LineHeight;
      end;

      //etq.linha 03, cod.barras.01
      Report.YPos :=Report.YPos +Report.LineHeight/2;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      //etq.linha 04, preco
      Report.YPos :=Report.YPos +Report.LineHeight;
      Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);
  end;

  procedure PrintEtq04();
  begin
      //etq. linha 01, xFant
      //Report.PrintLeft(Empresa.xFant, Col);
      //Report.NewLine;

      //etq. linha 02, descricao
      if Report.TextWidth(Item.descri) < W then
      begin
          Report.PrintLeft(Item.descri, Col);
          //Report.NewLine;
      end
      else begin
          M :=TMemoBuf.Create;
          try
            M.BaseReport  :=Self.Report;
            M.Text        :=Item.descri;
            M.Justify     :=pjLeft;
            M.PrintStart  :=Col;
            M.PrintEnd    :=Col +W;
            M.PrintHeight(2 *Report.LineHeight, False);
          finally
            M.Free;
          end;
          Report.YPos :=Report.YPos -Report.LineHeight;
      end;

      //etq.linha 03, cod.barras.01
      Report.YPos :=Report.YPos +Report.LineHeight/2;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      //etq.linha 04, preco
      Report.YPos :=Report.YPos +Report.LineHeight;
      Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);
  end;
  //
  procedure PrintEtq03();
  var
    X,Y: Double;
  begin
      //etq. linha 01, Descri
      Report.SetFont(FONT_ARIAL, 12); Report.AdjustLine;
      Report.PrintLeft(Item.descri, Col);

      Report.SetFont(FONT_ARIAL, 10); Report.AdjustLine;
      Report.NewLine;Report.NewLine;  Y :=Report.YPos +2.5*Report.LineHeight ;
      if Item.qtsata > 0 then
        Report.PrintLeft(
        Format('ATACADO %7.2m ACIMA DE %d%s',[Item.pcomin,Item.qtsata,Item.unidad]),
        Col)
      else
        Report.PrintLeft('', Col);

      //etq.linha 03, cod.barras.01
      Report.YPos :=Report.YPos +Report.LineHeight/4;
      B.Text :=codbar ;
      B.PrintXY(Col, Report.YPos);

      Report.SetFont(FONT_ARIAL, 32); Report.AdjustLine;
      Report.PrintXY(5.00, Y, Format('%7.2m',[Item.vlunit]));
  end;
  //
begin

    Report.FontRotation :=_rotation ;
    Report.Bold :=True;

    case _etqtyp of
        ett105X58mm:
        begin
            Report.LinesPerInch :=7;
        end;
        ett111X22mm:
        begin
            Report.LinesPerInch :=8;
        end;
        ett110X30mm:
        begin
            //Report.LinesPerInch :=8;
        end;
        ett30X15mm:
        begin
            Report.LinesPerInch :=10;
        end;
        ett90X30mm:
        begin
            Report.LinesPerInch :=10;
        end;
    end;

    EtqImpress :=0;
    LinImpress :=0;

    W :=_labelW; // Self.PaperW /Self.PageCols ;

    for Item in Self.Items do
    begin

        if Length(Item.codbar) >= 8 then
        begin
            codbar :=Item.codbar ;
            B :=TRPBarsEAN.Create(Report) ;
        end
        else begin
            if Length(Item.codbar) <= 5 then
            begin
            codbar :=PadLeft(Item.codbar, 5, '0') ;
            if TryStrToInt(codbar,c) then
            B :=TRPBars2of5.Create(Report) else
            B :=TRPBarsCode128.Create(Report) ;
            end else
            begin
            codbar :=PadLeft(Item.codbar, 7, '0') ;
            if TryStrToInt(codbar,c) then
            B :=TRPBars2of5.Create(Report) else
            B :=TRPBarsCode128.Create(Report) ;
            end;
        end;


        B.WideFactor:=BAR_WIDE_FACTOR;
        B.BarHeight :=BAR_HEIGHT;
        B.BarWidth  :=BAR_WIDTH;
        B.PrintReadable:=True;
        B.PrintChecksum:=False;
        B.TextJustify  :=pjCenter;
        //
        //calc. o fator
        //
        Factor :=EtqImpress mod Self.PageCols ;
        if Factor > 0 then
        begin
            if Factor > 1 then
                Col :=(Factor     *W) +(Factor *Self._space) +Self.MarginLeft
            else
                Col :=(Factor     *W) +Self._space +Self.MarginLeft;
        end
        else
            Col :=(Factor     *W) +Self.MarginLeft;
        Row :=(LinImpress *Self.PaperH) +Self.MarginTop ;
        Report.GotoXY(Col, Row);

        case _etqtyp of
            ett105X58mm:
            begin
                Report.SetFont(FONT_ARIAL, 8); Report.AdjustLine;
                PrintEtq01 ;
            end;

            ett111X22mm:
            begin
                B.BarHeight :=0.50;
                Report.SetFont(FONT_ARIAL, 7); Report.AdjustLine;
                PrintEtq02;
            end;

            ett110X30mm:
            begin
                B.BarHeight :=0.50;
                //Report.SetFont(FONT_ARIAL, 7); Report.AdjustLine;
                PrintEtq03;
            end;

            ett30X15mm:
            begin
                B.BarHeight :=0.40;
                Report.SetFont(FONT_ARIAL, 7); Report.AdjustLine;
                PrintEtq04;
            end;
            ett90X30mm:
            begin
                B.BarHeight :=0.30;
                Report.SetFont(FONT_ARIAL, 7); Report.AdjustLine;
                PrintEtq05;
            end;
        end;

        B.Free ;

        Inc(EtqImpress);
        if Factor = (Self.PageCols -1) then
        begin
            Inc(LinImpress);
        end;

        if LinImpress >= Self.PageRows then
        begin
            LinImpress :=0;
            if Items.IndexOf(Item) < Items.Count -1 then
            begin
                Report.NewPage;
            end;
        end;

    end;

end;


procedure TCReportEtq.DoPrintEtq01() ;
const
  BAR_WIDE_FACTOR = 0;
  BAR_HEIGHT = 0.70 ;
  BAR_WIDTH = 0.030;
var
  Item: TCReportEtqItem ;

var
  EtqImpress: Integer;
  LinImpress: Integer;
  Row, Col: Double;
  Factor,W: Double ;
var
  M: TMemoBuf;
  B: TRPBarsBase ;
var
  codbar: string ;
begin

    Report.Bold :=True;

    EtqImpress :=0;
    LinImpress :=0;
    W :=Self.PaperW /Self.PageCols ;

    for Item in Self.Items do
    begin

        if Length(Item.codbar) >= 8 then
        begin
            codbar :=Item.codbar ;
            B :=TRPBarsEAN.Create(Report) ;
        end
        else begin
            codbar :=PadLeft(Item.codbar, 7, '0') ;
            B :=TRPBarsCode128.Create(Report) ;
        end;

        B.WideFactor:=BAR_WIDE_FACTOR;
        B.BarHeight :=BAR_HEIGHT;
        B.BarWidth  :=BAR_WIDTH;
        B.PrintReadable:=True;
        B.PrintChecksum:=False;
        B.TextJustify  :=pjCenter;

        //calcs
        Factor :=EtqImpress mod Self.PageCols ;
        Col :=(Factor     *W) +Self.MarginLeft;
        Row :=(LinImpress *Self.PaperH) +Self.MarginTop ;
        Report.GotoXY(Col, Row);

        Report.SetFont(FONT_ARIAL, 8); Report.AdjustLine;



        //etq. linha 01, logo
        if _logo <> nil then
        begin
            Report.PrintBitmapRect(Col, Row, Col +3.0, Row +2.5*Report.LineHeight, _logo);
            Report.YPos :=Report.YPos +3.5*Report.LineHeight;
        end;

        //etq. linha 02, descricao
        if Report.TextWidth(Item.descri) < W then
        begin
            Report.PrintLeft(Item.descri, Col);
            Report.NewLine;
        end
        else begin
            M :=TMemoBuf.Create;
            try
              M.BaseReport  :=Self.Report;
              M.Text        :=Item.descri;
              M.Justify     :=pjLeft;
              M.PrintStart  :=Col;
              M.PrintEnd    :=Col +W;
              M.PrintHeight(2 *Report.LineHeight, False);
            finally
              M.Free;
            end;
            Report.YPos :=Report.YPos -Report.LineHeight;
        end;

        //etq.linha 03, cod.barras.01
        Report.YPos :=Report.YPos +Report.LineHeight/4;
        B.Text :=codbar ;
        B.PrintXY(Col, Report.YPos);

        //etq.linha 04, preco
        Report.SetFont(FONT_ARIAL, 10); Report.AdjustLine;
        Report.YPos :=Report.YPos +1.5*Report.LineHeight;
        Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);

        //etq 02. linha 05, cod.barras
        Report.SetFont(FONT_ARIAL, 8); Report.AdjustLine;
        Report.YPos :=Report.SectionBottom +Report.LineHeight;
        B.PrintReadable:=False;
        B.Text :=codbar ;
        B.PrintXY(Col, Report.YPos);

        B.Free ;

        //etq 02. linha 06, preco
        Report.SetFont(FONT_ARIAL, 10); Report.AdjustLine;
        Report.YPos :=Report.YPos +2.75*Report.LineHeight;
        Report.PrintLeft(Format('%12.2m',[Item.vlunit]), Col);

        Inc(EtqImpress);
        if Factor = (Self.PageCols -1) then
        begin
            Inc(LinImpress);
        end;

        if LinImpress >= Self.PageRows then
        begin
            LinImpress :=0;
            Report.NewPage;
        end;

    end;

end;

procedure TCReportEtq.Load;
var
  Q: TADOQuery ;
  I: TCReportEtqItem ;
var
  codpro: Integer;
  codbar: string;
  C,qtd: Integer ;
begin

    //
    Self.Items.Clear ;
    //
    Q :=TADOQuery.NewADOQuery();
    try

        Q.AddCmd('select                                                ');
        Q.AddCmd('  p.codproduto as pro_codigo,p.codbarra as pro_codbar,');
        Q.AddCmd('  p.nome as pro_descri,p.unidade as pro_unidad,       ');
        Q.AddCmd('  p.precovenda as pro_vlunit,p.precominimo as pcomin, ');
        Q.AddCmd('  p.qtsatacado as qtsata,                             ');
        Q.AddCmd('  dg.coddetalhegrade as coddetgrade,                  ');
        Q.AddCmd('  g1.Descricao Grade1,g2.Descricao Grade2,            ');
        Q.AddCmd('  e.quantidade as qts                                 ');
        Q.AddCmd('from etiqueta e                                       ');
        Q.AddCmd('left join detalhegrade dg on dg.coddetalhegrade=e.coddetalhegrade');
        Q.AddCmd('inner join produto p on p.codproduto=e.codproduto ');
        Q.AddCmd('left join grade1 g1 on g1.codgrade=dg.codgrade1   ');
        Q.AddCmd('left join grade2 g2 on g2.codgrade=dg.codgrade2   ');
        Q.AddCmd('order by e.codetiqueta desc                       ');

        Q.Open ;

        C :=0;
        while not Q.Eof do
        begin
            codpro :=Q.Field('pro_codigo').AsInteger;
            codbar :=Trim(Q.Field('pro_codbar').AsString);
            qtd :=Q.Field('qts').AsInteger;

            for  C :=1 to qtd do
            begin

                I :=Self.AddItem ;
                I.codpro :=Q.Field('pro_codigo').AsInteger;
                I.descri :=Q.Field('pro_descri').AsString;
                I.codbar :=Q.Field('pro_codbar').AsString;
                I.unidad :=Q.Field('pro_unidad').AsString;
                I.vlunit :=Q.Field('pro_vlunit').AsCurrency;

                if (Length(I.codbar)<7) and (not Q.Field('coddetgrade').IsNull) then
                begin
                    I.coddetgrade:=Q.Field('coddetgrade').AsInteger;
                    I.grade1:=Q.Field('grade1').AsString;
                    I.grade2:=Q.Field('grade2').AsString;
                end;
                I.qts:=Q.Field('qts').AsInteger;
                I.pcomin:=Q.Field('pcomin').AsCurrency;

                if Q.Field('qtsata').AsString <> '' then
                    I.qtsata:=Q.Field('qtsata').AsInteger;

                if (Length(I.codbar)<7) and (i.coddetgrade>0) then
                begin
                    codpro :=StrToIntDef(codbar,0);
                    I.codbar :=Format('1%.6d%.5d',[codpro,I.coddetgrade]);
                    I.descri :=Format('%s %s %s',[I.descri,I.grade1,I.grade2]);
                end;

            end;

            Q.Next ;
        end;

    finally
        Q.Free ;
    end;

    //logo
    if Empresa.Logo <> nil then
    begin
        Empresa.Logo.Position :=0;
        _logo :=TBitmap.Create ;
        _logo.LoadFromStream(Empresa.Logo);
    end
    else
        _logo :=nil;
end;

procedure TCReportEtq.setPage(const aW, aH, aSpace, aLimit: Double;
  const aRotation: Integer);
begin
    _labelW :=aW ;
    _labelH :=aH ;
    _space  :=aSpace ;
    if aLimit > 0 then
        _paperW :=aLimit
    else
        _paperW :=(_pagecols *aW) +(_pagecols -1) *aSpace ;
    _paperH :=_labelH ;
    _rotation :=aRotation ;
end;

{ Tfrm_ConfigEtq }

procedure Tfrm_ConfigEtq.btn_CloseClick(Sender: TObject);
begin
    Self.Close ;

end;

procedure Tfrm_ConfigEtq.btn_PrintClick(Sender: TObject);
var
  E: TCReportEtq;
  angle: Integer ;
//  lst: TCLabelList;
//  ptr: TRLPrinterWrapper;
//  sv: TLabelStyleView;
begin

    {ptr :=RLPrinter ;
    ptr.PrinterName :=cbx_Printers.Text ;
    //ptr.SetPaperSize();

    case cbx_Layout.ItemIndex of
        0: sv :=sv3X35X58;
        1: sv :=sv3X35X58;
        2: sv :=sv1X100X30;
    end;

    lst :=TCLabelList.Create ;
    try
        lst.Load ;
        if lst.Count > 0 then
        begin
            Tfrm_BaseETQ.DoExec(lst, sv,
                                edt_MLeft.FloatValue, edt_MTop.FloatValue,
                                edt_PagCols.Value ,
                                edt_EtqW.FloatValue, edt_Space.FloatValue );
        end;
    finally
        lst.Free ;
    end;
    exit;}

    angle :=0;

    if not RPDev.SelectPrinter(cbx_Printers.Text, False) then
    begin
        CMsgDlg.Warning(Format('Não foi possível selecionar impressora "%s"!',[cbx_Printers.Text])) ;
    end;

    if not RPDev.SelectPaper(cbx_Forms.Text, False) then
    begin
        CMsgDlg.Warning(Format('Impressora não suporta papel "%s"!',[cbx_Forms.Text])) ;
    end;

    case cbx_Layout.ItemIndex of
        0: E :=TCReportEtq.Create(ett105X58mm);
        1: E :=TCReportEtq.Create(ett111X22mm);
        2: E :=TCReportEtq.Create(ett110X30mm);
        3: E :=TCReportEtq.Create(ett30X15mm);
        4: E :=TCReportEtq.Create(ett90X30mm);
    end;

    {E.SetMargins(unCM, 2.54,
                  edt_MLeft.FloatValue, edt_MTop.FloatValue,
                  edt_MLeft.FloatValue, edt_MTop.FloatValue);

    E.SetPaperSize(0,
                  (10.0, //edt_EtqW.FloatValue
                  edt_EtqH.FloatValue);
    }

    if rg_Orient.ItemIndex in[2,3] then
        angle :=180
    else
        angle :=0;

    E.MarginLeft:=edt_MLeft.FloatValue;
    E.MarginTop :=edt_MTop.FloatValue ;
    E.PageRows :=edt_PagRows.Value ;
    E.PageCols :=edt_PagCols.Value ;

    E.setPage(edt_EtqW.FloatValue, edt_EtqH.FloatValue,
              edt_Space.FloatValue, edt_PageW.FloatValue,
              angle);

    E.Load ;

    if E.Items.Count > 0 then
    begin
        E.DoExec();
    end;

end;

procedure Tfrm_ConfigEtq.cbx_LayoutSelect(Sender: TObject);
begin
    case cbx_Layout.ItemIndex of
        0://3 x 1(105mm x 58mm)
        begin
            edt_MLeft.FloatValue:=0.25;
            edt_MTop.FloatValue :=0.75;
            edt_Space.FloatValue:=0.25;

            edt_EtqW.FloatValue :=3.33;
            edt_EtqH.FloatValue :=5.8;

            edt_PagRows.FloatValue :=1;
            edt_PagCols.FloatValue :=3;

        end;
        1://3 x 1(111mm x 22mm)
        begin
            edt_MLeft.FloatValue:=0.50;
            edt_MTop.FloatValue :=0.50;
            edt_Space.FloatValue:=0.30;

            edt_EtqW.FloatValue :=3.30;
            edt_EtqH.FloatValue :=2.20;

            edt_PagRows.FloatValue :=1;
            edt_PagCols.FloatValue :=3;

        end;
        2://1 x 1(110mm x 30mm)
        begin
            edt_MLeft.FloatValue:=1.0;
            edt_MTop.FloatValue :=0.75;
            edt_Space.FloatValue:=0.0;

            edt_EtqW.FloatValue :=10.0;
            edt_EtqH.FloatValue :=3.0;

            edt_PagRows.FloatValue :=1;
            edt_PagCols.FloatValue :=1;
        end;
        3://3 x 1(30mm x 15mm)
        begin
            edt_MLeft.FloatValue:=0.20;
            edt_MTop.FloatValue :=0.25;
            edt_Space.FloatValue:=0.10;

            edt_EtqW.FloatValue :=3.00;
            edt_EtqH.FloatValue :=1.5;

            edt_PagRows.FloatValue :=1;
            edt_PagCols.FloatValue :=3;

        end;
        4://1 x 1(90mm x 30mm)
        begin
            edt_MLeft.FloatValue:=0.10;
            edt_MTop.FloatValue :=0.25;
            edt_Space.FloatValue:=0;

            edt_EtqW.FloatValue :=7.5;
            edt_EtqH.FloatValue :=1.3;

            edt_PagRows.FloatValue :=1;
            edt_PagCols.FloatValue :=1;

        end;
    end;
end;

procedure Tfrm_ConfigEtq.cbx_PrintersSelect(Sender: TObject);
begin
    if RPDev.SelectPrinter(cbx_Printers.Text, True) then
    begin
        cbx_Forms.Items.Clear ;
        cbx_Forms.Items.Assign(RPDev.Papers);
        cbx_Forms.ItemIndex :=0;
    end;
end;

procedure Tfrm_ConfigEtq.DoResetForm;
begin
    DoClear(Self);

    //etq
//    edt_MLeft.FloatValue:=0.25;
//    edt_MTop.FloatValue :=0.75;
//    edt_MRight.FloatValue:=0;
//    edt_MBottom.FloatValue:=1.50;
//
//    edt_EtqW.FloatValue :=10.5;
//    edt_EtqH.FloatValue :=5.8;

    edt_PagRows.Value  :=1;
    edt_PagCols.Value  :=3;
    cbx_Layout.ItemIndex :=0;
    cbx_LayoutSelect(cbx_Layout);

    //opt
    cbx_Printers.Items.Assign(RPDev.Printers);
    cbx_Printers.ItemIndex :=cbx_Printers.Items.IndexOf(RPDev.Device);
    cbx_PrintersSelect(cbx_Printers);

    //cbx_Forms.Items.Assign(RPDev.Papers);
    cbx_Layout.ItemIndex :=_layout;
    cbx_LayoutSelect(cbx_Layout);

end;

class procedure Tfrm_ConfigEtq.DoShow(const Layout: Integer);
var
    F: Tfrm_ConfigEtq;
begin
    F :=Tfrm_ConfigEtq.Create(Application);
    try
        F._layout :=Layout;
        F.ShowModal ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_ConfigEtq.FormShow(Sender: TObject);
begin
    DoResetForm
    ;
end;


end.
