use uretimm2
create table musteri(
	musteriId int primary key,
	
	);

create table urun(
	urunId int primary key,
	fiyati decimal(10,2),
	stok int,
	
);


create table fire(
	
	urunId int foreign key references urun(urunId),
	karantina int,
	hurda int,
	saglam int,
);




create table talep(
	musteriId int foreign key references musteri(musteriId),
	urunId int foreign key references urun(urunId),
	miktar int,
	taleptarih DATETIME,
	toplamfiyat decimal(10,2),
	);


declare @counter int
declare @musteriId int
declare @urunId int

set @counter=0

while @counter<100000
begin 

	insert into musteri(musteriId)
	values(@counter+1)

	insert into urun(urunId,fiyati,stok)
	values(@counter+1,RAND()*100,RAND()*1000)

	insert into fire(urunId,karantina,hurda,saglam)
	values(@counter+1,RAND()*30,RAND()*10,RAND()*960)

	insert into talep(musteriId,urunId,miktar,taleptarih,toplamfiyat)
	values(@counter+1,@counter+1,RAND()*1000,GETDATE(),RAND()*10000)

	set @counter=@counter+1
end

--alter
alter table musteri add gecmistalep int,
create procedure update talepbilgisi
	@musteriId int,
	@urunId int,

as
begin

	update talep
	set toplamfiyat=(select sum(f.fiyati*m.miktar)
	                  from talep m
					  inner join  urun u on m.urunId=u.urunId
					  where m.talep=@orderId
					  ) where m.urunId=@urunId
	where urunId=@counterId


	update musteri
	set proviousordercount=proviousordercount+1
	where musteriId=@musteriId
end



--trigger

create trigger stokguncelle
on urun
after insert
as
begin
	declare @urunId int
	declare @miktar int

	select @urunId=@urunId,@miktar=@miktar from inserted

	update urun
	set stok=stok-@miktar
	where urunId=@urunId

end 

--view

create view fiyatagoretoplamsatis as 
select u.urun, sum(t.toplamfiyat) as toplamsatis
from talep t
join urun u on t.urunId=u.urunId
join urun u on u.urun=t.urunId
group by u.urunId

select*from totalsalesbycategories

--sql sorgular? 

--sorgu1

use uretimm2

select 
fire.saglam,
urun.stok

from

fire

inner join talep on fire.urunId=talep.urunId
inner join urun on talep.urunId=urun.urunId


--sorgu2

select top 1
urunId,

(select count(urunId)from urun) as totalhurda
from talep
order by taleptarih desc

--sorgu3

declare @hurda int
declare @karantina int
declare @saglam int
declare @miktar int
declare @stok int

IF @hurda+@karantina<@saglam and @stok>@miktar
begin 
	print 'firma kar yapar';
end
else 
IF @hurda+@karantina>@saglam and @stok<@miktar 
begin
	print 'firma zararda';
end

--sorgu4


declare @urunId int
declare @hurda int
declare @saglam int

set @urunId=(select max(urunId) from fire)
set @hurda=(select hurda from fire where urunId=@urunId)

while @urunId

begin
	if @hurda < @saglam
	begin 
		set @urunId=(select max(urunId) from fire where urunId=@urunId)
		set @hurda =(select hurda from fire where urunId=@urunId)
		continue 
	end

	print 'kar'
 end 

	if @hurda>@saglam
	begin
	set @urunId=(select max(urunId) from fire where urunId=@urunId)
	set @hurda=(select hurda from fire where urunId=@urunId)
	continue

	end
	print 'zarar'









