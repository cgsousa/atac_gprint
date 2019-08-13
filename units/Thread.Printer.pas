{***
* Thread para o serviço de impressão
* Atac Sistemas
* Todos os direitos reservados
* Autor: Carlos Gonzaga
* Data: 03.04.2019
*}
unit Thread.Printer;

{*
******************************************************************************
|* PROPÓSITO: Registro de Alterações
******************************************************************************

Símbolo : Significado

[+]     : Novo recurso
[*]     : Recurso modificado/melhorado
[-]     : Correção de Bug (assim esperamos)



02.05.2019
[*] Controle tipo documento
    Um ponto pode conter varias portas/documentos(TCPrinterPP01.pp1_typdoc)
    A fila de trabalhos é agrupada por tipo documento(TCPrinter01.pr1_typdoc)

25.04.2019
[-] Aborta impressão do PP (agrupamento) qdo ocorrer erros na impressão do PP
    normal

03.04.2019
[*] Movido o source antigo pra K

16.05.2018
[*] SQL de TCPrinter01List.Load(...) modificado, para lincar primeiro os pontos
    de produção, e so depois, os items/produtos

25.04.2018, CGonzaga,
[*] Indicador se mostra qtd em formato de fração (1/4, 1/2, etc)

*}


interface

uses SysUtils, Classes,
  Generics.Collections ,
  uclass, ulog, uprinter;

type

  RegPrint = record
    doc_MostraCodPro: TPair<string, Boolean>;
    procedure Load() ;
  end;


  TCSvcPrinter = class(TCThreadProcess)
  private
    { Private declarations }
    m_Log: TCLog;
    m_Terminal: string ;
    m_Reg: RegPrint ;
    procedure DoExceptDBError(Sender: TObject; const E: Exception);
  protected
    procedure Execute; override;
    procedure RunProc; override;
    procedure RunProc00;
  public
    constructor Create(const aTerminal: string);
    destructor Destroy; override;
  end;




implementation

uses Windows, ActiveX, DateUtils, DB,
  uadodb, uparam;

{ TCSvcPrinter }

constructor TCSvcPrinter.Create(const aTerminal: string);
begin
    inherited Create(True, False);
    m_Log :=TCLog.Create('', True) ;
    m_Log.AddSec('%s.Create',[Self.ClassName]);
    m_Terminal :=aTerminal ;
    //Self.OnExceptProc :=DoExceptDBError;
end;

destructor TCSvcPrinter.Destroy;
begin
    m_Log.Destroy ;
    inherited;
end;

procedure TCSvcPrinter.DoExceptDBError(Sender: TObject; const E: Exception);
begin
    if ConnectionADO.Connected then
    begin
        ConnectionADO.Close ;
    end;
end;

procedure TCSvcPrinter.Execute;
begin
    m_Log.AddSec('%s.Execute',[Self.ClassName]);
    //
    //
    if ConnectionADO = nil then
    begin
        CoInitialize(nil);
        try
            ConnectionADO :=NewADOConnFromIniFile(
                                ExtractFilePath(ParamStr(0)) +'Configuracoes.ini'
                                ) ;
            inherited Execute;
        finally
            CoUninitialize;
        end;
    end
    else
        inherited Execute;
end;

procedure TCSvcPrinter.RunProc;
var
  p00List: TCPrinter00List; //Lista de impressoras
  p00: TCPrinter00 ;
  p01List: TCPrinter01List;
  p1,p2,p3: TCPrinter01;
  pp00: TCPrinterPP00 ; //Ponto produção
  pp01: TCPrinterPP01 ; //Porta do PP / terminal
  doc: IPrinter01Doc ;
var
  err: string ;
  F: TPrinter01Filter ;
begin
    //
    p00 :=nil;
    //
    //
    // connect database
    if ConnectionADO.Connected then
    begin
        ConnectionADO.Close ;
    end;

    ConnectionADO.Connected :=True;
    if Empresa = nil then
    begin
        Empresa :=TCEmpresa.Instance;
        Empresa.DoLoad(1);
        //CallOnStrProc('Emitente: %s-%s',[Empresa.CNPJ,Empresa.RzSoci]);
    end;
    {if CadEmp = nil then
    begin
        CadEmp :=TCCadEmp.New(1) ;
        CallOnStrProc('Emitente: %s-%s',[CadEmp.CNPJ,CadEmp.xNome]);
    end;}

    //
    // chk impressoras
    p00List :=TCPrinter00List.Create;
    if not p00List.Load() then
    begin
        CallOnStrProc('Nenhuma impressora cadastrada!');
        p00List.Free ;
        ConnectionADO.Close ;
        Self.Terminate;
        Exit ;
    end;

    //
    // carrega parametros
    m_Reg.Load ;

    //
    // inicializa um ponto vazio
    pp00 :=TCPrinterPP00.Create;

    //
    // inicializa lita dos trabalhos
    p01List :=TCPrinter01List.Create ;
    try
//        m_Terminal :='DESENVOLVIMENTO';
      //

      //
      // carrega trabalhos por terminal
      if p01List.Load01(m_Terminal) then
      begin
          //
          // processamento de cada doc
          for p1 in p01List do
          begin
              //
              // chk items
              if not p1.LoadPed(F) then
              begin
                  CallOnStrProc('Nenhum item a imprimir neste pedido[%d]',[p1.codseq]);
                  Continue ;
              end;

              //
              // ordena os pontos por tip doc
              p1.SortByGroup ;

              //
              // processamento de cada ponto de produção
              for p2 in p1.Items do
              begin
                  //
                  // check se abort impressao
                  if p2.status =psAbort then
                  begin
                      Continue;
                  end;

                  CallOnStrProc('%s|Iniciando impressão',[p2.descri]);

                  //
                  // set ponto padrão
                  pp00.pp0_codseq :=p2.codseq;
                  pp00.pp0_descri :=p2.descri;
                  pp00.pp0_codptr :=p2.codptr;
                  //
                  // carrega portas
                  //
                  if not pp00.LoadItems(pp00.pp0_codseq, m_Terminal) then
                  begin
                      //
                      // advertencia!
                      CallOnStrProc('Nenhuma porta encontrada neste ponto\terminal[%s\%s]!',[pp00.pp0_descri,m_Terminal]);
                      //Self.Terminate ;
                      //Break;
                      Continue;
                  end;

                  //
                  // ler porta conforme typdoc
                  //
                  pp01 :=pp00.IndexOfByDoc(p1.typdoc) ;
                  if pp01 = nil then
                  begin
                      //
                      // advertencia!
                      CallOnStrProc('Porta não definida o documento[%s]!',[getPrinter01DocToStr(p1.typdoc)]);
                      Continue;
                  end;

                  //
                  // check tentativas
                  if(pp01.pp1_maxttv > 0)and(pp01.pp1_numttv >= pp01.pp1_maxttv)then
                  begin
                      Continue;
                  end;

                  //
                  // ler impressora
                  //
                  p00 :=p00List.IndexOf(pp01.pp1_codptr);
                  if p00 = nil then
                  begin
                      CallOnStrProc('%s\%s|Impressora não definida!',[p2.descri,pp01.pp1_terminalport]);
                      Continue;
                  end ;

                  CallOnStrProc('%s\%s|Configurando...',[p2.descri,pp01.pp1_terminalport]);
                  //
                  // Configura impressora
                  //
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
                  p00.NumCop    :=pp01.pp1_numcop;

                  //
                  // prepara o doc conforme tipo
                  case p1.typdoc of
                      pdNormal: doc :=TCPrinter01DocPP.New(m_Reg.doc_MostraCodPro.Value); //p2.DoPreparePrint(doc, p00, m_Reg.doc_MostraCodPro.Value);
                      pdAuxiliar: { TODO -cNFE : IMPLEMENTAR ROTINA, APOS IMPRESSAO NORMAL FALHAR! } ;
                      pdParcial: doc :=TCPrinter01DocParcial.Create;
                      // outros ...
                  end;

                  //
                  // print doc
                  //
                  CallOnStrProc('%s\%s|Imprimindo doc(%s)',[p2.descri,pp01.pp1_terminalport,getPrinter01DocToStr(p1.typdoc)]);
                  if p00.Execute(doc.Prepare(p2, p00)) then
                  begin
                      p2.setPrintStatus ;
                      CallOnStrProc('%s\%s|Terminou impressão.',[p2.descri,pp01.pp1_terminalport]);
                  end

                  //
                  // erro/adv impressão
                  //
                  else begin
                      CallOnStrProc('%s\%s|Erro %s!',[p2.descri,pp01.pp1_terminalport, p00.ErrMsg]);
                      //
                      // erro comunicação
                      // check tentativas
                      if(p00.ErrCod =-2)and(pp01.pp1_maxttv > 0)then
                      begin
                          //
                          // inc. tentativa
                          pp01.pp1_numttv :=pp01.pp1_numttv +1;
                          pp00.DoUpdate(pp01);
                      end;

                      //
                      // chk PP qdo agrupamento,
                      // para abortar impressão tbm
                      p3 :=p1.IndexOf(p2.codppr) ;
                      if p3 <> nil then
                      begin
                          p3.status :=psAbort ;
                          CallOnStrProc('%s\%s|Abortado',[p3.descri,pp01.pp1_terminalport]);
                      end;
                  end;

                  //
                  //
                  if Self.Terminated then
                  begin
                      Break;
                  end;
              end;
              if Self.Terminated then
              begin
                  Break ;
              end;
          end;
      end;

    finally
      if Assigned(p00)then
      begin
        p00.Free ;
      end;
      if Assigned(p00List)then
      begin
        p00List.Free;
      end;
      if Assigned(p01List)then
      begin
        p01List.Free ;
      end;
      ConnectionADO.Close ;
    end;
end;

procedure TCSvcPrinter.RunProc00;
var
  p00List: TCPrinter00List; //Lista de impressoras
  p00: TCPrinter00 ;
  p01List: TCPrinter01List;
  p1,p2,p3: TCPrinter01;
  pp00: TCPrinterPP00 ; //Ponto produção
  pp01: TCPrinterPP01 ; //Porta do PP / terminal
var
  doc,err: string ;
begin
    try
    //
    // connect database
    ConnectionADO.Connected :=True ;
    if Empresa = nil then
    begin
        Empresa :=TCEmpresa.Instance;
        Empresa.DoLoad(1);
    end;

    p00List :=TCPrinter00List.Create;
    p01List :=nil;
    pp00 :=TCPrinterPP00.Create;

    //
    // chk impressoras
    if not p00List.Load() then
    begin
        CallOnStrProc('Nenhuma impressora cadastrada!');
        Self.Terminate ;
        Exit ;
    end;

    try
        //
        // cria lista vazia
        p01List :=TCPrinter01List.Create ;

        //
        // monitora impressão
        // carrega pedidos por terminal
        if p01List.Load(m_Terminal) then
        begin
            //
            // processamento de cada doc/impressão
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
                    //
                    // check se abort impressao
                    if p2.status =psAbort then
                    begin
                        Continue;
                    end;

                    CallOnStrProc('%s|Iniciando impressão',[p2.descri]);

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
                    pp01 :=pp00.IndexOf(m_Terminal) ;
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
                            CallOnStrProc('%s|Imprimindo...',[p2.descri]);
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

                            //
                            // chk doctyp


                            p2.DoPreparePrint(doc, p00, m_Reg.doc_MostraCodPro.Value) ;
                            if p00.Execute(doc) then
                            begin
                                p2.setPrintStatus ;
                                CallOnStrProc('%s|Terminou impressão.',[p2.descri]);
                            end

                            //
                            // erro/adv impressão
                            //
                            else begin
                                CallOnStrProc('%s|Erro %s!',[p2.descri, p00.ErrMsg]);
                                //
                                // erro comunicação
                                // check tentativas
                                if(p00.ErrCod =-2)and(pp01.pp1_maxttv > 0)then
                                begin
                                    //
                                    // inc. tentativa
                                    pp01.pp1_numttv :=pp01.pp1_numttv +1;
                                    pp00.DoUpdate(pp01);
                                end;

                                //
                                // chk PP qdo agrupamento,
                                // para abortar impressão tbm
                                p3 :=p1.IndexOf(p2.codppr) ;
                                if p3 <> nil then
                                begin
                                    p3.status :=psAbort ;
                                    CallOnStrProc('%s|Abortado',[p3.descri]);
                                end;
                            end;
                        end
                        else
                            CallOnStrProc('%s|Impressora não definida!',[p2.descri]);
                        if Self.Terminated then
                        begin
                            Break;
                        end;
                    end
                    else begin
                        //
                        // mostra erro com respectivo terminal
                        CallOnStrProc('Nenhuma porta configurada neste terminal[%s]!',[m_Terminal]);
                        Self.Terminate ;
                        Break;
                    end;
                end;
                if Self.Terminated then
                begin
                    Break ;
                end;
            end;
        end;

    finally
      ConnectionADO.Close ;
      if Assigned(p01List)then
      begin
          p01List.Free ;
      end;
      p00List.Free ;
    end;

    except
        on E:EDatabaseError do
        begin
            m_Log.AddSec('Erro de banco: %s',[E.Message]);
        end;
        on E:Exception do
        begin
            m_Log.AddSec('Erro geral: %s',[E.Message]);
        end;
    end;

end;

{ RegPrint }

procedure RegPrint.Load;
const
  CST_CATEGO = 'GPRINT' ;
var
  params: TCParametroList ;
  p: TCParametro ;
  s: TStrings ;
  pp00List: TCPrinterPP00List ;
  pp00: TCPrinterPP00 ;
begin

    params :=TCParametroList.Create ;
    try
        //
        // carrega todos do nfe
        params.Load('', CST_CATEGO) ;

        //
        //
        //
        doc_MostraCodPro.Key :='doc_mostracodpro';
        p :=params.IndexOf(doc_MostraCodPro.Key) ;
        if p = nil then
        begin
            p :=params.AddNew(doc_MostraCodPro.Key) ;
            p.ValTyp:=ftBoolean ;
            P.xValor :='1';
            P.Catego :='GPRINT';
            p.Descricao :='Indicador para mostrar/esconder o cod.produto';
            P.Save ;
        end;
        doc_MostraCodPro.Value :=p.ReadBoo() ;

    finally
        params.Free ;
    end;

end;

end.
