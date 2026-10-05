# 9. Relational Database Model

The relational model (E. F. Codd, 1970) stores all data as **relations**
(tables). Each relation has a **heading** (schema) and a **body** (set of tuples).

## Terminology with an HMS example

| Formal term | Informal term | HMS example |
|---|---|---|
| Relation | Table | PATIENT |
| Tuple | Row / record | (101, Rahul Sharma, 12-May-2002, Male, 9876500101, Bhopal, O+) |
| Attribute | Column / field | Blood_Group |
| Domain | Set of allowed values | Blood_Group ∈ {A+, A−, B+, B−, AB+, AB−, O+, O−} |
| Degree (arity) | Number of columns | PATIENT has degree 7 |
| Cardinality | Number of rows | PATIENT has cardinality 15 |
| Relation schema | Table definition | PATIENT(Patient_ID, Name, DOB, Gender, Phone, City, Blood_Group) |
| Relation instance | Data at one moment | the 15 rows currently stored |
| Database schema | All relation schemas | the 12 relations of the HMS |

## Sample relation — PATIENT (first 5 tuples)

| Patient_ID | Name | DOB | Gender | Phone | City | Blood_Group |
|---|---|---|---|---|---|---|
| 101 | Rahul Sharma | 2002-05-12 | Male | 9876500101 | Bhopal | O+ |
| 102 | Priya Verma | 1995-08-23 | Female | 9876500102 | Indore | A+ |
| 103 | Aman Gupta | 1988-01-15 | Male | 9876500103 | Bhopal | B+ |
| 104 | Sneha Iyer | 2010-11-02 | Female | 9876500104 | Sehore | O+ |
| 105 | Mohammed Arif | 1975-03-30 | Male | 9876500105 | Bhopal | AB+ |

## Properties of a relation

1. No two tuples are identical (it is a **set**).
2. Order of tuples does not matter.
3. Order of attributes does not matter (they are referred to by name).
4. Every value is **atomic** (single-valued), which is first normal form.
5. Each attribute has a distinct name within the relation.

## Integrity constraints

| Constraint | Rule | HMS example |
|---|---|---|
| Domain constraint | A value must belong to the attribute's domain | `CHECK (Gender IN ('Male','Female','Other'))` |
| Key constraint | Key values are unique | No two patients share a Patient_ID or a Phone |
| Entity integrity | A primary key can never be NULL | Patient_ID is NOT NULL |
| Referential integrity | A foreign key must match an existing primary key, or be NULL | Doctor.Department_ID must exist in DEPARTMENT; inserting Department_ID = 99 is rejected |

## Codd's 12 rules (summary)

0. Foundation: managed entirely through relational capabilities
1. Information: all data in tables
2. Guaranteed access: table + primary key + column
3. Systematic treatment of NULL
4. Active online catalog (`user_tables`, `user_constraints`)
5. Comprehensive data sub-language (SQL)
6. View updating
7. High-level insert, update, delete
8. Physical data independence
9. Logical data independence
10. Integrity independence
11. Distribution independence
12. Non-subversion
