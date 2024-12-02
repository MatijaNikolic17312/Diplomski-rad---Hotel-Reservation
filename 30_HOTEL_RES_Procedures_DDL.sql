/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 30_HOTEL_RES_Procedures_DDL.sql
OPIS		: DDL skripita za samostale procedure
		
			Procedure:	
				--P01 PLAYGROUND.POPULATE_TMP_ROOM_UTILIZATION
				--P02 PLAYGROUND.SEND_MAIL (NAPOMENA: Iz procedure je izostavljen nalog za SMTP server)

AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.0.1			DEC-02-2024		Ispravke u P01						M.Nikolic
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/

/********************************
	PROCEDURE
*********************************/
--P01 PLAYGROUND.POPULATE_TMP_ROOM_UTILIZATION
set define off;

CREATE OR REPLACE EDITIONABLE PROCEDURE "PLAYGROUND"."POPULATE_TMP_ROOM_UTILIZATION" 
(
    PERIOD_START_DT IN DATE DEFAULT SYSDATE - 30,
    PERIOD_END_DT   IN DATE DEFAULT SYSDATE 
) AS
    --Variables
    cursor cur is 
        select distinct room_num
        from e_reservations r
        inner join e_reservation_rooms rr on r.reservation_cd = rr.reservation_cd
        where start_dt BETWEEN period_start_dt and period_end_dt;
        
    var_room_num e_reservation_rooms.room_num%type;
    var_num_of_days number;
    var_period_length number;
    var_color varchar2(10);
    
BEGIN
    --Step 00 Calculate period length
    var_period_length := trunc(period_end_dt) - trunc(period_start_dt);

    --Step 01 Truncate the current table
    EXECUTE IMMEDIATE 'truncate table TMP_ROOM_UTILIZATION';
    commit;
  
    --Step 02 Loop over all rooms in the period
    open cur;
    loop
        var_num_of_days := 0;
        
        --Step 03 Get one room
        fetch cur into var_room_num;
        EXIT WHEN cur%NOTFOUND;
        
        --Step 04 Get number of days that was room occupied
        select sum(case when end_dt > period_end_dt then period_end_dt else end_dt end - start_dt) into var_num_of_days
        from e_reservations r
        inner join e_reservation_rooms rr on r.reservation_cd = rr.reservation_cd
        where start_dt BETWEEN period_start_dt and period_end_dt
        and room_num = var_room_num
        and curr_status <> 'CANCELED';
        
        --Step 05 Generate random color for graphing
        var_color :=  '#' || to_char(dbms_random.value(0,256),'fm0X') || to_char(dbms_random.value(0,256),'fm0X') || to_char(dbms_random.value(0,256),'fm0X');
        
        --Step 06 Insert into TMP table
        insert into tmp_room_utilization values (var_room_num, trunc((var_num_of_days / var_period_length), 2), var_color);
    end loop;
    close cur;
  
END POPULATE_TMP_ROOM_UTILIZATION;

/

--P02 PLAYGROUND.SEND_MAIL
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "PLAYGROUND"."SEND_MAIL" (p_to        IN VARCHAR2,
                                       p_from      IN VARCHAR2 default '',
                                       p_subject   IN VARCHAR2,
                                       p_message   IN VARCHAR2,
                                       p_smtp_host IN VARCHAR2 DEFAULT '',
                                       p_smtp_port IN NUMBER DEFAULT 587)
AS
  l_mail_conn   UTL_SMTP.connection;
  smtp_pass     varchar(50);
BEGIN

  --Fetch Password
  select value into smtp_pass from playground.e_lov where key = 'SMTP_PASS' and type = 'SYS_CONFIG';

  l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  UTL_SMTP.ehlo(l_mail_conn, p_smtp_host);
  UTL_SMTP.starttls(l_mail_conn);
  UTL_SMTP.auth(l_mail_conn, '<SMTP nalog>', smtp_pass, utl_smtp.all_schemes);
  UTL_SMTP.mail(l_mail_conn, p_from);
  UTL_SMTP.rcpt(l_mail_conn, p_to);

  UTL_SMTP.open_data(l_mail_conn);
  UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.close_data(l_mail_conn);

  UTL_SMTP.quit(l_mail_conn);
END;

/
