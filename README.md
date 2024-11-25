# Diplomski rad - Hotel Reservation
Diplomski rad, implementacija sistema za hotelske rezervacije u Oracle APEX-u

Instrukcije za instalaciju projekta:
1. Preko SQL Developer-a, povezati se na admin korisnika baze podataka
2. Pokrenuti skriptu *00_HOTEL_RES_Schema_DDL.sql*
3. Dodati konekciju na istu bazu, ali sada sa novim **PLAYGROUND** korisnikom.
4. Pokrenuti preostale skripte redom (10, 20...)

----------------------------------------------------------------------------------------------  
1. Povezati se na APEX server
2. Preko APEX administratorskog naloga, pokrenuti akciju **Manage Workspaces -> Create Workspace**
3. Uneti u formu sledece vrednosti i kreirati workspace
  > + Workspace Name: proizvoljno
  > + Re-use existing schema: Yes
  > + Schema Name: PLAYGROUND
  > + Administrator Username, Password, Email: proizvoljno
4. Prijaviti se na PLAYGROUND workspace admin nalogom
5. Ici na **App Builder -> Import**
6. Izabrati fajl *f100.sql* i izabrati opciju **Install Application**

