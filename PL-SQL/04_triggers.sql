SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER trg_check_bill_amount
BEFORE INSERT OR UPDATE OF Total_Amount ON Bill
FOR EACH ROW
BEGIN
    IF :NEW.Total_Amount < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Bill amount cannot be negative');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_admission_room
BEFORE INSERT ON Admission
FOR EACH ROW
DECLARE
    v_status Room.Status%TYPE;
BEGIN
    SELECT Status INTO v_status
    FROM   Room
    WHERE  Room_ID = :NEW.Room_ID;

    IF v_status = 'Occupied' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Room ' || :NEW.Room_ID || ' is already occupied');
    END IF;

    UPDATE Room SET Status = 'Occupied' WHERE Room_ID = :NEW.Room_ID;
END;
/

CREATE OR REPLACE TRIGGER trg_update_bill_status
AFTER INSERT OR DELETE ON Payment
BEGIN
    UPDATE Bill b
    SET    Status = CASE
                      WHEN (SELECT NVL(SUM(p.Amount), 0) FROM Payment p
                            WHERE  p.Bill_ID = b.Bill_ID) >= b.Total_Amount THEN 'Paid'
                      WHEN (SELECT NVL(SUM(p.Amount), 0) FROM Payment p
                            WHERE  p.Bill_ID = b.Bill_ID) > 0              THEN 'Partially Paid'
                      ELSE 'Pending'
                    END;
END;
/

CREATE TABLE Patient_Audit (
    Audit_ID    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Patient_ID  NUMBER(5),
    Action      VARCHAR2(10),
    Old_Phone   VARCHAR2(15),
    New_Phone   VARCHAR2(15),
    Changed_By  VARCHAR2(30),
    Changed_On  DATE
);

CREATE OR REPLACE TRIGGER trg_patient_audit
AFTER UPDATE OR DELETE ON Patient
FOR EACH ROW
BEGIN
    INSERT INTO Patient_Audit (Patient_ID, Action, Old_Phone, New_Phone, Changed_By, Changed_On)
    VALUES (:OLD.Patient_ID,
            CASE WHEN UPDATING THEN 'UPDATE' ELSE 'DELETE' END,
            :OLD.Phone,
            :NEW.Phone,
            USER,
            SYSDATE);
END;
/

INSERT INTO Bill VALUES (917, 101, DATE '2026-10-01', -500, 'Pending');

INSERT INTO Admission VALUES (510, 104, 408, DATE '2026-10-01', NULL);
INSERT INTO Admission VALUES (510, 104, 405, DATE '2026-10-01', NULL);
SELECT Room_ID, Status FROM Room WHERE Room_ID = 405;

INSERT INTO Payment VALUES (1017, 910, DATE '2026-10-01', 5000, 'UPI');
SELECT Bill_ID, Status FROM Bill WHERE Bill_ID = 910;
INSERT INTO Payment VALUES (1018, 910, DATE '2026-10-02', 4500, 'Card');
SELECT Bill_ID, Status FROM Bill WHERE Bill_ID = 910;

UPDATE Patient SET Phone = '9111100101' WHERE Patient_ID = 101;
SELECT * FROM Patient_Audit;

ROLLBACK;
