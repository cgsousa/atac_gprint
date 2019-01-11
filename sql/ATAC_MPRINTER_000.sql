--drop table printer00
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

create table printerpp00(pp0_codseq smallint not null identity(1,1) ,
  pp0_descri varchar(30) null ,
  pp0_codptr smallint null ,
	pp0_active smallint not null default(1) ,
  constraint pk__printerpp00 primary key (pp0_codseq) ,
  constraint fk__pp0_codptr foreign key (pp0_codptr) references printer00(pr0_codseq) ,
);

create table printerpp01(pp1_codseq int not null identity(1,1) ,
  pp1_codppr smallint not null ,
  pp1_codptr smallint not null ,
  pp1_terminalid varchar(40) not null ,
  pp1_terminalname varchar(30) null , 
  pp1_terminalport varchar(20) not null,
  pp1_xhost varchar(30) null,
  pp1_princ smallint null 
  constraint pk__printerpp01 primary key (pp1_codseq) ,
  constraint fk__pp1_codppr foreign key (pp1_codppr) references printerpp00(pp0_codseq) ,
  constraint fk__pp1_codptr foreign key (pp1_codptr) references printer00(pr0_codseq) 
);

declare @pontos varchar(50), @ponto varchar(10); 
set @pontos = 'Cozinha;Bar;Caixa;Copa';

declare @tot smallint, @cnt smallint, @pos smallint;

set @tot = 5;

delete from printerpp00;

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

create table printer01 (pr1_codseq int not null identity(1,1) ,
  pr1_codped int not null,
  pr1_xhost varchar(30) null,
  pr1_datsys datetime null ,
  pr1_codppr smallint null ,
  pr1_codptr smallint null  
);


alter table produto add codppr smallint null
go

alter table detalhevenda add MPrintStatus smallint null
go


begin tran
update produto 
set codppr = pp_codseq
from printponto
where Impressora = pp_descri
commit tran
