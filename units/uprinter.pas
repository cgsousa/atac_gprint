{***
* Gerenciador para recursos de impressão
* Atac Sistemas
* Todos os direitos reservados
* Autor: Carlos Gonzaga
* Data: 06.10.2017
*}

unit uprinter;
{*
******************************************************************************
|* PROPÓSITO: Registro de Alterações
******************************************************************************

Símbolo : Significado

[+]     : Novo recurso
[*]     : Recurso modificado/melhorado
[-]     : Correção de Bug (assim esperamos)

27.07.2019
[-] Adiciona a hora da impressão

11.06.2019
[-] Criado o method <TCPrinter01.SortByGroup> para ordenar os PP qdo existir PP
    de agrupamento

02.05.2019
[+] Um ponto pode conter varias portas/documentos(TCPrinterPP01.pp1_typdoc)
[+] A fila de trabalhos é agrupada por tipo documento(TCPrinter01.pr1_typdoc)

16.05.2018
[*] SQL de TCPrinter01List.Load(...) modificado, para lincar primeiro os pontos
    de produção, e so depois, os items/produtos

25.04.2018
[*] Indicador (detalhevenda.ativafracao) se mostra qtd em formato de
    fração (1/4, 1/2, etc)

*}

interface

uses
  Windows, Classes, SysUtils,
  Generics.Defaults, Generics.Collections ;


type
  TCPrinter00 = class; // object impressora
  TCPrinter00List = class; //Lista de impressoras
  TCPrinter01List = class; //Lista de pedidos/p.produção/item a ser impressos
  TCPrinter01 = class; //Pedido/P.Produção/Item)

  TCPrinterPP00 = class; //Cadastro de ponto de produção
  TCPrinterPP00List = class; //Lista de ponto de produção
  TCPrinterPP01 = class; //Terminal /ponto produção /porta e doc

  IPrinter01Doc = interface
    function Prepare(p01: TCPrinter01; p00: TCPrinter00): string ;
  end;

//  TCPrinter01Comparer = class(TComparer<TCPrinter01>)
//  public
//    function Compare(const Left, Right: TCPrinter01): Integer; override;
//  end;

  //pedido, ponto produção e item(produto)
  TPrinter01Type = (ptNone, ptPed, ptPPtr, ptItem);
  TPrinter01Status = (psNoPrint, psPrint, psAbort, psPrintCancel=8, psCancel=9);
  TPrinter01Doc = (pdNormal, pdAuxiliar, pdParcial, pdNone);
  TPrinter01Filter = record
    typdoc: TPrinter01Doc ;
    terminal: string;
    status: TPrinter01Status;
    codped,codppr: Int32 ;
  end;

  { Cadastro de impressora }
  TCPrinter00 = class
  private
    _itemindex: Integer;
    _ErrCod: Int16;
    _ErrMsg: string;
    _NumCop: Int16;
    procedure setCopys(const avalue: Int16);
  public
    pr0_codseq: smallint;
    pr0_modelo: string;
    pr0_nporta: string ;
    pr0_xhost: string ;
    pr0_descri: string ;
    pr0_avanco: smallint;
    pr0_tenttv: smallint;
    pr0_checki: Boolean;
    pr0_expand: Boolean;
    pr0_corte: Boolean;
    pr0_defcol: smallint;
    pr0_active: Boolean;
  public
    property ItemIndex: Integer read _itemindex ;
    property ErrCod: Int16 read _ErrCod;
    property ErrMsg: string read _ErrMsg;
    property NumCop: Int16 read _NumCop write setCopys;
    constructor Create;
    procedure DoMerge();
    procedure DoPrint(const AText: string);
    function Execute(const AText: string): Boolean;
    //function LimStr(const aS1, aS2: string): String ;
  end;

  TCPrinter00List = class(TList<TCPrinter00>)
  private
  public
    function AddNew(): TCPrinter00;
    function IndexOf(const codseq: smallint): TCPrinter00; overload ;
    function Load(const codseq: smallint = 0; strlst: TStrings = nil): Boolean ;
  end;

  TCPrinterPP00 = class
  private
    _owner: TCPrinterPP00List ;
    _items: TList<TCPrinterPP01> ;
    _ItemIndex: Integer;
  public
    pp0_codseq: Int32;
    pp0_descri: string;
    pp0_codptr: Int16;
	  pp0_active: Boolean;
    pp0_codppr: Int32;
  public
    property Items: TList<TCPrinterPP01> read _items;
    property ItemIndex: Integer read _ItemIndex;
    constructor Create ;
    destructor Destroy; override ;
    //procedure DoUpdate();
    function AddItem(): TCPrinterPP01;
    function IndexOf(const terminal_id: string): TCPrinterPP01;
    function IndexOfByDoc(const typdoc: TPrinter01Doc): TCPrinterPP01;
    procedure DoLoadItems(const codppr: Int16);
    function LoadItems(const codppr: Int16; const terminal: string): Boolean;

    procedure DoInsert(Item: TCPrinterPP01);
    procedure DoUpdate(Item: TCPrinterPP01);
    procedure DoDelete(Item: TCPrinterPP01);

  end;

  TCPrinterPP00List = class(TList<TCPrinterPP00>)
  private
    _hosts: TStrings ;
  public
    constructor Create ;
    destructor Destroy ; override ;
  public
    property Hosts: TStrings read _hosts ;
    function AddNew(): TCPrinterPP00;
    function IndexOf(const codseq: smallint): TCPrinterPP00; overload ;
    procedure DoLoad() ;
    procedure DoRemoveTerminal(const terminal_name: string);
  end;

  //TPrinterPP01TypDoc = (ptdDefault);
  TCPrinterPP01 = class
  public
    pp1_codseq: Int32;
    pp1_codppr: Int16;
    pp1_codptr: Int16;
    pp1_terminalid: string;
    pp1_terminalname: string;
    pp1_terminalport: string;
    pp1_xhost: string;
    pp1_princ: Boolean;
    pp1_numcop: smallint;
    pp1_numttv: smallint;
    pp1_maxttv: smallint;
    pp1_typdoc: TPrinter01Doc;
  public
    const PORT_REMOTE_COMP = 'COMP';
    const PORT_REMOTE_TCP = 'TCP';
    procedure DoMerge() ;
  end;

  TCPrinter01 = class
  private
    m_ItemTyp: TPrinter01Type ;
    m_Parent: TCPrinter01;
    m_Index: Integer ;
    m_Group: Word ;
  private
    _items: TList<TCPrinter01>;
    _error: Boolean ;
    procedure DoRemove(Sender: TObject;
      const Item: TCPrinter01; Action: TCollectionNotification);
  public
    { pedido / ponto produção }
    codseq: Int32;
    xhost: string;
    datsys: TDateTime;
    descri: string;
    codppr,codptr: Int16;
    codmsa: Int16;
    npessoa: SmallInt;
    issenh: Boolean;
    vacres: Currency;
    dtvend: TDateTime;
    retirada: Boolean;
    vdesc: Currency;
    //cliente
    cli_nome,cli_endere,cli_bairro,cli_obs: string;
    //
    // type doc
    typdoc: TPrinter01Doc ;
  public
    { produto / item }
    //ptrtyp: TPrinter01Type ;
    codpro: Int32;
    quanti: Double;
    vlunit: Currency;
    unidad: string;
    codbar: string;
    observ: string;
    openom: string;
    transf: string;
    status: TPrinter01Status ;
    fmtqtd: Boolean ;
  public
    property Items: TList<TCPrinter01> read _items;
    property Parent: TCPrinter01 read m_Parent;
    property ItemIndex: Integer read m_Index;
    constructor Create;
//    destructor Destroy; override ;
    function AddNew(const ptrtyp: TPrinter01Type): TCPrinter01;
    function IndexOf(const codseq: Int32): TCPrinter01; overload ;
    function IndexOf(const descri: string): TCPrinter01; overload;
    function IndexOfByPRO(const codpro: Int32): TCPrinter01; overload ;
    function ItemsCancel: Boolean ;
    procedure DoDelete ;
  public
    procedure DoPreparePrint(out ADoc: string; APtr: TCPrinter00;
      const aShowCodPro: Boolean);
    procedure setPrintStatus();
    procedure SortByGroup  ;
  public
    function LoadPed(const aFilter: TPrinter01Filter): Boolean;
  end;

  TCPrinter01List = class(TList<TCPrinter01>)
  private
    procedure DoRemove(Sender: TObject;
      const Item: TCPrinter01; Action: TCollectionNotification);
    procedure LoadItemsCancel(const terminal_id: string) ;
  public
    constructor Create;
    destructor Destroy; override;
    function AddNew(const ptrtyp: TPrinter01Type): TCPrinter01;
    function IndexOf(const codseq: Int32): TCPrinter01; overload ;
    function Load(const aTerminal: string): Boolean;
    function Load01(const aTerminal: string): Boolean;
    procedure DoClear(const terminal_name: string) ;
  end;

  TCPrinter01DocPP = class (TInterfacedObject, IPrinter01Doc)
  private
    m_ShowCodPro: Boolean;
  public
    constructor Create(const aShowCodPro: Boolean); reintroduce ;
    function Prepare(p01: TCPrinter01; p00: TCPrinter00): string;
    class function New(const aShowCodPro: Boolean): IPrinter01Doc;
  end;

  TCPrinter01DocParcial = class (TInterfacedObject, IPrinter01Doc)
  private
  public
    function Prepare(p01: TCPrinter01; p00: TCPrinter00): string;
  end;

  TCPrinter01DocDelivery = class (TInterfacedObject, IPrinter01Doc)
  private
  public
    function Prepare(p01: TCPrinter01; p00: TCPrinter00): string;
  end;



function getPrinter01DocToStr(const typdoc: TPrinter01Doc): string;


implementation

uses IOUtils, TypInfo, ADODB, Math,
  uadodb, ulog, uparam, ustr ,
  ACBrPosPrinter
  ;

type
  TCFile = class (TStreamWriter)
  private
    _filename: string;
    _columns: Int16;
  public
    property FileName: string read _filename ;
    constructor NewFile(const AFilename: string);
  end;

  { TCFile }
  constructor TCFile.NewFile(const AFilename: string);
  begin
      _filename :=TDirectory.GetCurrentDirectory() +AFilename;
      Create(_filename);
      Self.AutoFlush :=True ;
      Self.NewLine   :=#13#10;
  end;


function getPrinter01DocToStr(const typdoc: TPrinter01Doc): string;
begin
    case typdoc of
        pdNormal: Result :='PONTO IMPRESSÃO';
        pdAuxiliar: Result :='AUXILIAR';
        pdParcial: Result :='PARCIAL';
    else
        Result :='Nenhum';
    end;
end;



{ TCPrinter00List }

function TCPrinter00List.AddNew: TCPrinter00;
begin
    Result :=TCPrinter00.Create ;
    Result._itemindex :=Self.Count ;
    Self.Add(Result);
end;

function TCPrinter00List.IndexOf(const codseq: smallint): TCPrinter00;
var
  found: Boolean ;
begin
    found :=false ;
    for Result in Self do
    begin
        if Result.pr0_codseq = codseq then
        begin
            found :=True ;
            Break;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinter00List.Load(const codseq: smallint;
  strlst: TStrings): Boolean;
var
  Q: TADOQuery ;
  P: TCPrinter00;
begin
    //
    Self.Clear ;
    //

    if Assigned(strlst) then
    begin
        strlst.Clear ;
    end;

    Q :=TADOQuery.NewADOQuery() ;
    try
        Q.AddCmd('select *from printer00');
        if codseq <> 0 then
        begin
            Q.AddCmd('where pr0_codseq = %d',[codseq]);
        end;

        Q.Open ;
        Result :=not Q.IsEmpty ;

        while not Q.Eof do
        begin
            P :=Self.AddNew();
            P.pr0_codseq:=Q.Field('pr0_codseq').AsInteger;
            P.pr0_modelo:=Q.Field('pr0_modelo').AsString ;
            P.pr0_nporta:=Q.Field('pr0_nporta').AsString;
            P.pr0_xhost :=Q.Field('pr0_xhost').AsString ;
            P.pr0_descri:=Q.Field('pr0_descri').AsString ;
            P.pr0_avanco:=Q.Field('pr0_avanco').AsInteger;
            P.pr0_tenttv:=Q.Field('pr0_tenttv').AsInteger;
            P.pr0_checki:=Q.Field('pr0_checki').AsInteger = 1;
            P.pr0_expand:=Q.Field('pr0_expand').AsInteger = 1;
            P.pr0_corte :=Q.Field('pr0_corte').AsInteger = 1;
            P.pr0_defcol:=Q.Field('pr0_defcol').AsInteger;
            P.pr0_active:=Q.Field('pr0_active').AsInteger = 1;
            if Assigned(strlst) then
            begin
                strlst.AddObject(P.pr0_descri, P);
            end;

            //
            // inicializa colunas padrão
            if P.pr0_defcol = 0 then
              P.pr0_defcol :=48 ;

            Q.Next ;
        end;
    finally
        Q.Free ;
    end;
end;

{ TCPrinter00 }

constructor TCPrinter00.Create;
begin
    _itemindex :=-1;
    _NumCop :=1;
    _ErrCod :=0;
    _ErrMsg :='';
end;

procedure TCPrinter00.DoMerge;
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand() ;
    try
        //update
        if Self.pr0_codseq > 0 then
        begin
            C.AddCmd('update printer00 set');
            if Self.pr0_active then
            begin
                C.AddCmd('  pr0_modelo = %s,  ',[C.FStr(Self.pr0_modelo)]);
//                C.AddCmd('  pr0_nporta = %s,  ',[C.FStr(Self.pr0_nporta)]);
//                C.AddCmd('  pr0_xhost  = %s,  ',[C.FStr(Self.pr0_xhost)]);
                C.AddCmd('  pr0_descri = %s,  ',[C.FStr(Self.pr0_descri)]);
                C.AddCmd('  pr0_avanco = %d,  ',[Self.pr0_avanco]);
//                C.AddCmd('  pr0_tenttv = %d,  ',[Self.pr0_tenttv]);
                C.AddCmd('  pr0_checki = %d,  ',[Ord(Self.pr0_checki)]);
                C.AddCmd('  pr0_expand = %d,  ',[Ord(Self.pr0_expand)]);
                C.AddCmd('  pr0_corte  = %d,  ',[Ord(Self.pr0_corte)]);
                C.AddCmd('  pr0_defcol = %d   ',[Self.pr0_defcol]);
            end
            else begin
                C.AddCmd('  pr0_active = %d  ',[Ord(Self.pr0_active)]);
            end;
            C.AddCmd('where pr0_codseq = %d  ',[Self.pr0_codseq]);
        end

        //insert
        else begin
            C.AddCmd('insert into printer00(pr0_modelo,');
//            C.AddCmd('                      pr0_nporta,');
//            C.AddCmd('                      pr0_xhost ,');
            C.AddCmd('                      pr0_descri,');
            C.AddCmd('                      pr0_avanco,');
//            C.AddCmd('                      pr0_tenttv,');
            C.AddCmd('                      pr0_checki,');
            C.AddCmd('                      pr0_expand,');
            C.AddCmd('                      pr0_corte ,');
            C.AddCmd('                      pr0_defcol)');
            C.AddCmd('values               (%s,',[C.FStr(Self.pr0_modelo)]);
//            C.AddCmd('                      %s,',[C.FStr(Self.pr0_nporta)]);
//            C.AddCmd('                      %s,',[C.FStr(Self.pr0_xhost)]);
            C.AddCmd('                      %s,',[C.FStr(Self.pr0_descri)]);
            C.AddCmd('                      %d,',[Self.pr0_avanco]);
//            C.AddCmd('                      %d,',[Self.pr0_tenttv]);
            C.AddCmd('                      %d,',[Ord(Self.pr0_checki)]);
            C.AddCmd('                      %d,',[Ord(Self.pr0_expand)]);
            C.AddCmd('                      %d,',[Ord(Self.pr0_corte)]);
            C.AddCmd('                      %d)',[Self.pr0_defcol]);
        end;

        C.Execute ;
    finally
        C.Free ;
    end;
end;

procedure TCPrinter00.DoPrint(const AText: string);
var
  pp: TACBrPosPrinter;
begin

    pp :=TACBrPosPrinter.Create(nil);
    try
        pp.Modelo :=TACBrPosPrinterModelo(
                                GetEnumValue(TypeInfo(TACBrPosPrinterModelo),
                                Self.pr0_modelo));
        pp.Porta :=Self.pr0_nporta;
        pp.ArqLOG :=Format('%s.LOG',[Self.pr0_modelo]);
//        pp.LinhasBuffer := seLinhasBuffer.Value;
//        pp.LinhasEntreCupons := seLinhasPular.Value;
//        pp.EspacoEntreLinhas := seEspLinhas.Value;
//        pp.ColunasFonteNormal := seColunas.Value;
        if Pos('TCP',Self.pr0_nporta)>0 then
        begin
            pp.ControlePorta :=True;
        end;
        pp.CortaPapel :=Self.pr0_corte;
//        pp.TraduzirTags := cbTraduzirTags.Checked;
//        pp.IgnorarTags := cbIgnorarTags.Checked;
//        pp.PaginaDeCodigo := TACBrPosPaginaCodigo( cbxPagCodigo.ItemIndex );

        if not pp.ControlePorta then
        begin
            pp.Ativar ;
        end;
        pp.Imprimir(AText);

    finally
        if not pp.ControlePorta then
        begin
            pp.Desativar ;
        end;
        pp.Free ;
    end;
end;

function TCPrinter00.Execute(const AText: string): Boolean;
var
  pp: TACBrPosPrinter;
  Status: TACBrPosPrinterStatus;
begin
    Result :=True ;
    pp :=TACBrPosPrinter.Create(nil);
    try
        pp.Modelo :=TACBrPosPrinterModelo(
                                GetEnumValue(TypeInfo(TACBrPosPrinterModelo),
                                Self.pr0_modelo));
        pp.Porta :=Self.pr0_nporta;
//        pp.ArqLOG :=Format('%s.LOG',[Self.pr0_modelo]);
//        pp.LinhasBuffer := seLinhasBuffer.Value;
//        pp.LinhasEntreCupons := seLinhasPular.Value;
//        pp.EspacoEntreLinhas := seEspLinhas.Value;
//        pp.ColunasFonteNormal := seColunas.Value;
        if Pos('TCP',Self.pr0_nporta)>0 then
        begin
            pp.ControlePorta :=True;
        end;
        pp.CortaPapel :=Self.pr0_corte;
//        pp.TraduzirTags := cbTraduzirTags.Checked;
        pp.IgnorarTags :=False;
//        pp.PaginaDeCodigo := TACBrPosPaginaCodigo( cbxPagCodigo.ItemIndex );

        try //
            if not pp.ControlePorta then
            begin
                pp.Ativar ;
            end;

            Status :=pp.LerStatusImpressora;
//              TACBrPosTipoStatus = (stErro, stNaoSerial, stPoucoPapel, stSemPapel,
//                        stGavetaAberta, stImprimindo, stOffLine, stTampaAberta);

            if(Status = [])or(Status =[stPoucoPapel])or(Status =[stNaoSerial]) then
                pp.Imprimir(AText)
            else begin
              _ErrCod :=-1;
              if stNaoSerial in Status then
                  _ErrMsg :='Não serial';
              if stPoucoPapel in Status then
                  _ErrMsg :=_ErrMsg +' Pouco Papel';
//              if stSemPapel in Status then
//                  AErr :=AErr +' Sem Papel';
              if stGavetaAberta in Status then
                  _ErrMsg :=_ErrMsg +' Gaveta Aberta';
              if stImprimindo in Status then
                  _ErrMsg :=_ErrMsg +' Imprimindo';
              if stOffLine in Status then
                  _ErrMsg :=_ErrMsg +' Off Line';
              if stTampaAberta in Status then
                  _ErrMsg :=_ErrMsg +' TampaAberta';
              if stErro in Status then
                  _ErrMsg :=_ErrMsg +' Impressora';
              Result:=False ;
            end;
        except
            on E:Exception do
            begin
                _ErrCod :=-2;
                _ErrMsg :=E.Message ;
                Result:=False ;
            end;
        end;
    finally
        if not pp.ControlePorta then
        begin
            pp.Desativar ;
        end;
        pp.Free ;
    end;
end;


procedure TCPrinter00.setCopys(const avalue: Int16);
begin
    if(avalue > 0)and(avalue <=9)then
    begin
        _NumCop :=avalue ;
    end;
end;

{ TCPrinter01List }

function TCPrinter01List.AddNew(const ptrtyp: TPrinter01Type): TCPrinter01;
begin
    Result :=TCPrinter01.Create ;
    Result.m_Parent:=nil;
    Result.m_ItemTyp :=ptrtyp;
    Self.Add(Result) ;
end;

constructor TCPrinter01List.Create;
begin
    Self.OnNotify :=DoRemove ;

end;


destructor TCPrinter01List.Destroy;
begin

    inherited;
end;

procedure TCPrinter01List.DoClear(const terminal_name: string);
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand();
    try
        C.AddCmd('delete from printer01 ');
        C.AddCmd('where pr1_xhost =%s   ',[C.FStr(terminal_name)]);
        C.Execute;
    finally
        C.Free ;
    end;
end;

procedure TCPrinter01List.DoRemove(Sender: TObject; const Item: TCPrinter01;
  Action: TCollectionNotification);
begin
    if Action = cnRemoved then
    begin
        Item.Free
        ;
    end;
end;

function TCPrinter01List.IndexOf(const codseq: Int32): TCPrinter01;
var
  found: Boolean ;
begin
    found :=false ;
    for Result in Self do
    begin
        if Result.codseq = codseq then
        begin
            found :=True ;
            Break;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinter01List.Load(const aTerminal: string): Boolean;
var
  Q: TADOQuery ;
  p0,p1,p2,p3,p4: TCPrinter01;
  pp00List: TCPrinterPP00List ;
  pp00: TCPrinterPP00 ; //Ponto produção (PP)
  pp01: TCPrinterPP01 ; //Porta do PP / terminal
var
  //pcname: string ;
  codped,codpp0,codppr: Int32;
  status: TPrinter01Status;
  datsys: TDateTime ;
begin
    //
    Self.Clear ;
    //
    pp00List :=TCPrinterPP00List.Create ;
    pp00List.DoLoad ;
    //pp00 :=TCPrinterPP00.Create ;
    //
    datsys :=TADOQuery.getDateTime();
    //
    Q :=TADOQuery.NewADOQuery() ;
    try

        status :=psNoPrint ;

        Q.AddCmd('declare @termid varchar(20); set @termid =%s;       ',[Q.FStr(aTerminal)]);
        Q.AddCmd('declare @status smallint; set @status  =%d;         ',[Ord(status)]);
        //Q.AddCmd('declare @codped int; set @codped  =%d;              ',[Ord(aFilter.pedido_id)]);

        Q.AddCmd('select distinct                                     ');

        Q.AddCmd('    pr1_codped,pr1_xhost,pr1_typdoc ,               ');
        Q.AddCmd('    v.CodMesa as ped_codmsa ,                       ');
        Q.AddCmd('    v.retiradabalcao as ped_retirada ,              ');
        Q.AddCmd('    u.Nome as ped_openom ,                          ');
        Q.AddCmd('    s.CodContadorSenha as ped_xsenha ,              ');

        Q.AddCmd('    c.nomerazao as cli_nome ,                       ');
        Q.AddCmd('    c.endereco as cli_endere,                       ');
        Q.AddCmd('    c.bairro as cli_bairro ,                        ');
        Q.AddCmd('    c.obs as cli_obs ,                              ');

        Q.AddCmd('    i.Coddetvenda as itm_codseq,                    ');
        Q.AddCmd('    i.qts as itm_quanti,                            ');
        Q.AddCmd('    i.Preco as itm_vlunit,                          ');
        Q.AddCmd('    i.Obsproduto as itm_observ,                     ');
        Q.AddCmd('    i.operador as itm_openom,                       ');
        Q.AddCmd('    i.mprintstatus as itm_status,                   ');
        //
        // 25.04.2018-CGonzaga, indicador se mostra qtd em formato de fração
        // 1/4, 1/2, etc
        Q.AddCmd('    ativafracao as itm_fmtqtd,                      ');

        Q.AddCmd('    p.Codproduto as itm_codpro,                     ');
        Q.AddCmd('    p.Nome as itm_descri,                           ');
        Q.AddCmd('    p.Unidade as itm_unidad,                        ');
        Q.AddCmd('    p.CodBarra as itm_codbar,                       ');
        Q.AddCmd('    pp0_codseq, pp0_descri, pp0_codptr, pp0_codppr  ');

        Q.AddCmd('from printer01                                      ');
        Q.AddCmd('inner join venda v on v.codvenda = pr1_codped       ');
        Q.AddCmd('inner join printerpp00 on pp0_codseq = pr1_codppr   ');

        Q.AddCmd('inner join produto p on p.codppr = pp0_codseq       ');
        Q.AddCmd('inner join detalhevenda i on i.codvenda  =v.codvenda');
        Q.AddCmd('                         and i.Codproduto=p.Codproduto');
        Q.AddCmd('left join ContadorSenha s on s.CodVenda = v.codvenda');
        Q.AddCmd('left join usuario u on u.codusuario = v.CodUsuario  ');
        Q.AddCmd('left join cliente c on c.codcliente =v.codcliente   ');

        Q.AddCmd('where pr1_xhost       =@termid                      ');
        Q.AddCmd('and   i.mprintstatus  =@status                      ');

        Q.AddCmd('order by pr1_codped, pp0_codseq                     ');

        if not Q.Prepared then
        begin
            Q.Prepared :=True ;
        end;

        Q.Open ;

        Result :=not Q.IsEmpty;

        while not Q.Eof do
        begin
            codped :=Q.Field('pr1_codped').AsInteger ;
            codpp0 :=Q.Field('pp0_codseq').AsInteger ;

            //
            // pedido (venda)
            //
            p0 :=Self.IndexOf(codped);
            if p0 = nil then
            begin
                p0 :=Self.AddNew(ptPed) ;
                p0.codseq:=codped;
                p0.xhost :=Q.Field('pr1_xhost').AsString ;
                p0.datsys:=datsys;
                p0.openom :=Q.Field('ped_openom').AsString ;
                if not Q.Field('ped_codmsa').IsNull then
                    p0.codmsa:=Q.Field('ped_codmsa').AsInteger
                else
                    if not Q.Field('ped_xsenha').IsNull then
                    begin
                        p0.codmsa:=Q.Field('ped_xsenha').AsInteger;
                        p0.issenh:=True;
                    end;
                p0.retirada :=LowerCase(Q.Field('ped_retirada').AsString)='sim' ;
                //dados do cliente para entrega
                p0.cli_nome :=Q.Field('cli_nome').AsString ;
                p0.cli_endere :=Q.Field('cli_endere').AsString ;
                p0.cli_bairro :=Q.Field('cli_bairro').AsString ;
                p0.cli_obs :=Q.Field('cli_obs').AsString ;
            end;

            //
            // ponto de impressão
            //
            p1 :=p0.IndexOf(codpp0);
            if p1 = nil then
            begin
                //
                // carrega as portas para chegagem
                //
                pp00 :=pp00List.IndexOf(codpp0) ;
                pp00.DoLoadItems(pp00.pp0_codseq);

                pp01 :=pp00.IndexOf(aTerminal) ;
                //
                // se porta configurada para este terminal, adiciona
                //
                if pp01 <> nil then
                begin
                    p1 :=p0.AddNew(ptPPtr);
                    p1.codseq:=codpp0;
                    p1.descri:=Q.Field('pp0_descri').AsString ;
                    p1.codptr:=Q.Field('pp0_codptr').AsInteger;
                    if p1.codptr = 0 then
                    begin
                        p1.codptr:=-1;
                    end;
                    p1.codppr:=Q.Field('pp0_codppr').AsInteger;
                end;
            end;

            //
            // adiciona item, se , e somente se, PP ok!
            //
            if p1 <> nil then
            begin
                p2 :=p1.AddNew(ptItem) ;
                p2.codseq:=Q.Field('itm_codseq').AsInteger;
                p2.codpro:=Q.Field('itm_codpro').AsInteger;
                p2.quanti:=Q.Field('itm_quanti').AsFloat;
                p2.vlunit:=Q.Field('itm_vlunit').AsCurrency;
                p2.descri:=Q.Field('itm_descri').AsString;
                p2.unidad:=Q.Field('itm_unidad').AsString ;
                p2.codbar:=Q.Field('itm_codbar').AsString ;
                p2.observ:=Q.Field('itm_observ').AsString ;
                p2.status:=TPrinter01Status(Q.Field('itm_status').AsInteger);
                if not Q.Field('itm_openom').IsNull then
                begin
                    p2.openom:=Q.Field('itm_openom').AsString ;
                end;
                p2.fmtqtd:=Q.Field('itm_fmtqtd').AsInteger > 0;

                //
                // verifica agrupamento
                //
                if p1.codppr > 0 then
                begin
                    //
                    // ler dados do PP de agrupamento
                    //
                    pp00 :=pp00List.IndexOf(p1.codppr) ;

                    //
                    // adiciona novo PP (agrupamento)
                    //
                    p3 :=p0.IndexOf(p1.codppr);
                    if p3 = nil then
                    begin
                        p3 :=p0.AddNew(ptPPtr);
                        p3.codseq:=pp00.pp0_codseq;
                        p3.descri:=pp00.pp0_descri;
                        p3.codptr:=pp00.pp0_codptr;
                        if p3.codptr = 0 then
                        begin
                            p3.codptr:=-1;
                        end;
                    end;

                    //
                    // agrupa todos os produtos neste PP
                    //
                    p4 :=p3.AddNew(ptItem);
                    p4.codseq:=p2.codseq ;
                    p4.codpro:=p2.codpro ;
                    p4.quanti:=p2.quanti ;
                    p4.vlunit:=p2.vlunit ;
                    p4.descri:=p2.descri ;
                    p4.unidad:=p2.unidad ;
                    p4.codbar:=p2.codbar ;
                    p4.observ:=p2.observ ;
                    p4.status:=p2.status ;
                    p4.openom:=p2.openom ;
                    p4.fmtqtd:=p2.fmtqtd ;
                end;
            end;

            Q.Next ;
        end;
    finally
        Q.Free ;
        pp00List.Free ;
    end;

    //
    // add itens cancelelados
    //
    Self.LoadItemsCancel(aTerminal) ;

    //
    Result :=Self.Count > 0;

end;

function TCPrinter01List.Load01(const aTerminal: string): Boolean;
var
  Q: TADOQuery ;
  p0: TCPrinter01;
begin
    //
    Self.Clear ;
    //
    Q :=TADOQuery.NewADOQuery() ;
    try
        Q.AddCmd('declare @host_name varchar(20); set @host_name=%s;',[Q.FStr(aTerminal)]);
        Q.AddCmd('select *from printer01 where pr1_xhost =@host_name');
        Q.AddCmd('order by pr1_typdoc                               ');

        Q.Open ;

        Result :=not Q.IsEmpty;

        while not Q.Eof do
        begin
            p0 :=Self.AddNew(ptNone) ;
            p0.codseq:=Q.Field('pr1_codped').AsInteger;
            p0.xhost :=Q.Field('pr1_xhost').AsString  ;
            p0.datsys:=Q.Field('pr1_datsys').AsDateTime;
            p0.codppr:=Q.Field('pr1_codppr').AsInteger;
            p0.codptr:=Q.Field('pr1_codptr').AsInteger;
            p0.typdoc :=TPrinter01Doc(Q.Field('pr1_typdoc').AsInteger) ;
            p0.m_Group :=0;
            Q.Next ;
        end;
    finally
        Q.Free ;
    end;
end;

procedure TCPrinter01List.LoadItemsCancel(const terminal_id: string) ;
var
  Q: TADOQuery ;
  p0,p1,p2: TCPrinter01;
var
  codped,codppr: Int32;
  status: TPrinter01Status;
  datsys: TDateTime ;
begin
    //
    datsys :=TADOQuery.getDateTime();
    Q :=TADOQuery.NewADOQuery() ;
    try

        //pcname :=GetLocalComputerName ;
        status :=psCancel ;

        Q.AddCmd('declare @xhost varchar(20); set @xhost =%s;       ',[Q.FStr(terminal_id)]);
        Q.AddCmd('declare @status smallint; set @status  =%d;       ',[Ord(status)]);
        Q.AddCmd('select distinct                                   ');
        Q.AddCmd('    pr1_codped,pr1_xhost,--pr1_datsys,            ');
        Q.AddCmd('    v.CodMesa as ped_codmsa,                      ');
        Q.AddCmd('    i.CodCancelamentoVenda as itm_codseq,         ');
        Q.AddCmd('    i.qts as itm_quanti,                          ');
        Q.AddCmd('    i.Preco as itm_vlunit,                        ');
        Q.AddCmd('    null as itm_observ,                           ');
        Q.AddCmd('    u.nome as itm_openom,                         ');
        Q.AddCmd('    i.mprintstatus as itm_status,                 ');
        Q.AddCmd('    p.Codproduto as itm_codpro,                   ');
        Q.AddCmd('    p.Nome as itm_descri,                         ');
        Q.AddCmd('    p.Unidade as itm_unidad,                      ');
        Q.AddCmd('    p.CodBarra as itm_codbar,                     ');
        Q.AddCmd('    pp0_codseq, pp0_descri, pp0_codptr            ');
        Q.AddCmd('from printer01                                    ');
        Q.AddCmd('inner join venda v on v.codvenda = pr1_codped     ');
        Q.AddCmd('inner join CancelamentoVenda i on i.codvenda = v.codvenda ');
        Q.AddCmd('left join produto p on p.Codproduto = i.Codproduto        ');
        Q.AddCmd('left join usuario u on u.codusuario = i.CodUsuarioCancelamento');
        Q.AddCmd('left join printerpp00 on pp0_codseq = p.codppr    ');
        Q.AddCmd('where pr1_xhost       =@xhost                     ');
        Q.AddCmd('and   i.mprintstatus  =@status                    ');
        Q.AddCmd('order by pr1_codped, pp0_codseq                   ');

        if not Q.Prepared then
        begin
            Q.Prepared :=True ;
        end;

        Q.Open ;

        while not Q.Eof do
        begin
            codped :=Q.Field('pr1_codped').AsInteger ;
            codppr :=Q.Field('pp0_codseq').AsInteger ;

            p0 :=Self.IndexOf(codped);
            if p0 = nil then
            begin
                p0 :=Self.AddNew(ptPed) ;
                p0.codseq:=codped;
                p0.codmsa:=Q.Field('ped_codmsa').AsInteger;
                p0.xhost :=Q.Field('pr1_xhost').AsString ;
                p0.datsys:=datsys;
            end;

            p1 :=p0.IndexOf(codppr);
            if p1 = nil then
            begin
                p1 :=p0.AddNew(ptPPtr);
                p1.codseq:=codppr;
                p1.descri:=Q.Field('pp0_descri').AsString ;
                p1.codptr:=Q.Field('pp0_codptr').AsInteger;
                if p1.codptr = 0 then
                begin
                    p1.codptr:=-1;
                end;
            end;

            p2 :=p1.AddNew(ptItem) ;
            p2.codseq:=Q.Field('itm_codseq').AsInteger;
            p2.codpro:=Q.Field('itm_codpro').AsInteger;
            p2.quanti:=Q.Field('itm_quanti').AsFloat;
            p2.vlunit:=Q.Field('itm_vlunit').AsCurrency;
            p2.descri:=Q.Field('itm_descri').AsString;
            p2.unidad:=Q.Field('itm_unidad').AsString ;
            p2.codbar:=Q.Field('itm_codbar').AsString ;
            p2.observ:=Q.Field('itm_observ').AsString ;
            p2.openom:=Q.Field('itm_openom').AsString ;
            p2.status:=TPrinter01Status(Q.Field('itm_status').AsInteger);

            Q.Next ;
        end;
    finally
        Q.Free ;
    end;
end;

{ TCPrinter01 }

function TCPrinter01.AddNew(const ptrtyp: TPrinter01Type): TCPrinter01;
begin
    if _items = nil then
    begin
        _items :=TList<TCPrinter01>.Create ;
        _items.OnNotify :=DoRemove ;
    end;
    Result :=TCPrinter01.Create ;
    Result.m_ItemTyp :=ptrtyp;
    Result.m_Parent :=Self;
    Result.m_Index :=Items.Count ;
    Items.Add(Result) ;
end;

constructor TCPrinter01.Create;
begin
    m_ItemTyp :=ptNone ;
    m_Parent :=nil;
    m_Index :=-1;
    _items :=nil;
    status :=psNoPrint ;
end;

procedure TCPrinter01.DoDelete;
var
  C: TADOCommand ;
  E: TCPrinter01 ;
begin
    //apaga do banco
    C :=TADOCommand.NewADOCommand() ;
    try
        C.AddCmd('delete from printer01 ');
        C.AddCmd('where pr1_codped = %d',[Self.m_Parent.codseq]);
        C.AddCmd('and   pr1_codppr = %d',[Self.codseq]);
        if not C.Prepared then
        begin
            C.Prepared :=True;
        end;
        //C.SaveToFile();
        C.Execute ;
    finally
        C.Free ;
    end;
end;

procedure TCPrinter01.DoPreparePrint(out ADoc: string; APtr: TCPrinter00;
  const aShowCodPro: Boolean);
var
  S: TTextWriter;
  I: TCPrinter01;
var
  L,P,C: Integer;
  lin_pro,lin_qtd: string;
  oper_id: string;
  part_dec: Currency;
  obs: TStrings;
  Q,part_Q: Double;
  N,part_I: Int32 ;
begin
    //
    // format doc. conforme impressora!
    //
    if APtr <> nil then
    begin
{
        S :=TStringWriter.Create();
        try
            //
            // copias
            //
            C :=0; Q :=0; N :=0;
            repeat

              I :=Self.Items[0];
              if I.status = psCancel then
                  S.WriteLine('<e><n>*** C A N C E L A D O **</n></e>')
              else begin
                  S.WriteLine('***' +Empresa.xFant +'***');
              end;

              S.WriteLine('Pedido.: %.6d      Data/Hora: %s',[Self.m_parent.codseq,TFrmtStr.Dat(Self.m_parent.datsys)]);

              if Self.m_parent.codmsa >= 800 then
              begin
                  S.WriteLine('Atend..: %-16s',[I.openom]) ;
                  if Self.m_parent.retirada then
                  begin
                      S.WriteLine('<e><n>RETIRADA   BALCAO</n></e>');
                  end ;
                  S.WriteLine(Format('<e><n>Entrega : %.3d</n></e>',[Self.m_parent.codmsa,Self.m_parent.codseq]));
                  S.WriteLine(Format('Cliente : <e><n>%s</n></e>',[UpperCase(Self.m_parent.cli_nome)]));
                  S.WriteLine(Format('Endereco: <e><n>%s</n></e>',[UpperCase(Self.m_parent.cli_endere)]));
                  S.WriteLine(Format('Bairro  : <e><n>%s</n></e>',[UpperCase(Self.m_parent.cli_bairro)]));
                  S.WriteLine(Format('Obs     : <e><n>%s</n></e>',[UpperCase(Self.m_parent.cli_obs)]));
              end
              else begin
                  if Self.m_parent.issenh then
                  begin
                      S.WriteLine('Atend..: %-16s',[Self.m_parent.openom]) ;
                      S.WriteLine('<e><n>Senha: %.3d</n></e>',[Self.m_parent.codmsa]) ;
                  end
                  else begin
                      S.WriteLine('Atend..: %-16s',[I.openom]);
                      S.WriteLine('<e><n>Mesa: %.3d</n></e>',[Self.m_parent.codmsa]);
                  end;
              end;

              S.WriteLine(DupeString('*', APtr.pr0_defcol));

              if APtr.NumCop > 1 then
              begin
                  lin_pro :=Format('%s   Via:%.2d',[UpperCase(Self.descri),C+1]);
                  S.WriteLine(Format('<e><n>%s</n></e>',[lin_pro]));
              end
              else
                  S.WriteLine(Format('<e><n>%s</n></e>',[UpperCase(Self.descri)]));

              S.WriteLine(DupeString('-', APtr.pr0_defcol));
              if aShowCodPro then
                  S.WriteLine('Codigo Descricao')
              else
                  S.WriteLine('Descricao');
              S.WriteLine(DupeString('-', APtr.pr0_defcol));

              for I in Self.Items do
              begin
                  if aShowCodPro then
                      lin_pro :=Format('<e><n>%s %s',[I.codbar,UpperCase(I.descri)])
                  else
                      lin_pro :=Format('<e><n>%s',[UpperCase(I.descri)]);
                  if I.fmtqtd then
                  begin
                      part_Q :=RoundTo(I.quanti, -2) ;
                      part_I :=Trunc(part_Q*100);
                      //if part_Q = 0.25 then
                      if part_I = 25 then
                        lin_qtd :='  <s>Qtde: 1/4</s></n></e>'
                      else if part_I = 33 then
                        lin_qtd :='  <s>Qtde: 1/3</s></n></e>'
                      //else if part_Q = 0.50 then
                      else if part_I = 50 then
                        lin_qtd :='  <s>Qtde: 1/2</s></n></e>'
                      //else if part_Q = 0.75 then
                      else if part_Q = 75 then
                        lin_qtd :='  <s>Qtde: 3/4</s></n></e>'
                      else begin
                        if Frac(I.quanti) > 0 then
                          lin_qtd :=Format('  <s>Qtde: %5.3n</s></n></e>',[I.quanti])
                        else
                          lin_qtd :=Format('  <s>Qtde: %d</s></n></e>',[Trunc(I.quanti)]) ;
                      end;
                      Q :=Q +part_Q;
                      N :=N +part_I;
                      if(100 -N)=1 then
                      begin
                          N :=100;
                          Q :=1;
                      end;
                  end
                  else begin
                      if Frac(I.quanti) > 0 then
                          lin_qtd :=Format('  <s>Qtde:%5.3f</s></n></e>',[I.quanti])
                      else
                          lin_qtd :=Format('  <s>Qtde: %d</s></n></e>',[Trunc(I.quanti)]);
                  end;
                  S.WriteLine(lin_pro) ;
                  S.WriteLine(lin_qtd) ;

                  if I.observ <> '' then
                  begin
                      //S.WriteLine('<e><n>Obs: %-42s</n></e>',[I.observ]);
                      lin_pro :=I.observ ;
                      obs :=TStringList.Create ;
                      while lin_pro <> '' do
                      begin
                          P :=PosEx(';', lin_pro) ;
                          if P > 0 then
                          begin
                              obs.Add(Copy(lin_pro,1,P-1));
                              lin_pro :=Copy(lin_pro,P+1,Length(lin_pro))
                          end
                          else begin
                              obs.Add(lin_pro);
                              lin_pro :='';
                          end;
                      end;
                      for L :=0 to obs.Count -1 do
                      begin
                          lin_pro :=obs.Strings[L];
                          if L = 0 then
                            S.WriteLine('<e><n>Obs: %s</n></e>',[lin_pro])
                          else
                            S.WriteLine('<e><n> %s</n></e>',[lin_pro]);
                      end;
                  end;

                  if I.fmtqtd then
                  begin
                      if Q >= 1 then
                      begin
                          Q :=0;
                          S.WriteLine(DupeString('-', APtr.pr0_defcol));
                      end;
                  end
                  else
                      S.WriteLine(DupeString('-', APtr.pr0_defcol));
              end;

              if I.status = psCancel then
              begin
                  S.WriteLine('<e><n>*** C A N C E L A D O **</n></e>');
              end;

              if APtr.pr0_avanco > 0 then
              begin
                  for L :=1 to APtr.pr0_avanco do
                  begin
                      S.WriteLine('');
                  end;
              end;
              S.WriteLine('</corte_parcial>');

              Inc(C);

            until (C >= APtr.NumCop);

            ADoc :=S.ToString ;
        finally
            S.Free;
            if Assigned(obs) then
            begin
//              obs.Clear;
//              obs.Add(Adoc) ;
//              obs.SaveToFile('obs.txt');
              obs.Free;
            end;
        end;
        }
    end ;
end;

procedure TCPrinter01.DoRemove(Sender: TObject; const Item: TCPrinter01;
  Action: TCollectionNotification);
begin
    if Action = cnRemoved then
    begin
        Item.Free ;
    end;
end;

function TCPrinter01.IndexOf(const descri: string): TCPrinter01;
var
  found: Boolean ;
begin
    found :=false ;
    if Assigned(Self.Items)then
    begin
        for Result in Self.Items do
        begin
            if Result.descri = descri then
            begin
                found :=True ;
                Break;
            end;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinter01.IndexOfByPRO(const codpro: Int32): TCPrinter01;
var
  found: Boolean ;
begin
    found :=false ;
    if Assigned(Self.Items)then
    begin
        for Result in Self.Items do
        begin
            if Result.codpro = codpro then
            begin
                found :=True ;
                Break;
            end;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinter01.ItemsCancel: Boolean;
var
  I: TCPrinter01;
begin
    Result :=False ;
    for I in Self.Items do
    begin
        if I.status = psCancel then
        begin
            Result :=True ;
            Break;
        end;
    end;
end;

function TCPrinter01.LoadPed(const aFilter: TPrinter01Filter): Boolean;
var
  Q: TADOQuery ;
  p0,p1,p2,p3,p4: TCPrinter01;
  pp00List: TCPrinterPP00List ;
  pp00: TCPrinterPP00 ; //Ponto produção (PP)
  pp01: TCPrinterPP01 ; //Porta do PP / terminal
var
  codpp0,codppr,codpro: Int32;
begin
    //
    Result :=False ;
    //
    //
    pp00List :=TCPrinterPP00List.Create ;
    pp00List.DoLoad ;
    //
    //

    Q :=TADOQuery.NewADOQuery();
    try
        Q.AddCmd('declare @codped int; set @codped  =%d;              ',[Self.codseq]);
        Q.AddCmd('declare @codppr int; set @codppr  =%d;              ',[Self.codppr]);
        Q.AddCmd('declare @status smallint; set @status  =%d;         ',[Ord(psNoPrint)]);

        Q.AddCmd('select                                              ');

        Q.AddCmd('    v.codvenda as ped_codigo,                       ');
        Q.AddCmd('    v.datavenda as ped_dhvend,                      ');
        Q.AddCmd('    v.CodMesa as ped_codmsa ,                       ');
        Q.AddCmd('    v.retiradabalcao as ped_retirada ,              ');
        Q.AddCmd('    v.totala as ped_vacres ,                        ');
        Q.AddCmd('    v.npessoa as ped_npessoa,                       ');
        Q.AddCmd('    v.desconto as ped_vdesc,                        ');
        Q.AddCmd('    u.Nome as ped_openom ,                          ');
        Q.AddCmd('    s.CodContadorSenha as ped_xsenha ,              ');

        Q.AddCmd('    c.nomerazao as cli_nome ,                       ');
        Q.AddCmd('    c.endereco as cli_endere,                       ');
        Q.AddCmd('    c.bairro as cli_bairro ,                        ');
        Q.AddCmd('    c.obs as cli_obs ,                              ');

        Q.AddCmd('    i.Coddetvenda as itm_codseq,                    ');
        Q.AddCmd('    i.qts as itm_quanti,                            ');
        Q.AddCmd('    i.Preco as itm_vlunit,                          ');
        Q.AddCmd('    i.Obsproduto as itm_observ,                     ');
        Q.AddCmd('    i.operador as itm_openom,                       ');
        Q.AddCmd('    i.mprintstatus as itm_status,                   ');
        Q.AddCmd('    i.ativafracao as itm_fmtqtd,                    ');
        Q.AddCmd('    i.transferenciamesa as itm_transf,              ');
        Q.AddCmd('    i.desconto as itm_vdesc,                        ');

        Q.AddCmd('    p.Codproduto as itm_codpro,                     ');
        Q.AddCmd('    p.Nome as itm_descri,                           ');
        Q.AddCmd('    p.Unidade as itm_unidad,                        ');
        Q.AddCmd('    p.CodBarra as itm_codbar,                       ');
        Q.AddCmd('    p.codppr as pp0_codseq                          ');

        Q.AddCmd('from venda v                                        ');

        Q.AddCmd('inner join detalhevenda i on i.codvenda  =v.codvenda');
        Q.AddCmd('inner join produto p on p.Codproduto =i.Codproduto  ');
        Q.AddCmd('inner join printerpp00 on pp0_codseq =p.codppr      ');
        Q.AddCmd('left join ContadorSenha s on s.CodVenda = v.codvenda');
        Q.AddCmd('left join usuario u on u.codusuario = v.CodUsuario  ');
        Q.AddCmd('left join cliente c on c.codcliente =v.codcliente   ');

        Q.AddCmd('where v.codvenda =@codped                           ');
        if Self.typdoc = pdNormal then
        begin
          Q.AddCmd('and   i.mprintstatus  =@status                      ');
        end;

        Q.AddCmd('order by ped_codigo, pp0_codseq                     ');

        if not Q.Prepared then
        begin
            Q.Prepared :=True ;
        end;

        {case Self.typdoc of
            pdNormal: Q.SaveToFile(Format('%s.LoadPed-PP.txt',[Self.ClassName]));
            pdAuxiliar: Q.SaveToFile(Format('%s.LoadPed-Aux.txt',[Self.ClassName]));
            pdParcial: Q.SaveToFile(Format('%s.LoadPed-Parcial.txt',[Self.ClassName]));
        end;}

        Q.Open ;
        Result :=not Q.IsEmpty;
        //
        // pedido (venda)
        //
        p0 :=Self ;
        if p0 <> nil then
        begin
            p0.dtvend :=Q.Field('ped_dhvend').AsDateTime ;
            p0.vacres :=Q.Field('ped_vacres').AsCurrency ;
            p0.npessoa :=Q.Field('ped_npessoa').AsInteger ;
            p0.openom :=Q.Field('ped_openom').AsString ;
            if not Q.Field('ped_codmsa').IsNull then
                p0.codmsa:=Q.Field('ped_codmsa').AsInteger
            else
                if not Q.Field('ped_xsenha').IsNull then
                begin
                    p0.codmsa:=Q.Field('ped_xsenha').AsInteger;
                    p0.issenh:=True;
                end;
            p0.retirada :=LowerCase(Q.Field('ped_retirada').AsString)='sim' ;
            p0.vdesc :=Q.Field('ped_vdesc').AsCurrency ;
            //dados do cliente para entrega
            p0.cli_nome :=Q.Field('cli_nome').AsString ;
            p0.cli_endere :=Q.Field('cli_endere').AsString ;
            p0.cli_bairro :=Q.Field('cli_bairro').AsString ;
            p0.cli_obs :=Q.Field('cli_obs').AsString ;
        end;

        //
        // items
        //
        while not Q.Eof do
        begin
            //
            // doc. normal ler o respectivo PP
            if p0.typdoc = pdNormal then
                codpp0 :=Q.Field('pp0_codseq').AsInteger
            //
            // doc. parcial
            else
                codpp0 :=p0.codppr;

            //
            // ponto de impressão
            //
            p1 :=p0.IndexOf(codpp0);
            if p1 = nil then
            begin
                //
                // carrega as portas para checagem
                //
                pp00 :=pp00List.IndexOf(codpp0) ;
                pp00.DoLoadItems(pp00.pp0_codseq);

                pp01 :=pp00.IndexOf(Self.xhost) ;
                //
                // se porta configurada para este terminal, adiciona
                //
                if pp01 <> nil then
                begin
                    p1 :=p0.AddNew(ptPPtr);
                    p1.codseq:=pp00.pp0_codseq;
                    p1.descri:=pp00.pp0_descri;
                    p1.codptr:=pp00.pp0_codptr;
                    if p1.codptr = 0 then
                    begin
                        p1.codptr:=-1;
                    end;
                    p1.codppr:=pp00.pp0_codppr;
                    p1.m_Group :=1;
                end;
            end;

            //
            // adiciona item, se , e somente se, PP ok!
            //
            if p1 <> nil then
            begin
                //
                // agrupa items por codigo, somente na parcial
                if p0.typdoc = pdParcial then
                begin
                    p2 :=p1.IndexOfByPRO(Q.Field('itm_codpro').AsInteger) ;
                    if p2 = nil then
                      p2 :=p1.AddNew(ptItem) ;
                end
                else
                    p2 :=p1.AddNew(ptItem) ;
                //
                // add novo item em PP
                if p2.codseq = 0 then
                begin
                    p2.codseq:=Q.Field('itm_codseq').AsInteger;
                    p2.codpro:=Q.Field('itm_codpro').AsInteger;
                    p2.quanti:=Q.Field('itm_quanti').AsFloat;
                    p2.vlunit:=Q.Field('itm_vlunit').AsCurrency;
                    p2.descri:=Q.Field('itm_descri').AsString;
                    p2.unidad:=Q.Field('itm_unidad').AsString ;
                    p2.codbar:=Q.Field('itm_codbar').AsString ;
                    p2.observ:=Q.Field('itm_observ').AsString ;
                    p2.status:=TPrinter01Status(Q.Field('itm_status').AsInteger);
                    if not Q.Field('itm_openom').IsNull then
                    begin
                        p2.openom:=Q.Field('itm_openom').AsString ;
                    end;
                    p2.fmtqtd:=Q.Field('itm_fmtqtd').AsInteger > 0;
                    p2.transf:=Q.Field('itm_transf').AsString ;
                    p2.vdesc :=Q.Field('itm_vdesc').AsCurrency ;
                end
                else begin
                    p2.quanti:=p2.quanti +Q.Field('itm_quanti').AsFloat;
                    p2.vdesc :=p2.vdesc +Q.Field('itm_vdesc').AsCurrency;
                end;

                //
                // verifica agrupamento
                //
                if p1.codppr > 0 then
                begin
                    //
                    // ler dados do PP de agrupamento
                    //
                    pp00 :=pp00List.IndexOf(p1.codppr) ;

                    //
                    // adiciona novo PP (agrupamento)
                    //
                    p3 :=p0.IndexOf(p1.codppr);
                    if p3 = nil then
                    begin
                        p3 :=p0.AddNew(ptPPtr);
                        p3.codseq:=pp00.pp0_codseq;
                        p3.descri:=pp00.pp0_descri;
                        p3.codptr:=pp00.pp0_codptr;
                        if p3.codptr = 0 then
                        begin
                            p3.codptr:=-1;
                        end;
                        p3.m_Group :=2;
                    end;

                    //
                    // agrupa todos os produtos neste PP
                    //
                    p4 :=p3.AddNew(ptItem);
                    p4.codseq:=p2.codseq ;
                    p4.codpro:=p2.codpro ;
                    p4.quanti:=p2.quanti ;
                    p4.vlunit:=p2.vlunit ;
                    p4.descri:=p2.descri ;
                    p4.unidad:=p2.unidad ;
                    p4.codbar:=p2.codbar ;
                    p4.observ:=p2.observ ;
                    p4.status:=p2.status ;
                    p4.openom:=p2.openom ;
                    p4.fmtqtd:=p2.fmtqtd ;
                    p4.vdesc:=p2.vdesc ;
                end;
            end;

            Q.Next ;
        end;

        //
        // add itens cancelelados
        //
        if Self.typdoc = pdNormal then
        begin
            Q.AddCmd('declare @codped int; set @codped  =%d;              ',[Self.codseq]);
            Q.AddCmd('declare @codppr int; set @codppr  =%d;              ',[Self.codppr]);
            Q.AddCmd('declare @status smallint; set @status  =%d;         ',[Ord(psCancel)]);

            Q.AddCmd('select                                            ');
            Q.AddCmd('    v.codvenda as ped_codigo,                     ');
            Q.AddCmd('    v.CodMesa as ped_codmsa,                      ');
            Q.AddCmd('    i.CodCancelamentoVenda as itm_codseq,         ');
            Q.AddCmd('    i.qts as itm_quanti,                          ');
            Q.AddCmd('    i.Preco as itm_vlunit,                        ');
            Q.AddCmd('    null as itm_observ,                           ');
            Q.AddCmd('    u.nome as itm_openom,                         ');
            Q.AddCmd('    i.mprintstatus as itm_status,                 ');
            Q.AddCmd('    p.codproduto as itm_codpro,                   ');
            Q.AddCmd('    p.Nome as itm_descri,                         ');
            Q.AddCmd('    p.Unidade as itm_unidad,                      ');
            Q.AddCmd('    p.CodBarra as itm_codbar,                     ');
            Q.AddCmd('    pp0_codseq, pp0_descri, pp0_codptr            ');
            Q.AddCmd('from venda v                                      ');
            Q.AddCmd('inner join CancelamentoVenda i on i.codvenda = v.codvenda ');
            Q.AddCmd('left join produto p on p.Codproduto = i.Codproduto        ');
            Q.AddCmd('left join usuario u on u.codusuario = i.CodUsuarioCancelamento');
            Q.AddCmd('left join printerpp00 on pp0_codseq = p.codppr    ');
            Q.AddCmd('where v.codvenda      =@codped                    ');
            Q.AddCmd('and   i.mprintstatus  =@status                    ');
            Q.AddCmd('order by pp0_codseq                               ');
            Q.Open ;

            //
            // pedido (venda)
            //
            p0 :=Self ;
            if p0 <> nil then
            begin
                p0.openom :=Q.Field('itm_openom').AsString ;
                if not Q.Field('ped_codmsa').IsNull then
                    p0.codmsa:=Q.Field('ped_codmsa').AsInteger
            end;

            while not Q.Eof do
            begin
//                codped :=Q.Field('ped_codigo').AsInteger ;
                codppr :=Q.Field('pp0_codseq').AsInteger ;

                p1 :=p0.IndexOf(codppr);
                if p1 = nil then
                begin
                    p1 :=p0.AddNew(ptPPtr);
                    p1.codseq:=codppr;
                    p1.descri:=Q.Field('pp0_descri').AsString ;
                    p1.codptr:=Q.Field('pp0_codptr').AsInteger;
                    if p1.codptr = 0 then
                    begin
                        p1.codptr:=-1;
                    end;
                end;

                p2 :=p1.AddNew(ptItem) ;
                p2.codseq:=Q.Field('itm_codseq').AsInteger;
                p2.codpro:=Q.Field('itm_codpro').AsInteger;
                p2.quanti:=Q.Field('itm_quanti').AsFloat;
                p2.vlunit:=Q.Field('itm_vlunit').AsCurrency;
                p2.descri:=Q.Field('itm_descri').AsString;
                p2.unidad:=Q.Field('itm_unidad').AsString ;
                p2.codbar:=Q.Field('itm_codbar').AsString ;
                p2.observ:=Q.Field('itm_observ').AsString ;
                p2.openom:=Q.Field('itm_openom').AsString ;
                p2.status:=TPrinter01Status(Q.Field('itm_status').AsInteger);

                Q.Next ;
            end;

        end;

    finally
        Q.Free ;
        pp00List.Free ;
    end;

    //
    if Items <> nil then
        Result :=Items.Count > 0
    else
        Result:=False;

end;

function TCPrinter01.IndexOf(const codseq: Int32): TCPrinter01;
var
  found: Boolean ;
begin
    found :=false ;
    if Assigned(Self.Items)then
    begin
        for Result in Self.Items do
        begin
            if Result.codseq = codseq then
            begin
                found :=True ;
                Break;
            end;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;


procedure TCPrinter01.setPrintStatus;
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand() ;
    try
        C.AddCmd('declare @codped int; set @codped =%d;                  ',[Self.m_parent.codseq]);
        C.AddCmd('declare @codppr int; set @codppr =%d;                  ',[Self.codseq]);
        C.AddCmd('begin tran                                             ');

        if Self.ItemsCancel then
        begin
        Self.status :=psPrintCancel ;
        C.AddCmd('  --//Seta status para ImpressoCancelado              ');
        C.AddCmd('  update CancelamentoVenda                            ');
        C.AddCmd('  set CancelamentoVenda.MPrintStatus =%d              ',[Ord(Self.status)]);
        C.AddCmd('  from produto p                                      ');
        C.AddCmd('  where CancelamentoVenda.codvenda =@codped           ');
        C.AddCmd('  and   p.codppr      =@codppr                        ');
        C.AddCmd('  and   p.Codproduto  =CancelamentoVenda.Codproduto;  ');
        end
        else begin
        Self.status :=psPrint ;
        C.AddCmd('  --//Seta status para Impresso                        ');
        C.AddCmd('  update detalhevenda set detalhevenda.MPrintStatus =%d',[Ord(Self.status)]);
        C.AddCmd('  from produto p                                       ');
        C.AddCmd('  where detalhevenda.codvenda =@codped                 ');
        C.AddCmd('  and   p.codppr              =@codppr                 ');
        C.AddCmd('  and   p.Codproduto          =detalhevenda.Codproduto;');
        end;
        C.AddCmd('  --//Del. somente o ponto produção dos items impresso ');
        C.AddCmd('  delete from printer01                                ');
        C.AddCmd('  where pr1_codped =@codped                            ');
        C.AddCmd('  and   pr1_codppr =@codppr;                           ');

        C.AddCmd('commit tran                                            ');
        if not C.Prepared then
        begin
            C.Prepared :=True;
        end;
        //C.SaveToFile();
        C.Execute ;
    finally
        C.Free ;
    end;
end;

procedure TCPrinter01.SortByGroup;
var
  comp: IComparer<TCPrinter01> ;
begin
    comp :=TComparer<TCPrinter01>.Construct(
        function (const L, R: TCPrinter01): Integer
        begin
            Result :=Ord(L.m_Group) -Ord(R.m_Group) ;
        end
        );
    _items.Sort(comp) ;
end;

{ TCPrinterPP00List }

function TCPrinterPP00List.AddNew: TCPrinterPP00;
begin
    Result :=TCPrinterPP00.Create ;
    Result._owner :=Self ;
    Result._ItemIndex :=Self.Count ;
    Self.Add(Result) ;
end;

constructor TCPrinterPP00List.Create;
begin
  _hosts :=TStringList.Create ;

end;

destructor TCPrinterPP00List.Destroy;
begin
  _hosts.Destroy ;
  inherited;
end;

procedure TCPrinterPP00List.DoLoad;
var
  Q: TADOQuery ;
  P: TCPrinterPP00;
begin
    //
    // reset
    Self.Clear ;
    //
    Q :=TADOQuery.NewADOQuery() ;
    try
        Q.AddCmd('select *from printerpp00');
        Q.AddCmd('order by pp0_codseq     ');
        Q.Open ;
        while not Q.Eof do
        begin
            P :=Self.AddNew();
            P.pp0_codseq :=Q.Field('pp0_codseq').AsInteger;
            P.pp0_descri :=Q.Field('pp0_descri').AsString ;
            P.pp0_codptr :=Q.Field('pp0_codptr').AsInteger;
            P.pp0_active :=Q.Field('pp0_active').AsInteger > 0;
            P.pp0_codppr :=Q.Field('pp0_codppr').AsInteger;
            Q.Next ;
        end;

        //carrega os hots ja usados
        _hosts.Clear ;
        Q.AddCmd('select distinct pp1_terminalname from printerpp01');
        Q.AddCmd('union all');
        Q.AddCmd('select distinct pr1_xhost from printer01');
        Q.Open;
        while not Q.Eof do
        begin
            if _hosts.IndexOf(Q.Field('pp1_terminalname').AsString) < 0 then
                _hosts.Add(Q.Field('pp1_terminalname').AsString) ;
            Q.Next ;
        end;

    finally
        Q.Free ;
    end;
end;

procedure TCPrinterPP00List.DoRemoveTerminal(const terminal_name: string);
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand();
    try
        C.AddCmd('delete from printerpp01');
        C.AddCmd('where pp1_terminalname =%s',[C.FStr(terminal_name)]);
        C.Execute;
    finally
        C.Free ;
    end;
end;

function TCPrinterPP00List.IndexOf(const codseq: smallint): TCPrinterPP00;
var
  found: Boolean ;
begin
    found :=false ;
    for Result in Self do
    begin
        if Result.pp0_codseq = codseq then
        begin
            found :=True ;
            Break;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

{ TCPrinterPP00 }

function TCPrinterPP00.AddItem: TCPrinterPP01;
begin
    Result :=TCPrinterPP01.Create ;
    Items.Add(Result) ;
end;

constructor TCPrinterPP00.Create;
begin
    _items :=TList<TCPrinterPP01>.Create ;
    _owner :=nil ;

end;

destructor TCPrinterPP00.Destroy;
begin
    _items.Destroy ;
    inherited;
end;

procedure TCPrinterPP00.DoDelete(Item: TCPrinterPP01);
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand() ;
    try
        C.AddCmd('begin tran');
        C.AddCmd('delete from printerpp01');
        C.AddCmd('where pp1_codseq = %d  ',[Item.pp1_codseq]);
        C.AddCmd('commit tran');
        //C.SaveToFile();
        C.Execute ;
    finally
        C.Free ;
    end;
end;

procedure TCPrinterPP00.DoInsert (Item: TCPrinterPP01);
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand() ;
    try
        C.AddCmd('begin tran');
        if Self.pp0_codptr > 0 then
            C.AddCmd('  update printerpp00 set pp0_codptr = %d',[Self.pp0_codptr])
        else
            C.AddCmd('  update printerpp00 set pp0_codptr = null');
        C.AddCmd('  where pp0_codseq = %d  ',[Self.pp0_codseq]);

        C.AddCmd('  insert into printerpp01(pp1_codppr ,     ');
        C.AddCmd('                          pp1_codptr ,     ');
        C.AddCmd('                          pp1_terminalid  ,');
        C.AddCmd('                          pp1_terminalname,');
        C.AddCmd('                          pp1_terminalport,');
        C.AddCmd('                          pp1_xhost       ,');
        C.AddCmd('                          pp1_princ ,      ');
        C.AddCmd('                          pp1_maxttv,      ');
        C.AddCmd('                          pp1_numcop,      ');
        C.AddCmd('                          pp1_typdoc)      ');
        C.AddCmd('  values               (  %d,--pp1_codppr  ',[Item.pp1_codppr]);
        C.AddCmd('                          %d,--pp1_codptr  ',[Item.pp1_codptr]);
        C.AddCmd('                          %s,--pp1_terminalid',[C.FStr(Item.pp1_terminalid)]);
        C.AddCmd('                          %s,--pp1_terminalname',[C.FStr(Item.pp1_terminalname)]);
        C.AddCmd('                          %s,--pp1_terminalport',[C.FStr(Item.pp1_terminalport)]);
        C.AddCmd('                          %s,--pp1_xhost   ',[C.FStr(Item.pp1_xhost)]);
        C.AddCmd('                          %d,--pp1_princ   ',[Ord(Item.pp1_princ)]);
        C.AddCmd('                          %d,--pp1_numttv  ',[Item.pp1_numttv]);
        C.AddCmd('                          %d,--pp1_numcop  ',[Item.pp1_numcop]);
        C.AddCmd('                          %d)--pp1_typdoc  ',[Ord(Item.pp1_typdoc)]);

        C.AddCmd('commit tran');
        //C.SaveToFile();
        C.Execute ;
    finally
        C.Free ;
    end;

    //
    // obtem o ult. codseq
    //
    Item.pp1_codseq :=TADOQuery.ident_current('printerpp01') ;
end;

procedure TCPrinterPP00.DoLoadItems(const codppr: Int16);
var
  Q: TADOQuery ;
  p01: TCPrinterPP01;
begin
    Self.Items.Clear;

    Q :=TADOQuery.NewADOQuery() ;
    try
        Q.AddCmd('select *from printerpp01  ');
        Q.AddCmd('where pp1_codppr     =%d  ',[codppr]);
        //Q.AddCmd('and   pp1_terminalid =%s  ',[Q.FStr(terminal)]) ;
        Q.Open ;
        while not Q.Eof do
        begin
            p01 :=Self.AddItem();
            p01.pp1_codseq :=Q.Field('pp1_codseq').AsInteger;
            p01.pp1_codppr :=Q.Field('pp1_codppr').AsInteger;
            p01.pp1_codptr :=Q.Field('pp1_codptr').AsInteger;
            p01.pp1_terminalid :=Q.Field('pp1_terminalid').AsString ;
            p01.pp1_terminalname :=Q.Field('pp1_terminalname').AsString ;
            p01.pp1_terminalport :=Q.Field('pp1_terminalport').AsString ;
            p01.pp1_xhost :=Q.Field('pp1_xhost').AsString ;
            p01.pp1_princ :=Q.Field('pp1_princ').AsInteger > 0;
            p01.pp1_numcop:=Q.Field('pp1_numcop').AsInteger ;
            p01.pp1_numttv:=Q.Field('pp1_numttv').AsInteger ;
            p01.pp1_maxttv:=Q.Field('pp1_maxttv').AsInteger ;
            p01.pp1_typdoc:=TPrinter01Doc(Q.Field('pp1_typdoc').AsInteger) ;
            //
            // proxima porta
            Q.Next ;
        end;
    finally
        Q.Free ;
    end;
end;

procedure TCPrinterPP00.DoUpdate (Item: TCPrinterPP01);
var
  C: TADOCommand ;
begin
    //
    // LIMITA DESCRIÇÃO
    pp0_descri :=Copy(pp0_descri, 1, 30) ;
    //
    //
    C :=TADOCommand.NewADOCommand() ;
    try
        C.AddCmd('begin tran');
        C.AddCmd('update printerpp00 set ');
        if pp0_codptr > 0 then
            C.AddCmd('  pp0_codptr = %d,',[Self.pp0_codptr])
        else
            C.AddCmd('  pp0_codptr = null,');

        if pp0_codppr > 0 then
            C.AddCmd('  pp0_codppr = %d,',[Self.pp0_codppr])
        else
            C.AddCmd('  pp0_codppr = null,') ;

        C.AddCmd('  pp0_descri = %s',[C.FStr(Self.pp0_descri)]) ;
        C.AddCmd('where pp0_codseq = %d  ;',[Self.pp0_codseq]);

        //
        // ch item
        if Item <> nil then
        begin
            C.AddCmd('update printerpp01 set ');
            if Item.pp1_codptr > 0 then
            begin
                C.AddCmd('  pp1_codptr       =%d,',[Item.pp1_codptr]);
                C.AddCmd('  pp1_terminalname =%s,',[C.FStr(Item.pp1_terminalname)]);
                C.AddCmd('  pp1_terminalport =%s,',[C.FStr(Item.pp1_terminalport)]);
                C.AddCmd('  pp1_xhost        =%s,',[C.FStr(Item.pp1_xhost)]);
                C.AddCmd('  pp1_numcop       =%d,',[Item.pp1_numcop]);
                C.AddCmd('  pp1_maxttv       =%d,',[Item.pp1_maxttv]);
                C.AddCmd('  pp1_numttv       =%d,',[Item.pp1_numttv]);
                C.AddCmd('  pp1_typdoc       =%d ',[Ord(Item.pp1_typdoc)]) ;
            end
            else begin
                C.AddCmd('  pp1_codptr       =null,');
                C.AddCmd('  pp1_terminalname =null,');
                C.AddCmd('  pp1_terminalport =null,');
                C.AddCmd('  pp1_xhost        =null,');
                C.AddCmd('  pp1_numcop       =1,   ');
                C.AddCmd('  pp1_maxttv       =0,   ');
                C.AddCmd('  pp1_numttv       =0,   ');
                C.AddCmd('  pp1_typdoc       =null ') ;
            end;
            C.AddCmd('where pp1_codseq = %d  ',[Item.pp1_codseq]);
        end;

        C.AddCmd('commit tran');
        //C.SaveToFile();
        C.Execute ;
    finally
        C.Free ;
    end;
end;

function TCPrinterPP00.IndexOf(const terminal_id: string): TCPrinterPP01;
var
  found: Boolean ;
begin
    found :=false ;
    for Result in Self.Items do
    begin
        if Result.pp1_terminalid = terminal_id then
        begin
            found :=True ;
            Break;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinterPP00.IndexOfByDoc(const typdoc: TPrinter01Doc): TCPrinterPP01;
var
  found: Boolean ;
begin
    found :=false ;
    for Result in Self.Items do
    begin
        if Result.pp1_typdoc = typdoc then
        begin
            found :=True ;
            Break;
        end;
    end;
    if not found then
    begin
        Result :=nil;
    end;
end;

function TCPrinterPP00.LoadItems(const codppr: Int16;
  const terminal: string): Boolean;
var
  Q: TADOQuery ;
  p01: TCPrinterPP01;
begin
    Self.Items.Clear;

    Q :=TADOQuery.NewADOQuery() ;
    try
        Q.AddCmd('select *from printerpp01  ');
        Q.AddCmd('where pp1_codppr     =%d  ',[codppr]);
        Q.AddCmd('and   pp1_terminalid =%s  ',[Q.FStr(terminal)]) ;
        Q.Open ;
        Result :=not Q.IsEmpty ;
        while not Q.Eof do
        begin
            p01 :=Self.AddItem();
            p01.pp1_codseq :=Q.Field('pp1_codseq').AsInteger;
            p01.pp1_codppr :=Q.Field('pp1_codppr').AsInteger;
            p01.pp1_codptr :=Q.Field('pp1_codptr').AsInteger;
            p01.pp1_terminalid :=Q.Field('pp1_terminalid').AsString ;
            p01.pp1_terminalname :=Q.Field('pp1_terminalname').AsString ;
            p01.pp1_terminalport :=Q.Field('pp1_terminalport').AsString ;
            p01.pp1_xhost :=Q.Field('pp1_xhost').AsString ;
            p01.pp1_princ :=Q.Field('pp1_princ').AsInteger > 0;
            p01.pp1_numcop:=Q.Field('pp1_numcop').AsInteger ;
            p01.pp1_numttv:=Q.Field('pp1_numttv').AsInteger ;
            p01.pp1_maxttv:=Q.Field('pp1_maxttv').AsInteger ;
            p01.pp1_typdoc:=TPrinter01Doc(Q.Field('pp1_typdoc').AsInteger) ;
            //
            // proxima porta
            Q.Next ;
        end;
    finally
        Q.Free ;
    end;
end;

{ TCPrinterPP01 }

procedure TCPrinterPP01.DoMerge() ;
var
  C: TADOCommand ;
begin
    C :=TADOCommand.NewADOCommand() ;
    try
        if Self.pp1_codseq > 0 then
        begin
            C.AddCmd('update printerpp01 set ');
            C.AddCmd('  pp1_terminalname =%s,',[C.FStr(Self.pp1_terminalname)]);
            C.AddCmd('  pp1_terminalport =%s,',[C.FStr(Self.pp1_terminalport)]);
            C.AddCmd('  pp1_xhost        =%s ',[C.FStr(Self.pp1_xhost)]);
            C.AddCmd('where pp1_codseq = %d  ',[Self.pp1_codseq]);
        end
        else begin
            C.AddCmd('insert into printerpp01(pp1_codppr    ,');
            C.AddCmd('                      pp1_codptr      ,');
            C.AddCmd('                      pp1_terminalid  ,');
            C.AddCmd('                      pp1_terminalname,');
            C.AddCmd('                      pp1_terminalport,');
            C.AddCmd('                      pp1_xhost       ,');
            C.AddCmd('                      pp1_princ)      ');
            C.AddCmd('values               (%d              ,',[Self.pp1_codppr]);
            C.AddCmd('                      %d              ,',[Self.pp1_codptr]);
            C.AddCmd('                      %s              ,',[C.FStr(Self.pp1_terminalid)]);
            C.AddCmd('                      %s              ,',[C.FStr(Self.pp1_terminalname)]);
            C.AddCmd('                      %s              ,',[C.FStr(Self.pp1_terminalport)]);
            C.AddCmd('                      %s              ,',[C.FStr(Self.pp1_xhost)]);
            C.AddCmd('                      %d)              ',[Ord(Self.pp1_princ)]);
        end;
        C.Execute ;
    finally
        C.Free ;
    end;
end;


{ TCPrinter01DocPP }

constructor TCPrinter01DocPP.Create(const aShowCodPro: Boolean);
begin
    inherited Create;
    m_ShowCodPro :=aShowCodPro ;
end;

class function TCPrinter01DocPP.New(
  const aShowCodPro: Boolean): IPrinter01Doc;
begin
    Result :=TCPrinter01DocPP.Create(aShowCodPro);

end;

function TCPrinter01DocPP.Prepare(p01: TCPrinter01; p00: TCPrinter00): string;
var
  S: TStringWriter;
  I: TCPrinter01;
  U: UtilStr ;
var
  L,P,C: Integer;
  lin_f1,lin_f2: string;
  oper_id: string;
  part_dec: Currency;
  obs: TStrings;
  Q,part_Q: Double;
  N,part_I: Int32 ;
begin
    if p00 = nil then
    begin
        Exit('');
    end;
    //
    // format doc. conforme impressora!
    //
    S :=TStringWriter.Create();
    try
        //
        // copias
        //
        C :=0; Q :=0; N :=0;
        repeat

          I :=p01.Items[0];
          if I.status = psCancel then
              S.WriteLine('<e><n>*** C A N C E L A D O **</n></e>')
          else begin
              S.WriteLine('***' +Empresa.xFant +'***');
          end;

          //S.WriteLine('Pedido.: %.6d      Data/Hora: %s',[p01.parent.codseq,U.fDat(p01.parent.datsys)]);
          lin_f1 :=Format('Pedido.: %.6d',[p01.m_parent.codseq]);
          lin_f2 :='Data/Hora: '+U.fDtTm(p01.m_parent.datsys);
          S.WriteLine(lin_f1 +'  '+lin_f2);

          if p01.m_parent.codmsa >= 800 then
          begin
              S.WriteLine('Atend..: %-16s',[I.openom]) ;
              if p01.m_parent.retirada then
              begin
                  S.WriteLine('<e><n>RETIRADA   BALCAO</n></e>');
              end ;
              S.WriteLine(Format('<e><n>Entrega : %.3d</n></e>',[p01.m_parent.codmsa,p01.m_parent.codseq]));
              S.WriteLine(Format('Cliente : <e><n>%s</n></e>',[UpperCase(p01.m_parent.cli_nome)]));
              S.WriteLine(Format('Endereco: <e><n>%s</n></e>',[UpperCase(p01.m_parent.cli_endere)]));
              S.WriteLine(Format('Bairro  : <e><n>%s</n></e>',[UpperCase(p01.m_parent.cli_bairro)]));
              S.WriteLine(Format('Obs     : <e><n>%s</n></e>',[UpperCase(p01.m_parent.cli_obs)]));
          end
          else begin
              if p01.m_parent.issenh then
              begin
                  S.WriteLine('Atend..: %-16s',[p01.m_parent.openom]) ;
                  S.WriteLine('<e><n>Senha: %.3d</n></e>',[p01.m_parent.codmsa]) ;
              end
              else begin
                  S.WriteLine('Atend..: %-16s',[I.openom]);
                  S.WriteLine('<e><n>Mesa: %.3d</n></e>',[p01.m_parent.codmsa]);
              end;
          end;

          S.WriteLine(U.Dupe(p00.pr0_defcol,'*'));

          if p00.NumCop > 1 then
          begin
              lin_f1 :=Format('%s   Via:%.2d',[UpperCase(p01.descri),C+1]);
              S.WriteLine(Format('<e><n>%s</n></e>',[lin_f1]));
          end
          else
              S.WriteLine(Format('<e><n>%s</n></e>',[UpperCase(p01.descri)]));

          S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
          if m_ShowCodPro then
              S.WriteLine('Codigo Descricao')
          else
              S.WriteLine('Descricao');
          S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));

          for I in p01.Items do
          begin
              if m_ShowCodPro then
                  lin_f1 :=Format('<e><n>%s %s',[I.codbar,UpperCase(I.descri)])
              else
                  lin_f1 :=Format('<e><n>%s',[UpperCase(I.descri)]);
              if I.fmtqtd then
              begin
                  part_Q :=RoundTo(I.quanti, -2) ;
                  part_I :=Trunc(part_Q*100);
                  //if part_Q = 0.25 then
                  if part_I = 25 then
                    lin_f2 :='  <s>Qtde: 1/4</s></n></e>'
                  else if part_I = 33 then
                    lin_f2 :='  <s>Qtde: 1/3</s></n></e>'
                  //else if part_Q = 0.50 then
                  else if part_I = 50 then
                    lin_f2 :='  <s>Qtde: 1/2</s></n></e>'
                  //else if part_Q = 0.75 then
                  else if part_Q = 75 then
                    lin_f2 :='  <s>Qtde: 3/4</s></n></e>'
                  else begin
                    if Frac(I.quanti) > 0 then
                      lin_f2 :=Format('  <s>Qtde: %5.3n</s></n></e>',[I.quanti])
                    else
                      lin_f2 :=Format('  <s>Qtde: %d</s></n></e>',[Trunc(I.quanti)]) ;
                  end;
                  Q :=Q +part_Q;
                  N :=N +part_I;
                  if(100 -N)=1 then
                  begin
                      N :=100;
                      Q :=1;
                  end;
              end
              else begin
                  if Frac(I.quanti) > 0 then
                      lin_f2 :=Format('  <s>Qtde:%5.3f</s></n></e>',[I.quanti])
                  else
                      lin_f2 :=Format('  <s>Qtde: %d</s></n></e>',[Trunc(I.quanti)]);
              end;
              S.WriteLine(lin_f1) ;
              S.WriteLine(lin_f2) ;

              if I.observ <> '' then
              begin
                  //S.WriteLine('<e><n>Obs: %-42s</n></e>',[I.observ]);
                  lin_f1 :=I.observ ;
                  obs :=TStringList.Create ;
                  while lin_f1 <> '' do
                  begin
                      P :=U.Pos(';', lin_f1) ;
                      if P > 0 then
                      begin
                          obs.Add(Copy(lin_f1,1,P-1));
                          lin_f1 :=Copy(lin_f1,P+1,Length(lin_f1))
                      end
                      else begin
                          obs.Add(lin_f1);
                          lin_f1 :='';
                      end;
                  end;
                  for L :=0 to obs.Count -1 do
                  begin
                      lin_f1 :=obs.Strings[L];
                      if L = 0 then
                        S.WriteLine('<e><n>Obs: %s</n></e>',[lin_f1])
                      else
                        S.WriteLine('<e><n> %s</n></e>',[lin_f1]);
                  end;
              end;

              if I.fmtqtd then
              begin
                  if Q >= 1 then
                  begin
                      Q :=0;
                      S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
                  end;
              end
              else
                  S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
          end;

          if I.status = psCancel then
          begin
              S.WriteLine('<e><n>*** C A N C E L A D O **</n></e>');
          end;

          if p00.pr0_avanco > 0 then
          begin
              for L :=1 to p00.pr0_avanco do
              begin
                  S.WriteLine('');
              end;
          end;
          S.WriteLine('</corte_parcial>');

          Inc(C);

        until (C >= p00.NumCop);

        Result :=S.ToString ;
    finally
        S.Free;
        if Assigned(obs) then
        begin
          obs.Free;
        end;
    end;
end;

{ TCPrinter01DocParcial }

function TCPrinter01DocParcial.Prepare(p01: TCPrinter01;
  p00: TCPrinter00): string;
var
  S: TStringWriter;
  I: TCPrinter01;
var
  L,P: Integer;
  lin_pro,lin_qtd,fmt_fra,fmt_int,F: string;
  oper_id: string;
  sub_tot,sum_itms: Currency;
  vTot_Desc: Currency;
var
  U: UtilStr ;
begin

    if p00 = nil then
    begin
        Exit('');
    end;
    //
    // Format doc. conforme impressora!
    S :=TStringWriter.Create();
    try
        L :=p00.pr0_defcol -6 ;
        S.WriteLine('<e><n>NAO E DOCUMENTO FISCAL</n></e>');
        S.WriteLine('***%.'+IntToStr(L)+'s***',[Empresa.xFant]);

        F :=Format('Pedido: %.6d',[p01.parent.codseq]);
        F :=F +U.fDtTm(p01.parent.datsys,'"  Data/Hora: "DD/MM/YYYY hh:nn');

        S.WriteLine(F);
        S.WriteLine('Atend.: %-16s',[p01.parent.openom]) ;
        S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
        S.WriteLine('P A R C I A L  MESA No.: %.3d',[p01.parent.codmsa]);
        S.WriteLine(U.Dupe(p00.pr0_defcol,'='));
        //
        // format column.cab conforme largura!
        if p00.pr0_defcol >42 then
        begin
          S.WriteLine(' #  DESCRICAO    QDE  UN   R$VL.UN   R$VL.TOT ');
          fmt_fra :='             %6.3f  %s %7.2f  %7.2f ';
          fmt_int :='             %6d  %s %7.2f  %7.2f ';
        end
        else begin
          if p00.pr0_defcol >36 then
          begin
            S.WriteLine('#  DESCRICAO    QDE  UN  R$VL.UN  R$VL.TOT');
            fmt_fra :='             %6.3f  %s    %7.2f     %9.2f';
            fmt_int :='             %6d  %s     %7.2f      %9.2f';
          end
          else begin
            S.WriteLine('#  DESCRICAO QDE UN R$VL.UN R$VL.TOT');
            fmt_fra :='         %6.3f %s   %7.2f    %9.2f';
            fmt_int :='         %6d   %s   %7.2f    %9.2f';
          end;
        end;
        S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));

        //
        // inicia totalizadores
        sub_tot :=0; sum_itms :=0;
        vTot_Desc :=p01.parent.vdesc ;
        for I in p01.Items do
        begin
            L :=(p00.pr0_defcol  -U.Len(I.codbar))-1;
            lin_pro :='%.2d %-.'+IntToStr(L)+'s';
            lin_pro :=Format(lin_pro,[I.ItemIndex +1,UpperCase(I.descri) +I.transf]);
            if Frac(I.quanti) > 0 then
                lin_qtd :=Format(fmt_fra,[I.quanti,I.unidad,I.vlunit,I.quanti *I.vlunit])
            else
                lin_qtd :=Format(fmt_int,[Trunc(I.quanti),I.unidad,I.vlunit,I.quanti *I.vlunit]);
            S.WriteLine(lin_pro) ;
            S.WriteLine(lin_qtd) ;
            //
            //
            sub_tot :=sub_tot +I.quanti *I.vlunit;
            sum_itms :=sum_itms +I.quanti ;
            vTot_Desc :=vTot_Desc +I.vdesc ;
        end;
        S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));

        F :=Format('Quantidade Itens: %d',[Trunc(sum_itms)]) ;
        S.WriteLine(F);

        F :=Format('Sub. total: %12.2m',[sub_tot]) ;
        S.WriteLine(F);

        F :=Format('Tx de servico: %12.2m',[p01.parent.vacres]);
        S.WriteLine(F);

        if vTot_Desc > 0 then
        begin
            F :=Format('Desconto: %12.2m',[vTot_Desc]);
            S.WriteLine(F);
        end;

        F :=Format('TOTAL: %12.2m',[(sub_tot +p01.parent.vacres)-vTot_Desc]) ;
        S.WriteLine('<e><n>%s</n></e>',[F]);

        S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
        F :='Tempo de permanencia: '+U.fTm(p01.parent.datsys -p01.parent.dtvend);
        //L :=p00.pr0_defcol -U.Len(F) ;
        //F :=StuffString(F, Pos(':',F)+1, L, U.Dupe(L)) ;
        S.WriteLine(F);
        if p01.parent.npessoa > 1 then
        begin
            F :=Format('Valor por pessoa: %10.2m',[(sub_tot +p01.parent.vacres)/p01.parent.npessoa]) ;
            S.WriteLine(F);
        end;
        S.WriteLine(U.Dupe(p00.pr0_defcol,'-'));
        S.WriteLine('<e><n>NAO E DOCUMENTO FISCAL</n></e>');

        if p00.pr0_avanco > 0 then
        begin
            for L :=0 to p00.pr0_avanco do
            begin
                S.WriteLine('');
            end;
        end;
        S.WriteLine('</corte_parcial>');

        Result :=S.ToString ;
        {with TStringList.Create do
        try
          Add(Result) ;
          SaveToFile('0.txt');
        finally
          free;
        end;}

    finally
        S.Free;
    end;
end;


{ TCPrinter01DocDelivery }

function TCPrinter01DocDelivery.Prepare(p01: TCPrinter01;
  p00: TCPrinter00): string;
begin

end;


end.
