unit Form.Print00List;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvExStdCtrls, JvButton, JvCtrls, JvFooter, ExtCtrls,
  JvExExtCtrls, JvExtComponent, VirtualTrees,
  FormBase, uVSTree, uprinter
  ;

type
  Tfrm_Print00List = class(TBaseForm)
    pnl_Footer: TJvFooter;
    btn_Close: TJvFooterBtn;
    btn_New: TJvFooterBtn;
    vst_Grid1: TVirtualStringTree;
    btn_Upd: TJvFooterBtn;
    btn_Can: TJvFooterBtn;
    btn_PPList: TJvFooterBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vst_Grid1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vst_Grid1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure btn_UpdClick(Sender: TObject);
    procedure btn_NewClick(Sender: TObject);
    procedure btn_CloseClick(Sender: TObject);

  private
    { Private declarations }
    _printers: TCPrinter00List ;
    procedure DoResetForm(); override ;
  public
    { Public declarations }
    class procedure DoShow();
  end;


implementation

{$R *.dfm}

uses StrUtils ,
  Form.Print00;


{ Tfrm_Print00List }

procedure Tfrm_Print00List.btn_CloseClick(Sender: TObject);
begin
    Self.Close
    ;
end;

procedure Tfrm_Print00List.btn_NewClick(Sender: TObject);
begin
//    Tfrm_Print00Log.DoShow ;
    if Tfrm_Print00.Execute(nil) then
    begin
        DoResetForm ;
    end;
end;

procedure Tfrm_Print00List.btn_UpdClick(Sender: TObject);
var
  N: PVirtualNode ;
  P: TCPrinter00 ;
begin
    N :=vst_Grid1.GetFirstSelected();
    if Assigned(N) then
    begin
        P :=_printers.Items[N.Index] ;
        if Tfrm_Print00.Execute(P) then
        begin
//            vst_Grid1.IndexItem :=N.Index;
//            vst_Grid1.Refresh ;
//            ActiveControl :=vst_Grid1 ;
        end;
    end;
end;

procedure Tfrm_Print00List.DoResetForm;
begin
    vst_Grid1.Clear ;
    btn_Upd.Enabled :=False;
    btn_Can.Enabled :=False;

    if _printers.Load() then
    begin
        vst_Grid1.RootNodeCount :=_printers.Count ;
        vst_Grid1.IndexItem :=0;
        ActiveControl :=vst_Grid1 ;
    end;
end;

class procedure Tfrm_Print00List.DoShow;
var
  F: Tfrm_Print00List;
begin
    F :=Tfrm_Print00List.Create(Application);
    try
        F.vst_Grid1.Clear ;
        F.ShowModal ;
    finally
        FreeAndNil(F);
    end;

end;

procedure Tfrm_Print00List.FormCreate(Sender: TObject);
begin
    _printers :=TCPrinter00List.Create ;

end;

procedure Tfrm_Print00List.FormShow(Sender: TObject);
begin
    DoResetForm;

end;

procedure Tfrm_Print00List.vst_Grid1Change(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  P: TCPrinter00 ;
begin
    if Assigned(Node) then
    begin
        P :=_printers.Items[Node.Index] ;
        if P <> nil then
        begin
            btn_Upd.Enabled :=True ;
            btn_Can.Enabled :=True ;
        end
        else begin
            btn_Upd.Enabled :=False;
            btn_Can.Enabled :=False;
        end;
    end;
end;

procedure Tfrm_Print00List.vst_Grid1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  P: TCPrinter00 ;
begin
    P :=_printers.Items[Node.Index] ;
    CellText :='';
    case Column of
        0:CellText :=IntToStr(P.pr0_codseq) ;
        1:CellText :=P.pr0_descri ;
        2:CellText :=IntToStr(P.pr0_avanco) ;
        3:CellText :=ifthen(P.pr0_checki, 'SIM', 'NÃO');
        4:CellText :=IntToStr(P.pr0_tenttv) ;
        5:CellText :=ifthen(P.pr0_expand, 'SIM', 'NÃO');
        6:CellText :=ifthen(P.pr0_corte, 'SIM', 'NÃO');
    end;
end;

end.
