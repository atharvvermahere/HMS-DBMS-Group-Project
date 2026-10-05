# 1. ER Model — Hospital Management System

![ER Diagram](ER-Diagram.png)

*Chen notation: rectangle = entity, diamond = relationship, oval = attribute,
underlined = key attribute, red labels = cardinality.*

## Entities

| Entity | Key attribute | Other attributes |
|---|---|---|
| DEPARTMENT | <u>Department_ID</u> | Department_Name, Location |
| DOCTOR | <u>Doctor_ID</u> | Name, Specialization, Phone, Salary |
| PATIENT | <u>Patient_ID</u> | Name, DOB, Gender, Phone, City, Blood_Group |
| ROOM | <u>Room_ID</u> | Room_Number, Room_Type, Daily_Charge, Status |
| MEDICINE | <u>Medicine_ID</u> | Medicine_Name, Manufacturer, Price, Stock |
| PRESCRIPTION | <u>Prescription_ID</u> | Prescription_Date |
| LAB_TEST | <u>Test_ID</u> | Test_Name, Test_Date, Result, Cost |
| BILL | <u>Bill_ID</u> | Bill_Date, Total_Amount, Status |
| PAYMENT | <u>Payment_ID</u> | Payment_Date, Amount, Payment_Mode |

## Relationships

| Relationship | Between | Cardinality | Relationship attributes | Becomes table |
|---|---|---|---|---|
| Works_In | DEPARTMENT – DOCTOR | 1 : N | — | FK `Department_ID` in DOCTOR |
| Appointment | DOCTOR – PATIENT | M : N | Appointment_ID, Date, Time, Status | **APPOINTMENT** |
| Writes | DOCTOR – PRESCRIPTION | 1 : N | — | FK `Doctor_ID` in PRESCRIPTION |
| Receives | PATIENT – PRESCRIPTION | 1 : N | — | FK `Patient_ID` in PRESCRIPTION |
| Contains | PRESCRIPTION – MEDICINE | M : N | Dosage, Duration_Days | **PRESCRIPTION_DETAIL** |
| Orders | DOCTOR – LAB_TEST | 1 : N | — | FK `Doctor_ID` in LAB_TEST |
| Undergoes | PATIENT – LAB_TEST | 1 : N | — | FK `Patient_ID` in LAB_TEST |
| Admitted_In | PATIENT – ROOM | M : N | Admission_ID, Admission_Date, Discharge_Date | **ADMISSION** |
| Billed | PATIENT – BILL | 1 : N | — | FK `Patient_ID` in BILL |
| Settles | BILL – PAYMENT | 1 : N | — | FK `Bill_ID` in PAYMENT |

## ER → relational mapping rules used

1. Every **strong entity** → its own table, key attribute → primary key.
2. **1 : N** relationship → put the primary key of the "1" side as a **foreign key** in the "N" side.
3. **M : N** relationship → a **new table** whose key combines both sides' keys
   (we use a surrogate key `Appointment_ID` / `Admission_ID`, and a composite key
   `(Prescription_ID, Medicine_ID)` for PRESCRIPTION_DETAIL).
4. Relationship attributes go into the table created for the relationship.

## Crow's-foot version (renders automatically on GitHub)

```mermaid
erDiagram
    DEPARTMENT ||--o{ DOCTOR : "works in"
    DOCTOR ||--o{ APPOINTMENT : attends
    PATIENT ||--o{ APPOINTMENT : books
    DOCTOR ||--o{ PRESCRIPTION : writes
    PATIENT ||--o{ PRESCRIPTION : receives
    PRESCRIPTION ||--|{ PRESCRIPTION_DETAIL : contains
    MEDICINE ||--o{ PRESCRIPTION_DETAIL : "appears in"
    DOCTOR ||--o{ LAB_TEST : orders
    PATIENT ||--o{ LAB_TEST : undergoes
    PATIENT ||--o{ ADMISSION : "admitted as"
    ROOM ||--o{ ADMISSION : hosts
    PATIENT ||--o{ BILL : "billed in"
    BILL ||--o{ PAYMENT : "settled by"

    DEPARTMENT {
        int Department_ID PK
        string Department_Name UK
        string Location
    }
    DOCTOR {
        int Doctor_ID PK
        string Name
        string Specialization
        string Phone UK
        float Salary
        int Department_ID FK
    }
    PATIENT {
        int Patient_ID PK
        string Name
        date DOB
        string Gender
        string Phone UK
        string City
        string Blood_Group
    }
    APPOINTMENT {
        int Appointment_ID PK
        int Patient_ID FK
        int Doctor_ID FK
        date Appointment_Date
        string Appointment_Time
        string Status
    }
    ROOM {
        int Room_ID PK
        string Room_Number UK
        string Room_Type
        float Daily_Charge
        string Status
    }
    ADMISSION {
        int Admission_ID PK
        int Patient_ID FK
        int Room_ID FK
        date Admission_Date
        date Discharge_Date
    }
    MEDICINE {
        int Medicine_ID PK
        string Medicine_Name UK
        string Manufacturer
        float Price
        int Stock
    }
    PRESCRIPTION {
        int Prescription_ID PK
        int Patient_ID FK
        int Doctor_ID FK
        date Prescription_Date
    }
    PRESCRIPTION_DETAIL {
        int Prescription_ID PK,FK
        int Medicine_ID PK,FK
        string Dosage
        int Duration_Days
    }
    LAB_TEST {
        int Test_ID PK
        int Patient_ID FK
        int Doctor_ID FK
        string Test_Name
        date Test_Date
        string Result
        float Cost
    }
    BILL {
        int Bill_ID PK
        int Patient_ID FK
        date Bill_Date
        float Total_Amount
        string Status
    }
    PAYMENT {
        int Payment_ID PK
        int Bill_ID FK
        date Payment_Date
        float Amount
        string Payment_Mode
    }
```
