SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE GetPatientDetails (
    p_patient_id IN Patient.Patient_ID%TYPE
)
IS
    v_patient Patient%ROWTYPE;
BEGIN
    SELECT * INTO v_patient
    FROM   Patient
    WHERE  Patient_ID = p_patient_id;

    DBMS_OUTPUT.PUT_LINE('Patient ID  : ' || v_patient.Patient_ID);
    DBMS_OUTPUT.PUT_LINE('Name        : ' || v_patient.Name);
    DBMS_OUTPUT.PUT_LINE('Age         : ' || GetPatientAge(p_patient_id));
    DBMS_OUTPUT.PUT_LINE('Gender      : ' || v_patient.Gender);
    DBMS_OUTPUT.PUT_LINE('Phone       : ' || v_patient.Phone);
    DBMS_OUTPUT.PUT_LINE('City        : ' || v_patient.City);
    DBMS_OUTPUT.PUT_LINE('Blood Group : ' || v_patient.Blood_Group);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No patient found with ID ' || p_patient_id);
END GetPatientDetails;
/

CREATE OR REPLACE PROCEDURE BookAppointment (
    p_patient_id IN  Appointment.Patient_ID%TYPE,
    p_doctor_id  IN  Appointment.Doctor_ID%TYPE,
    p_date       IN  Appointment.Appointment_Date%TYPE,
    p_time       IN  Appointment.Appointment_Time%TYPE,
    p_new_id     OUT Appointment.Appointment_ID%TYPE
)
IS
BEGIN
    SELECT NVL(MAX(Appointment_ID), 300) + 1 INTO p_new_id
    FROM   Appointment;

    INSERT INTO Appointment
    VALUES (p_new_id, p_patient_id, p_doctor_id, p_date, p_time, 'Scheduled');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment ' || p_new_id || ' booked for '
                         || TO_CHAR(p_date, 'DD-Mon-YYYY') || ' at ' || p_time);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_new_id := NULL;
        DBMS_OUTPUT.PUT_LINE('Doctor ' || p_doctor_id || ' is already booked at that time.');
    WHEN OTHERS THEN
        p_new_id := NULL;
        DBMS_OUTPUT.PUT_LINE('Could not book: ' || SQLERRM);
END BookAppointment;
/

CREATE OR REPLACE PROCEDURE DischargePatient (
    p_admission_id   IN Admission.Admission_ID%TYPE,
    p_discharge_date IN DATE DEFAULT TRUNC(SYSDATE)
)
IS
    v_room_id Admission.Room_ID%TYPE;
BEGIN
    UPDATE Admission
    SET    Discharge_Date = p_discharge_date
    WHERE  Admission_ID   = p_admission_id
    AND    Discharge_Date IS NULL
    RETURNING Room_ID INTO v_room_id;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Admission ' || p_admission_id
                             || ' does not exist or is already discharged.');
        RETURN;
    END IF;

    UPDATE Room SET Status = 'Available' WHERE Room_ID = v_room_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Admission ' || p_admission_id || ' discharged. Room '
                         || v_room_id || ' is now available.');
    DBMS_OUTPUT.PUT_LINE('Room charge : Rs. ' || GetStayCharge(p_admission_id));
END DischargePatient;
/

BEGIN
    GetPatientDetails(101);
    DBMS_OUTPUT.PUT_LINE('---');
    GetPatientDetails(999);
END;
/

DECLARE
    v_id Appointment.Appointment_ID%TYPE;
BEGIN
    BookAppointment(112, 208, DATE '2026-10-10', '10:00', v_id);
    BookAppointment(113, 208, DATE '2026-10-10', '10:00', v_id);
    BookAppointment(999, 208, DATE '2026-10-11', '10:00', v_id);
END;
/

BEGIN
    DischargePatient(507, DATE '2026-09-30');
    DischargePatient(501);
END;
/
