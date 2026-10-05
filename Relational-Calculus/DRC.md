# 6. Relational Calculus — Domain Relational Calculus (DRC)

In DRC, variables range over **values of attributes (domains)**, not whole
tuples. A relation is written as a predicate with one variable per attribute, in
schema order.

General form:

```text
{ < x1, x2, …, xn > | P(x1, x2, …, xn) }
```

Attribute order used:

```text
PATIENT     (pid, name, dob, gen, ph, city, bg)
DOCTOR      (did, dname, spec, dph, sal, dept)
DEPARTMENT  (dept, dptname, loc)
APPOINTMENT (aid, pid, did, adate, atime, st)
MEDICINE    (mid, mname, mfr, price, stock)
PRESCRIPTION(rid, pid, did, rdate)
PRESCRIPTION_DETAIL (rid, mid, dose, days)
BILL        (bid, pid, bdate, amt, st)
```

`_` can be read as "any value" (an existentially quantified variable we don't care about).

---

**Q1. All female patients**

```text
{ <pid, name, dob, gen, ph, city, bg> | PATIENT(pid, name, dob, gen, ph, city, bg) ∧ gen = 'Female' }
```

**Q2. Names of O+ patients from Bhopal**

```text
{ <name> | ∃ pid, dob, gen, ph, city, bg
           ( PATIENT(pid, name, dob, gen, ph, city, bg) ∧ bg = 'O+' ∧ city = 'Bhopal' ) }
```

**Q3. Names of doctors in Cardiology**

```text
{ <dname> | ∃ did, spec, dph, sal, dept, loc
            ( DOCTOR(did, dname, spec, dph, sal, dept)
              ∧ DEPARTMENT(dept, 'Cardiology', loc) ) }
```
The shared variable `dept` performs the join; the constant `'Cardiology'` performs the selection.

**Q4. Names of patients who saw Dr. Anil Mehta**

```text
{ <name> | ∃ pid, dob, gen, ph, city, bg, aid, did, adate, atime, st, spec, dph, sal, dept
           ( PATIENT(pid, name, dob, gen, ph, city, bg)
             ∧ APPOINTMENT(aid, pid, did, adate, atime, st)
             ∧ DOCTOR(did, 'Dr. Anil Mehta', spec, dph, sal, dept) ) }
```

**Q5. Patients who never had an appointment**

```text
{ <pid, name> | ∃ dob, gen, ph, city, bg ( PATIENT(pid, name, dob, gen, ph, city, bg) )
                ∧ ¬∃ aid, did, adate, atime, st ( APPOINTMENT(aid, pid, did, adate, atime, st) ) }
```

**Q6. Bills above 10,000 that are not fully paid**

```text
{ <bid, amt> | ∃ pid, bdate, st ( BILL(bid, pid, bdate, amt, st) ∧ amt > 10000 ∧ st ≠ 'Paid' ) }
```

**Q7. Doctors who prescribed ALL Sun Pharma medicines** (division)

```text
{ <did> | ∃ dname, spec, dph, sal, dept ( DOCTOR(did, dname, spec, dph, sal, dept) )
          ∧ ∀ mid ( ∃ mname, price, stock ( MEDICINE(mid, mname, 'Sun Pharma', price, stock) )
                    ⇒ ∃ rid, pid, rdate, dose, days
                        ( PRESCRIPTION(rid, pid, did, rdate)
                          ∧ PRESCRIPTION_DETAIL(rid, mid, dose, days) ) ) }
```
Result: 201

## TRC vs DRC

| | TRC | DRC |
|---|---|---|
| Variables range over | tuples | attribute values (domains) |
| Example variable | `p ∈ PATIENT`, then `p.Name` | `PATIENT(pid, name, …)` |
| Join is written as | equality between attributes `a.Patient_ID = p.Patient_ID` | the **same variable** in both predicates |
| Based on | — | the basis of QBE (Query-By-Example) |
| Power | same as relational algebra (safe expressions) | same |
