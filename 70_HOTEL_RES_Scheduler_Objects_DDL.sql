/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 70_HOTEL_RES_Scheduler_Objects_DDL.sql
OPIS		: DDL skripita za Scheduler poslove (jobs) i programe
		
			Programi:
				--P02 PLAYGROUND.PROG_MAIL_SEND_CANCEL_RESERVATION
				--P03 PLAYGROUND.PROG_MAIL_SEND_CHECK_IN_CONFIRMATION
				--P04 PLAYGROUND.PROG_MAIL_SEND_CHECK_IN_LINK
				--P05 PLAYGROUND.PROG_MAIL_SEND_CONFIRMATION_RESERVATION
				--P06 PLAYGROUND.PROG_MAIL_SEND_SUCCESSFUL_RESERVATION
				--P07 PLAYGROUND.PROG_MAIL_SEND_NOSHOW
			Poslovi:	
				--J01 PLAYGROUND.JOB_CALC_CURRENT_HOTEL_UTIL
				--J03 PLAYGROUND.MAKE_RESERVATION_CHECK_IN_OPEN

AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.1.0			DEC-02-2024		Nov program vezan za dashboard
								Uklonjen program i job ranije
								korišćen za dashboard				M.Nikolic
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/
/********************************
	PROGRAMI
*********************************/
--P02 PLAYGROUND.PROG_MAIL_SEND_CANCEL_RESERVATION
BEGIN 
    dbms_scheduler.create_program
    (
        '"PROG_MAIL_SEND_CANCEL_RESERVATION"',
        'STORED_PROCEDURE',
        'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_CANCEL_RESERVATION',
        2,
        FALSE,
        'Program to async send cancel reservation mail'
    );
    COMMIT; 
END; 
/  

--P03 PLAYGROUND.PROG_MAIL_SEND_CHECK_IN_CONFIRMATION
BEGIN 
    dbms_scheduler.create_program
    (
        '"PROG_MAIL_SEND_CHECK_IN_CONFIRMATION"',
        'STORED_PROCEDURE',
        'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_CHECK_IN_CONFIRMATION',
        2,
        FALSE,
        'Program to async send check in confirmation mail'
    );
    COMMIT; 
END; 
/

--P04 PLAYGROUND.PROG_MAIL_SEND_CHECK_IN_LINK
BEGIN 
    dbms_scheduler.create_program
    (
        '"PROG_MAIL_SEND_CHECK_IN_LINK"',
        'STORED_PROCEDURE',
        'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_CHECK_IN_LINK',
        2,
        FALSE,
        'Program to async send check in link mail'
    );
    COMMIT; 
END; 
/ 

--P05 PLAYGROUND.PROG_MAIL_SEND_CONFIRMATION_RESERVATION
BEGIN 
    dbms_scheduler.create_program
    (
        '"PROG_MAIL_SEND_CONFIRMATION_RESERVATION"',
        'STORED_PROCEDURE',
        'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_CONFIRMATION_RESERVATION',
        2,
        FALSE,
        'Program to async send confirmation reservation mail'
    );
    COMMIT; 
END; 
/

--P06 PLAYGROUND.PROG_MAIL_SEND_SUCCESSFUL_RESERVATION
BEGIN 
    dbms_scheduler.create_program
    (
        '"PROG_MAIL_SEND_SUCCESSFUL_RESERVATION"',
        'STORED_PROCEDURE',
        'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_SUCCESSFUL_RESERVATION',
        2,
        FALSE,
        'Program to async send successful reservation mail'
    );
    COMMIT; 
END; 
/

--P07 PLAYGROUND.PROG_MAIL_SEND_NOSHOW
BEGIN 
	dbms_scheduler.create_program
	(
		'"PROG_MAIL_SEND_NOSHOW"',
		'STORED_PROCEDURE',
		'PLAYGROUND.MAIL_SENDING_TEMPLATES2.SEND_NOSHOW',
		2, 
		FALSE,
		'Program to async send successful reservation mail'
	);
	COMMIT; 
END; 
/ 

/********************************
	POSLOVI
*********************************/
--J01 PLAYGROUND.JOB_CALC_CURRENT_HOTEL_UTIL
BEGIN 
    dbms_scheduler.create_job
    (
        '"JOB_CALC_CURRENT_HOTEL_UTIL"',
        job_type=>'PLSQL_BLOCK', 
        job_action=>
            'declare
                v_max number;
                v_curr number;
            begin
                --Step 01 Calculate current number of guests
                --END_DT - 1 because to not include leaving guests
                select sum(num_of_guests) into v_curr
                from e_reservations
                where sysdate between start_dt and end_dt - 1;
                --Step 02 Calculate max number of guests in the hotel
                select sum(persons) into v_max
                from e_rooms;
                --Step 03 Update values in E_LOV
                update e_lov
    			set key = nvl(v_curr,0), value = nvl(v_max,0)
                where type = ''DASH_HOTEL_UTIL'';
            end;
                ',
        number_of_arguments=>0,
        start_date=>TO_TIMESTAMP_TZ('31-OCT-2024 08.59.54.105378000 PM EUROPE/BELGRADE','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), 
        repeat_interval=> 'FREQ=DAILY;BYTIME=060000;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN', 
        end_date=>NULL,
        job_class=>'"DEFAULT_JOB_CLASS"',
        enabled=>FALSE,
        auto_drop=>FALSE,
        comments=>'Program that updates values for today''s hotel utilization'
    );
    sys.dbms_scheduler.set_attribute('"JOB_CALC_CURRENT_HOTEL_UTIL"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA'' NLS_CURRENCY=''$'' NLS_ISO_CURRENCY=''AMERICA'' NLS_NUMERIC_CHARACTERS=''.,'' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS'' NLS_DATE_LANGUAGE=''AMERICAN'' NLS_SORT=''BINARY'' NLS_TIME_FORMAT=''HH.MI.SSXFF AM'' NLS_TIMESTAMP_FORMAT=''DD-MON-RR HH.MI.SSXFF AM'' NLS_TIME_TZ_FORMAT=''HH.MI.SSXFF AM TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD-MON-RR HH.MI.SSXFF AM TZR'' NLS_DUAL_CURRENCY=''$'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
    dbms_scheduler.enable('"JOB_CALC_CURRENT_HOTEL_UTIL"');
    COMMIT; 
END; 
/ 

--J03 PLAYGROUND.MAKE_RESERVATION_CHECK_IN_OPEN
BEGIN 
    dbms_scheduler.create_job
    (
        '"MAKE_RESERVATION_CHECK_IN_OPEN"',
        job_type=>'PLSQL_BLOCK',
        job_action=>
            'DECLARE
                --Types
                type email_and_res is record
                (
                    reservation_cd e_reservations.reservation_cd%type,
                    email e_reservations.user_mail%type
                );
                type guest_info is table of email_and_res;
                --Variables
                guests guest_info;
                sent_status boolean;
            BEGIN
                update e_reservations
                set curr_status = ''CHECK IN OPEN''
                where trunc(start_dt) <= trunc(sysdate) + 7
                and curr_status = ''CONFIRMED''
                RETURNing reservation_cd, user_mail bulk collect into guests;
                FOR i IN guests.first..guests.last
                LOOP
                    wrappers_mail_sending_templates2.send_check_in_link
                    (
                        MAIL => guests(i).email,
                        RESERVATION_CD => guests(i).reservation_cd
                    );
            --		MAIL_SENDING_TEMPLATES.send_check_in_link
            --		(  
            --			MAIL => guests(i).email,
            --			RESERVATION_CD => guests(i).reservation_cd,
            --			SENT => sent_status
            --		);  
                END LOOP;
            END;  ',
        number_of_arguments=>0,
        start_date=>TO_TIMESTAMP_TZ('09-OCT-2024 09.08.34.025093000 PM EUROPE/BELGRADE','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'),
        repeat_interval=>'FREQ=DAILY;BYTIME=060000;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN',
        end_date=>NULL,
        job_class=>'"DEFAULT_JOB_CLASS"',
        enabled=>FALSE,
        auto_drop=>FALSE,
        comments=>NULL
    );
    sys.dbms_scheduler.set_attribute('"MAKE_RESERVATION_CHECK_IN_OPEN"','NLS_ENV','NLS_LANGUAGE=''AMERICAN'' NLS_TERRITORY=''AMERICA'' NLS_CURRENCY=''$'' NLS_ISO_CURRENCY=''AMERICA'' NLS_NUMERIC_CHARACTERS=''.,'' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD-MON-YYYY HH24:MI:SS'' NLS_DATE_LANGUAGE=''AMERICAN'' NLS_SORT=''BINARY'' NLS_TIME_FORMAT=''HH.MI.SSXFF AM'' NLS_TIMESTAMP_FORMAT=''DD-MON-RR HH.MI.SSXFF AM'' NLS_TIME_TZ_FORMAT=''HH.MI.SSXFF AM TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD-MON-RR HH.MI.SSXFF AM TZR'' NLS_DUAL_CURRENCY=''$'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
    dbms_scheduler.enable('"MAKE_RESERVATION_CHECK_IN_OPEN"');
    COMMIT; 
END; 
/   
