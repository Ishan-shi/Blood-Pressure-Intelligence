1. Compare Individual vs Country Average

SELECT 
    d.Country,
    d.Patient_ID,
    d.Systolic_BP_mmHg,
    s.Mean_SBP,
    d.Systolic_BP_mmHg - s.Mean_SBP AS Difference_From_Avg
FROM blood_pressure_global_dataset d
JOIN country_bp_summary s
ON d.Country = s.Country;

2. 2. High Risk Patients

SELECT *
FROM blood_pressure_global_dataset
WHERE Systolic_BP_mmHg > 140 
   OR Diastolic_BP_mmHg > 90;

3. Risk Segmentation

SELECT 
    Patient_ID,
    Country,
    Systolic_BP_mmHg,
    Diastolic_BP_mmHg,
    CASE 
        WHEN Systolic_BP_mmHg >= 140 OR Diastolic_BP_mmHg >= 90 THEN 'High Risk'
        WHEN Systolic_BP_mmHg BETWEEN 120 AND 139 THEN 'Pre-Hypertension'
        ELSE 'Normal'
    END AS Risk_Category
FROM blood_pressure_global_dataset;

4. Country Ranking

SELECT 
    Country,
    Mean_SBP,
    RANK() OVER (ORDER BY Avg_Systolic_BP DESC) AS BP_Rank
FROM country_bp_summary;

5. Top 5 Risk Countries

SELECT *
FROM (
    SELECT 
        Country,
        Mean_SBP,
        RANK() OVER (ORDER BY Avg_Systolic_BP DESC) AS rnk
    FROM country_bp_summary
) t
WHERE rnk <= 5;

6. Age Group Analysis

SELECT 
    CASE 
        WHEN Age < 30 THEN 'Young'
        WHEN Age < 50 THEN 'Middle Age'
        ELSE 'Senior'
    END AS Age_Group,
    AVG(Systolic_BP_mmHg) AS Avg_BP
FROM blood_pressure_global_dataset
GROUP BY Age_Group;

7. Advanced Risk Scoring

WITH risk_calc AS (
    SELECT 
        Patient_ID,
        Country,
        Systolic_BP_mmHg,
        Diastolic_BP_mmHg,
        Age,
        (Systolic_BP_mmHg * 0.6 + Diastolic_BP_mmHg * 0.4 + Age * 0.2) AS Risk_Score
    FROM blood_pressure_global_dataset
)
SELECT *,
    CASE 
        WHEN Risk_Score >= 160 THEN 'Critical'
        WHEN Risk_Score >= 140 THEN 'High'
        WHEN Risk_Score >= 120 THEN 'Moderate'
        ELSE 'Low'
    END AS Risk_Level
FROM risk_calc;

8. Country Vs  Individual Gap

SELECT 
    d.Country,
    COUNT(*) AS Total_Patients,
    AVG(d.Systolic_BP_mmHg) AS Actual_Avg,
    s.Mean_SBP AS Reported_Avg,
    AVG(d.Systolic_BP_mmHg) - s.Mean_SBP AS Gap
FROM blood_pressure_global_dataset d
JOIN country_bp_summary s
ON d.Country = s.Country
GROUP BY d.Country, s.Mean_SBP
ORDER BY Gap DESC;

9. Risk Concentration

SELECT 
    Country,
    COUNT(*) AS Total,
    SUM(CASE WHEN Systolic_BP_mmHg > 140 THEN 1 ELSE 0 END) AS High_BP_Count,
    ROUND(
        SUM(CASE WHEN Systolic_BP_mmHg > 140 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS High_BP_Percentage,
    RANK() OVER (ORDER BY 
        SUM(CASE WHEN Systolic_BP_mmHg > 140 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) DESC
    ) AS Risk_Rank
FROM blood_pressure_global_dataset
GROUP BY Country;

10. BP Progression with Age 

SELECT 
    Country,
    Age,
    AVG(Systolic_BP_mmHg) OVER (PARTITION BY Country ORDER BY Age) AS Running_BP
FROM blood_pressure_global_dataset;

11. Top 1% High-Risk Patients

SELECT *
FROM (
    SELECT *,
        NTILE(100) OVER (ORDER BY Systolic_BP DESC) AS percentile_rank
    FROM blood_pressure_global_dataset
) t
WHERE percentile_rank = 1;