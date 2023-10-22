
-- 1 --
select ssNo, name, phone, role, vaccinationStatus
from Shifts, Vaccinations as V, StaffMembers
where station = location
and weekday = 'Monday'
and worker = ssNo
and vaccinationDate='2021-05-10';

-- %OUTPUT:table 1 %

-- 2 --
select ssNo, SM.name 
from StaffMembers as SM, Shifts, VaccinationStations as VS
where ssNo = worker
and role = 'doctor'
and address like '%HELSINKI%'
and VS.name = station 
and weekday = 'Wednesday';

-- %OUTPUT:table 2 %

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

-- %OUTPUT:table 3.1 %

select batchID, phone 
from BatchLocationInfo, VaccinationStations
where location <> lastLocation
and lastLocation = name;

-- %OUTPUT:table 3.2 %

-- 4 --
drop view if exists CriticalPatient;
create view CriticalPatient as
select patient
from Diagnosis as D, Symptoms as S
where D.symptom = S.name
and reportDate > '2021-05-10'
and criticality = True;

select * from CriticalPatient;

-- %OUTPUT:table 4.1 %

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

-- %OUTPUT:table 4.2 %



