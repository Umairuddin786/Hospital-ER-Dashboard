-- Database Setup
CREATE TABLE Patient_Info (
    Patient_Id VARCHAR2(100),
    Patient_Admission_Date TIMESTAMP,
    Patient_First_Initial CHAR(1),
    Patient_Last_Name VARCHAR2(500),
    Patient_Gender CHAR(1),
    Patient_Age NUMBER(3),
    Patient_Race VARCHAR2(50),
    Department_Referral VARCHAR2(50),
    Patient_Admission_Flag VARCHAR2(5),
    Patient_Satisfaction_Score NUMBER(2),
    Patient_Waittime NUMBER(3),
    Patients_CM NUMBER(1)
);
SELECT * FROM Patient_Info;
ALTER TABLE Patient_Info
RENAME COLUMN Patient_First_Inital TO Patient_First_Initial;


-- Data Quality Check
SELECT 
       patient_id,
       CASE 
            WHEN patient_id IS NULL OR Patient_id = '' THEN 'Invalid'
            ELSE 'Valid'
        END AS Patient_ID_Status,
        CASE 
        WHEN Patient_Admission_Date IS NULL THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Admission_Date_Status,
    CASE 
        WHEN Patient_First_Initial IS NULL OR Patient_First_Initial = '' THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_First_Initial_Status,
    CASE 
        WHEN Patient_Last_Name IS NULL OR Patient_Last_Name = '' THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Last_Name_Status,
    CASE 
        WHEN Patient_Gender NOT IN ('m', 'f') THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Gender_Status,
    CASE 
        WHEN Patient_Age IS NULL OR Patient_Age < 0 OR Patient_Age > 120 THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Age_Status,
    CASE 
        WHEN Patient_Race IS NULL OR Patient_Race = '' THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Race_Status,
    CASE 
        WHEN Department_Referral IS NULL OR Department_Referral = '' THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Department_Referral_Status,
    CASE 
        WHEN Patient_Admission_Flag IS NULL OR Patient_Admission_Flag = '' THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Admission_Flag_Status,
    CASE 
        WHEN Patient_Satisfaction_Score IS NULL OR Patient_Satisfaction_Score < 1 OR Patient_Satisfaction_Score > 10 THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Satisfaction_Score_Status,
    CASE 
        WHEN Patient_Waittime IS NULL OR Patient_Waittime < 0 THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_Waittime_Status,
    CASE 
        WHEN Patient_CM IS NULL OR Patient_CM NOT IN (0, 1) THEN 'Invalid' 
        ELSE 'Valid' 
    END AS Patient_CM_Status
FROM Patient_info;
  
-- Data Preprocessing
-- M = male , F = Female
UPDATE patient_info
SET patient_gender = 'Male'
WHERE patient_gender = 'M';

UPDATE Patient_info
SET patient_Gender = 'Female'
WHERE patient_Gender = 'F';

-- Patient Full Name
ALTER TABLE patient_info
ADD (Patient_Full_Name VARCHAR2(100));

UPDATE Patient_Info
SET Patient_Full_Name = Patient_First_Initial || ' ' || Patient_Last_Name;

-- Admission Status
ALTER TABLE patient_info
ADD (Admission_Status VARCHAR2(20));
UPDATE patient_info
SET admission_status = CASE
  WHEN patient_Admission_Flag = 'TRUE' THEN ' Admitted'
  ELSE 'Not Admitted'
END;

-- Age Group
ALTER Table patient_info
ADD (Age_Group VARCHAR2(10));

UPDATE Patient_info
SET Age_Group = CASE
    WHEN Patient_Age >= 100 THEN '100+'
    WHEN Patient_Age >= 90 THEN '90-99'
    WHEN Patient_Age >= 80 THEN '80-89'
    WHEN Patient_Age >= 70 THEN '70-79'
    WHEN Patient_Age >= 60 THEN '60-69'
    WHEN Patient_Age >= 50 THEN '50-59'
    WHEN Patient_Age >= 40 THEN '40-49'
    WHEN Patient_Age >= 30 THEN '30-39'
    WHEN Patient_Age >= 20 THEN '20-29'
    WHEN Patient_Age >= 10 THEN '10-19'
    ELSE '0-9'
END;

-- Patient_Admin Date
ALTER TABLE Patient_info
ADD Patient_Admin_Date DATE;

UPDATE patient_info
SET patient_Admin_Date = TO_Date
   (EXTRACT (YEAR FROM patient_admission_date) || '-' ||
    EXTRACT (MONTH FROM patient_admission_date) || '-' ||
    EXTRACT (DAY FROM patient_admission_date),'YYYY-MM-DD');
    
-- Wait_Time_Status
ALTER TABLE Patient_info
ADD Wait_Time_Status VARCHAR2(50);

UPDATE patient_info
SET wait_time_status = CASE
    WHEN patient_waittime <= 30 THEN 'Within Target'
    ELSE 'Target Missed'
END;

-- Admission Hour
ALTER TABLE Patient_info
ADD Admission_Hour NUMBER(2);

UPDATE patient_info
SET admission_hour = EXTRACT(HOUR FROM patient_admission_date);
-- Wait Time Interval
ALTER TABLE Patient_info
ADD(Wait_Time_Interval VARCHAR2(50));

UPDATE Patient_info
SET wait_time_interval = CASE
     WHEN admission_hour <2 THEN '00-02'
     WHEN admission_hour <4 THEN '03-04'
     WHEN admission_hour <6 THEN '05-06'
     WHEN admission_hour <8 THEN '07-08'
     WHEN admission_hour <10 THEN '09-10'
     WHEN admission_hour <12 THEN '11-12'
     WHEN admission_hour <14 THEN '13-14'
     WHEN admission_hour <16 THEN '15-16'
     WHEN admission_hour <18 THEN '17-18'
     WHEN admission_hour <20 THEN '19-20'
     WHEN admission_hour <22 THEN '21-22'
     WHEN admission_hour <24 THEN '23-24'
     ELSE 'Above 24'
END;
    
-- Creating Date Table
SELECT
       MIN(patient_admission_date) AS min_date,
       MAX(patient_admission_date) AS max_date
FROM patient_info;

CREATE TABLE date_table (
    date_value DATE
);

INSERT INTO date_table (date_value)
WITH date_range AS (
    SELECT 
          MIN(Patient_Admin_Date) AS start_date,
          MAX(Patient_Admin_Date) AS end_date
    FROM patient_info
),
calendar AS(
    SELECT start_date + LEVEL -1 AS date_value
    FROM date_range
    CONNECT BY LEVEL <= (end_date - start_date + 1)
    )
SELECT date_value
FROM calendar;

ALTER TABLE date_table
ADD (
     Month_Name VARCHAR(20),
     Month_Number NUMBER(2),
     Day_Name VARCHAR(10),
     WeekDay NUMBER(1)
     );

ALTER TABLE date_table
ADD ( year_col NUMBER(5),
      Month_&_Year VARCHAR2(50)
      );
      
UPDATE date_table
SET 
    month_name = TO_CHAR(admission_date,'Month'),
    month_number = EXTRACT(MONTH FROM admission_date),
    Year_Col = EXTRACT(YEAR FROM admission_date),
    Month_&_year = TO_CHAR(admission_date,'MM-YYYY'),
    day_name = TO_CHAR(admission_date,'Day'),
    Weekday = TO_CHAR(admission_date,'D');
    
ALTER TABLE patient_info
ADD CONSTRAINT patient_admission_date
FOREIGN KEY (Patient_Admin_date) 
REFERENCES date_table (admission_date);

ALTER TABLE date_table
ADD CONSTRAINT pk_admission_date PRIMARY KEY (admission_date);

ALTER TABLE Patient_info
MODIFY patient_satisfaction_score NUMBER(10,0)
;

SELECT * FROM date_table;