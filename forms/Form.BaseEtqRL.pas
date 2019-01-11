unit Form.BaseEtqRL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Generics.Collections,
  RLReport, RLBarcode ;


type
  TCLabelItem = class
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

  TCLabelList = class (TList<TCLabelItem>)
  private
    m_Logo: TBitmap;
  public
    function AddItem(): TCLabelItem;
    procedure Load();
  end;



type
  TLabelStyleView = (sv3X35X58, sv3X24X22, sv1X100X30) ;
  Tfrm_BaseETQ = class(TForm)
    rl_BaseETQ: TRLReport;
    RLSubDetail1: TRLSubDetail;
    RLDetailGrid1: TRLDetailGrid;
    lbl_NomeFant: TRLLabel;
    txt_DescrPro: TRLMemo;
    lbl_BarCod1: TRLBarcode;
    img_Logo: TRLImage;
    RLReport1: TRLReport;
    RLSubDetail2: TRLSubDetail;
    RLDetailGrid2: TRLDetailGrid;
    RLMemo1: TRLMemo;
    pnl_Bottom: TRLPanel;
    lbl_Preco: TRLLabel;
    lbl_BarCod2: TRLBarcode;
    RLBarcode1: TRLBarcode;
    RLLabel1: TRLLabel;
    procedure rl_BaseETQBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rl_BaseETQDataRecord(Sender: TObject; RecNo, CopyNo: Integer;
      var Eof: Boolean; var RecordAction: TRLRecordAction);
    procedure RLSubDetail1DataRecord(Sender: TObject; RecNo, CopyNo: Integer;
      var Eof: Boolean; var RecordAction: TRLRecordAction);
    procedure RLDetailGrid1BeforePrint(Sender: TObject; var PrintIt: Boolean);
  private
    { Private declarations }
    m_StyleView: TLabelStyleView;
    m_PaperW, m_PaperH: Double ;
    m_Left,m_Top: Double ;
    m_ColCount: Integer ;
    m_ColWidth, m_ColSpace: Double ;
    m_LblList: TCLabelList;
    m_IndexItem: Integer;
    procedure setPage() ;
    procedure setStyleView(const aStyleView: TLabelStyleView) ;
  public
    { Public declarations }
    class procedure DoExec(aLblList: TCLabelList;
      const aStyleView: TLabelStyleView;
      const aLeft, aTop: Double;
      const aColumns: Integer ;
      const aColW, aSpace: Double) ;
  end;


implementation

{$R *.dfm}

uses StrUtils,
  ACBrUtil,
  uadodb,
  RLTypes ;

const
  PAPER_LIMIT_W =105; // largura limit do papel


{ TCLabelList }

function TCLabelList.AddItem: TCLabelItem;
begin
    Result :=TCLabelItem.Create ;
    Add(Result) ;
end;

procedure TCLabelList.Load;
var
  Q: TADOQuery ;
  I: TCLabelItem ;
var
  codpro: Integer;
  codbar: string;
  C,qtd: Integer ;
begin

    //
    Self.Clear ;
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
        m_Logo :=TBitmap.Create ;
        m_logo.LoadFromStream(Empresa.Logo);
    end
    else
        m_logo :=nil;
end;

{ Tfrm_BaseETQ }

class procedure Tfrm_BaseETQ.DoExec(aLblList: TCLabelList;
  const aStyleView: TLabelStyleView;
  const aLeft, aTop: Double;
  const aColumns: Integer ;
  const aColW, aSpace: Double);
var
  F: Tfrm_BaseETQ ;
begin
    F :=Tfrm_BaseETQ.Create(Application) ;
    try
        F.m_StyleView :=aStyleView ;
        F.m_Left:=aLeft ;
        F.m_Top :=aTop ;
        F.m_ColCount :=aColumns ;
        F.m_ColWidth :=aColW ;
        F.m_ColSpace :=aSpace;
        F.m_LblList :=aLblList ;
        F.rl_BaseETQ.PreviewModal ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_BaseETQ.RLDetailGrid1BeforePrint(Sender: TObject;
  var PrintIt: Boolean);
var
  L: TCLabelItem ;
  codbar,descri: string ;
  //
begin

    txt_DescrPro.Lines.Clear ;


    L :=m_LblList.Items[m_IndexItem] ;

    if Length(L.codbar) >= 8 then
    begin
        codbar :=L.codbar ;
        lbl_BarCod1.BarcodeType :=bcEAN13 ;
    end
    else begin
        codbar :=PadLeft(L.codbar, 8, '0') ;
        lbl_BarCod1.BarcodeType :=bcCode2OF5Interleaved ;
    end;

    case m_StyleView of
        sv3X35X58:
        begin
            //
            // format descrição
            descri :=Format(#13#10'%s'#13#10,[L.descri]) ;
        end;

        {sv3X24X22:
        begin
            lbl_DescrPro.Caption :=L.descri ;
            lbl_BarCod.Caption:=codbar ;
            lbl_Preco.Caption :=Format('%12.2m',[L.vlunit])
        end;}

        sv1X100X30:
        begin
            //
            // format descrição
            descri :=Format(#13#10'%s'#13#10,[L.descri]) ;
        end;
    end;

    lbl_NomeFant.Caption :=Empresa.xFant ;

    //
    // descrição do produto
    txt_DescrPro.Lines.Add(descri) ;

    //
    // codbar #1
    lbl_BarCod1.Caption:=codbar ;

    //
    // codbar #2
    lbl_BarCod2.BarcodeType :=lbl_BarCod1.BarcodeType ;
    lbl_BarCod2.Caption:=codbar ;

    //
    // preço
    lbl_Preco.Caption :=Format('%12.2m',[L.vlunit]) ;

end;

procedure Tfrm_BaseETQ.RLSubDetail1DataRecord(Sender: TObject; RecNo,
  CopyNo: Integer; var Eof: Boolean; var RecordAction: TRLRecordAction);
begin
    m_IndexItem :=RecNo -1 ;
    Eof := (RecNo > m_LblList.Count) ;
    RecordAction := raUseIt ;
end;

procedure Tfrm_BaseETQ.rl_BaseETQBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
    setPage();
    setStyleView(m_StyleView);
end;

procedure Tfrm_BaseETQ.rl_BaseETQDataRecord(Sender: TObject; RecNo, CopyNo: Integer;
  var Eof: Boolean; var RecordAction: TRLRecordAction);
begin
    Eof := (RecNo > 1);
    RecordAction :=raUseIt;
end;

procedure Tfrm_BaseETQ.setPage() ;
var
  ps: TRLPageSetup;
  mp: TRLMargins;
  mleft: Double ;

begin
    ps :=rl_BaseETQ.PageSetup;
    ps.Orientation:=poPortrait;
    ps.PaperSize  :=fpCustom ;
    ps.PaperWidth :=PAPER_LIMIT_W ;
    //ps.ForceEmulation :=True ;

    case m_StyleView of
        sv3X35X58: ps.PaperHeight :=58 ;
        sv3X24X22: ps.PaperHeight :=22 ;
        sv1X100X30: ps.PaperHeight :=30;
    end;

    //mleft :=((3*m_ColWidth) -PAPER_LIMIT_W)/2;

    mp :=rl_BaseETQ.Margins;
    mp.LeftMargin:=m_Left ;
    mp.TopMargin :=m_Top ;
    mp.RightMargin :=mleft;
    mp.BottomMargin:=2;
    mp.ParentControl.Print

end;

procedure Tfrm_BaseETQ.setStyleView(const aStyleView: TLabelStyleView);
begin
    case aStyleView of
        sv3X35X58:
        begin
            RLSubDetail1.Height :=198 ;
            lbl_NomeFant.Visible :=False ;
            //lbl_Preco.Visible :=False ;
        end;

        sv3X24X22:
        begin
        end;

        sv1X100X30:
        begin
            rl_BaseETQ.Font.Size :=12;
            RLSubDetail1.Height :=82 ;
            pnl_Bottom.Height :=35 ;
            lbl_BarCod2.Align :=faLeft ;
            lbl_Preco.Align :=faRight ;
            lbl_Preco.Font.Size :=32;
            //lbl_Preco.Font.Style :=[fsBold];

            img_Logo.Visible :=False ;
            lbl_NomeFant.Visible :=False;
            lbl_BarCod1.Visible :=False ;
        end;
    end;

    RLDetailGrid1.ColCount  :=m_ColCount ;
    RLDetailGrid1.ColWidth  :=m_ColWidth;
    RLDetailGrid1.ColSpacing:=m_ColSpace;
    RLDetailGrid1.Height :=RLSubDetail1.ClientHeight -10;
    rl_BaseETQ.RealignControls;
end;


end.
