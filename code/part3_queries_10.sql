-- patients that the nurse may have met in vaccination events in the past 10 days
SELECT DISTINCT vp.patientssno, p.name
FROM vaccinations v
JOIN vaccinepatients vp ON v.vaccinationdate = vp.vaccinationdate AND v.location = vp.location
JOIN patients p ON vp.patientssno = p.ssno
JOIN staffmembers s ON v.location = s.hospital
WHERE v.vaccinationdate >= '2021-05-05' 
  AND v.vaccinationdate <= '2021-05-15'
  AND s.ssno = '19740919-7140';

-- staff members that the nurse may have met in vaccination events in the past 10 days
SELECT DISTINCT s.ssno, s.name
FROM staffmembers s
JOIN shifts sh ON s.ssno = sh.worker
JOIN vaccinations v ON sh.station = v.location
WHERE v.location = (SELECT hospital FROM staffmembers WHERE ssno = '19740919-7140')
  AND sh.weekday IN (SELECT weekday FROM shifts WHERE worker = '19740919-7140')
  AND s.ssno != '19740919-7140';




