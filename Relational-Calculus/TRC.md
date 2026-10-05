# 6. Relational Calculus — Tuple Relational Calculus (TRC)

Relational calculus is **non-procedural (declarative)**: it states *what* the
result must satisfy, not how to compute it. In TRC, variables range over
**tuples**.

General form:

```text
{ t | P(t) }        "the set of all tuples t such that predicate P(t) is true"
```

| Symbol | Meaning |
|---|---|
| `PATIENT(t)` or `t ∈ PATIENT` | t is a tuple of relation PATIENT |
| `t.Name` | value of attribute Name in tuple t |
| ∧ ∨ ¬ | and, or, not |
| ∃ t (…) | there exists a tuple t such that … |
| ∀ t (…) | for all tuples t … |
| ⇒ | implies |

A variable bound by ∃ or ∀ is a **bound variable**; otherwise it is **free**. The
variable to the left of `|` must be the only free variable.

---

**Q1. All female patients**

```text
{ t | t ∈ PATIENT ∧ t.Gender = 'Female' }
```

**Q2. Names of patients with blood group O+ from Bhopal** (projection)

```text
{ t.Name | t ∈ PATIENT ∧ t.Blood_Group = 'O+' ∧ t.City = 'Bhopal' }
```

**Q3. Names of doctors in the Cardiology department** (join with ∃)

```text
{ d.Name | d ∈ DOCTOR ∧ ∃ p ( p ∈ DEPARTMENT ∧ p.Department_ID = d.Department_ID
                                            ∧ p.Department_Name = 'Cardiology' ) }
```

**Q4. Names of patients who have had an appointment with Dr. Anil Mehta**

```text
{ p.Name | p ∈ PATIENT ∧ ∃ a ∃ d ( a ∈ APPOINTMENT ∧ d ∈ DOCTOR
                                 ∧ a.Patient_ID = p.Patient_ID
                                 ∧ a.Doctor_ID  = d.Doctor_ID
                                 ∧ d.Name = 'Dr. Anil Mehta' ) }
```

**Q5. Patients who have NEVER had an appointment** (difference with ¬∃)

```text
{ p | p ∈ PATIENT ∧ ¬∃ a ( a ∈ APPOINTMENT ∧ a.Patient_ID = p.Patient_ID ) }
```
Result: Meera Pillai (112)

**Q6. Bills above 10,000 that are not fully paid**

```text
{ b | b ∈ BILL ∧ b.Total_Amount > 10000 ∧ b.Status ≠ 'Paid' }
```

**Q7. Doctors who prescribed ALL Sun Pharma medicines** (division with ∀)

```text
{ d | d ∈ DOCTOR ∧
      ∀ m ( ( m ∈ MEDICINE ∧ m.Manufacturer = 'Sun Pharma' ) ⇒
            ∃ r ∃ x ( r ∈ PRESCRIPTION ∧ x ∈ PRESCRIPTION_DETAIL
                      ∧ r.Doctor_ID = d.Doctor_ID
                      ∧ x.Prescription_ID = r.Prescription_ID
                      ∧ x.Medicine_ID = m.Medicine_ID ) ) }
```
Result: Dr. Anil Mehta (201)

**Q8. Patients who had an appointment OR a lab test** (union with ∨)

```text
{ t | ∃ a ( a ∈ APPOINTMENT ∧ t.Patient_ID = a.Patient_ID )
    ∨ ∃ l ( l ∈ LAB_TEST    ∧ t.Patient_ID = l.Patient_ID ) }
```

## Safety

`{ t | ¬ (t ∈ PATIENT) }` is **unsafe**: it describes infinitely many tuples
that are *not* patients. A safe expression only returns values that appear in
the database (its *domain*). All queries above are safe because every free
variable is first restricted to a relation (`t ∈ PATIENT`).

## Equivalence

Relational algebra, safe TRC and safe DRC have the **same expressive power**
(Codd's theorem). See [DRC.md](DRC.md) and
[relational-algebra.md](../Relational-Algebra/relational-algebra.md) for the same
queries in the other two languages.
