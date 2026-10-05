DESC Patient;

SELECT table_name
FROM   user_tables
ORDER  BY table_name;

SELECT table_name, constraint_name, constraint_type
FROM   user_constraints
WHERE  table_name IN ('PATIENT', 'DOCTOR', 'APPOINTMENT', 'PRESCRIPTION_DETAIL')
ORDER  BY table_name, constraint_type;

SELECT c.table_name   AS child_table,
       cc.column_name AS fk_column,
       p.table_name   AS parent_table
FROM   user_constraints  c
JOIN   user_cons_columns cc ON c.constraint_name = cc.constraint_name
JOIN   user_constraints  p  ON c.r_constraint_name = p.constraint_name
WHERE  c.constraint_type = 'R'
ORDER  BY child_table;

ALTER TABLE Patient ADD Email VARCHAR2(60);
ALTER TABLE Patient MODIFY Email VARCHAR2(80);
ALTER TABLE Patient DROP COLUMN Email;

SELECT * FROM Patient;

SELECT Name, Phone FROM Doctor;

SELECT Patient_ID, Name, City
FROM   Patient
WHERE  Blood_Group = 'O+';

SELECT DISTINCT City FROM Patient;

SELECT Name, Specialization, Salary
FROM   Doctor
ORDER  BY Salary DESC;

SELECT Medicine_Name,
       Price,
       Stock,
       Price * Stock AS Stock_Value
FROM   Medicine
ORDER  BY Stock_Value DESC;

SELECT Room_Number, Room_Type, Daily_Charge
FROM   Room
WHERE  Status = 'Available';

SELECT Admission_ID, Patient_ID, Room_ID, Admission_Date
FROM   Admission
WHERE  Discharge_Date IS NULL;

SAVEPOINT before_dml;

INSERT INTO Patient (Patient_ID, Name, DOB, Gender, Phone, City, Blood_Group)
VALUES (116, 'Nikhil Bansal', DATE '1998-01-20', 'Male', '9876500116', 'Bhopal', 'A+');

UPDATE Patient
SET    Phone = '9999900116'
WHERE  Patient_ID = 116;

UPDATE Medicine
SET    Price = Price * 1.10
WHERE  Manufacturer = 'Cipla';

DELETE FROM Patient
WHERE  Patient_ID = 116;

ROLLBACK TO before_dml;
