SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION GetPatientAge (
    p_patient_id IN Patient.Patient_ID%TYPE
) RETURN NUMBER
IS
    v_dob Patient.DOB%TYPE;
BEGIN
    SELECT DOB INTO v_dob
    FROM   Patient
    WHERE  Patient_ID = p_patient_id;

    RETURN TRUNC(MONTHS_BETWEEN(SYSDATE, v_dob) / 12);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END GetPatientAge;
/

CREATE OR REPLACE FUNCTION GetTotalPaid (
    p_bill_id IN Bill.Bill_ID%TYPE
) RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(Amount), 0) INTO v_total
    FROM   Payment
    WHERE  Bill_ID = p_bill_id;

    RETURN v_total;
END GetTotalPaid;
/

CREATE OR REPLACE FUNCTION GetBalanceDue (
    p_bill_id IN Bill.Bill_ID%TYPE
) RETURN NUMBER
IS
    v_total_amount Bill.Total_Amount%TYPE;
BEGIN
    SELECT Total_Amount INTO v_total_amount
    FROM   Bill
    WHERE  Bill_ID = p_bill_id;

    RETURN v_total_amount - GetTotalPaid(p_bill_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END GetBalanceDue;
/

CREATE OR REPLACE FUNCTION GetStayCharge (
    p_admission_id IN Admission.Admission_ID%TYPE
) RETURN NUMBER
IS
    v_days   NUMBER;
    v_charge Room.Daily_Charge%TYPE;
BEGIN
    SELECT GREATEST(NVL(a.Discharge_Date, TRUNC(SYSDATE)) - a.Admission_Date, 1),
           r.Daily_Charge
    INTO   v_days, v_charge
    FROM   Admission a
    JOIN   Room r ON a.Room_ID = r.Room_ID
    WHERE  a.Admission_ID = p_admission_id;

    RETURN v_days * v_charge;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END GetStayCharge;
/

SELECT Patient_ID, Name, GetPatientAge(Patient_ID) AS Age
FROM   Patient;

SELECT Bill_ID,
       Total_Amount,
       GetTotalPaid(Bill_ID)  AS Paid,
       GetBalanceDue(Bill_ID) AS Balance_Due
FROM   Bill
ORDER  BY Balance_Due DESC;

SELECT Admission_ID, Patient_ID, GetStayCharge(Admission_ID) AS Room_Charge
FROM   Admission;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Balance due on bill 905 : Rs. ' || GetBalanceDue(905));
    DBMS_OUTPUT.PUT_LINE('Room charge, admission 501 : Rs. ' || GetStayCharge(501));
END;
/
