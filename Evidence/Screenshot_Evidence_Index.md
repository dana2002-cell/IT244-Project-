# Screenshot Evidence Index

All files listed below are genuine MySQL Workbench evidence or readable crops taken from the original MySQL Workbench captures.

## Task 2 - Populated Tables

| Figure | Requirement | File |
|---|---|---|
| 2.1 | PERSON table | `task2_01_person_table.jpg` |
| 2.2 | PATIENT table | `task2_02_patient_table.jpg` |
| 2.3 | DOCTOR table | `task2_03_doctor_table.jpg` |
| 2.4 | APPOINTMENT table | `task2_04_appointment_table.jpg` |
| 2.5 | TREATMENT table | `task2_05_treatment_table.jpg` |
| 2.6 | MEDICINE table | `task2_06_medicine_table.jpg` |
| 2.7 | TREATMENT_MEDICINE table | `task2_07_treatment_medicine_table.jpg` |
| 2.8 | PAYMENT table | `task2_08_payment_table.jpg` |

## Task 3 - SQL Operations

| Figure | Requirement | File | Verified Result |
|---|---|---|---|
| 3.1A | Completed-appointment SELECT | `task3_01a_select_completed_appointments.jpg` | Five rows |
| 3.1B | Low-stock SELECT | `task3_01b_select_low_stock.jpg` | Hydrocortisone and Sodium Fluoride Gel |
| 3.2A | Appointment-details JOIN | `task3_02a_join_appointment_details.jpg` | Five rows |
| 3.2B | Patient-prescription JOIN | `task3_02b_join_patient_prescriptions.jpg` | Seven rows |
| 3.3 | Nested query | `task3_03_nested_query.jpg` | Faisal and Mohammed |
| 3.4 | Aggregate functions with GROUP BY | `task3_04_group_by.jpg` | Five doctor summaries |
| 3.5 | UPDATE demonstration | `task3_05_update.jpg` | SAR 18.00 to SAR 18.90 |
| 3.6 | DELETE and rollback | `task3_06_delete_rollback.jpg` | `1 -> 0 -> 1` after rollback |
| 3.7A | VIEW existence | `task3_07a_view_exists.jpg` | `vw_appointment_summary` confirmed as a view |
| 3.7B | VIEW full result | `task3_07b_view_result.jpg` | Five complete rows |
| 3.8A | TRIGGER existence | `task3_08a_trigger_exists.jpg` | `trg_treatment_medicine_stock` confirmed |
| 3.8B | TRIGGER stock test | `task3_08b_trigger_stock_test.jpg` | `40 -> 38 -> 40` after rollback |
