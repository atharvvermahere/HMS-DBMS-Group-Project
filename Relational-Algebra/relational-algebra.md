# 5. Relational Algebra  ·  7. Set operations, Renaming, Join, Division, Syntax  ·  8. Operators, Grouping/Ungrouping, Relational comparison

Relational algebra is a **procedural** query language: an expression says *how* to
build the answer, step by step, from operators that take relations as input and
return a relation as output (closure property).

Relations used (see [schema](../Database-Schema/schema.md)):

```text
PATIENT(Patient_ID, Name, DOB, Gender, Phone, City, Blood_Group)
DOCTOR(Doctor_ID, Name, Specialization, Phone, Salary, Department_ID)
DEPARTMENT(Department_ID, Department_Name, Location)
APPOINTMENT(Appointment_ID, Patient_ID, Doctor_ID, Appointment_Date, Appointment_Time, Status)
PRESCRIPTION(Prescription_ID, Patient_ID, Doctor_ID, Prescription_Date)
PRESCRIPTION_DETAIL(Prescription_ID, Medicine_ID, Dosage, Duration_Days)
MEDICINE(Medicine_ID, Medicine_Name, Manufacturer, Price, Stock)
LAB_TEST(Test_ID, Patient_ID, Doctor_ID, Test_Name, Test_Date, Result, Cost)
```

## Syntax summary

| Operator | Symbol | Syntax | Type |
|---|---|---|---|
| Selection | σ | σ<sub>condition</sub>(R) | Unary, basic |
| Projection | π | π<sub>A1, A2…</sub>(R) | Unary, basic |
| Rename | ρ | ρ<sub>S(B1, B2…)</sub>(R) | Unary, basic |
| Union | ∪ | R ∪ S | Binary, basic (union-compatible) |
| Set difference | − | R − S | Binary, basic (union-compatible) |
| Cartesian product | × | R × S | Binary, basic |
| Intersection | ∩ | R ∩ S = R − (R − S) | Derived |
| Theta join | ⋈<sub>θ</sub> | R ⋈<sub>θ</sub> S = σ<sub>θ</sub>(R × S) | Derived |
| Natural join | ⋈ | R ⋈ S | Derived |
| Division | ÷ | R ÷ S | Derived |
| Left / right / full outer join | ⟕ ⟖ ⟗ | R ⟕ S | Extended |
| Aggregation / grouping | γ (𝒢) | <sub>grouping attrs</sub>γ<sub>F(A)</sub>(R) | Extended |
| Semijoin / semiminus | ⋉ / ▷ | R ⋉ S, R ▷ S | Additional |
| Extend | EXTEND | EXTEND R ADD (expr) AS A | Additional |

*Union-compatible* = both relations have the same number of attributes and
corresponding attributes have the same domain.

---

## Basic operations

**Q1. Selection — female patients**

```text
σ Gender = 'Female' (PATIENT)
```
SQL: `SELECT * FROM Patient WHERE Gender = 'Female';`

**Q2. Projection — name and phone of every doctor**

```text
π Name, Phone (DOCTOR)
```

**Q3. Selection + projection — names of O+ patients from Bhopal**

```text
π Name ( σ Blood_Group = 'O+' ∧ City = 'Bhopal' (PATIENT) )
```
Result: Rahul Sharma, Vivek Tiwari

**Q4. Composite condition — doctors earning more than 1.5 lakh in department 1 or 2**

```text
π Name, Salary ( σ Salary > 150000 ∧ (Department_ID = 1 ∨ Department_ID = 2) (DOCTOR) )
```

## Set operations

Let

```text
A_P ← π Patient_ID (APPOINTMENT)      -- patients with an appointment
L_P ← π Patient_ID (LAB_TEST)         -- patients with a lab test
```

**Q5. Union — patients with an appointment OR a lab test** `A_P ∪ L_P` → 15 patients

**Q6. Intersection — patients with BOTH** `A_P ∩ L_P`

**Q7. Difference — patients with a lab test but NO appointment** `L_P − A_P` → {112}

**Q8. Difference — doctors who never wrote a prescription**

```text
π Doctor_ID (DOCTOR) − π Doctor_ID (PRESCRIPTION)        → {209}
```

## Cartesian product and joins

**Q9. Cartesian product**

```text
PATIENT × DOCTOR          -- 15 × 10 = 150 tuples, every patient paired with every doctor
```
On its own this is rarely useful; a selection on top turns it into a join.

**Q10. Theta / equi join = σ on a product — each doctor with their department name**

```text
π Name, Department_Name ( σ DOCTOR.Department_ID = DEPARTMENT.Department_ID (DOCTOR × DEPARTMENT) )
   ≡  π Name, Department_Name ( DOCTOR ⋈ DOCTOR.Department_ID = DEPARTMENT.Department_ID DEPARTMENT )
   ≡  π Name, Department_Name ( DOCTOR ⋈ DEPARTMENT )            -- natural join on Department_ID
```

**Q11. Names of doctors in Cardiology**

```text
π Name ( σ Department_Name = 'Cardiology' (DOCTOR ⋈ DEPARTMENT) )
```

**Q12. Outer join — every patient, with appointment details where they exist**

```text
PATIENT ⟕ APPOINTMENT          -- patient 112 appears with NULLs
```

## Renaming

**Q13. Rename a relation and its attributes**

```text
ρ P(PID, PName, PDOB, PGender, PPhone, PCity, PBG) (PATIENT)
```

**Q14. Rename to avoid a name clash — which patient saw which doctor?**
PATIENT and DOCTOR both have `Name` and `Phone`, so a natural join would wrongly
match on them. Rename first:

```text
PT ← ρ PT(Patient_ID, Patient_Name) ( π Patient_ID, Name (PATIENT) )
DR ← ρ DR(Doctor_ID, Doctor_Name)   ( π Doctor_ID,  Name (DOCTOR)  )

Result ← π Patient_Name, Doctor_Name ( PT ⋈ APPOINTMENT ⋈ DR )
```

**Q15. Self-join needs rename — doctors earning more than a colleague in the same department**

```text
D1 ← ρ D1 (DOCTOR)
D2 ← ρ D2 (DOCTOR)
π D1.Name, D2.Name ( D1 ⋈ D1.Department_ID = D2.Department_ID ∧ D1.Salary > D2.Salary D2 )
```

## Division

Use division for queries containing **"for all" / "every"**.

**Q16. Doctors who prescribed ALL medicines made by Sun Pharma**

```text
R1 ← π Doctor_ID, Medicine_ID ( PRESCRIPTION ⋈ PRESCRIPTION_DETAIL )
R2 ← π Medicine_ID ( σ Manufacturer = 'Sun Pharma' (MEDICINE) )         -- {602, 603, 605}

Result ← R1 ÷ R2                                                         -- {201}
```

Division written with basic operators:

```text
R1 ÷ R2 = π Doctor_ID (R1) − π Doctor_ID ( ( π Doctor_ID (R1) × R2 ) − R1 )
```
Step by step: (π Doctor_ID(R1) × R2) = every doctor paired with every Sun Pharma
medicine. Subtracting R1 leaves the pairs that did **not** happen. Their doctors
are the ones who missed at least one medicine; removing them leaves 201.

Worked example:

| R1: Doctor_ID | Medicine_ID |
|---|---|
| 201 | 602 |
| 201 | 603 |
| 201 | 605 |
| 202 | 603 |
| 202 | 605 |
| 207 | 602 |

R2 = {602, 603, 605} → R1 ÷ R2 = **{201}** (202 lacks 602, 207 lacks 603 and 605).

---

## 8. Additional operators

**EXTEND — add a computed attribute**

```text
EXTEND DOCTOR ADD (Salary × 12) AS Annual_Salary
-- extended RA notation:  π Doctor_ID, Name, Salary, Salary*12 → Annual_Salary (DOCTOR)
```

**SUMMARIZE / aggregation — doctors per department**

```text
Department_ID γ COUNT(Doctor_ID) → Total_Doctors (DOCTOR)
-- Date's notation:  SUMMARIZE DOCTOR PER (DEPARTMENT {Department_ID}) ADD (COUNT() AS Total_Doctors)
```

**Average bill per status**: `Status γ AVG(Total_Amount) (BILL)`

**SEMIJOIN ⋉ — patients that have at least one appointment** (only PATIENT's attributes are kept)

```text
PATIENT ⋉ APPOINTMENT   ≡   π PATIENT-attributes ( PATIENT ⋈ APPOINTMENT )
```

**SEMIMINUS ▷ (anti-join) — patients with no appointment**

```text
PATIENT ▷ APPOINTMENT   ≡   PATIENT − (PATIENT ⋉ APPOINTMENT)          → Meera Pillai (112)
```

## 8. Grouping and ungrouping

`GROUP` turns several tuples into one tuple whose attribute holds a **relation**
(a relation-valued attribute). `UNGROUP` does the reverse.

```text
PD ← π Prescription_ID, Medicine_Name ( PRESCRIPTION_DETAIL ⋈ MEDICINE )

G  ← PD GROUP { Medicine_Name } AS Medicines
U  ← G  UNGROUP Medicines                  -- U = PD again
```

| PD: Prescription_ID | Medicine_Name |
|---|---|
| 705 | Atorvastatin 10mg |
| 705 | Amlodipine 5mg |
| 705 | Aspirin 75mg |
| 713 | Amoxicillin 250mg |
| 713 | Amlodipine 5mg |

⇩ GROUP { Medicine_Name } AS Medicines

| G: Prescription_ID | Medicines |
|---|---|
| 705 | { Atorvastatin 10mg, Amlodipine 5mg, Aspirin 75mg } |
| 713 | { Amoxicillin 250mg, Amlodipine 5mg } |

⇩ UNGROUP Medicines → back to the 5 flat tuples of PD.

SQL: [`SQL/07_aggregate_and_grouping.sql`](../SQL/07_aggregate_and_grouping.sql) (Oracle `COLLECT` / `TABLE()`).

## 8. Relational comparison

Two relations with the **same heading** can be compared as whole sets:

| Comparison | Meaning | Test with algebra |
|---|---|---|
| R = S | equal | (R − S) = ∅ and (S − R) = ∅ |
| R ≠ S | not equal | not (R = S) |
| R ⊆ S | subset | (R − S) = ∅ |
| R ⊂ S | proper subset | R ⊆ S and R ≠ S |
| R ⊇ S, R ⊃ S | superset | S ⊆ R … |

Examples on our data:

```text
π Patient_ID (LAB_TEST) ⊆ π Patient_ID (APPOINTMENT)                         → FALSE (112)
π Patient_ID (PRESCRIPTION) = π Patient_ID (σ Status='Completed' (APPOINTMENT)) → TRUE
π Patient_ID (APPOINTMENT) ⊂ π Patient_ID (PATIENT)                          → TRUE
```

A relational comparison can also be the *condition* of a selection:

```text
Doctors who have treated both patient 105 and 115:
σ ( {105, 115} ⊆ π Patient_ID (σ Doctor_ID = d (APPOINTMENT)) ) (DOCTOR)      → Dr. Anil Mehta
```

SQL for all of these: [`SQL/04_operators_and_comparison.sql`](../SQL/04_operators_and_comparison.sql)
