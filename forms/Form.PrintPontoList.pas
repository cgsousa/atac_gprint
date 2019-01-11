unit Form.PrintPontoList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvExStdCtrls, JvButton, JvCtrls, JvFooter, ExtCtrls,
  JvExExtCtrls, JvExtComponent, VirtualTrees,
  uVSTree, uprinter
  ;


{$REGION 'TPropertyEditLink'}
type
  //function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
  // Our own edit link to implement several different node editors.
  TPropertyEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TComboBox;        // One of the property editor classes.
    FTree: TVirtualStringTree; // A back reference to the tree calling.
    FNode: PVirtualNode;       // The node being edited.
    FColumn: Integer;          // The column of the node being edited.
    FItems: TStrings;
    procedure DoSelectPrinter(Sender: TObject);
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AItems: TStrings); reintroduce;
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;
{$ENDREGION}

const
  // Helper message to decouple node change handling from edit handling.
  WM_STARTEDITING = WM_USER + 778;


type
  Tfrm_PrintPontoList = class(TForm)
    pnl_Footer: TJvFooter;
    btn_Close: TJvFooterBtn;
    btn_New: TJvFooterBtn;
    vst_Grid1: TVirtualStringTree;
    btn_Upd: TJvFooterBtn;
    btn_Can: TJvFooterBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vst_Grid1Change(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vst_Grid1GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure btn_UpdClick(Sender: TObject);
    procedure btn_NewClick(Sender: TObject);
    procedure vst_Grid1CreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure vst_Grid1Editing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vst_Grid1PaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vst_Grid1InitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vst_Grid1ColumnDblClick(Sender: TBaseVirtualTree;
      Column: TColumnIndex; Shift: TShiftState);

  private
    { Private declarations }
    _ppList: TCPrintPontoList ;
    _pList: TCPrinter00List ;
    _items: TStrings ;
    procedure DoResetForm();
    procedure WMStartEditing(var Message: TMessage); message WM_STARTEDITING;

  public
    { Public declarations }
    class function Execute(): Boolean ;
  end;


implementation

{$R *.dfm}

uses StrUtils ;

{$REGION 'TPropertyEditLink'}

  { TPropertyEditLink }

  function TPropertyEditLink.BeginEdit: Boolean;
  begin
      Result := True;
      FEdit.Show;
      FEdit.SetFocus;
  end;

  function TPropertyEditLink.CancelEdit: Boolean;
  begin
      Result :=True;
      FEdit.Hide;
  end;

  constructor TPropertyEditLink.Create(AItems: TStrings);
  begin
      FItems :=AItems ;

  end;

  destructor TPropertyEditLink.Destroy;
  begin
      //FEdit.Free; casues issue #357. Fix:
      if FEdit.HandleAllocated then
      begin
          PostMessage(FEdit.Handle, CM_RELEASE, 0, 0);
      end;
      inherited;
  end;

  procedure TPropertyEditLink.DoSelectPrinter(Sender: TObject);
  var
    P: TCPrinter00 ;
  begin
//      P :=FPrinters.Items[TComboBox(Sender).ItemIndex];
      if P <> nil then
      begin
      end;
  end;

  procedure TPropertyEditLink.EditKeyDown(Sender: TObject; var Key: Word;
    Shift: TShiftState);
  var
    CanAdvance: Boolean;

  begin
      CanAdvance :=True;

      case Key of
        VK_ESCAPE:
          begin
            Key := 0;//ESC will be handled in EditKeyUp()
          end;
        VK_RETURN:
          if CanAdvance then
          begin
            FTree.EndEditNode;
            Key := 0;
          end;

        VK_UP,
        VK_DOWN:
          begin
            // Consider special cases before finishing edit mode.
            CanAdvance := Shift = [];
            if FEdit is TComboBox then
              CanAdvance := CanAdvance and not TComboBox(FEdit).DroppedDown;

            if CanAdvance then
            begin
              // Forward the keypress to the tree. It will asynchronously change the focused node.
              PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
              Key := 0;
            end;
          end;
      end;
  end;

  procedure TPropertyEditLink.EditKeyUp(Sender: TObject; var Key: Word;
    Shift: TShiftState);
  begin
      case Key of
        VK_ESCAPE:
          begin
            FTree.CancelEditNode;
            Key := 0;
          end;//VK_ESCAPE
      end;//case
  end;

  function TPropertyEditLink.EndEdit: Boolean;
  var
    Data: PPrintPonto;
    Buffer: array[0..1024] of Char;
    S: UnicodeString;
    I: Integer;
    P: TCPrinter00;
  begin
      Result :=True;

      Data :=FTree.GetNodeData(FNode);
      S :=FEdit.Text;

      if S <> Data.pp.pr0_descri then
      begin
          I :=FItems.IndexOf(S) ;
          if I >= 0 then
          begin
              P :=TCPrinter00(FItems.Objects[I]);
              if P <> nil then
              begin
                  Data.pp.pp_codptr :=P.pr0_codseq;
                  Data.pp.pr0_descri:=P.pr0_descri;
                  Data.pp.changed :=True;
                  Data.pp.DoUpdate ;
              end;
          end;
          FTree.InvalidateNode(FNode);
      end;
      FEdit.Hide;
      FTree.SetFocus;
  end;

  function TPropertyEditLink.GetBounds: TRect;
  begin
      Result :=FEdit.BoundsRect;

  end;

  function TPropertyEditLink.PrepareEdit(Tree: TBaseVirtualTree;
    Node: PVirtualNode; Column: TColumnIndex): Boolean;
  var
    Data: PPrintPonto;
  begin
      Result :=True;
      FTree :=Tree as TVirtualStringTree;
      FNode :=Node;
      FColumn :=Column;

      // determine what edit type actually is needed
      FEdit.Free;
      FEdit:=nil;
      Data :=FTree.GetNodeData(Node);

      FEdit :=TComboBox.Create(nil);
      FEdit.Visible :=False;
      FEdit.Parent :=Tree;
      FEdit.Text :=Data.pp.pr0_descri;
      FEdit.Items.Add('');
      if Assigned(FItems) then
      begin
          FEdit.Items.Assign(FItems);
      end;
      FEdit.Style :=csDropDownList;
      FEdit.OnKeyDown := EditKeyDown;
      FEdit.OnKeyUp := EditKeyUp;
      FEdit.OnSelect:=DoSelectPrinter;
  end;

  procedure TPropertyEditLink.ProcessMessage(var Message: TMessage);
  begin
      FEdit.WindowProc(Message);
  end;

  procedure TPropertyEditLink.SetBounds(R: TRect);
  var
    Dummy: Integer;
  begin
      // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
      // we have to set the edit's width explicitly to the width of the column.
      FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
      FEdit.BoundsRect := R;
  end;
{$ENDREGION}


{ Tfrm_Print00List }

procedure Tfrm_PrintPontoList.btn_NewClick(Sender: TObject);
begin
//    if Tfrm_Print00.Execute(nil) then
//    begin
//        DoResetForm ;
//    end;
end;

procedure Tfrm_PrintPontoList.btn_UpdClick(Sender: TObject);
//var
//  N: PVirtualNode ;
//  P: TCPrinter00 ;
begin
//    N :=vst_Grid1.GetFirstSelected();
//    if Assigned(N) then
//    begin
//        P :=_printers.Items[N.Index] ;
//        if Tfrm_Print00.Execute(P) then
//        begin
//            vst_Grid1.IndexItem :=N.Index;
//            vst_Grid1.Refresh ;
//            ActiveControl :=vst_Grid1 ;
//        end;
//    end;
end;

procedure Tfrm_PrintPontoList.DoResetForm;
begin
    vst_Grid1.Clear ;
    btn_Upd.Enabled :=False;
    btn_Can.Enabled :=False;

    _ppList.DoLoad ;
    if _ppList.Count > 0 then
    begin
        _pList.Load(0, _items) ;
        vst_Grid1.RootNodeCount :=_ppList.Count ;
        vst_Grid1.IndexItem :=0;
        ActiveControl :=vst_Grid1 ;
    end;
end;

class function Tfrm_PrintPontoList.Execute(): Boolean;
var
  F: Tfrm_PrintPontoList;
begin
    F :=Tfrm_PrintPontoList.Create(Application);
    try
        F.vst_Grid1.Clear ;
        Result :=F.ShowModal = mrOk ;
    finally
        FreeAndNil(F);
    end;
end;

procedure Tfrm_PrintPontoList.FormCreate(Sender: TObject);
begin
    _ppList:=TCPrintPontoList.Create ;
    _pList :=TCPrinter00List.Create ;
    _items :=TStringList.Create ;
    vst_Grid1.NodeDataSize :=SizeOf(TPrintPonto);
end;

procedure Tfrm_PrintPontoList.FormShow(Sender: TObject);
begin
    DoResetForm;

end;

procedure Tfrm_PrintPontoList.vst_Grid1Change(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  P: TCPrintPonto ;
begin
    if Assigned(Node) then
    begin
            P :=_ppList.Items[Node.Index] ;
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

procedure Tfrm_PrintPontoList.vst_Grid1ColumnDblClick(Sender: TBaseVirtualTree;
  Column: TColumnIndex; Shift: TShiftState);
var
  Node: PVirtualNode;
begin
    Node :=vst_Grid1.GetFirstSelected();
    //Inicie a edição imediata assim que outro nó se concentre.
    if(Column = 2)and not(tsIncrementalSearching in Sender.TreeStates)then
    begin
//Queremos começar a editar o nó atualmente selecionado. No entanto, pode acontecer
//que este evento de mudança aqui é causada pelo editor de nó se outro nó estiver
//sendo editado atualmente. Isso causa problemas para iniciar uma nova operação
//de edição se o último ainda estiver em progresso. Então, nos publicamos uma
//mensagem especial e No manipulador de mensagens, podemos começar a editar o novo nó.
//Isso funciona porque a mensagem postada é executado pela primeira vez * após *
//este evento e a mensagem, que desencadeou está terminada.
      PostMessage(Self.Handle, WM_STARTEDITING, WPARAM(Node), 0);
    end;
end;

procedure Tfrm_PrintPontoList.vst_Grid1CreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
//Este é o retorno de chamada do controle da árvore para solicitar um link de edição
//definido pelo aplicativo. Fornecer um aqui permite nós para controlar o processo
//de edição até o qual o controle real será criado.
//TPropertyEditLink implementa uma interface e, portanto, beneficia da contagem de
//referência. Não precisamos manter um referência para liberá-lo.
//Assim que a árvore acabou de editar, a classe será destruída automaticamente.
begin
    EditLink :=TPropertyEditLink.Create(_items);

end;

procedure Tfrm_PrintPontoList.vst_Grid1Editing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  Data: PPrintPonto;
begin
    Data :=Sender.GetNodeData(Node);
//    Allowed :=(Node.Parent <> Sender.RootNode) and
//              (Column = 2); // and (Data.ValueType <> vtNone);
    Allowed :=Column = 2;
end;

procedure Tfrm_PrintPontoList.vst_Grid1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  P: TCPrintPonto ;
begin
    P :=_ppList.Items[Node.Index] ;
    CellText :='';
    case Column of
        0:CellText :=IntToStr(P.pp_codseq) ;
        1:CellText :=P.pp_descri ;
        2:CellText :=P.pr0_descri;
    end;
end;

procedure Tfrm_PrintPontoList.vst_Grid1InitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Data: PPrintPonto;
begin
    Data :=Sender.GetNodeData(Node);
    Data.pp :=_ppList[Node.Index];
end;

procedure Tfrm_PrintPontoList.vst_Grid1PaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var
  Data: PPrintPonto;
begin
    Data :=Sender.GetNodeData(Node);
    if Data.pp.Changed then
        TargetCanvas.Font.Style := [fsBold]
    else
        TargetCanvas.Font.Style := [];
end;

procedure Tfrm_PrintPontoList.WMStartEditing(var Message: TMessage);
var
  Node: PVirtualNode;
begin
    Node := Pointer(Message.WParam);
    //Note: the test whether a node can really be edited is done in the OnEditing event.
    vst_Grid1.EditNode(Node, 2);
end;

end.
