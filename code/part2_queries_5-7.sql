--q5
drop view if exists vaccinationStatus;
create view vaccinationStatus as 
select p.ssno, p.name, p.dateofbirth, p.gender, (case when (COUNT(ssno) = COALESCE(vt.doses, -1)) then 1 else 0 end) as vaccinationStatus 
from patients p 
left join vaccinepatients vp on p.ssno = vp.patientssno 
left join vaccinations as v on v.vaccinationdate = vp.vaccinationdate and v.location  = vp.location 
left join vaccinebatch on vaccinebatch.batchid  = v.batchid 
left join vaccinetype as vt on vt.id = vaccinebatch.vaccineid 
group by p.ssno, doses;

-- No output is displayed since it was not requested 

--q6
--vaccines of all types
select vs.name, sum(vb.numvaccines) as totalNoOfVaccines from vaccinationstations vs 
left join vaccinebatch vb 
on vb.location = vs.name 
group by vs.name;
-- %OUTPUT:table 6.1 vaccines of all types%

--vaccines by vaccine type
select vs.name, vb.vaccineid , sum(vb.numvaccines) as noOfVaccines from vaccinationstations vs 
left join vaccinebatch vb 
on vb.location = vs.name 
group by vs.name, vb.vaccineid;
-- %OUTPUT:table 6.2 vaccines by vaccine type%

--q7
select vt.id, d.symptom, count(d.symptom) as count, round(cast(count(d.symptom) AS Numeric)/ cast(vaccinationcount AS Numeric),2) as frequency
from vaccinetype vt
left join vaccinebatch vb on vb.vaccineid = vt.id
left join vaccinations v on v.batchid = vb.batchid 
left join vaccinepatients vp on v.vaccinationdate = v.vaccinationdate and v.location = vp.location
left join diagnosis d on d.patient = vp.patientssno, 
(select vt.id, count(vt.id) as vaccinationcount
	from vaccinetype vt
	left join vaccinebatch vb on vb.vaccineid = vt.id
	left join vaccinations v on v.batchid = vb.batchid 
	left join vaccinepatients vp on v.vaccinationdate = v.vaccinationdate and v.location = vp.location	
	group by vt.id
) AS vaccinationcases
where d.reportdate::date >= v.vaccinationdate and vaccinationcases.id = vt.id
group by d.symptom, vt.id, vaccinationcount
order by vt.id, count DESC;
-- %OUTPUT:table 7%
