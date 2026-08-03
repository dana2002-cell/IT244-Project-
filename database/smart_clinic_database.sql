/*
===============================================================================
Smart Clinic Database System
IT244 - Database Design and Implementation Project

Stage 2 Scope: Task 1 (Design), Task 2 (Implementation), and Task 3 (SQL Operations)
Task 4 Project Reflection remains intentionally excluded until final review.

Team Members
1. Dana Mohammed Alajmi   - 240040990 - Group Leader and Repository Manager
2. AMANI BARJAS           - 240047827 - Task 1: Database Design
3. Dareen Alanazi         - 240022387 - Task 2: Database Implementation
4. Manar Mutaib Al-Harbi  - 240061219 - Task 3: SQL Operations

Target DBMS: MySQL 8.0+
All personal and clinical data below are fictional and created for academic use.
===============================================================================
*/

-- Recreate the database so the script can be executed repeatedly during testing.
DROP DATABASE IF EXISTS smart_clinic_db;
CREATE DATABASE smart_clinic_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE smart_clinic_db;
SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- TASK 1 RELATIONAL MAPPING AND TASK 2 TABLE IMPLEMENTATION
-- EER feature: PERSON is a supertype specialized into PATIENT and DOCTOR.
-- The specialization is total and disjoint as an application-level rule.
-- -----------------------------------------------------------------------------

CREATE TABLE person (
    person_id       INT             NOT NULL,
    national_id     VARCHAR(10)     NOT NULL,
    full_name       VARCHAR(100)    NOT NULL,
    date_of_birth   DATE            NOT NULL,
    gender          ENUM('Female', 'Male') NOT NULL,
    phone           VARCHAR(13)     NOT NULL,
    email           VARCHAR(120)    NULL,
    address         VARCHAR(200)    NOT NULL,
    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT uq_person_national_id UNIQUE (national_id),
    CONSTRAINT uq_person_phone UNIQUE (phone),
    CONSTRAINT uq_person_email UNIQUE (email),
    CONSTRAINT chk_person_national_id CHECK (national_id REGEXP '^[12][0-9]{9}$'),
    CONSTRAINT chk_person_phone CHECK (phone REGEXP '^\\+9665[0-9]{8}$')
) ENGINE = InnoDB;

CREATE TABLE patient (
    patient_id              INT             NOT NULL,
    blood_type              ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-') NOT NULL,
    insurance_provider      VARCHAR(100)    NULL,
    emergency_contact_name  VARCHAR(100)    NOT NULL,
    emergency_contact_phone VARCHAR(13)     NOT NULL,
    registration_date       DATE            NOT NULL,
    CONSTRAINT pk_patient PRIMARY KEY (patient_id),
    CONSTRAINT fk_patient_person
        FOREIGN KEY (patient_id) REFERENCES person (person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_patient_emergency_phone
        CHECK (emergency_contact_phone REGEXP '^\\+9665[0-9]{8}$')
) ENGINE = InnoDB;

CREATE TABLE doctor (
    doctor_id        INT             NOT NULL,
    license_number   VARCHAR(25)     NOT NULL,
    specialty        VARCHAR(80)     NOT NULL,
    room_number      VARCHAR(10)     NOT NULL,
    consultation_fee DECIMAL(10, 2)  NOT NULL,
    hire_date        DATE            NOT NULL,
    CONSTRAINT pk_doctor PRIMARY KEY (doctor_id),
    CONSTRAINT uq_doctor_license UNIQUE (license_number),
    CONSTRAINT uq_doctor_room UNIQUE (room_number),
    CONSTRAINT fk_doctor_person
        FOREIGN KEY (doctor_id) REFERENCES person (person_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_doctor_fee CHECK (consultation_fee >= 0)
) ENGINE = InnoDB;

CREATE TABLE appointment (
    appointment_id              INT             NOT NULL,
    patient_id                  INT             NOT NULL,
    doctor_id                   INT             NOT NULL,
    scheduled_at                DATETIME        NOT NULL,
    appointment_duration_minutes SMALLINT       NOT NULL DEFAULT 30,
    status                      ENUM('Scheduled', 'Completed', 'Cancelled', 'No Show') NOT NULL DEFAULT 'Scheduled',
    reason                      VARCHAR(250)    NOT NULL,
    created_at                  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_appointment PRIMARY KEY (appointment_id),
    CONSTRAINT uq_appointment_doctor_slot UNIQUE (doctor_id, scheduled_at),
    CONSTRAINT uq_appointment_patient_slot UNIQUE (patient_id, scheduled_at),
    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctor (doctor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_appointment_duration
        CHECK (appointment_duration_minutes BETWEEN 15 AND 180)
) ENGINE = InnoDB;

CREATE TABLE treatment (
    treatment_id     INT             NOT NULL,
    appointment_id  INT             NOT NULL,
    treatment_date  DATE            NOT NULL,
    diagnosis       VARCHAR(200)    NOT NULL,
    treatment_notes VARCHAR(500)    NOT NULL,
    treatment_cost  DECIMAL(10, 2)  NOT NULL DEFAULT 0.00,
    CONSTRAINT pk_treatment PRIMARY KEY (treatment_id),
    CONSTRAINT uq_treatment_appointment UNIQUE (appointment_id),
    CONSTRAINT fk_treatment_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_treatment_cost CHECK (treatment_cost >= 0)
) ENGINE = InnoDB;

CREATE TABLE medicine (
    medicine_id           INT             NOT NULL,
    medicine_name         VARCHAR(100)    NOT NULL,
    strength              VARCHAR(30)     NOT NULL,
    dosage_form           VARCHAR(40)     NOT NULL,
    unit_price            DECIMAL(10, 2)  NOT NULL,
    stock_quantity        INT             NOT NULL,
    prescription_required BOOLEAN         NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_medicine PRIMARY KEY (medicine_id),
    CONSTRAINT uq_medicine_name_strength UNIQUE (medicine_name, strength),
    CONSTRAINT chk_medicine_price CHECK (unit_price >= 0),
    CONSTRAINT chk_medicine_stock CHECK (stock_quantity >= 0)
) ENGINE = InnoDB;

CREATE TABLE treatment_medicine (
    treatment_id INT             NOT NULL,
    medicine_id  INT             NOT NULL,
    dosage       VARCHAR(80)     NOT NULL,
    frequency    VARCHAR(80)     NOT NULL,
    duration_days SMALLINT       NOT NULL,
    quantity     SMALLINT        NOT NULL,
    instructions VARCHAR(250)    NULL,
    CONSTRAINT pk_treatment_medicine PRIMARY KEY (treatment_id, medicine_id),
    CONSTRAINT fk_tm_treatment
        FOREIGN KEY (treatment_id) REFERENCES treatment (treatment_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_tm_medicine
        FOREIGN KEY (medicine_id) REFERENCES medicine (medicine_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_tm_duration CHECK (duration_days > 0),
    CONSTRAINT chk_tm_quantity CHECK (quantity > 0)
) ENGINE = InnoDB;

CREATE TABLE payment (
    payment_id     INT             NOT NULL,
    appointment_id INT             NOT NULL,
    amount         DECIMAL(10, 2)  NOT NULL,
    payment_date   DATETIME        NOT NULL,
    payment_method ENUM('Cash', 'Card', 'Bank Transfer', 'Insurance') NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Refunded', 'Failed') NOT NULL DEFAULT 'Pending',
    reference_no   VARCHAR(40)     NULL,
    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT uq_payment_reference UNIQUE (reference_no),
    CONSTRAINT fk_payment_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
) ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- TASK 2 SAMPLE DATA
-- Ten PERSON rows support five PATIENT subtypes and five DOCTOR subtypes.
-- -----------------------------------------------------------------------------

START TRANSACTION;

INSERT INTO person
    (person_id, national_id, full_name, date_of_birth, gender, phone, email, address)
VALUES
    (1,  '1098765432', 'Noura Fahad Alotaibi',      '1993-04-18', 'Female', '+966501234567', 'noura.alotaibi@example.sa',      'Al Malqa District, Riyadh'),
    (2,  '1087654321', 'Mohammed Saad Alharbi',     '1986-09-03', 'Male',   '+966502345678', 'mohammed.alharbi@example.sa',    'Al Yasmin District, Riyadh'),
    (3,  '1076543219', 'Reem Abdullah Alqahtani',   '1998-12-11', 'Female', '+966503456789', 'reem.alqahtani@example.sa',      'Al Narjis District, Riyadh'),
    (4,  '1065432198', 'Faisal Omar Alzahrani',     '1979-02-26', 'Male',   '+966504567890', 'faisal.alzahrani@example.sa',    'Al Rawdah District, Riyadh'),
    (5,  '1123456789', 'Layan Ahmed Alshammari',    '2014-06-07', 'Female', '+966505678901', 'layan.alshammari@example.sa',     'Al Qurtubah District, Riyadh'),
    (6,  '1054321987', 'Huda Saleh Almutairi',      '1982-01-14', 'Female', '+966506789012', 'huda.almutairi@smartclinic.sa',   'Al Wurud District, Riyadh'),
    (7,  '1043219876', 'Fahad Nasser Alghamdi',     '1978-08-22', 'Male',   '+966507890123', 'fahad.alghamdi@smartclinic.sa',   'Al Olaya District, Riyadh'),
    (8,  '1032198765', 'Maha Khalid Aldosari',      '1987-05-30', 'Female', '+966508901234', 'maha.aldosari@smartclinic.sa',    'Al Nakheel District, Riyadh'),
    (9,  '1021987654', 'Omar Ali Alqahtani',        '1984-10-09', 'Male',   '+966509012345', 'omar.alqahtani@smartclinic.sa',   'Al Sahafah District, Riyadh'),
    (10, '1019876543', 'Sara Ibrahim Alsubaie',     '1981-03-17', 'Female', '+966550123456', 'sara.alsubaie@smartclinic.sa',    'Al Rabwah District, Riyadh');

INSERT INTO patient
    (patient_id, blood_type, insurance_provider, emergency_contact_name,
     emergency_contact_phone, registration_date)
VALUES
    (1, 'O+',  'Bupa Arabia',              'Fahad Alotaibi',     '+966551111111', '2026-07-01'),
    (2, 'A+',  'Tawuniya',                 'Abeer Alharbi',      '+966552222222', '2026-07-02'),
    (3, 'B-',  'MedGulf',                  'Abdullah Alqahtani', '+966553333333', '2026-07-03'),
    (4, 'AB+', NULL,                       'Mona Alzahrani',     '+966554444444', '2026-07-04'),
    (5, 'O-',  'Al Rajhi Takaful',         'Ahmed Alshammari',   '+966555555555', '2026-07-05');

INSERT INTO doctor
    (doctor_id, license_number, specialty, room_number, consultation_fee, hire_date)
VALUES
    (6,  'SCFHS-10001', 'General Medicine', 'A101', 150.00, '2021-02-01'),
    (7,  'SCFHS-10002', 'Cardiology',       'A102', 300.00, '2020-09-15'),
    (8,  'SCFHS-10003', 'Dermatology',      'B201', 250.00, '2022-01-10'),
    (9,  'SCFHS-10004', 'Pediatrics',       'B202', 200.00, '2019-06-20'),
    (10, 'SCFHS-10005', 'Dentistry',        'C301', 220.00, '2023-03-05');

INSERT INTO appointment
    (appointment_id, patient_id, doctor_id, scheduled_at,
     appointment_duration_minutes, status, reason)
VALUES
    (1001, 1, 6,  '2026-07-15 09:00:00', 30, 'Completed', 'Facial pain and persistent nasal congestion'),
    (1002, 2, 7,  '2026-07-16 10:00:00', 45, 'Completed', 'Blood pressure follow-up and medication review'),
    (1003, 3, 8,  '2026-07-17 11:00:00', 30, 'Completed', 'Itchy skin rash on both hands'),
    (1004, 5, 9,  '2026-07-18 13:00:00', 30, 'Completed', 'Fever, cough, and fatigue'),
    (1005, 4, 10, '2026-07-19 15:00:00', 60, 'Completed', 'Tooth sensitivity and localized pain');

INSERT INTO treatment
    (treatment_id, appointment_id, treatment_date, diagnosis, treatment_notes, treatment_cost)
VALUES
    (2001, 1001, '2026-07-15', 'Acute bacterial sinusitis',
     'Oral antibiotic course, analgesic as needed, hydration, and follow-up if symptoms persist.', 120.00),
    (2002, 1002, '2026-07-16', 'Essential hypertension - controlled',
     'Continue antihypertensive therapy, reduce sodium intake, and record home blood pressure readings.', 150.00),
    (2003, 1003, '2026-07-17', 'Mild contact dermatitis',
     'Use topical corticosteroid for seven days and avoid the suspected irritant.', 100.00),
    (2004, 1004, '2026-07-18', 'Seasonal influenza',
     'Supportive care, adequate fluids, rest, temperature monitoring, and return if breathing worsens.', 90.00),
    (2005, 1005, '2026-07-19', 'Early dental caries',
     'Cavity restored, fluoride applied, and oral hygiene instructions provided.', 250.00);

INSERT INTO medicine
    (medicine_id, medicine_name, strength, dosage_form, unit_price,
     stock_quantity, prescription_required)
VALUES
    (3001, 'Paracetamol',           '500 mg', 'Tablet',  0.50, 500, FALSE),
    (3002, 'Amoxicillin',           '500 mg', 'Capsule', 1.20, 200, TRUE),
    (3003, 'Amlodipine',            '5 mg',   'Tablet',  0.85, 180, TRUE),
    (3004, 'Hydrocortisone',        '1%',     'Cream',  18.00,  60, TRUE),
    (3005, 'Sodium Fluoride Gel',   '1.23%',  'Gel',    25.00,  40, TRUE);

INSERT INTO treatment_medicine
    (treatment_id, medicine_id, dosage, frequency, duration_days,
     quantity, instructions)
VALUES
    (2001, 3002, '500 mg',            'Three times daily', 7,  21, 'Take after meals and complete the full course.'),
    (2001, 3001, '500 mg',            'Every 8 hours as needed', 5, 15, 'Do not exceed the recommended daily dose.'),
    (2002, 3003, '5 mg',              'Once daily', 30, 30, 'Take at the same time each day.'),
    (2003, 3004, 'Thin topical layer','Twice daily', 7,   1, 'Apply only to the affected area.'),
    (2004, 3001, '500 mg',            'Every 8 hours as needed', 3,  9, 'Use for fever or discomfort.'),
    (2005, 3005, 'Professional dose', 'Single application', 1,  1, 'Applied by the dentist during the visit.'),
    (2005, 3001, '500 mg',            'Every 8 hours as needed', 2,  6, 'Use only if post-treatment discomfort occurs.');

INSERT INTO payment
    (payment_id, appointment_id, amount, payment_date, payment_method,
     payment_status, reference_no)
VALUES
    (4001, 1001, 270.00, '2026-07-15 09:50:00', 'Card',          'Paid', 'PAY-2026-0001'),
    (4002, 1002, 450.00, '2026-07-16 11:00:00', 'Insurance',     'Paid', 'PAY-2026-0002'),
    (4003, 1003, 350.00, '2026-07-17 11:45:00', 'Card',          'Paid', 'PAY-2026-0003'),
    (4004, 1004, 290.00, '2026-07-18 13:40:00', 'Insurance',     'Paid', 'PAY-2026-0004'),
    (4005, 1005, 470.00, '2026-07-19 16:20:00', 'Bank Transfer', 'Paid', 'PAY-2026-0005');

COMMIT;

-- -----------------------------------------------------------------------------
-- TASK 2 VERIFICATION QUERIES
-- These basic table displays are provided for population screenshots.
-- -----------------------------------------------------------------------------

SELECT * FROM person ORDER BY person_id;
SELECT * FROM patient ORDER BY patient_id;
SELECT * FROM doctor ORDER BY doctor_id;
SELECT * FROM appointment ORDER BY appointment_id;
SELECT * FROM treatment ORDER BY treatment_id;
SELECT * FROM medicine ORDER BY medicine_id;
SELECT * FROM treatment_medicine ORDER BY treatment_id, medicine_id;
SELECT * FROM payment ORDER BY payment_id;

-- =============================================================================
-- TASK 3 - SQL OPERATIONS
-- Every assessed operation includes a short purpose statement. UPDATE, DELETE,
-- and trigger demonstrations use ROLLBACK so the original academic dataset is
-- preserved after the evidence queries are executed.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TASK 3.1 - SELECT STATEMENTS
-- Purpose: List the completed clinic appointments in chronological order so the
-- clinic can review the encounter schedule and the reason for each visit.
-- -----------------------------------------------------------------------------
SELECT
    appointment_id,
    scheduled_at,
    appointment_duration_minutes,
    status,
    reason
FROM appointment
WHERE status = 'Completed'
ORDER BY scheduled_at;

-- Purpose: Identify medicines with 100 units or fewer so clinic staff can
-- prioritize stock monitoring and replenishment.
SELECT
    medicine_id,
    medicine_name,
    strength,
    stock_quantity,
    unit_price
FROM medicine
WHERE stock_quantity <= 100
ORDER BY stock_quantity ASC, medicine_name ASC;

-- -----------------------------------------------------------------------------
-- TASK 3.2 - JOIN QUERIES
-- Purpose: Combine appointments with the related patient, doctor, and specialty
-- details to produce a readable appointment summary.
-- -----------------------------------------------------------------------------
SELECT
    a.appointment_id,
    a.scheduled_at,
    patient_person.full_name AS patient_name,
    doctor_person.full_name AS doctor_name,
    d.specialty,
    a.status
FROM appointment AS a
JOIN patient AS pat
    ON pat.patient_id = a.patient_id
JOIN person AS patient_person
    ON patient_person.person_id = pat.patient_id
JOIN doctor AS d
    ON d.doctor_id = a.doctor_id
JOIN person AS doctor_person
    ON doctor_person.person_id = d.doctor_id
ORDER BY a.scheduled_at;

-- Purpose: Connect each patient to the diagnosis and prescribed medicines,
-- including dosage and treatment duration, for a complete prescription report.
SELECT
    patient_person.full_name AS patient_name,
    t.diagnosis,
    m.medicine_name,
    m.strength,
    tm.dosage,
    tm.frequency,
    tm.duration_days
FROM patient AS pat
JOIN person AS patient_person
    ON patient_person.person_id = pat.patient_id
JOIN appointment AS a
    ON a.patient_id = pat.patient_id
JOIN treatment AS t
    ON t.appointment_id = a.appointment_id
JOIN treatment_medicine AS tm
    ON tm.treatment_id = t.treatment_id
JOIN medicine AS m
    ON m.medicine_id = tm.medicine_id
ORDER BY patient_person.full_name, m.medicine_name;

-- -----------------------------------------------------------------------------
-- TASK 3.3 - NESTED QUERY
-- Purpose: Find patients whose total paid amount is greater than the average
-- paid transaction amount, helping the clinic identify higher-value encounters.
-- -----------------------------------------------------------------------------
SELECT
    pat.patient_id,
    patient_person.full_name AS patient_name,
    SUM(pay.amount) AS total_paid
FROM patient AS pat
JOIN person AS patient_person
    ON patient_person.person_id = pat.patient_id
JOIN appointment AS a
    ON a.patient_id = pat.patient_id
JOIN payment AS pay
    ON pay.appointment_id = a.appointment_id
WHERE pay.payment_status = 'Paid'
GROUP BY pat.patient_id, patient_person.full_name
HAVING SUM(pay.amount) > (
    SELECT AVG(paid_payment.amount)
    FROM payment AS paid_payment
    WHERE paid_payment.payment_status = 'Paid'
)
ORDER BY total_paid DESC;

-- -----------------------------------------------------------------------------
-- TASK 3.4 - AGGREGATE FUNCTIONS WITH GROUP BY
-- Purpose: Summarize each doctor's workload and related financial results using
-- appointment counts, average duration, treatment cost, and collected payments.
-- -----------------------------------------------------------------------------
SELECT
    d.doctor_id,
    doctor_person.full_name AS doctor_name,
    d.specialty,
    COUNT(DISTINCT a.appointment_id) AS appointment_count,
    ROUND(AVG(a.appointment_duration_minutes), 2) AS average_duration_minutes,
    SUM(t.treatment_cost) AS total_treatment_cost,
    SUM(CASE WHEN pay.payment_status = 'Paid' THEN pay.amount ELSE 0 END) AS total_collected
FROM doctor AS d
JOIN person AS doctor_person
    ON doctor_person.person_id = d.doctor_id
LEFT JOIN appointment AS a
    ON a.doctor_id = d.doctor_id
LEFT JOIN treatment AS t
    ON t.appointment_id = a.appointment_id
LEFT JOIN payment AS pay
    ON pay.appointment_id = a.appointment_id
GROUP BY d.doctor_id, doctor_person.full_name, d.specialty
ORDER BY appointment_count DESC, doctor_name;

-- -----------------------------------------------------------------------------
-- TASK 3.5 - UPDATE STATEMENT
-- Purpose: Demonstrate a five-percent price adjustment for Hydrocortisone. The
-- transaction is rolled back after displaying the before-and-after values.
-- -----------------------------------------------------------------------------
START TRANSACTION;

SET @original_hydrocortisone_price = (
    SELECT unit_price
    FROM medicine
    WHERE medicine_id = 3004
);

UPDATE medicine
SET unit_price = ROUND(unit_price * 1.05, 2)
WHERE medicine_id = 3004;

SELECT
    medicine_id,
    medicine_name,
    @original_hydrocortisone_price AS price_before_update,
    unit_price AS price_after_update
FROM medicine
WHERE medicine_id = 3004;

ROLLBACK;

-- -----------------------------------------------------------------------------
-- TASK 3.6 - DELETE STATEMENT
-- Purpose: Demonstrate removing one optional treatment-medicine detail record.
-- ROLLBACK restores the deleted row so later queries keep the original dataset.
-- -----------------------------------------------------------------------------
START TRANSACTION;

SELECT
    treatment_id,
    medicine_id,
    dosage,
    quantity
FROM treatment_medicine
WHERE treatment_id = 2005
  AND medicine_id = 3001;

DELETE FROM treatment_medicine
WHERE treatment_id = 2005
  AND medicine_id = 3001;

SELECT ROW_COUNT() AS deleted_rows;

SELECT COUNT(*) AS matching_rows_after_delete
FROM treatment_medicine
WHERE treatment_id = 2005
  AND medicine_id = 3001;

ROLLBACK;

SELECT COUNT(*) AS matching_rows_after_rollback
FROM treatment_medicine
WHERE treatment_id = 2005
  AND medicine_id = 3001;

-- -----------------------------------------------------------------------------
-- TASK 3.7 - VIEW
-- Purpose: Provide a reusable appointment summary that combines patient,
-- doctor, treatment, and paid-payment information for reporting.
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS vw_appointment_summary;

CREATE VIEW vw_appointment_summary AS
SELECT
    a.appointment_id,
    a.scheduled_at,
    patient_person.full_name AS patient_name,
    doctor_person.full_name AS doctor_name,
    d.specialty,
    a.status,
    t.diagnosis,
    t.treatment_cost,
    COALESCE(SUM(CASE WHEN pay.payment_status = 'Paid' THEN pay.amount ELSE 0 END), 0.00)
        AS paid_amount
FROM appointment AS a
JOIN patient AS pat
    ON pat.patient_id = a.patient_id
JOIN person AS patient_person
    ON patient_person.person_id = pat.patient_id
JOIN doctor AS d
    ON d.doctor_id = a.doctor_id
JOIN person AS doctor_person
    ON doctor_person.person_id = d.doctor_id
LEFT JOIN treatment AS t
    ON t.appointment_id = a.appointment_id
LEFT JOIN payment AS pay
    ON pay.appointment_id = a.appointment_id
GROUP BY
    a.appointment_id,
    a.scheduled_at,
    patient_person.full_name,
    doctor_person.full_name,
    d.specialty,
    a.status,
    t.diagnosis,
    t.treatment_cost;

SELECT *
FROM vw_appointment_summary
ORDER BY scheduled_at;

-- -----------------------------------------------------------------------------
-- TASK 3.8 - TRIGGER
-- Purpose: Protect medicine inventory by rejecting an excessive prescription
-- quantity and automatically reducing stock when a new detail row is inserted.
-- -----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_treatment_medicine_stock;

DELIMITER $$

CREATE TRIGGER trg_treatment_medicine_stock
BEFORE INSERT ON treatment_medicine
FOR EACH ROW
BEGIN
    DECLARE v_available_stock INT DEFAULT -1;

    SELECT COALESCE(MAX(stock_quantity), -1)
    INTO v_available_stock
    FROM medicine
    WHERE medicine_id = NEW.medicine_id;

    IF v_available_stock = -1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The selected medicine does not exist.';
    ELSEIF NEW.quantity > v_available_stock THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient medicine stock for this treatment.';
    ELSE
        UPDATE medicine
        SET stock_quantity = stock_quantity - NEW.quantity
        WHERE medicine_id = NEW.medicine_id;
    END IF;
END$$

DELIMITER ;

-- Trigger test: stock decreases from 40 to 38 after inserting two units. The
-- transaction is rolled back afterward so the permanent stock returns to 40.
START TRANSACTION;

SELECT
    medicine_id,
    medicine_name,
    stock_quantity AS stock_before_trigger
FROM medicine
WHERE medicine_id = 3005;

INSERT INTO treatment_medicine
    (treatment_id, medicine_id, dosage, frequency, duration_days, quantity, instructions)
VALUES
    (2004, 3005, 'Professional dose', 'Single application', 1, 2,
     'Temporary row used to verify the stock-control trigger.');

SELECT
    medicine_id,
    medicine_name,
    stock_quantity AS stock_after_trigger
FROM medicine
WHERE medicine_id = 3005;

ROLLBACK;

SELECT
    medicine_id,
    medicine_name,
    stock_quantity AS stock_after_rollback
FROM medicine
WHERE medicine_id = 3005;

SHOW TRIGGERS LIKE 'treatment_medicine';
