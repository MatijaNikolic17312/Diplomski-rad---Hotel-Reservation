/************************************************************************
APLIKACIJA	: Hotel Reservation - Diplomski rad
SKRIPTA		: 40_HOTEL_RES_Types_DDL.sql
OPIS		: DDL skripita za tipove podataka
		
			Procedure:	
				--T01 PLAYGROUND.T_DASH_GUEST_NUM_REC
				--T02 PLAYGROUND.T_DASH_GUEST_NUM_TABLE

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
	TIPOVI
*********************************/
--T01 PLAYGROUND.T_DASH_GUEST_NUM_REC
CREATE OR REPLACE EDITIONABLE TYPE "PLAYGROUND"."T_DASH_GUEST_NUM_REC" as object
(
    d_date date,
    num_of_guests number
);

/

--T02 PLAYGROUND.T_DASH_GUEST_NUM_TABLE
CREATE OR REPLACE EDITIONABLE TYPE "PLAYGROUND"."T_DASH_GUEST_NUM_TABLE" as table of t_dash_guest_num_rec;

/
