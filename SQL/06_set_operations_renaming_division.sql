SELECT Patient_ID FROM Appointment
UNION
SELECT Patient_ID FROM Lab_Test
ORDER  BY Patient_ID;

SELECT Patient_ID FROM Appointment
UNION ALL
SELECT Patient_ID FROM Lab_Test;

SELECT Patient_ID FROM Appointment
INTERSECT
SELECT Patient_ID FROM Lab_Test
ORDER  BY Patient_ID;

SELECT Patient_ID FROM Lab_Test
MINUS
SELECT Patient_ID FROM Appointment;

SELECT Doctor_ID FROM Doctor
MINUS
SELECT Doctor_ID FROM Prescription;

SELECT Name, Phone, 'Doctor'  AS Role FROM Doctor
UNION
SELECT Name, Phone, 'Patient' AS Role FROM Patient
ORDER  BY Role, Name;

SELECT Patient_ID AS PID,
       Name       AS PatientName
FROM   Patient;

SELECT P.Name, P.City
FROM   Patient P;

SELECT P1.Name AS Patient_1, P2.Name AS Patient_2, P1.City
FROM   Patient P1
JOIN   Patient P2
       ON  P1.City = P2.City
       AND P1.Patient_ID < P2.Patient_ID
ORDER  BY P1.City;

SELECT Dept_Stats.Department_ID, Dept_Stats.Avg_Salary
FROM   (SELECT Department_ID, AVG(Salary) AS Avg_Salary
        FROM   Doctor
        GROUP  BY Department_ID) Dept_Stats
WHERE  Dept_Stats.Avg_Salary > 150000;

SELECT d.Doctor_ID, d.Name
FROM   Doctor d
WHERE  NOT EXISTS (
         SELECT m.Medicine_ID
         FROM   Medicine m
         WHERE  m.Manufacturer = 'Sun Pharma'
         AND    NOT EXISTS (
                  SELECT 1
                  FROM   Prescription pr
                  JOIN   Prescription_Detail pd ON pr.Prescription_ID = pd.Prescription_ID
                  WHERE  pr.Doctor_ID    = d.Doctor_ID
                  AND    pd.Medicine_ID  = m.Medicine_ID
                )
       );

SELECT d.Doctor_ID, d.Name
FROM   Doctor d
WHERE  NOT EXISTS (
         SELECT Medicine_ID FROM Medicine WHERE Manufacturer = 'Sun Pharma'
         MINUS
         SELECT pd.Medicine_ID
         FROM   Prescription pr
         JOIN   Prescription_Detail pd ON pr.Prescription_ID = pd.Prescription_ID
         WHERE  pr.Doctor_ID = d.Doctor_ID
       );

SELECT pr.Doctor_ID
FROM   Prescription pr
JOIN   Prescription_Detail pd ON pr.Prescription_ID = pd.Prescription_ID
JOIN   Medicine m             ON pd.Medicine_ID     = m.Medicine_ID
WHERE  m.Manufacturer = 'Sun Pharma'
GROUP  BY pr.Doctor_ID
HAVING COUNT(DISTINCT pd.Medicine_ID) =
       (SELECT COUNT(*) FROM Medicine WHERE Manufacturer = 'Sun Pharma');
