# Smart Clinic Database System

## IT244 - Database Design and Implementation Project

The **Smart Clinic Database System** is a relational database project developed for a private clinic. It replaces fragmented manual records with a structured MySQL database for patients, doctors, appointments, treatments, medicines, and payments.


## Team Task Distribution

| Student | ID | Contribution |
|---|---:|---|
| Dana Mohammed Alajmi | 240040990 | Group Leader and Repository Manager |
| AMANI BARJAS | 240047827 | Task 1: Database Design |
| Dareen Alanazi | 240022387 | Task 2: Database Implementation |
| Manar Mutaib Al-Harbi | 240061219 | Task 3: SQL Operations (next stage) |


## Task 1 - Database Design

The EER model contains eight relational tables:

| Entity | Purpose |
|---|---|
| `PERSON` | Supertype holding shared personal and contact data |
| `PATIENT` | Subtype holding patient-specific clinical and registration data |
| `DOCTOR` | Subtype holding professional and clinic employment data |
| `APPOINTMENT` | Links one patient with one doctor at a scheduled time |
| `TREATMENT` | Records the diagnosis, notes, date, and cost for an appointment |
| `MEDICINE` | Stores the clinic medicine catalog and stock information |
| `TREATMENT_MEDICINE` | Resolves the many-to-many relationship between treatments and medicines |
| `PAYMENT` | Stores one or more financial transactions for an appointment |

### EER Specialization

`PERSON` is the supertype, while `PATIENT` and `DOCTOR` are subtypes. The model treats the specialization as **total and disjoint**: every person stored by this clinic model must be either a patient or a doctor, and the same person is not assigned to both roles. The subtype primary keys are also foreign keys referencing `PERSON`.

### Main Relationships and Cardinalities

- One patient can have zero or many appointments; each appointment belongs to one patient.
- One doctor can have zero or many appointments; each appointment belongs to one doctor.
- One appointment can produce zero or one treatment; each treatment belongs to one appointment.
- One treatment can use zero or many medicines, and one medicine can appear in zero or many treatments. `TREATMENT_MEDICINE` resolves this many-to-many relationship.
- One appointment can have zero or many payments; each payment belongs to one appointment.

### Design Assumptions

1. All monetary values are recorded in Saudi riyals (SAR).
2. The data are fictional and created only for academic use.
3. A doctor and a patient cannot be booked into two appointments at the same date and time.
4. An appointment can have no more than one treatment record.
5. An appointment may have multiple payment records to support installments or mixed settlement processes.
6. The sum of payments is not automatically forced to equal treatment and consultation charges because insurance adjustments may apply.
7. The total/disjoint specialization rule is documented as a business rule; application validation will ensure a person is assigned to exactly one subtype.
8. Transactional records use restrictive deletion rules to protect history, while treatment-medicine details are removed if their parent treatment is removed.

## Task 2 - Database Implementation

The MySQL script currently contains:

- database creation using UTF-8 (`utf8mb4`);
- eight tables using the InnoDB engine;
- primary keys, foreign keys, unique constraints, required fields, and checks;
- five patient records and five doctor records supported by ten person records;
- at least five records in every other main table;
- logically consistent Saudi-context fictional data;
- simple table-display statements for capturing Task 2 population evidence.

The final version of the same SQL file will later be extended with the assessed Task 3 queries, one VIEW, and one TRIGGER.

## Running the Stage 1 Script

1. Open MySQL Workbench and connect to a MySQL 8.0 or newer server.
2. Open `database/smart_clinic_database.sql`.
3. Run the complete script using **Execute All**.
4. Confirm that `smart_clinic_db` and all eight tables were created.
5. Run or highlight the verification statements at the end of the file.
6. Capture clear screenshots showing the SQL code and the corresponding table results.

## Required Stage 1 Evidence

Store actual MySQL screenshots in `evidence/screenshots/`. The recommended evidence set is:

1. successful database and table creation;
2. `PERSON` table with ten rows;
3. `PATIENT` and `DOCTOR` tables with five rows each;
4. `APPOINTMENT` and `TREATMENT` tables with five rows each;
5. `MEDICINE` and `TREATMENT_MEDICINE` tables;
6. `PAYMENT` table with five rows;
7. successful script execution with no errors.


## Repository Structure

```text
Smart-Clinic-Database-System/
├── README.md
├── database/
│   └── smart_clinic_database.sql
├── Report_docs/
│   ├── Smart_Clinic_Final_Report.docx
│   ├── Smart_Clinic_Mid_Project_Progress_Report.docx
│   └── Smart_Clinic_Team_Contribution_Record.docx
├── diagrams/
│   └── er_diagram.png
└── evidence/
    └── screenshots/
```

## Next Approved Stage

After the team reviews Tasks 1 and 2 and confirms the MySQL screenshots, the next stage will add the required SELECT, JOIN, nested, aggregate, UPDATE, DELETE, VIEW, and TRIGGER operations. The Project Reflection will remain unwritten until all technical work and evidence are complete.

