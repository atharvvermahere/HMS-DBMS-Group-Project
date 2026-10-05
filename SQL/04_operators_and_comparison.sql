SELECT Name FROM Doctor WHERE Department_ID = 5;

SELECT Appointment_ID, Status FROM Appointment WHERE Status <> 'Completed';

SELECT Bill_ID, Total_Amount FROM Bill WHERE Total_Amount > 10000;

SELECT Medicine_Name, Stock FROM Medicine WHERE Stock < 150;

SELECT Name, Salary FROM Doctor WHERE Salary >= 150000 AND Salary <= 170000;

SELECT Name, Salary FROM Doctor WHERE Salary BETWEEN 150000 AND 170000;

SELECT Name, Blood_Group FROM Patient WHERE Blood_Group IN ('A-', 'B-', 'AB-', 'O-');

SELECT Medicine_Name FROM Medicine WHERE Medicine_Name LIKE 'A%';

SELECT Test_ID, Test_Name, Patient_ID FROM Lab_Test WHERE Result IS NULL;

SELECT Name, Gender, City, Blood_Group
FROM   Patient
WHERE  (Gender = 'Female' OR City = 'Indore')
AND    NOT Blood_Group = 'O+';

SELECT Doctor_ID, Name, Salary, Salary * 12 AS Annual_Salary
FROM   Doctor;

SELECT Patient_ID, Name, DOB,
       TRUNC(MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS Age
FROM   Patient;

SELECT a.Admission_ID, a.Patient_ID, r.Room_Type,
       (a.Discharge_Date - a.Admission_Date)                  AS Days_Stayed,
       (a.Discharge_Date - a.Admission_Date) * r.Daily_Charge AS Room_Charge
FROM   Admission a
JOIN   Room r ON a.Room_ID = r.Room_ID
WHERE  a.Discharge_Date IS NOT NULL;

SELECT p.*
FROM   Patient p
WHERE  EXISTS (SELECT 1 FROM Appointment a WHERE a.Patient_ID = p.Patient_ID);

SELECT p.*
FROM   Patient p
WHERE  NOT EXISTS (SELECT 1 FROM Appointment a WHERE a.Patient_ID = p.Patient_ID);

SELECT CASE
         WHEN NOT EXISTS (SELECT Patient_ID FROM Lab_Test
                          MINUS
                          SELECT Patient_ID FROM Appointment)
         THEN 'TRUE' ELSE 'FALSE'
       END AS LabTest_Subset_Of_Appointment
FROM   dual;

SELECT CASE
         WHEN NOT EXISTS (SELECT Patient_ID FROM Prescription
                          MINUS
                          SELECT Patient_ID FROM Appointment WHERE Status = 'Completed')
          AND NOT EXISTS (SELECT Patient_ID FROM Appointment WHERE Status = 'Completed'
                          MINUS
                          SELECT Patient_ID FROM Prescription)
         THEN 'TRUE' ELSE 'FALSE'
       END AS Relations_Are_Equal
FROM   dual;

SELECT CASE
         WHEN NOT EXISTS (SELECT Patient_ID FROM Appointment
                          MINUS
                          SELECT Patient_ID FROM Patient)
          AND EXISTS     (SELECT Patient_ID FROM Patient
                          MINUS
                          SELECT Patient_ID FROM Appointment)
         THEN 'TRUE' ELSE 'FALSE'
       END AS Proper_Subset
FROM   dual;

SELECT d.Doctor_ID, d.Name
FROM   Doctor d
WHERE  NOT EXISTS (
         SELECT Patient_ID FROM Patient WHERE Patient_ID IN (105, 115)
         MINUS
         SELECT a.Patient_ID FROM Appointment a WHERE a.Doctor_ID = d.Doctor_ID
       );
