drop table if exists Manufacturer cascade;
drop table if exists VaccineType cascade;
drop table if exists VaccinationStations cascade;
drop table if exists StaffMembers cascade;
drop table if exists VaccineBatch cascade;
drop table if exists TransportationLog cascade;
drop table if exists Shifts cascade;
drop table if exists Vaccinations cascade;
drop table if exists Patients cascade;
drop table if exists VaccinePatients cascade;
drop table if exists Symptoms cascade;
drop table if exists Diagnosis cascade;

-- /*VaccineType*/
create table VaccineType (
	ID text primary key,
	name text not null,
	doses int not null,
	tempMin int not null,
	tempMax int not null
);

-- /*Manufacturer*/
create table Manufacturer(
	ID text primary key,
	country text not null,
	phone text not null,
	vaccineID text not null,
	foreign key (vaccineID) references VaccineType(ID)
);

-- /*VaccinationStations*/
create table VaccinationStations (
	name text primary key,
	address text not null,
	phone text not null
);

-- /*StaffMembers*/
create table StaffMembers (
	ssNo text primary key,
	name text not null,
	dateOfBirth date not null,
	phone text not null,
	role text not null,
	vaccinationStatus boolean not null,
	hospital text not null,
	foreign key (hospital) references VaccinationStations(name)
);

-- /*VaccineBatch
-- Constraint: expiration date should be at least 6 months from 
-- production date.*/
create table VaccineBatch (
	batchID text primary key,
	numVaccines int not null,
	vaccineID  text not null,
	manufacturer text not null,
	dateProduced date not null,
	expirationDate date not null check (expirationDate >= dateProduced + interval '6 months'),
	location text not null,
	foreign key (manufacturer) references Manufacturer(ID),
	foreign key (vaccineID) references VaccineType(ID),
	foreign key (location) references VaccinationStations(name)
);

-- /*TransportationLog
-- Constraint: arrival date should be after or on the 
-- same day as departure date.*/
create table TransportationLog (
	batchID text not null,
	arrivalDestination text not null,
	departureDestination text not null,
	arrivalDate date not null,
	departureDate date not null check(arrivalDate >= departureDate),
	primary key (batchID, arrivalDestination, departureDestination),
	foreign key (batchID) references VaccineBatch(batchID),
	foreign key (arrivalDestination) references VaccinationStations(name),
	foreign key (departureDestination) references VaccinationStations(name)
);

-- /*Shifts*/
create table Shifts(
	station text not null,
	weekday text not null,
	worker text not null,
	primary key (weekday, worker),
	foreign key (station) references VaccinationStations(name),
	foreign key (worker) references StaffMembers(ssNo)
);

-- /*Vaccinations*/
create table Vaccinations(
	vaccinationDate date not null,
	location text not null,
	batchID text not null,
	primary key (vaccinationDate, location),
	foreign key (location) references VaccinationStations(name),
	foreign key (batchID) references VaccineBatch(batchID)
);

-- /*Patients*/
create table Patients(
	ssNo text primary key,
	name text not null,
	dateOfBirth date not null,
	gender text not null check (gender in('F','M'))
);


-- /*VaccinePatients*/
create table VaccinePatients(
	vaccinationDate date not null,
	location text not null,
	patientSsNo text not null,
	primary key (vaccinationDate, location, patientSsNo),
	foreign key (location) references VaccinationStations(name),
	foreign key (patientSsNo) references Patients(ssNo)
);

-- /*Symptoms*/
create table Symptoms (
	name text primary key ,
	criticality boolean not null
);

-- /*Diagnosis*/
create table Diagnosis(
	patient text not null,
	symptom text not null,
	reportDate date not null,
	primary key (patient, symptom, reportDate),
	foreign key (patient) references Patients(ssNo),
	foreign key (symptom) references Symptoms(name)
);

