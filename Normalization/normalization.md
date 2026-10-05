# 10. Normalization

Normalization breaks a badly designed relation into smaller relations so that
redundancy and the **insertion, update and deletion anomalies** it causes
disappear, using **functional dependencies (FDs)** as the guide.

## Step 0 — Unnormalized form (UNF)

Suppose the hospital first kept prescriptions in one big register:

**HOSPITAL_RECORD**

| Presc_ID | Presc_Date | Patient_ID | Patient_Name | Patient_Phone | Doctor_ID | Doctor_Name | Dept_ID | Dept_Name | Medicines (Medicine_ID, Name, Manufacturer, Price, Dosage, Days) |
|---|---|---|---|---|---|---|---|---|---|
| 705 | 06-08-2026 | 105 | Mohammed Arif | 9876500105 | 201 | Dr. Anil Mehta | 1 | Cardiology | (603, Atorvastatin 10mg, Sun Pharma, 120, 0-0-1, 30), (605, Amlodipine 5mg, Sun Pharma, 60, 1-0-0, 30), (609, Aspirin 75mg, Bayer, 35, 0-1-0, 30) |
| 713 | 20-08-2026 | 115 | Deepak Saxena | 9876500115 | 201 | Dr. Anil Mehta | 1 | Cardiology | (602, Amoxicillin 250mg, Sun Pharma, 85, 1-0-1, 7), (605, Amlodipine 5mg, Sun Pharma, 60, 1-0-0, 30) |
| 707 | 10-08-2026 | 107 | Karan Malhotra | 9876500107 | 202 | Dr. Kavita Rao | 1 | Cardiology | (605, Amlodipine 5mg, Sun Pharma, 60, 1-0-0, 30), (603, Atorvastatin 10mg, Sun Pharma, 120, 0-0-1, 30) |

**Problems**

* **Repeating group**: the Medicines column holds many values, so it is not atomic.
* **Redundancy**: "Dr. Anil Mehta, Cardiology" and "Amlodipine 5mg, Sun Pharma, 60" are stored again and again.
* **Update anomaly**: if Amlodipine's price changes, every row containing it must be edited. Missing one leaves inconsistent data.
* **Insertion anomaly**: a new medicine or a new doctor can't be recorded until someone writes a prescription for it.
* **Deletion anomaly**: deleting prescription 709 would also delete everything we know about Metformin and Insulin Glargine (no other prescription uses them).

## Functional dependencies

```text
FD1  Presc_ID              → Presc_Date, Patient_ID, Doctor_ID
FD2  Patient_ID            → Patient_Name, Patient_Phone
FD3  Doctor_ID             → Doctor_Name, Dept_ID
FD4  Dept_ID               → Dept_Name
FD5  Medicine_ID           → Medicine_Name, Manufacturer, Price
FD6  (Presc_ID, Medicine_ID) → Dosage, Days
```

Key of the flattened relation: **(Presc_ID, Medicine_ID)**, because its closure gives every attribute:

```text
(Presc_ID, Medicine_ID)+ = { Presc_ID, Medicine_ID, Presc_Date, Patient_ID, Doctor_ID,
                             Patient_Name, Patient_Phone, Doctor_Name, Dept_ID, Dept_Name,
                             Medicine_Name, Manufacturer, Price, Dosage, Days }
```

## Step 1 — First Normal Form (1NF)

> **1NF**: every attribute holds only atomic (single) values, with no repeating groups.

Flatten the repeating group: one row per (prescription, medicine).

**HOSPITAL_RECORD_1NF** (Presc_ID, Medicine_ID, Presc_Date, Patient_ID, Patient_Name, Patient_Phone, Doctor_ID, Doctor_Name, Dept_ID, Dept_Name, Medicine_Name, Manufacturer, Price, Dosage, Days)

| Presc_ID | Medicine_ID | Patient_Name | Doctor_Name | Dept_Name | Medicine_Name | Price | Dosage | Days |
|---|---|---|---|---|---|---|---|---|
| 705 | 603 | Mohammed Arif | Dr. Anil Mehta | Cardiology | Atorvastatin 10mg | 120 | 0-0-1 | 30 |
| 705 | 605 | Mohammed Arif | Dr. Anil Mehta | Cardiology | Amlodipine 5mg | 60 | 1-0-0 | 30 |
| 705 | 609 | Mohammed Arif | Dr. Anil Mehta | Cardiology | Aspirin 75mg | 35 | 0-1-0 | 30 |
| 713 | 602 | Deepak Saxena | Dr. Anil Mehta | Cardiology | Amoxicillin 250mg | 85 | 1-0-1 | 7 |
| 713 | 605 | Deepak Saxena | Dr. Anil Mehta | Cardiology | Amlodipine 5mg | 60 | 1-0-0 | 30 |
| … | | | | | | | | |

*(some columns hidden for width)*. It is now in 1NF, but redundancy is even worse.

## Step 2 — Second Normal Form (2NF)

> **2NF**: in 1NF **and** no non-prime attribute depends on only **part** of a
> candidate key (no partial dependency).

Partial dependencies on the key (Presc_ID, Medicine_ID):

* FD1/FD2/FD3/FD4: Presc_Date, Patient…, Doctor…, Dept… depend on **Presc_ID alone**
* FD5: Medicine_Name, Manufacturer, Price depend on **Medicine_ID alone**

Decompose:

```text
PRESCRIPTION_2NF   ( Presc_ID, Presc_Date, Patient_ID, Patient_Name, Patient_Phone,
                     Doctor_ID, Doctor_Name, Dept_ID, Dept_Name )
MEDICINE           ( Medicine_ID, Medicine_Name, Manufacturer, Price )
PRESCRIPTION_DETAIL( Presc_ID, Medicine_ID, Dosage, Days )
```

## Step 3 — Third Normal Form (3NF)

> **3NF**: in 2NF **and** no non-prime attribute depends **transitively** on the
> key. For every FD X → A, either X is a super key or A is a prime attribute.

Transitive dependencies in PRESCRIPTION_2NF:

```text
Presc_ID → Patient_ID → Patient_Name, Patient_Phone
Presc_ID → Doctor_ID  → Doctor_Name, Dept_ID
Doctor_ID → Dept_ID   → Dept_Name               (two levels deep)
```

Decompose:

```text
PRESCRIPTION        ( Presc_ID, Presc_Date, Patient_ID, Doctor_ID )
PATIENT             ( Patient_ID, Patient_Name, Patient_Phone )
DOCTOR              ( Doctor_ID, Doctor_Name, Dept_ID )
DEPARTMENT          ( Dept_ID, Dept_Name )
MEDICINE            ( Medicine_ID, Medicine_Name, Manufacturer, Price )
PRESCRIPTION_DETAIL ( Presc_ID, Medicine_ID, Dosage, Days )
```

These are exactly the tables in our final schema.

## Step 4 — Boyce-Codd Normal Form (BCNF)

> **BCNF**: for every non-trivial FD X → Y, X is a **super key**.

Checking every relation:

| Relation | Determinants | Super key? |
|---|---|---|
| PRESCRIPTION | Presc_ID | ✔ |
| PATIENT | Patient_ID, Phone (Phone → Patient_ID, it is unique) | ✔ both are candidate keys |
| DOCTOR | Doctor_ID, Phone | ✔ |
| DEPARTMENT | Dept_ID, Dept_Name | ✔ |
| MEDICINE | Medicine_ID, Medicine_Name | ✔ |
| PRESCRIPTION_DETAIL | (Presc_ID, Medicine_ID) | ✔ |

So the whole schema is in **BCNF**.

## Properties of the decomposition

* **Lossless join**: each split shares an attribute that is a key of one side,
  e.g. DOCTOR ∩ DEPARTMENT = {Dept_ID}, which is the key of DEPARTMENT. Joining the
  pieces gives back exactly the original rows, with no spurious tuples.
* **Dependency preserving**: each of FD1–FD6 can be checked inside one relation.

## Anomalies — before vs after

| Anomaly | UNF/1NF | After 3NF |
|---|---|---|
| Change Amlodipine price | edit many rows | edit 1 row in MEDICINE |
| Add a new medicine with no prescription | impossible | insert into MEDICINE |
| Add a new doctor | needs a prescription | insert into DOCTOR |
| Delete prescription 709 | loses Metformin / Insulin data | only PRESCRIPTION/DETAIL rows removed |
