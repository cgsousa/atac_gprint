use comercio
go

set ansi_nulls on
go

set quoted_identifier on
go

/***
* SIS-script para uso de configurações parametrizadas e auto-numerações do sistema
* ATAC Sistemas
* Todos os Direitos Reservados
* Autor: Carlos Gonzaga
* Data: 02.02.2018
*/

--//***********************
--//gen. de numeração unica
--//***********************
if not exists(select 1 from sysobjects where id = object_id('genserial') and xtype = 'U')
  create table genserial(ser_ident varchar(50) not null ,
    ser_valor bigint null ,
    ser_inival int not null default 1 ,
    ser_incval int not null default 1 ,
    ser_minval int not null default 1 ,
    ser_maxval bigint null ,
    ser_descri varchar(250) ,
    constraint pk__genserial primary key (ser_ident)
  )
go

if not exists(select 1 from syscolumns where id = object_id('genserial') and name = 'ser_catego')
  alter table genserial add ser_catego varchar(30) null
go  

if exists(select 1 from sysobjects where id = object_id('sp_setval') and xtype = 'P')
  drop procedure sp_setval
go
create procedure sp_setval(@ser_ident varchar(50),
  @ser_inival int = 1,
  @ser_incval int = 1,
  @ser_minval int = 1,
  @ser_maxval bigint = 0,
  @ser_descri varchar(50) = null
)
as
  declare @ser_catego varchar(30); 
  --// 
  --// check categoria
  declare @p1 smallint; set @p1 =charindex('[', @ser_ident);
  declare @p2 smallint; set @p2 =charindex(']', @ser_ident);
  if(@p1 >0)and(@p2 >0)
  begin
      set @ser_catego =substring(@ser_ident, @p1+1, @p2-(@p1+1));
      set @ser_ident  =substring(@ser_ident, @p2+1, len(@ser_ident));
  end;

  --//check 
  if not exists(select *from genserial where ser_ident =@ser_ident)
  begin
      insert into genserial
      select  @ser_ident ,
              null ,
              case when @ser_inival is null then 1 else @ser_inival end ,
              case when @ser_incval is null then 1 else @ser_incval end ,
              case when @ser_minval is null then 1 else @ser_minval end ,
              case when @ser_maxval is null then 0 else @ser_maxval end ,
              @ser_descri, @ser_catego
  end
go

if exists(select 1 from sysobjects where id = object_id('sp_nextval') and xtype = 'P')
  drop procedure sp_nextval
go
create procedure sp_nextval(
  @ser_ident varchar(50),
  @ser_outval bigint out,
  @begin_tran smallint = 1 
)
as
  declare
    @ser_valor bigint,
    @ser_inival int,
    @ser_incval int,
    @ser_minval int,
    @ser_maxval bigint;

  declare
    @trans_count smallint; set @trans_count =@@trancount ;
  
  select
    @ser_valor  =ser_valor,
    @ser_inival =ser_inival,
    @ser_incval =ser_incval,
    @ser_minval =ser_minval,
    @ser_maxval =ser_maxval 
  from genserial
  where ser_ident =@ser_ident;
  
  set @ser_outval =0;
  
  if @ser_inival is not null
  begin
    if @ser_valor is null
      set @ser_outval =@ser_inival
    else begin
      set @ser_outval =@ser_valor +@ser_incval
      --//valida limite
      if @ser_maxval > 0 
      begin
        if @ser_outval > @ser_maxval 
          raiserror(N'Sequência [%s], chegou no limite [%d]!', 16, 1, @ser_ident, @ser_maxval);
      end
    end
    if @begin_tran = 1 
      begin tran
    update genserial
    set ser_valor =@ser_outval
    where ser_ident =@ser_ident
    if @begin_tran = 1
      commit tran
  end
  else
    raiserror(N'Sequência [%s] não encontrada!', 16, 1, @ser_ident);
go


if not exists (select *from dbo.sysobjects where id = object_id(N'parametro') and objectproperty(id, N'IsTable') = 1)
  create table parametro(prm_ident varchar (50) not null,
    prm_valtyp smallint	not null ,
    prm_xvalue varchar (125) null,
    prm_catego varchar (30) null ,
    prm_comple varchar (125) null,
    prm_descri varchar (100) null ,
    prm_update datetime	null
  )
go

if not exists (select name from sysindexes
            where name = 'idx_parametro_prm_ident_01')
create unique nonclustered index  idx_parametro_prm_ident_01
    on parametro(prm_ident)
go

