/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 20_HOTEL_RES_Views_DDL.sql
OPIS		: DDL skripita za poglede(views)
		
			Pogledi:	
				--V01 PLAYGROUND.V_CURRENT_FREE_ROOMS
				--V02 PLAYGROUND.V_CURRENT_PRICES
				--V03 PLAYGROUND.V_DASH_BREAKFAST
				--V04 PLAYGROUND.V_DASH_CURR_HOTEL_UTILIZATION
				--V05 PLAYGROUND.V_DASH_LATEST_GUEST_NUM
				--V06 PLAYGROUND.V_DASH_LENGTH_OF_STAY
				--V07 PLAYGROUND.V_DASH_PRICE_RANGE
				--V08 PLAYGROUND.V_DASH_ROOM_UTILZATION
				--V09 PLAYGROUND.V_RES_STATUS_MAPPING
				--V10 PLAYGROUND.V_TODAY_NEW_GUESTS

AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.1.0			DEC-02-2024		Ispravke u pogledima potrebnim za
								rad dashboard-a						M.Nikolic
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/

/********************************
	POGLEDI
*********************************/
--V01 PLAYGROUND.V_CURRENT_FREE_ROOMS
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_CURRENT_FREE_ROOMS" 
(
	"ROOM_NUM", 
	"PERSONS", 
	"CONFIG"
) 
AS 
	select room_num, persons, single_beds || '+' || double_beds config from e_rooms where e_rooms.persons > 0
	minus
	select rr.room_num, ro.persons, ro.single_beds || '+' || ro.double_beds
	from e_reservations r
	inner join e_reservation_rooms rr on r.reservation_cd = rr.reservation_cd
	inner join e_rooms ro on ro.room_num = rr.room_num
	where trunc(sysdate) BETWEEN trunc(start_dt) and trunc(end_dt) and
	r.curr_status <> 'CANCELED'
	order by room_num
;

--V02 PLAYGROUND.V_CURRENT_PRICES
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_CURRENT_PRICES" 
(
	"ID", 
	"PERSONS", 
	"PRICE", 
	"START_VALIDITY_DT", 
	"END_VALIDITY_DT", 
	"CREATED", 
	"CREATED_BY", 
	"UPDATED", 
	"UPDATED_BY"
)
AS 
	SELECT 
    	"ID",
		"PERSONS",
		"PRICE",
		"START_VALIDITY_DT",
		"END_VALIDITY_DT",
		"CREATED",
		"CREATED_BY",
		"UPDATED",
		"UPDATED_BY"
	FROM 
    	playground.e_room_prices p
	WHERE
    	sysdate between p.start_validity_dt and p.end_validity_dt
;

--V03 PLAYGROUND.V_DASH_BREAKFAST
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_BREAKFAST" 
(
	"LABEL", 
	"VALUE"
)
AS 
	select 
    	"LABEL",
		"VALUE"
	from dash_breakfast();

COMMENT ON TABLE "PLAYGROUND"."V_DASH_BREAKFAST"  IS 'Breakfast chosen option Y or N in last 30 days';

--V04 PLAYGROUND.V_DASH_CURR_HOTEL_UTILIZATION
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_CURR_HOTEL_UTILIZATION" 
(
	"VALUE", 
	"MAX_VALUE", 
	"LABEL"
) 
AS 
  	select 
  		to_number(key default 1 on conversion error) VALUE, 
		to_number(value default 1 on conversion error) MAX_VALUE, 
		'Popunjenosti hotela' LABEL 
	from e_lov where type = 'DASH_HOTEL_UTIL'
;

--V05 PLAYGROUND.V_DASH_LATEST_GUEST_NUM
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_LATEST_GUEST_NUM" 
(
	"LABEL", 
	"VALUE"
)
AS 
  	select to_char("D_DATE", 'DD.MM.YYYY.'),"NUM_OF_GUESTS" 
	from TABLE ( get_latest_guest_num2(sysdate-30, sysdate) )
;

--V06 PLAYGROUND.V_DASH_LENGTH_OF_STAY
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_LENGTH_OF_STAY" 
(
	"LABEL", 
	"VALUE", 
	"COLOR"
) AS 
	select 
		"LABEL",
		"VALUE",
		"COLOR" 
	from dash_length_of_stay();

--V07 PLAYGROUND.V_DASH_PRICE_RANGE
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_PRICE_RANGE" 
(
	"LABEL", 
	"VALUE", 
	"COLOR"
)
AS 
  	select 
		"LABEL",
		"VALUE",
		"COLOR" 
	from dash_price_range();

--V08 PLAYGROUND.V_DASH_ROOM_UTILZATION
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_DASH_ROOM_UTILZATION" 
(
	"ROOM_NUM", 
	"PERCENTAGE", 
	"COLOR"
) 
AS 
  	SELECT 
    	"ROOM_NUM",
		"PERCENTAGE",
		"COLOR"
	FROM
    	tmp_room_utilization
;

--V09 PLAYGROUND.V_RES_STATUS_MAPPING
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_RES_STATUS_MAPPING" 
(
	"d", 
	"r"
)
AS 
  	SELECT 
    	key "d", value "r"
	FROM 
    	E_LOV
	WHERE
    	type = 'RES_STATUS_MAPPING'
;
COMMENT ON TABLE "PLAYGROUND"."V_RES_STATUS_MAPPING"  IS 'Reservation status mapping';

--V10 PLAYGROUND.V_TODAY_NEW_GUESTS
CREATE OR REPLACE FORCE EDITIONABLE VIEW "PLAYGROUND"."V_TODAY_NEW_GUESTS" 
(
	"ID", 
	"START_DT", 
	"END_DT", 
	"RESERVATION_CD", 
	"USER_MAIL", 
	"BREAKFAST_INC", 
	"PRICE", 
	"NUM_OF_GUESTS", 
	"CURR_STATUS", 
	"GUESTS"
)
AS 
  	select
		"ID",
		"START_DT",
		"END_DT",
		"RESERVATION_CD",
		"USER_MAIL", 
		breakfast_inc, 
		price, 
		num_of_guests, 
		curr_status, 
		listagg(person_name, ', ') WITHIN GROUP (ORDER BY pid) guests
	from
	(
		select r.*, p.person_name, p.id pid from e_reservations r 
		left join e_checked_in_persons p
		on r.reservation_cd = p.reservation_cd
		where trunc(r.start_dt) = trunc(sysdate)
	)
		group by 
			"ID",
			"START_DT",
			"END_DT",
			"RESERVATION_CD",
			"USER_MAIL", 
			breakfast_inc, 
			price, 
			num_of_guests, 
			curr_status
;
