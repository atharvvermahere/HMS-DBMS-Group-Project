# Git workflow for the team

Goal: one shared repository, where **every member's work appears as their own
commits**. So don't upload everything from one account. Each member pushes
their own folder.

## Who commits what

| Member | Branch | Files to commit |
|---|---|---|
| Member 1 (repo owner) | `main`, then `member-1-design` | `README.md`, `docs/`, `.gitkeep` folders, then `ER-Diagram/`, `Database-Schema/` |
| Member 2 | `member-2-sql` | `SQL/`, `Screenshots/SQL/` |
| Member 3 | `member-3-relational` | `Relational-Algebra/`, `Relational-Calculus/`, `Relational-Model/` |
| Member 4 | `member-4-plsql` | `Normalization/`, `PL-SQL/`, `Screenshots/PL-SQL/` |
| Anyone (at the end) | `final-docs` | `Documentation/` (report), `Presentation/` (PPT) |

## Step 1 — Member 1 creates the repository

1. GitHub → **+ → New repository** → name `HMS-DBMS-Group-Project`.
   Keep it **Private** unless your faculty wants it public, and **do not** tick "Add a README" (we already have one).
2. **Settings → Collaborators → Add people** → invite the other three members.
3. On your laptop, inside the project folder:

```bash
git init -b main
git add README.md docs/ Screenshots/ Documentation/ Presentation/
git commit -m "Initial project structure and README"
git remote add origin https://github.com/<owner>/HMS-DBMS-Group-Project.git
git push -u origin main
```

## Step 2 — every member (including Member 1)

```bash
git clone https://github.com/<owner>/HMS-DBMS-Group-Project.git
cd HMS-DBMS-Group-Project
git checkout -b member-2-sql            # use YOUR branch name
```

Copy **only your folder** into the clone, then commit in small, meaningful steps:

```bash
git add SQL/01_create_tables.sql
git commit -m "Create hospital tables with keys and constraints"

git add SQL/02_insert_data.sql
git commit -m "Add sample data for all 12 tables"

git add SQL/
git commit -m "Add joins, set operations, division and grouping queries"

git push -u origin member-2-sql
```

Good commit messages by member:

| Member 1 | Member 2 | Member 3 | Member 4 |
|---|---|---|---|
| Add ER diagram | Create hospital tables | Add relational algebra queries | Add UNF to 3NF normalization |
| Add relational schema and keys | Add sample data | Add division and grouping in RA | Add PL/SQL functions |
| Add data dictionary | Add join and set-operation queries | Add TRC queries | Add procedures and cursors |
| | Add nested queries and views | Add DRC queries | Add triggers with test cases |

## Step 3 — pull request and review

1. On GitHub click **Compare & pull request** (base `main` ← your branch).
2. Write what you added, and ask one teammate to review.
3. The reviewer checks: names match the schema, SQL runs in Live SQL, no typos.
4. **Merge pull request**.

Suggested merge order (because later parts depend on earlier ones):
`member-1-design` → `member-2-sql` → `member-3-relational` → `member-4-plsql`.

## Step 4 — keep your branch up to date

```bash
git checkout main
git pull
git checkout member-4-plsql
git merge main
```

## Screenshots

Run each file in Oracle Live SQL, screenshot the output, and save it as e.g.
`Screenshots/SQL/05_joins_J9_left_join.png`. Screenshots are the proof that the
code actually runs.

## Never commit

Passwords, `.env` files, personal phone numbers or Aadhaar numbers. Our sample
data is fictional.

## No command line? Use GitHub Desktop

File → Clone repository → Current branch → New branch → copy your files →
write the commit message → **Commit** → **Publish branch** → **Create Pull Request**.
