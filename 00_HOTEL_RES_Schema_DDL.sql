/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 00_HOTEL_RES_Schema_DDL.sql
OPIS		: DDL skripita za PLAYGROUND korisnika i access control list podesavanja za slanje email-a
NAPOMENA	: Skripta se izvrsava preko administratorskog korsnika!
		
			
AUTOR		: M.Nikolic
VERZIJA     : 1.0.0
DATUM       : Nov 2024

ISTORIJA REVIZIJE
===============================================================================
REVIZIJA    |  	DATUM     	|  	OPIS IZMENA						  | POTPIS
-------------------------------------------------------------------------------
1.0.0   	 	NOV-20-2024   	Inicijalna verzija					M.Nikolic
********************************************************************************/

create user PLAYGROUND identified by <SIFRA>;
/
grant create session to PLAYGROUND;
/
grant unlimited tablespace to PLAYGROUND;
/

BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
        host => '<ADRESA SMTP SERVERA>',
        ace  =>  xs$ace_type(privilege_list => xs$name_list('SMTP'),
                       principal_name => 'PLAYGROUND',
                       principal_type => xs_acl.ptype_db)); 
END;

