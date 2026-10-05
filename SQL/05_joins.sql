SELECT COUNT(*) AS Rows_In_Product
FROM   Patient CROSS JOIN Doctor;

SELECT d.Name, dp.Department_Name
FROM   Doctor d, Department dp
WHERE  d.Department_ID = dp.Department_ID;

SELECT d.Name, d.Specialization, dp.Department_Name, dp.Location
FROM   Doctor d
JOIN   Department dp ON d.Department_ID = dp.Department_ID;

SELECT Name, Department_Name
FROM   Doctor NATURAL JOIN Department;

SELECT p.Name  AS Patient,
       d.Name  AS Doctor,
       a.Appointment_Date,
       a.Appointment_Time,
       a.Status
FROM   Appointment a
JOIN   Patient p ON a.Patient_ID = p.Patient_ID
JOIN   Doctor  d ON a.Doctor_ID  = d.Doctor_ID
ORDER  BY a.Appointment_Date;

SELECT pr.Prescription_ID,
       p.Name          AS Patient,
       d.Name          AS Doctor,
       m.Medicine_Name,
       pd.Dosage,
       pd.Duration_Days
FROM   Prescription pr
JOIN   Patient p              ON pr.Patient_ID      = p.Patient_ID
JOIN   Doctor d               ON pr.Doctor_ID       = d.Doctor_ID
JOIN   Prescription_Detail pd ON pr.Prescription_ID = pd.Prescription_ID
JOIN   Medicine m             ON pd.Medicine_ID     = m.Medicine_ID
ORDER  BY pr.Prescription_ID;

SELECT p.Name, r.Room_Number, r.Room_Type, a.Admission_Date
FROM   Admission a
JOIN   Patient p ON a.Patient_ID = p.Patient_ID
JOIN   Room    r ON a.Room_ID    = r.Room_ID
WHERE  a.Discharge_Date IS NULL;

SELECT d1.Name AS Doctor, d1.Salary,
       d2.Name AS Earns_More_Than, d2.Salary AS Colleague_Salary
FROM   Doctor d1
JOIN   Doctor d2
       ON  d1.Department_ID = d2.Department_ID
       AND d1.Salary > d2.Salary;

SELECT p.Patient_ID, p.Name, a.Appointment_ID, a.Appointment_Date
FROM   Patient p
LEFT JOIN Appointment a ON p.Patient_ID = a.Patient_ID
ORDER  BY p.Patient_ID;

SELECT dp.Department_Name, d.Name AS Doctor
FROM   Doctor d
RIGHT JOIN Department dp ON d.Department_ID = dp.Department_ID
ORDER  BY dp.Department_Name;

SELECT r.Room_Number, r.Status, a.Admission_ID, a.Patient_ID
FROM   Room r
FULL OUTER JOIN Admission a ON r.Room_ID = a.Room_ID
ORDER  BY r.Room_Number;
