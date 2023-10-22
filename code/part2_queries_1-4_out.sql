
-- 1 --
select ssNo, name, phone, role, vaccinationStatus
from Shifts, Vaccinations as V, StaffMembers
where station = location
and weekday = 'Monday'
and worker = ssNo
and vaccinationDate='2021-05-10';

/* OUTPUT 1 

            ssno               name         phone    role  vaccinationstatus
0  19920802-4854        Kaden Tromp  044-624-1591   nurse               True
1  19740919-7140         Deon Hoppe  040-399-1121   nurse              False
2  19940615-4448      Jordy Hilpert  044-506-1982  doctor               True
3  19630812-6581   Jazlyn Schneider  040-868-2528   nurse               True
4  19771003-5988        Samir Hills  040-093-0059   nurse               True
5  19880817-8027  Haylie Wintheiser  050-448-8894   nurse               True
6  19820218-5928      Elena Bartell  041-938-9451   nurse               True
7  19720223-1761   Alfreda Champlin  041-631-1851   nurse               True
*/

-- 2 --
select ssNo, SM.name 
from StaffMembers as SM, Shifts, VaccinationStations as VS
where ssNo = worker
and role = 'doctor'
and address like '%HELSINKI%'
and VS.name = station 
and weekday = 'Wednesday';

/* OUTPUT 2 

            ssno              name
0  19740731-5488   Rosalia Simonis
1  19750726-4531      Shaylee Kris
2  19751212-3265     Hilbert Purdy
3  19760102-8374  Elnora Greenholt
*/

-- 3 --
drop view if exists LastArrivalDateView cascade;
drop view if exists LastLocationView cascade;
drop view if exists BatchLocationInfo cascade;

create view LastArrivalDateView as
select batchID, max(arrivalDate) as lastDate
from TransportationLog
group by batchID;

create view LastLocationView as
select LAD.batchID, arrivalDestination as lastLocation
from TransportationLog as TL, LastArrivalDateView as LAD
where LAD.batchID = TL.batchID
and arrivalDate = lastDate;

create view BatchLocationInfo as
select VB.batchID, location, lastLocation
from VaccineBatch as VB, LastLocationView as LL
where VB.batchID = LL.batchID;

select * from BatchLocationInfo;

/* OUTPUT 3.1 

   batchid                     location                 lastlocation
0      B01   Sanomala Vaccination Point   Sanomala Vaccination Point
1      B02                  Messukeskus   Sanomala Vaccination Point
2      B03      Myyrmäki Energia Areena      Myyrmäki Energia Areena
3      B04                        Malmi                        Malmi
4      B06  Iso Omena Vaccination Point      Myyrmäki Energia Areena
5      B07      Myyrmäki Energia Areena      Myyrmäki Energia Areena
6      B08        Tapiola Health Center        Tapiola Health Center
7      B12   Sanomala Vaccination Point   Sanomala Vaccination Point
8      B13  Iso Omena Vaccination Point  Iso Omena Vaccination Point
9      B15                        Malmi                        Malmi
10     B16        Tapiola Health Center        Tapiola Health Center
11     B17      Myyrmäki Energia Areena      Myyrmäki Energia Areena
12     B18        Tapiola Health Center        Tapiola Health Center
13     B21  Iso Omena Vaccination Point  Iso Omena Vaccination Point
14     B22      Myyrmäki Energia Areena      Myyrmäki Energia Areena
15     B23   Sanomala Vaccination Point   Sanomala Vaccination Point
16     B24                        Malmi                        Malmi
17     B25                        Malmi                        Malmi
18     B27      Myyrmäki Energia Areena      Myyrmäki Energia Areena
19     B28  Iso Omena Vaccination Point  Iso Omena Vaccination Point
20     B29      Myyrmäki Energia Areena   Sanomala Vaccination Point
21     B30  Iso Omena Vaccination Point  Iso Omena Vaccination Point
*/

select batchID, phone 
from BatchLocationInfo, VaccinationStations
where location <> lastLocation
and lastLocation = name;

/* OUTPUT 3.2 

  batchid         phone
0     B02  093-105-3153
1     B06  093-104-5930
2     B29  093-105-3153
*/

-- 4 --
drop view if exists CriticalPatient;
create view CriticalPatient as
select patient
from Diagnosis as D, Symptoms as S
where D.symptom = S.name
and reportDate > '2021-05-10'
and criticality = True;

select * from CriticalPatient;

/* OUTPUT 4.1 

Empty DataFrame
Columns: [patient]
Index: []
*/

select 
CP.patient, 
V.batchID, 
B.vaccineID, 
V.vaccinationDate, 
V.location
from 
CriticalPatient as CP, 
VaccinePatients as VP,
Vaccinations    as V, 
VaccineType     as VT, 
VaccineBatch    as B
where CP.patient = VP.patientSsNo
and V.batchID = B.batchID
and B.vaccineID = VT.ID 
and VP.vaccinationDate = V.vaccinationDate
and VP.location = V.location;

/* OUTPUT 4.2 

Empty DataFrame
Columns: [patient, batchid, vaccineid, vaccinationdate, location]
Index: []
*/



