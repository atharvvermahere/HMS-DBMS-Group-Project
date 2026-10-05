CREATE TABLE Department (
    Department_ID    NUMBER(4)     CONSTRAINT pk_department PRIMARY KEY,
    Department_Name  VARCHAR2(50)  NOT NULL
                                   CONSTRAINT uq_department_name UNIQUE,
    Location         VARCHAR2(50)
);

CREATE TABLE Doctor (
    Doctor_ID        NUMBER(4)     CONSTRAINT pk_doctor PRIMARY KEY,
    Name             VARCHAR2(50)  NOT NULL,
    Specialization   VARCHAR2(50)  NOT NULL,
    Phone            VARCHAR2(15)  NOT NULL
                                   CONSTRAINT uq_doctor_phone UNIQUE,
    Salary           NUMBER(10,2)  CONSTRAINT chk_doctor_salary CHECK (Salary > 0),
    Department_ID    NUMBER(4)     CONSTRAINT fk_doctor_department
                                   REFERENCES Department (Department_ID)
);

CREATE TABLE Patient (
    Patient_ID       NUMBER(5)     CONSTRAINT pk_patient PRIMARY KEY,
    Name             VARCHAR2(50)  NOT NULL,
    DOB              DATE          NOT NULL,
    Gender           VARCHAR2(10)  CONSTRAINT chk_patient_gender
                                   CHECK (Gender IN ('Male', 'Female', 'Other')),
    Phone            VARCHAR2(15)  NOT NULL
                                   CONSTRAINT uq_patient_phone UNIQUE,
    City             VARCHAR2(30),
    Blood_Group      VARCHAR2(3)   CONSTRAINT chk_patient_blood_group
                                   CHECK (Blood_Group IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);

CREATE TABLE Appointment (
    Appointment_ID   NUMBER(6)     CONSTRAINT pk_appointment PRIMARY KEY,
    Patient_ID       NUMBER(5)     NOT NULL
                                   CONSTRAINT fk_appointment_patient
                                   REFERENCES Patient (Patient_ID),
    Doctor_ID        NUMBER(4)     NOT NULL
                                   CONSTRAINT fk_appointment_doctor
                                   REFERENCES Doctor (Doctor_ID),
    Appointment_Date DATE          NOT NULL,
    Appointment_Time VARCHAR2(5)   NOT NULL,
    Status           VARCHAR2(10)  DEFAULT 'Scheduled'
                                   CONSTRAINT chk_appointment_status
                                   CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),
    CONSTRAINT uq_doctor_slot UNIQUE (Doctor_ID, Appointment_Date, Appointment_Time)
);

CREATE TABLE Room (
    Room_ID          NUMBER(4)     CONSTRAINT pk_room PRIMARY KEY,
    Room_Number      VARCHAR2(10)  NOT NULL
                                   CONSTRAINT uq_room_number UNIQUE,
    Room_Type        VARCHAR2(15)  NOT NULL
                                   CONSTRAINT chk_room_type
                                   CHECK (Room_Type IN ('General', 'Semi-Private', 'Private', 'ICU')),
    Daily_Charge     NUMBER(8,2)   NOT NULL
                                   CONSTRAINT chk_room_charge CHECK (Daily_Charge > 0),
    Status           VARCHAR2(10)  DEFAULT 'Available'
                                   CONSTRAINT chk_room_status
                                   CHECK (Status IN ('Available', 'Occupied'))
);

CREATE TABLE Admission (
    Admission_ID     NUMBER(6)     CONSTRAINT pk_admission PRIMARY KEY,
    Patient_ID       NUMBER(5)     NOT NULL
                                   CONSTRAINT fk_admission_patient
                                   REFERENCES Patient (Patient_ID),
    Room_ID          NUMBER(4)     NOT NULL
                                   CONSTRAINT fk_admission_room
                                   REFERENCES Room (Room_ID),
    Admission_Date   DATE          NOT NULL,
    Discharge_Date   DATE,
    CONSTRAINT chk_admission_dates
        CHECK (Discharge_Date IS NULL OR Discharge_Date >= Admission_Date)
);

CREATE TABLE Medicine (
    Medicine_ID      NUMBER(5)     CONSTRAINT pk_medicine PRIMARY KEY,
    Medicine_Name    VARCHAR2(50)  NOT NULL
                                   CONSTRAINT uq_medicine_name UNIQUE,
    Manufacturer     VARCHAR2(50),
    Price            NUMBER(8,2)   NOT NULL
                                   CONSTRAINT chk_medicine_price CHECK (Price > 0),
    Stock            NUMBER(6)     DEFAULT 0
                                   CONSTRAINT chk_medicine_stock CHECK (Stock >= 0)
);

CREATE TABLE Prescription (
    Prescription_ID   NUMBER(6)    CONSTRAINT pk_prescription PRIMARY KEY,
    Patient_ID        NUMBER(5)    NOT NULL
                                   CONSTRAINT fk_prescription_patient
                                   REFERENCES Patient (Patient_ID),
    Doctor_ID         NUMBER(4)    NOT NULL
                                   CONSTRAINT fk_prescription_doctor
                                   REFERENCES Doctor (Doctor_ID),
    Prescription_Date DATE         NOT NULL
);

CREATE TABLE Prescription_Detail (
    Prescription_ID  NUMBER(6)     CONSTRAINT fk_detail_prescription
                                   REFERENCES Prescription (Prescription_ID)
                                   ON DELETE CASCADE,
    Medicine_ID      NUMBER(5)     CONSTRAINT fk_detail_medicine
                                   REFERENCES Medicine (Medicine_ID),
    Dosage           VARCHAR2(20)  NOT NULL,
    Duration_Days    NUMBER(3)     CONSTRAINT chk_detail_duration CHECK (Duration_Days > 0),
    CONSTRAINT pk_prescription_detail PRIMARY KEY (Prescription_ID, Medicine_ID)
);

CREATE TABLE Lab_Test (
    Test_ID          NUMBER(6)     CONSTRAINT pk_lab_test PRIMARY KEY,
    Patient_ID       NUMBER(5)     NOT NULL
                                   CONSTRAINT fk_lab_test_patient
                                   REFERENCES Patient (Patient_ID),
    Doctor_ID        NUMBER(4)     CONSTRAINT fk_lab_test_doctor
                                   REFERENCES Doctor (Doctor_ID),
    Test_Name        VARCHAR2(50)  NOT NULL,
    Test_Date        DATE          NOT NULL,
    Result           VARCHAR2(50),
    Cost             NUMBER(8,2)   CONSTRAINT chk_lab_test_cost CHECK (Cost >= 0)
);

CREATE TABLE Bill (
    Bill_ID          NUMBER(6)     CONSTRAINT pk_bill PRIMARY KEY,
    Patient_ID       NUMBER(5)     NOT NULL
                                   CONSTRAINT fk_bill_patient
                                   REFERENCES Patient (Patient_ID),
    Bill_Date        DATE          NOT NULL,
    Total_Amount     NUMBER(10,2)  NOT NULL,
    Status           VARCHAR2(15)  DEFAULT 'Pending'
                                   CONSTRAINT chk_bill_status
                                   CHECK (Status IN ('Paid', 'Pending', 'Partially Paid'))
);

CREATE TABLE Payment (
    Payment_ID       NUMBER(6)     CONSTRAINT pk_payment PRIMARY KEY,
    Bill_ID          NUMBER(6)     NOT NULL
                                   CONSTRAINT fk_payment_bill
                                   REFERENCES Bill (Bill_ID),
    Payment_Date     DATE          NOT NULL,
    Amount           NUMBER(10,2)  NOT NULL
                                   CONSTRAINT chk_payment_amount CHECK (Amount > 0),
    Payment_Mode     VARCHAR2(10)  CONSTRAINT chk_payment_mode
                                   CHECK (Payment_Mode IN ('Cash', 'Card', 'UPI', 'Insurance'))
);
