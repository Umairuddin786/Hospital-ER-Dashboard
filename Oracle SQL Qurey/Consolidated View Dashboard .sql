-- Hospital Emergency Dashboard

-- Consolidated View

-- KPI'S

-- Patients Count
SELECT COUNT(DISTINCT Patient_id) AS Patient_Count
FROM patient_info;

-- Avg Wait Time
SELECT TO_CHAR(ROUND (AVG(Patient_WaitTime),1),'999.9') || 'Min' AS Avg_WaitTime
FROM Patient_info;

-- Patient Rating
SELECT ROUND(AVG(Patient_Satisfaction_Score),2 )AS Patient_Rating
FROM patient_info;

-- Patients Reffered
SELECT COUNT(*)  AS Patients_Referred
FROM Patient_info 
WHERE Department_Referral <> 'None';

-- Visulas

-- Patient_Admission_Status
SELECT 
      Admission_Status,
      COUNT(DISTINCT Patient_id) AS Patients,
      ROUND((COUNT(*) *100.0 / (SELECT COUNT (*) FROM Patient_info)),0) || '%'AS "%_of_Total"
FROM patient_info
GROUP BY Admission_Status;

-- Patients by Age group
SELECT
      AGE_Group,
      COUNT(DISTINCT Patient_id) AS Patients
FROM patient_info
GROUP BY Age_Group
ORDER BY Age_Group;

-- Patient by Department Referral
SELECT 
      Department_Referral,
      COUNT(DISTINCT Patient_id) AS Patients
FROM Patient_Info
GROUP BY Department_Referral
ORDER BY Patients DESC;

-- Patient by Race
SELECT 
      Patient_Race,
      COUNT(DISTINCT Patient_id) AS Patients
FROM Patient_info
GROUP BY Patient_Race
ORDER BY patients DESC;

-- Patient by Wait Time Status
SELECT 
     Wait_time_Status,
     COUNT(*) AS Patients,
     ROUND((COUNT(*) *100.0 / (SELECT COUNT (*) FROM Patient_info)),2) || '%'AS "%_of_Total"
FROM Patient_Info
GROUP BY Wait_time_Status;

-- Patient by Gender
SELECT 
      Patient_Gender,
      COUNT(*) AS Patients,
      ROUND((COUNT (*) *100.0/ (SELECT COUNT (*) FROM Patient_info)),2) || '%' AS "% of Total"
FROM Patient_info
GROUP BY Patient_Gender;

-- Patient by Day 
SELECT 
     d.day_name,
     d.WEEKDAY,
     COUNT(DISTINCT Patient_id) AS Patients
FROM patient_info p
JOIN date_table d ON p.Patient_Admin_Date = d.admission_date
GROUP BY day_name,WeekDay
ORDER BY WeekDay;

-- Patient by day name and hours
SELECT 
       d.WeekDay,
       d. day_name,
       Wait_Time_Interval AS Hours,
       COUNT(DISTINCT Patient_id) AS patients
FROM patient_info p
JOIN date_table d ON p.PATIENT_ADMIN_DATE = d.ADMISSION_DATE
GROUP BY p.WAIT_TIME_INTERVAL,d.DAY_NAME,d.WEEKDAY
ORDER BY p.WAIT_TIME_INTERVAL;