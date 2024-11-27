/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 60_HOTEL_RES_Functions_DDL.sql
OPIS		: DDL skripita za funkcije
		
			Procedure:	
				--F01 PLAYGROUND.CHECK_AVAILABILITY
				--F02 PLAYGROUND.GET_LATEST_GUEST_NUM2
				--F03 PLAYGROUND.GET_ROOM_OFFER

AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.0.1			NOV-27-2024		Ispravke u F02						M.Nikolic
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/

/********************************
	FUNKCIJE
*********************************/
--F01 PLAYGROUND.CHECK_AVAILABILITY
CREATE OR REPLACE EDITIONABLE FUNCTION "PLAYGROUND"."CHECK_AVAILABILITY" 
(
  	START_DATE 	IN DATE,
	END_DATE 	IN DATE,
	NUM_PERSONS IN NUMBER 
) RETURN boolean is
    ret_val BOOLEAN := false;
    num_of_free_rooms number;
    
BEGIN

    select count(room_num) into num_of_free_rooms
    from 
    (   --All rooms minus occupied rooms
        select room_num from e_rooms where persons >= num_persons
        minus
        select rm.room_num 
        from e_reservations r 
        inner join e_reservation_rooms rm on r.reservation_cd = rm.reservation_cd
        inner join e_rooms rooms on rm.room_num = rooms.room_num
        where rooms.persons >= num_persons
        and r.curr_status <> 'CANCELED'
        and not ((start_date < r.start_dt and end_date <= r.start_dt)
            or
            (start_date >= r.end_dt and end_date > r.end_dt))
    );
    
    
    if num_of_free_rooms > 0 then
        ret_val := true;
    end if;
        

    RETURN ret_val;
END CHECK_AVAILABILITY;

/

--F02 PLAYGROUND.GET_LATEST_GUEST_NUM2
CREATE OR REPLACE EDITIONABLE FUNCTION "PLAYGROUND"."GET_LATEST_GUEST_NUM2" 
(   
    period_start_dt date,
    period_end_dt 	date
)
return T_DASH_GUEST_NUM_TABLE PIPELINED is
    ret_tab T_DASH_GUEST_NUM_rec;
    var_num_of_guests number;
    iday date;
    trunc_period_end_dt date;
begin
    
    iday := trunc(period_start_dt);
    trunc_period_end_dt := trunc(period_end_dt);
    
    while iday <= trunc_period_end_dt
    loop
        select sum(num_of_guests) into var_num_of_guests from e_reservations where iday between start_dt and end_dt and curr_status <> 'CANCELED';
        ret_tab := T_DASH_GUEST_NUM_rec(iday, var_num_of_guests);
        iday := iday + 1;
        
        pipe row(ret_tab);
    end loop;
    
end;

/

--F03 PLAYGROUND.GET_ROOM_OFFER
CREATE OR REPLACE EDITIONABLE FUNCTION "PLAYGROUND"."GET_ROOM_OFFER" 
(
  	START_DATE 		IN DATE,
	END_DATE 		IN DATE,
	NUM_PERSONS 	IN NUMBER 
) RETURN CLOB sql_macro AS
 query_str CLOB;
 breakfast_price varchar(10);
BEGIN
 
 select value into breakfast_price from e_lov where key = 'BREAKFAST_PRICE_PER_PERSON' and type = 'HOTEL_REF';

 query_str := '
  select r.room, p.price * (trunc(end_date)-trunc(start_date)) price, p.price * (trunc(end_date)-trunc(start_date)) + num_persons * (trunc(end_date)-trunc(start_date)) * ' || breakfast_price || ' price_with_b from (select distinct persons room from 
(select room_num, persons from e_rooms where persons >= num_persons
minus
select rm.room_num, rooms.persons from e_reservations r inner join e_reservation_rooms rm
on r.reservation_cd = rm.reservation_cd
inner join e_rooms rooms
on rm.room_num = rooms.room_num
where rooms.persons >= num_persons 
and r.curr_status <> ''CANCELED'' and
not (((start_date < r.start_dt and end_date <= r.start_dt)
or
(start_date >= r.end_dt and end_date > r.end_dt)))
)) r inner join playground.e_room_prices p
on r.room = p.persons
where start_date between p.start_validity_dt and p.end_validity_dt';

 RETURN query_str;
END GET_ROOM_OFFER;

/
