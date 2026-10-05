# 2. Schema and 3. Keys

## Relational schema

The primary and foreign keys of each relation are listed in the table below the schema.

```text
DEPARTMENT          ( Department_ID, Department_Name, Location )
DOCTOR              ( Doctor_ID, Name, Specialization, Phone, Salary, Department_ID )
PATIENT             ( Patient_ID, Name, DOB, Gender, Phone, City, Blood_Group )
APPOINTMENT         ( Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Appointment_Time, Status )
ROOM                ( Room_ID, Room_Number, Room_Type, Daily_Charge, Status )
ADMISSION           ( Admission_ID, Patient_ID, Room_ID, Admission_Date, Discharge_Date )
MEDICINE            ( Medicine_ID, Medicine_Name, Manufacturer, Price, Stock )
PRESCRIPTION        ( Prescription_ID, Patient_ID, Doctor_ID, Prescription_Date )
PRESCRIPTION_DETAIL ( Prescription_ID, Medicine_ID, Dosage, Duration_Days )
LAB_TEST            ( Test_ID, Patient_ID, Doctor_ID, Test_Name, Test_Date, Result, Cost )
BILL                ( Bill_ID, Patient_ID, Bill_Date, Total_Amount, Status )
PAYMENT             ( Payment_ID, Bill_ID, Payment_Date, Amount, Payment_Mode )
```

| Relation | Primary key | Foreign keys |
|---|---|---|
| DEPARTMENT | **Department_ID** | — |
| DOCTOR | **Doctor_ID** | Department_ID → DEPARTMENT |
| PATIENT | **Patient_ID** | — |
| APPOINTMENT | **Appointment_ID** | Patient_ID → PATIENT, Doctor_ID → DOCTOR |
| ROOM | **Room_ID** | — |
| ADMISSION | **Admission_ID** | Patient_ID → PATIENT, Room_ID → ROOM |
| MEDICINE | **Medicine_ID** | — |
| PRESCRIPTION | **Prescription_ID** | Patient_ID → PATIENT, Doctor_ID → DOCTOR |
| PRESCRIPTION_DETAIL | **(Prescription_ID, Medicine_ID)** | Prescription_ID → PRESCRIPTION, Medicine_ID → MEDICINE |
| LAB_TEST | **Test_ID** | Patient_ID → PATIENT, Doctor_ID → DOCTOR |
| BILL | **Bill_ID** | Patient_ID → PATIENT |
| PAYMENT | **Payment_ID** | Bill_ID → BILL |

## Schema diagram (arrows: foreign key → referenced primary key)

```text
DEPARTMENT ◄──── DOCTOR ◄──┬──── APPOINTMENT ────► PATIENT
                           ├──── PRESCRIPTION ───► PATIENT
                           └──── LAB_TEST ───────► PATIENT
PRESCRIPTION ◄── PRESCRIPTION_DETAIL ──► MEDICINE
PATIENT ◄─────── ADMISSION ────────────► ROOM
PATIENT ◄─────── BILL ◄──────────────── PAYMENT
```

## Keys

| Key type | Definition | Example in our HMS |
|---|---|---|
| **Super key** | Any set of attributes that uniquely identifies a tuple | {Patient_ID}, {Patient_ID, Name}, {Phone}, {Phone, City} |
| **Candidate key** | A *minimal* super key (no attribute can be removed) | PATIENT: {Patient_ID} and {Phone}. ROOM: {Room_ID} and {Room_Number} |
| **Primary key** | The candidate key chosen to identify tuples | Patient_ID, Doctor_ID, Room_ID … |
| **Alternate key** | Candidate keys not chosen as primary | PATIENT.Phone, DOCTOR.Phone, ROOM.Room_Number, MEDICINE.Medicine_Name (declared `UNIQUE`) |
| **Foreign key** | Attribute referring to the primary key of another relation | DOCTOR.Department_ID → DEPARTMENT.Department_ID |
| **Composite key** | Key made of two or more attributes | PRESCRIPTION_DETAIL (Prescription_ID, Medicine_ID) |
| **Composite candidate key** | — | APPOINTMENT (Doctor_ID, Appointment_Date, Appointment_Time) — a doctor can't be booked twice in one slot |
| **Surrogate key** | System-generated key with no business meaning | Appointment_ID, Admission_ID, Patient_Audit.Audit_ID (identity) |

## Constraints used

| Constraint | Where |
|---|---|
| `PRIMARY KEY` | Every table |
| `FOREIGN KEY` | 15 references (see table above); `ON DELETE CASCADE` from PRESCRIPTION to PRESCRIPTION_DETAIL |
| `NOT NULL` | Names, dates, phone numbers, amounts |
| `UNIQUE` | Department_Name, Doctor.Phone, Patient.Phone, Room_Number, Medicine_Name, (Doctor_ID, Date, Time) |
| `CHECK` | Gender, Blood_Group, Status values, Salary > 0, Price > 0, Stock ≥ 0, Discharge_Date ≥ Admission_Date |
| `DEFAULT` | Appointment.Status = 'Scheduled', Room.Status = 'Available', Bill.Status = 'Pending', Stock = 0 |
| Trigger | Bill.Total_Amount ≥ 0 (`trg_check_bill_amount`) |
