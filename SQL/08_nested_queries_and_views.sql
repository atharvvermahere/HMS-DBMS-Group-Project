SELECT Bill_ID, Patient_ID, Total_Amount
FROM   Bill
WHERE  Total_Amount > (SELECT AVG(Total_Amount) FROM Bill);

SELECT Name
FROM   Patient
WHERE  Patient_ID IN (
         SELECT Patient_ID
         FROM   Appointment
         WHERE  Doctor_ID IN (SELECT Doctor_ID FROM Doctor
                              WHERE  Specialization = 'Cardiologist')
       );

SELECT d.Name, d.Salary, d.Department_ID
FROM   Doctor d
WHERE  d.Salary > (SELECT AVG(d2.Salary)
                   FROM   Doctor d2
                   WHERE  d2.Department_ID = d.Department_ID);

SELECT dp.Department_Name
FROM   Department dp
WHERE  EXISTS (SELECT 1 FROM Doctor d WHERE d.Department_ID = dp.Department_ID);

SELECT p.Patient_ID, p.Name
FROM   Patient p
WHERE  NOT EXISTS (SELECT 1 FROM Admission a WHERE a.Patient_ID = p.Patient_ID);

SELECT Name, Salary
FROM   Doctor
WHERE  Salary > ALL (SELECT Salary FROM Doctor WHERE Specialization = 'General Physician');

SELECT Room_Number, Room_Type, Daily_Charge
FROM   Room
WHERE  Daily_Charge > ANY (SELECT Daily_Charge FROM Room WHERE Room_Type = 'Semi-Private');

SELECT *
FROM  (SELECT p.Name, SUM(b.Total_Amount) AS Total_Billed
       FROM   Bill b
       JOIN   Patient p ON b.Patient_ID = p.Patient_ID
       GROUP  BY p.Name
       ORDER  BY Total_Billed DESC)
WHERE  ROWNUM = 1;

SELECT b.Bill_ID,
       b.Total_Amount,
       (SELECT NVL(SUM(p.Amount), 0) FROM Payment p WHERE p.Bill_ID = b.Bill_ID) AS Paid,
       b.Total_Amount -
       (SELECT NVL(SUM(p.Amount), 0) FROM Payment p WHERE p.Bill_ID = b.Bill_ID) AS Balance_Due
FROM   Bill b
ORDER  BY Balance_Due DESC;

CREATE OR REPLACE VIEW Patient_Bill_Summary AS
SELECT p.Patient_ID,
       p.Name,
       COUNT(b.Bill_ID)              AS No_Of_Bills,
       NVL(SUM(b.Total_Amount), 0)   AS Total_Billed
FROM   Patient p
LEFT JOIN Bill b ON p.Patient_ID = b.Patient_ID
GROUP  BY p.Patient_ID, p.Name;

SELECT *
FROM   Patient_Bill_Summary
WHERE  Total_Billed > 5000
ORDER  BY Total_Billed DESC;
