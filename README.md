# Smart Clinic Database System

## IT244 – Database Design and Implementation Project

## Project Overview

The **Smart Clinic Database System** is a relational database developed to support the main operational and clinical activities of a private clinic. The system organizes patient and doctor information, appointments, treatments, prescribed medicines, medicine inventory, and payment transactions within a structured MySQL database.

The project applies database design principles through an ER/EER model, a relational schema, integrity constraints, sample data, SQL operations, a database view, and a trigger. The accompanying reports and MySQL Workbench screenshots document the design, implementation, testing, and results.

## Project Objectives

- Design a clear ER/EER model for the clinic's main entities and relationships.
- Transform the conceptual model into a normalized relational schema.
- Implement the database in MySQL using appropriate keys and integrity constraints.
- Populate the tables with coherent fictional data suitable for academic testing.
- Demonstrate data retrieval, joins, nested queries, aggregation, updates, deletions, views, triggers, and transaction control.
- Document the implementation and provide verifiable execution evidence.

## Task Distribution Among Team Members

| Student | ID | Contribution |
|---|---:|---|
| Dana Mohammed Alajmi | 240040990 | Group Leader and Repository Manager |
| Amani Barjas | 240047827 | Task 1: Database Design |
| Dareen Alanazi | 240022387 | Task 2: Database Implementation |
| Manar Mutaib Al-Harbi | 240061219 | Task 3: SQL Operations |

The Project Reflection, technical review, evidence verification, and report preparation were completed collaboratively by all team members.

## Database Design

The database contains eight related tables:

| Table | Purpose |
|---|---|
| `PERSON` | Stores shared identification and contact details. |
| `PATIENT` | Stores patient-specific registration, insurance, blood type, and emergency contact data. |
| `DOCTOR` | Stores doctor credentials, specialty, room, fee, and employment data. |
| `APPOINTMENT` | Connects each patient with a doctor at a specified date and time. |
| `TREATMENT` | Records the diagnosis, notes, date, and cost associated with an appointment. |
| `MEDICINE` | Stores medicine details, price, stock quantity, and prescription requirements. |
| `TREATMENT_MEDICINE` | Resolves the many-to-many relationship between treatments and medicines. |
| `PAYMENT` | Records payment amounts, dates, methods, status, and reference numbers. |

`PERSON` is modeled as a supertype, while `PATIENT` and `DOCTOR` are disjoint subtypes. The schema also represents one-to-many relationships between patients and appointments, doctors and appointments, and appointments and payments. Each appointment can have no more than one treatment, while treatments and medicines are connected through the associative table `TREATMENT_MEDICINE`.

## Database Implementation

The database is implemented for **MySQL 8.0 or newer** using the InnoDB storage engine and `utf8mb4` character encoding. The implementation includes:

- primary and foreign keys;
- `NOT NULL`, `UNIQUE`, `CHECK`, and `ENUM` constraints;
- referential actions using `CASCADE` and `RESTRICT` where appropriate;
- ten person records representing five patients and five doctors;
- at least five coherent records in each assessed operational table;
- fictional Saudi-context names, contact details, diagnoses, medicines, and financial data.

## SQL Operations

The SQL script demonstrates the required database operations:

- filtered and ordered `SELECT` statements;
- multi-table `JOIN` queries for appointment, treatment, and medicine information;
- a nested query for identifying patients whose total paid amount exceeds the average paid transaction amount;
- aggregate functions with `GROUP BY` for doctor workload and financial summaries;
- `UPDATE` and `DELETE` operations with transaction rollback verification;
- the reusable view `vw_appointment_summary`;
- the inventory-control trigger `trg_treatment_medicine_stock`;
- transaction control using `START TRANSACTION` and `ROLLBACK`.

## Running the Database

1. Open MySQL Workbench and connect to a MySQL 8.0 or newer server.
2. Open `database/smart_clinic_database.sql`.
3. Run the complete script using **Execute All**.
4. Refresh the Schemas panel and open `smart_clinic_db`.
5. Review the table population queries and the Task 3 result sets included in the script.

The script recreates `smart_clinic_db`, which allows it to be executed repeatedly during testing while producing a consistent database state.

## Documentation and Evidence

The `Report_docs/` directory contains the team contribution record, mid-project progress report, and complete project report in the supplied document formats. The `diagrams/` directory contains the ER/EER diagram used to represent the database design.

The `evidence/screenshots/` directory contains **20 MySQL Workbench screenshots**:

- 8 screenshots documenting the populated tables for Task 2;
- 12 screenshots documenting the required SQL results for Task 3.

`evidence/Screenshot_Evidence_Index.md` provides the filename, task number, and purpose of every screenshot.

## Project Structure

```text
Smart-Clinic-Database-System/
├── README.md
├── database/
│   └── smart_clinic_database.sql
├── Report_docs/
│   ├── Smart_Clinic_Team_Contribution_Record.docx
│   ├── Smart_Clinic_Mid_Project_Progress_Report.docx
│   ├── Smart_Clinic_Mid_Project_Progress_Report.pdf
│   ├── Smart_Clinic_Final_Report.docx
│   └── Smart_Clinic_Final_Report.pdf
├── diagrams/
│   └── er_diagram.png
└── evidence/
    ├── screenshots/
    │   └── 20 JPG evidence files
    └── Screenshot_Evidence_Index.md
```

## Academic Data Notice

All personal, medical, appointment, and financial records contained in the sample database are fictional and were created exclusively for academic use.
