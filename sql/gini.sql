-- Active: 1767382271375@@127.0.0.1@3306
WITH cte_credit AS (
    SELECT 
        `0` AS CREDIT_SCORE, 
        `1` AS IS_DEFAULT 
    FROM credit_data
),
totals AS (
    SELECT 
        CAST(SUM(IS_DEFAULT) AS FLOAT) AS total_defaults,
        CAST(SUM(1 - IS_DEFAULT) AS FLOAT) AS total_non_defaults
    FROM cte_credit
),
cte_metrics AS (
    SELECT
        CREDIT_SCORE,
        SUM(IS_DEFAULT) OVER (ORDER BY CREDIT_SCORE ASC) / t.total_defaults AS TPR,
        SUM(1 - IS_DEFAULT) OVER (ORDER BY CREDIT_SCORE ASC) / t.total_non_defaults AS FPR
    FROM cte_credit, totals t
),
auc_calc AS (
    SELECT
    TPR * (FPR - LAG(FPR, 1, 0) OVER (ORDER BY CREDIT_SCORE ASC)) AS area
    FROM cte_metrics
)
SELECT 
    SUM(area) AS AUC,
    2 * SUM(area) - 1 AS GINI
FROM auc_calc;