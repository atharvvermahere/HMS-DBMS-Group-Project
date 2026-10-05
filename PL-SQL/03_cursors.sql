SET SERVEROUTPUT ON;

BEGIN
    UPDATE Medicine
    SET    Stock = Stock + 50
    WHERE  Manufacturer = 'Sun Pharma';

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' Sun Pharma medicines restocked.');
    END IF;

    ROLLBACK;
END;
/

DECLARE
    CURSOR c_due_bills IS
        SELECT b.Bill_ID, p.Name, b.Total_Amount
        FROM   Bill b
        JOIN   Patient p ON b.Patient_ID = p.Patient_ID
        WHERE  b.Status <> 'Paid'
        ORDER  BY b.Bill_ID;

    v_bill_id  Bill.Bill_ID%TYPE;
    v_name     Patient.Name%TYPE;
    v_amount   Bill.Total_Amount%TYPE;
BEGIN
    OPEN c_due_bills;
    DBMS_OUTPUT.PUT_LINE('BILL  PATIENT              TOTAL     DUE');
    LOOP
        FETCH c_due_bills INTO v_bill_id, v_name, v_amount;
        EXIT WHEN c_due_bills%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(v_bill_id || '   ' || RPAD(v_name, 20) || ' '
                             || RPAD(v_amount, 9) || ' ' || GetBalanceDue(v_bill_id));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(c_due_bills%ROWCOUNT || ' bill(s) pending.');
    CLOSE c_due_bills;
END;
/

DECLARE
    CURSOR c_patients IS
        SELECT p.Patient_ID, p.Name, COUNT(a.Appointment_ID) AS Visits
        FROM   Patient p
        LEFT JOIN Appointment a ON p.Patient_ID = a.Patient_ID
        GROUP  BY p.Patient_ID, p.Name
        ORDER  BY p.Patient_ID;
BEGIN
    FOR r IN c_patients LOOP
        DBMS_OUTPUT.PUT_LINE(r.Patient_ID || ' - ' || RPAD(r.Name, 18)
                             || ' visits: ' || r.Visits);
    END LOOP;
END;
/

DECLARE
    CURSOR c_doctors (p_dept_id Department.Department_ID%TYPE) IS
        SELECT Name, Specialization, Salary
        FROM   Doctor
        WHERE  Department_ID = p_dept_id;

    v_found BOOLEAN;
BEGIN
    FOR dept IN (SELECT Department_ID, Department_Name FROM Department ORDER BY Department_ID) LOOP
        DBMS_OUTPUT.PUT_LINE('== ' || dept.Department_Name || ' ==');
        v_found := FALSE;

        FOR doc IN c_doctors(dept.Department_ID) LOOP
            DBMS_OUTPUT.PUT_LINE('   ' || doc.Name || ' (' || doc.Specialization || ')');
            v_found := TRUE;
        END LOOP;

        IF NOT v_found THEN
            DBMS_OUTPUT.PUT_LINE('   No doctors yet');
        END IF;
    END LOOP;
END;
/
