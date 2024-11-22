/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 20_HOTEL_RES_Proc_Packets_DDL.sql
OPIS		: DDL skripita za PL\SQL pakete procedura
		
			Paketi:	
				--P01 PLAYGROUND.MAIL_SENDING_TEMPLATES2
				--P02 PLAYGROUND.WRAPPERS_MAIL_SENDING_TEMPLATES2

AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/
/********************************
	PAKETI
*********************************/
--P01 PLAYGROUND.MAIL_SENDING_TEMPLATES2
CREATE OR REPLACE EDITIONABLE PACKAGE "PLAYGROUND"."MAIL_SENDING_TEMPLATES2" AS 

    procedure send_successful_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_confirmation_reservation
    ( 
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_check_in_link
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_check_in_confirmation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_cancel_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

END MAIL_SENDING_TEMPLATES2;

/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PLAYGROUND"."MAIL_SENDING_TEMPLATES2" AS

    procedure send_successful_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        sent_mail_flg varchar2(2);
        sent varchar2(6);
    BEGIN
        --Get send mail flag
        select value into sent_mail_flg from e_lov where key = 'SEND_MAIL_FLG' and type = 'SYS_CONFIG';
        
        if sent_mail_flg = 'Y'
        then
            --Mail sending
            playground.send_mail
            (
                p_to        =>  mail,
                p_subject   =>  'Uspesna rezervacija hotela',
                p_message   =>  'Poštovani, ' || UTL_TCP.crlf || 'Uspešno ste rezervisali smeštaj u našem hotelu.' || UTL_TCP.crlf || 
                                'Vaša rezervacija se vodi pod šifrom br. ' || reservation_cd || UTL_TCP.crlf ||
                                'Očekujte mejl sa potvrdom vaše rezervacije u skorijem roku' || UTL_TCP.crlf ||
                                'Za otkazivanje rezervacije koristite sledeci link: http://localhost:8080/ords/r/playground/hotel-reservation-demo/cancel-reservation?p19_load_res=' || reservation_cd || UTL_TCP.crlf ||
                                'Prijatan boravak!'
            );
            sent := 'true';
        else
            sent := 'false';
        end if;
        
        --Exception procesing
        exception
            when others then
                sent := 'false';
                
    END send_successful_reservation;

    procedure send_confirmation_reservation
    ( 
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        sent_mail_flg varchar2(2);
        sent varchar2(6);
    BEGIN
        --Get send mail flag
        select value into sent_mail_flg from e_lov where key = 'SEND_MAIL_FLG' and type = 'SYS_CONFIG';
        
        if sent_mail_flg = 'Y'
        then
            --Mail sending
            playground.send_mail
            (
                p_to        =>  mail,
                p_subject   =>  'Rezervacija potvrđena',
                p_message   =>  'Poštovani, ' || UTL_TCP.crlf || 'Vaša rezervacija ' || reservation_cd || ' je potvrđena' || UTL_TCP.crlf || 
                                'Mejl sa linkom za online check in ćete dobiti najranije nedelju dana pred početak vašeg odsedanja' || UTL_TCP.crlf || 
                                'Srdačan pozdrav!'
            );
            sent := 'true';
        else
            sent := 'false';
        end if;
        
        --Exception procesing
        exception
            when others then
                sent := 'false';
    END send_confirmation_reservation;
    
    procedure send_check_in_link
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        sent_mail_flg varchar2(2);
        sent varchar2(6);
    BEGIN
        --Get send mail flag
        select value into sent_mail_flg from e_lov where key = 'SEND_MAIL_FLG' and type = 'SYS_CONFIG';
        
        if sent_mail_flg = 'Y'
        then
            -- Mail sending
            playground.send_mail
            (
                p_to        =>  mail,
                p_subject   =>  'Otvoren check in',
                p_message   =>  'Poštovani, ' || UTL_TCP.crlf || 'Check in za Vašu rezervaciju br. ' || reservation_cd || ' je otvoren.' || UTL_TCP.crlf || 
                                'Link za check in: http://localhost:8080/ords/r/playground/hotel-reservation-demo/online-check-in?p12_load_res=' || reservation_cd || UTL_TCP.crlf
            );
            sent := 'true';
        else
            sent := 'false';
        end if;
        
        --Exception procesing
        exception
            when others then
                sent := 'false';
    END send_check_in_link;

    procedure send_check_in_confirmation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        sent_mail_flg varchar2(2);
        sent varchar2(6);
    BEGIN
        --Get send mail flag
        select value into sent_mail_flg from e_lov where key = 'SEND_MAIL_FLG' and type = 'SYS_CONFIG';
        
        if sent_mail_flg = 'Y'
        then
            --Mail sending
            playground.send_mail
            (
                p_to        =>  mail,
                p_subject   =>  'Uspešan online check in',
                p_message   =>  'Poštovani, ' || UTL_TCP.crlf || 'Uspešno ste odradili check in za rezervaciju br. ' || reservation_cd || '.' || UTL_TCP.crlf || 
                                'Vaše sobe će biti dostupne od 14:00 na dan početka odsedanja' || UTL_TCP.crlf ||
                                'Check out iz Vaših soba je do 11:00.' || UTL_TCP.crlf ||
                                'Vasu rezervaciju mozete odstampati preko sledeceg linka: http://localhost:8080/ords/r/playground/hotel-reservation-demo/print-reservation?p13_load_Res=' || reservation_cd || UTL_TCP.crlf ||
                                'Prijatan boravak i srdačan pozdrav!'
            );
            sent := 'true';
        else
            sent := 'false';
        end if;
        
        --Exception procesing
        exception
            when others then
                sent := 'false';
    END send_check_in_confirmation;
    
    
    procedure send_cancel_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        sent_mail_flg varchar2(2);
        sent varchar2(6);
    BEGIN
        --Get send mail flag
        select value into sent_mail_flg from e_lov where key = 'SEND_MAIL_FLG' and type = 'SYS_CONFIG';
        
        if sent_mail_flg = 'Y'
        then
            --Mail sending
            playground.send_mail
            (
                p_to        =>  mail,
                p_subject   =>  'Otkazana rezervacija',
                p_message   =>  'Poštovani, ' || UTL_TCP.crlf || 'Vasa rezervacija br. ' || reservation_cd || ' je otkazana.' || UTL_TCP.crlf || 
                                'Pozdrav.'
            );
            sent := 'true';
        else
            sent := 'false';
        end if;
        
        --Exception procesing
        exception
            when others then
                sent := 'false';
    end send_cancel_reservation;
    

END MAIL_SENDING_TEMPLATES2;

/

--P02 PLAYGROUND.WRAPPERS_MAIL_SENDING_TEMPLATES2
CREATE OR REPLACE EDITIONABLE PACKAGE "PLAYGROUND"."WRAPPERS_MAIL_SENDING_TEMPLATES2" AS 

    procedure send_successful_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_confirmation_reservation
    ( 
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_check_in_link
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_check_in_confirmation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

    procedure send_cancel_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    );

END WRAPPERS_MAIL_SENDING_TEMPLATES2;

/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "PLAYGROUND"."WRAPPERS_MAIL_SENDING_TEMPLATES2" AS

    procedure send_successful_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        job_name varchar2(20);
    BEGIN
        --Creating a random job-name
        select DBMS_SCHEDULER.generate_job_name ('TEMP_JOB_') INTO job_name from dual;
        
        --Creating a job
        DBMS_SCHEDULER.create_job
        (   
            job_name        =>  job_name ,
            program_name    =>  'PROG_MAIL_SEND_SUCCESSFUL_RESERVATION',
            start_date      =>  SYSTIMESTAMP,
            auto_drop       =>  true,
            repeat_interval =>  null,
            end_date        =>  null
        );
        
        --Passing arguments to the job                      
        DBMS_SCHEDULER.set_job_argument_value(job_name, 1, mail);
        DBMS_SCHEDULER.set_job_argument_value(job_name, 2, reservation_cd);
        
        --Specifying the the database should drop the job after it has run
        DBMS_SCHEDULER.set_attribute(job_name,'max_runs',1);
        
        --Starting the job
        DBMS_SCHEDULER.enable(job_name);
        
        --Exception procesing
        exception
            when others then null;
                
    END send_successful_reservation;

    procedure send_confirmation_reservation
    ( 
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        job_name varchar2(20);
    BEGIN
        --Creating a random job-name
        select DBMS_SCHEDULER.generate_job_name ('TEMP_JOB_') INTO job_name from dual;
        
        --Creating a job
        DBMS_SCHEDULER.create_job
        (   
            job_name        =>  job_name ,
            program_name    =>  'PROG_MAIL_SEND_CONFIRMATION_RESERVATION',
            start_date      =>  SYSTIMESTAMP,
            auto_drop       =>  true,
            repeat_interval =>  null,
            end_date        =>  null
        );
        
        --Passing arguments to the job                      
        DBMS_SCHEDULER.set_job_argument_value(job_name, 1, mail);
        DBMS_SCHEDULER.set_job_argument_value(job_name, 2, reservation_cd);
        
        --Specifying the the database should drop the job after it has run
        DBMS_SCHEDULER.set_attribute(job_name,'max_runs',1);
        
        --Starting the job
        DBMS_SCHEDULER.enable(job_name);
        
        --Exception procesing
        exception
            when others then null;
            
    END send_confirmation_reservation;
    
    procedure send_check_in_link
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        job_name varchar2(20);
    BEGIN
        --Creating a random job-name
        select DBMS_SCHEDULER.generate_job_name ('TEMP_JOB_') INTO job_name from dual;
        
        --Creating a job
        DBMS_SCHEDULER.create_job
        (   
            job_name        =>  job_name ,
            program_name    =>  'PROG_MAIL_SEND_CHECK_IN_LINK',
            start_date      =>  SYSTIMESTAMP,
            auto_drop       =>  true,
            repeat_interval =>  null,
            end_date        =>  null
        );
        
        --Passing arguments to the job                      
        DBMS_SCHEDULER.set_job_argument_value(job_name, 1, mail);
        DBMS_SCHEDULER.set_job_argument_value(job_name, 2, reservation_cd);
        
        --Specifying the the database should drop the job after it has run
        DBMS_SCHEDULER.set_attribute(job_name,'max_runs',1);
        
        --Starting the job
        DBMS_SCHEDULER.enable(job_name);
        
        --Exception procesing
        exception
            when others then null;
            
    END send_check_in_link;

    procedure send_check_in_confirmation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        job_name varchar2(20);
    BEGIN
        --Creating a random job-name
        select DBMS_SCHEDULER.generate_job_name ('TEMP_JOB_') INTO job_name from dual;
        
        --Creating a job
        DBMS_SCHEDULER.create_job
        (   
            job_name        =>  job_name ,
            program_name    =>  'PROG_MAIL_SEND_CHECK_IN_CONFIRMATION',
            start_date      =>  SYSTIMESTAMP,
            auto_drop       =>  true,
            repeat_interval =>  null,
            end_date        =>  null
        );
        
        --Passing arguments to the job                      
        DBMS_SCHEDULER.set_job_argument_value(job_name, 1, mail);
        DBMS_SCHEDULER.set_job_argument_value(job_name, 2, reservation_cd);
        
        --Specifying the the database should drop the job after it has run
        DBMS_SCHEDULER.set_attribute(job_name,'max_runs',1);
        
        --Starting the job
        DBMS_SCHEDULER.enable(job_name);
        
        --Exception procesing
        exception
            when others then null;
            
    END send_check_in_confirmation;
    
    
    procedure send_cancel_reservation
    (
        mail in varchar2,
        reservation_cd in varchar2
    ) AS
        job_name varchar2(20);
    BEGIN
        --Creating a random job-name
        select DBMS_SCHEDULER.generate_job_name ('TEMP_JOB_') INTO job_name from dual;
        
        --Creating a job
        DBMS_SCHEDULER.create_job
        (   
            job_name        =>  job_name ,
            program_name    =>  'PROG_MAIL_SEND_CANCEL_RESERVATION',
            start_date      =>  SYSTIMESTAMP,
            auto_drop       =>  true,
            repeat_interval =>  null,
            end_date        =>  null
        );
        
        --Passing arguments to the job                      
        DBMS_SCHEDULER.set_job_argument_value(job_name, 1, mail);
        DBMS_SCHEDULER.set_job_argument_value(job_name, 2, reservation_cd);
        
        --Specifying the the database should drop the job after it has run
        DBMS_SCHEDULER.set_attribute(job_name,'max_runs',1);
        
        --Starting the job
        DBMS_SCHEDULER.enable(job_name);
        
        --Exception procesing
        exception
            when others then null;
            
    end send_cancel_reservation;
    

END WRAPPERS_MAIL_SENDING_TEMPLATES2;

/
