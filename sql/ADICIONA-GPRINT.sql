/**
* script cria/altera objetos do gerenciador de impressão
* Atac Sistemas
* Todos os direitos reservados
* Autor: Carlos Gonzaga
* Data: 16.10.2017
*
******************************************************************************
|* PROPÓSITO: Registro de Alterações
******************************************************************************

Símbolo : Significado

[+]     : Novo recurso
[*]     : Recurso modificado/melhorado
[-]     : Correção de Bug (assim esperamos)
*/

use comercio
go

--//
--//16.10.2017
--//[+] Criação das tabelas ...

--//printer00 (impressoras/esc-pos)
if not exists(select *from sysobjects o where o.id =object_id('printer00') and o.type='U' )
  create table printer00(pr0_codseq smallint not null identity(1,1) ,
    pr0_modelo varchar(30) null ,
	  pr0_nporta varchar(30) null ,
    pr0_descri varchar(50) null ,
	  pr0_xhost varchar(20) null ,
	  pr0_avanco smallint null ,
	  pr0_checki smallint null,
	  pr0_tenttv smallint null ,
	  pr0_expand smallint null ,
	  pr0_corte smallint null ,
    pr0_defcol smallint not null default (48),
    pr0_active smallint not null default (1) ,
    constraint pk__printer00 primary key (pr0_codseq) 
  );
go

--//printerpp00 (pontos de produção/impressão)
if not exists(select *from sysobjects o where o.id =object_id('printerpp00') and o.type='U' )
begin
  create table printerpp00(pp0_codseq smallint not null identity(1,1) ,
    pp0_descri varchar(30) null ,
    pp0_codptr smallint null ,
	  pp0_active smallint not null default(1) ,
    constraint pk__printerpp00 primary key (pp0_codseq) ,
    constraint fk__pp0_codptr foreign key (pp0_codptr) references printer00(pr0_codseq) ,
  )
  --//
  --// inicializa os pontos ...
  declare @pontos varchar(50), @ponto varchar(10); 
  set @pontos = 'Cozinha;Bar;Caixa;Copa';

  declare @tot smallint, @cnt smallint, @pos smallint;

  set @tot = 4;

  while (@pontos <> '')
  begin
      set @pos = charindex(';',@pontos,1);
      if(@pos > 0)
      begin
          set @ponto =substring(@pontos,1,@pos-1);
          set @pontos=substring(@pontos,@pos+1,len(@pontos));
      end
      else begin
          set @ponto =@pontos;
          set @pontos='';
      end;

      set @cnt = 1;
      while (@cnt <= @tot)
      begin
          insert into printerpp00(pp0_descri) values(@ponto +' '+cast(@cnt as char(1)));
          set @cnt =@cnt +1;
      end;
  end;
end
go

--//printerpp01 (portas do pontos de produção/impressão)
if not exists(select *from sysobjects o where o.id =object_id('printerpp01') and o.type='U' )
  create table printerpp01(pp1_codseq int not null identity(1,1) ,
    pp1_codppr smallint not null ,
    pp1_codptr smallint not null ,
    pp1_terminalid varchar(40) not null ,
    pp1_terminalname varchar(30) null , 
    pp1_terminalport varchar(100) not null,
    pp1_xhost varchar(100) null,
    pp1_princ smallint null 
    constraint pk__printerpp01 primary key (pp1_codseq) ,
    constraint fk__pp1_codppr foreign key (pp1_codppr) references printerpp00(pp0_codseq) ,
    constraint fk__pp1_codptr foreign key (pp1_codptr) references printer00(pr0_codseq) 
  );
go

--//printer01 (fila de documentos)
if not exists(select *from sysobjects o where o.id =object_id('printer01') and o.type='U' )
begin 
    create table printer01 (pr1_codseq int not null identity(1,1) ,
      pr1_codped int not null,
      pr1_xhost varchar(30) null,
      pr1_datsys datetime null ,
      pr1_codppr smallint null ,
      pr1_codptr smallint null  
    );
end
go

--//20.3.2018
--//[+] Campo para controle de agrupamento de pontos de impressão
if not exists(select 1from syscolumns where id = object_id('printerpp00') and name = 'pp0_codppr')
  alter table printerpp00 add 
    pp0_codppr smallint null ,
    constraint fk__pp0_codppr foreign key (pp0_codppr) references printerpp00(pp0_codseq) 
go  

--//02.5.2019
--//[+] Campo controle tipo documento

--//um ponto pode conter varias portas/documentos
if not exists(select 1from syscolumns where id = object_id('printerpp01') and name = 'pp1_typdoc')
  alter table printerpp01 add
    pp1_typdoc smallint null
go  

--//a fila de trabalhos é agrupada por tipo documento
if not exists(select 1from syscolumns where id = object_id('printer01') and name = 'pr1_typdoc')
  alter table printer01 add
    pr1_typdoc smallint null,
    pr1_buffer varchar(8000) null 
go  
