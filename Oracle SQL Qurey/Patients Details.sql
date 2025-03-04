-- Patients_Details
SELECT 
      Patient_id,
      Patient_Full_Name AS Name,
      patient_Gender AS Gender,
      Patient_Age AS Age,
      Patient_Admin_Date AS Admin_Date,
      Patient_Race AS Race,
      patient_waittime AS WaitTime,
      Department_Referral,
      admission_status
FROM PATIENT_INFO;