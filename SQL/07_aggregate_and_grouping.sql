SELECT COUNT(*)          AS Total_Patients     FROM Patient;
SELECT COUNT(Result)     AS Tests_With_Result  FROM Lab_Test;
SELECT SUM(Amount)       AS Total_Collected    FROM Payment;
SELECT AVG(Total_Amount) AS Average_Bill       FROM Bill;
SELECT MAX(Total_Amount) AS Highest_Bill,
       MIN(Total_Amount) AS Lowest_Bill        FROM Bill;

SELECT Blood_Group, COUNT(*) AS Total
FROM   Patient
GROUP  BY Blood_Group
ORDER  BY Total DESC;

SELECT dp.Department_Name,
       COUNT(d.Doctor_ID)   AS Total_Doctors,
       ROUND(AVG(d.Salary)) AS Avg_Salary
FROM   Department dp
LEFT JOIN Doctor d ON dp.Department_ID = d.Department_ID
GROUP  BY dp.Department_Name
ORDER  BY Total_Doctors DESC;

SELECT Department_ID, COUNT(*) AS Doctor_Count
FROM   Doctor
GROUP  BY Department_ID
HAVING COUNT(*) > 2;

SELECT Payment_Mode, COUNT(*) AS Payments, SUM(Amount) AS Total_Amount
FROM   Payment
GROUP  BY Payment_Mode
ORDER  BY Total_Amount DESC;

SELECT d.Name, a.Status, COUNT(*) AS Appointments
FROM   Appointment a
JOIN   Doctor d ON a.Doctor_ID = d.Doctor_ID
GROUP  BY d.Name, a.Status
ORDER  BY d.Name;

SELECT Doctor_ID, COUNT(*) AS Completed
FROM   Appointment
WHERE  Status = 'Completed'
GROUP  BY Doctor_ID
HAVING COUNT(*) >= 2;

SELECT p.Name, SUM(l.Cost) AS Lab_Spend
FROM   Lab_Test l
JOIN   Patient p ON l.Patient_ID = p.Patient_ID
GROUP  BY p.Name
ORDER  BY Lab_Spend DESC;

SELECT NVL(Status, '** GRAND TOTAL **') AS Status,
       SUM(Total_Amount)                 AS Amount
FROM   Bill
GROUP  BY ROLLUP (Status);

CREATE OR REPLACE TYPE Medicine_Name_List AS TABLE OF VARCHAR2(50);
/

SELECT pd.Prescription_ID,
       CAST(COLLECT(m.Medicine_Name) AS Medicine_Name_List) AS Medicines
FROM   Prescription_Detail pd
JOIN   Medicine m ON pd.Medicine_ID = m.Medicine_ID
GROUP  BY pd.Prescription_ID;

WITH Grouped AS (
    SELECT pd.Prescription_ID,
           CAST(COLLECT(m.Medicine_Name) AS Medicine_Name_List) AS Medicines
    FROM   Prescription_Detail pd
    JOIN   Medicine m ON pd.Medicine_ID = m.Medicine_ID
    GROUP  BY pd.Prescription_ID
)
SELECT g.Prescription_ID,
       t.COLUMN_VALUE AS Medicine_Name
FROM   Grouped g,
       TABLE(g.Medicines) t
ORDER  BY g.Prescription_ID;

SELECT d.Name AS Doctor,
       LISTAGG(p.Name, ', ') WITHIN GROUP (ORDER BY p.Name) AS Patients_Seen
FROM   Appointment a
JOIN   Doctor  d ON a.Doctor_ID  = d.Doctor_ID
JOIN   Patient p ON a.Patient_ID = p.Patient_ID
GROUP  BY d.Name;
