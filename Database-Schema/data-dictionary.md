# Data dictionary

PK = primary key, FK = foreign key, UQ = unique, NN = not null.

### DEPARTMENT
| Column | Type | Constraint | Description |
|---|---|---|---|
| Department_ID | NUMBER(4) | PK | Department number |
| Department_Name | VARCHAR2(50) | NN, UQ | e.g. Cardiology |
| Location | VARCHAR2(50) | | Block and floor |

### DOCTOR
| Column | Type | Constraint | Description |
|---|---|---|---|
| Doctor_ID | NUMBER(4) | PK | Doctor number |
| Name | VARCHAR2(50) | NN | Full name |
| Specialization | VARCHAR2(50) | NN | e.g. Cardiologist |
| Phone | VARCHAR2(15) | NN, UQ | Contact number |
| Salary | NUMBER(10,2) | CHECK > 0 | Monthly salary (Rs.) |
| Department_ID | NUMBER(4) | FK → DEPARTMENT | Department the doctor works in |

### PATIENT
| Column | Type | Constraint | Description |
|---|---|---|---|
| Patient_ID | NUMBER(5) | PK | Patient number |
| Name | VARCHAR2(50) | NN | Full name |
| DOB | DATE | NN | Date of birth (age is derived) |
| Gender | VARCHAR2(10) | CHECK IN (Male, Female, Other) | |
| Phone | VARCHAR2(15) | NN, UQ | Contact number (candidate key) |
| City | VARCHAR2(30) | | City of residence |
| Blood_Group | VARCHAR2(3) | CHECK IN (A±, B±, AB±, O±) | |

### APPOINTMENT
| Column | Type | Constraint | Description |
|---|---|---|---|
| Appointment_ID | NUMBER(6) | PK | Appointment number |
| Patient_ID | NUMBER(5) | NN, FK → PATIENT | |
| Doctor_ID | NUMBER(4) | NN, FK → DOCTOR | |
| Appointment_Date | DATE | NN | |
| Appointment_Time | VARCHAR2(5) | NN | 'HH24:MI' |
| Status | VARCHAR2(10) | DEFAULT 'Scheduled', CHECK | Scheduled / Completed / Cancelled |
| — | | UQ (Doctor_ID, Appointment_Date, Appointment_Time) | One booking per doctor per slot |

### ROOM
| Column | Type | Constraint | Description |
|---|---|---|---|
| Room_ID | NUMBER(4) | PK | |
| Room_Number | VARCHAR2(10) | NN, UQ | e.g. ICU-01 |
| Room_Type | VARCHAR2(15) | NN, CHECK | General / Semi-Private / Private / ICU |
| Daily_Charge | NUMBER(8,2) | NN, CHECK > 0 | Rs. per day |
| Status | VARCHAR2(10) | DEFAULT 'Available', CHECK | Available / Occupied |

### ADMISSION
| Column | Type | Constraint | Description |
|---|---|---|---|
| Admission_ID | NUMBER(6) | PK | |
| Patient_ID | NUMBER(5) | NN, FK → PATIENT | |
| Room_ID | NUMBER(4) | NN, FK → ROOM | |
| Admission_Date | DATE | NN | |
| Discharge_Date | DATE | CHECK ≥ Admission_Date | NULL while still admitted |

### MEDICINE
| Column | Type | Constraint | Description |
|---|---|---|---|
| Medicine_ID | NUMBER(5) | PK | |
| Medicine_Name | VARCHAR2(50) | NN, UQ | Name and strength |
| Manufacturer | VARCHAR2(50) | | |
| Price | NUMBER(8,2) | NN, CHECK > 0 | Rs. per strip |
| Stock | NUMBER(6) | DEFAULT 0, CHECK ≥ 0 | Strips in pharmacy |

### PRESCRIPTION
| Column | Type | Constraint | Description |
|---|---|---|---|
| Prescription_ID | NUMBER(6) | PK | |
| Patient_ID | NUMBER(5) | NN, FK → PATIENT | |
| Doctor_ID | NUMBER(4) | NN, FK → DOCTOR | |
| Prescription_Date | DATE | NN | |

### PRESCRIPTION_DETAIL
| Column | Type | Constraint | Description |
|---|---|---|---|
| Prescription_ID | NUMBER(6) | PK (part), FK → PRESCRIPTION (on delete cascade) | |
| Medicine_ID | NUMBER(5) | PK (part), FK → MEDICINE | |
| Dosage | VARCHAR2(20) | NN | '1-0-1' = morning-afternoon-night |
| Duration_Days | NUMBER(3) | CHECK > 0 | |

### LAB_TEST
| Column | Type | Constraint | Description |
|---|---|---|---|
| Test_ID | NUMBER(6) | PK | |
| Patient_ID | NUMBER(5) | NN, FK → PATIENT | |
| Doctor_ID | NUMBER(4) | FK → DOCTOR | Doctor who ordered the test |
| Test_Name | VARCHAR2(50) | NN | |
| Test_Date | DATE | NN | |
| Result | VARCHAR2(50) | | NULL = pending |
| Cost | NUMBER(8,2) | CHECK ≥ 0 | |

### BILL
| Column | Type | Constraint | Description |
|---|---|---|---|
| Bill_ID | NUMBER(6) | PK | |
| Patient_ID | NUMBER(5) | NN, FK → PATIENT | |
| Bill_Date | DATE | NN | |
| Total_Amount | NUMBER(10,2) | NN, trigger ≥ 0 | |
| Status | VARCHAR2(15) | DEFAULT 'Pending', CHECK | Paid / Pending / Partially Paid (kept in sync by trigger) |

### PAYMENT
| Column | Type | Constraint | Description |
|---|---|---|---|
| Payment_ID | NUMBER(6) | PK | |
| Bill_ID | NUMBER(6) | NN, FK → BILL | |
| Payment_Date | DATE | NN | |
| Amount | NUMBER(10,2) | NN, CHECK > 0 | |
| Payment_Mode | VARCHAR2(10) | CHECK | Cash / Card / UPI / Insurance |
