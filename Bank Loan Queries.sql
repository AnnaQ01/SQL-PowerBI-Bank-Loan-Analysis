-- I. OVERVIEW
--1.1 Total Loan Applications
select Count(id) as Total_Loan_Applications from Loan

--1.2. Total Loan Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM Loan

--1.3. Total Payment Amount
SELECT SUM(total_payment) AS Total_Amount_Collected FROM loan

--1.4. Average Interest Rate
SELECT Round(AVG(int_rate)*100, 2) AS Avg_Int_Rate FROM Loan

--1.5. Average DTI (Debt-to-Income)
SELECT Round(AVG(dti)*100, 2) AS Avg_DTI FROM Loan

--1.6. Total Loan Applications by Month
SELECT 
	MONTH(issue_date) AS Month_Munber, 
	DATENAME(MONTH, issue_date) AS Month_name, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Loan_Amount,
	SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date)

--1.7. Loan Applications by State
SELECT 
	address_state AS State, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Loan_Amount,
	SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY address_state
ORDER BY address_state

--1.8. Loan Application by TERM
SELECT 
	term AS Term, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Loan_Amount,
	SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY term
ORDER BY term

--1.9. EMPLOYEE LENGTH
SELECT 
	emp_length AS Employee_Length, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Loan_Amount,
	SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY emp_length
ORDER BY emp_length

--1.10. Top 5: Loan Applications by Purpose
SELECT TOP 5
    purpose AS PURPOSE, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Loan_Amount,
    SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY purpose
ORDER BY Total_Loan_Applications DESC;

--1.11. Bottom 5: Loan Applications by Purpose
SELECT TOP 5
    purpose AS PURPOSE, 
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Loan_Amount,
    SUM(total_payment) AS Total_Payment_Received
FROM loan
GROUP BY purpose
ORDER BY Total_Loan_Applications Asc;



--1.12. HOME OWNERSHIP
SELECT 
	home_ownership AS Home_Ownership, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Loan_Amount,
	SUM(total_payment) AS Total_Payment_Amount
FROM loan
GROUP BY home_ownership
ORDER BY home_ownership

--1.13. Loan to income by income category
SELECT 
    CASE 
        WHEN annual_income < 60000 THEN 'Low Income' 
        WHEN annual_income BETWEEN 60000 AND 100000 THEN 'Moderate Income' 
        ELSE 'High Income' 
    END AS income_category,
    Round(AVG(annual_income),2) AS avg_income,
    Round(AVG(loan_amount),2) AS avg_loan_amount,
    Round((AVG(loan_amount) / AVG(annual_income)),4)*100 AS loan_to_income_percentage
FROM loan
GROUP BY 
    CASE 
        WHEN annual_income < 60000 THEN 'Low Income' 
        WHEN annual_income BETWEEN 60000 AND 100000 THEN 'Moderate Income' 
        ELSE 'High Income' 
    END
ORDER BY income_category;

-- II. DETAIL ANALYSIS
--2.1. Count of Good Loan and Bad Loan
-- A Good Loan is a loan where the loan status is either "Fully Paid" or "Current." 
-- Otherwise, if the loan status is "Charged Off," it is considered a Bad Loan
SELECT 
    'Good Loan' AS Loan_Status,
    COUNT(id) AS Total_Applications,
    ROUND(COUNT(id) * 1.0 / (SELECT COUNT(*) FROM Loan) * 100, 2) AS Percentage_of_Good_Loans
FROM 
    Loan
WHERE 
    loan_status = 'Fully Paid' OR loan_status = 'Current'

UNION ALL

SELECT 
    'Bad Loan' AS Loan_Status,
    COUNT(id) AS Total_Applications,
    ROUND(COUNT(id) * 1.0 / (SELECT COUNT(*) FROM Loan) * 100, 2) AS Percentage_of_Bad_Loans
FROM 
    Loan
WHERE 
    loan_status = 'Charged Off'

UNION ALL

SELECT 
    'Total Applications' AS Loan_Status,
    COUNT(id) AS Total_Applications,
    100.00 AS Percentage_of_Total_Loans
FROM 
    Loan;

-- 2.2. Amount of Good Loan and Bad Loan
WITH TotalLoans AS (
    SELECT 
        SUM(loan_amount) AS Total_Loan_Amount
    FROM 
        loan
)
SELECT 
    'Good Loan' AS Loan_Status,
    SUM(loan_amount) AS Total_Loan,
    ROUND((SUM(loan_amount) * 100.0) / (SELECT Total_Loan_Amount FROM TotalLoans), 2) AS Loan_Percentage
FROM 
    loan
WHERE 
    loan_status = 'Fully Paid' OR loan_status = 'Current'

UNION ALL

SELECT 
    'Bad Loan' AS Loan_Status,
    SUM(loan_amount) AS Total_Loan,
    ROUND((SUM(loan_amount) * 100.0) / (SELECT Total_Loan_Amount FROM TotalLoans), 2) AS Loan_Percentage
FROM 
    loan
WHERE 
    loan_status = 'Charged Off';


--2.3. Loan Group by Credit Grade 
SELECT 
    grade, 
    COUNT(id) AS total_applications,
    SUM(CASE 
        WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 
        ELSE 0 
    END) AS good_loans,
    SUM(CASE 
        WHEN loan_status = 'Charged Off' THEN 1 
        ELSE 0 
    END) AS bad_loans
FROM loan
GROUP BY grade;

-- 2.4. Loan Group by Income Category
WITH LoanSummary AS (
    SELECT
        CASE 
            WHEN annual_income < 60000 THEN 'Low Income'
            WHEN annual_income BETWEEN 60000 AND 100000 THEN 'Moderate'
            ELSE 'High Income'
        END AS income_category,
        COUNT(CASE 
            WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 
        END) AS good_loan_applications,
        COUNT(CASE 
            WHEN loan_status = 'Charged Off' THEN 1 
        END) AS bad_loan_applications,
        SUM(CASE 
            WHEN loan_status IN ('Fully Paid', 'Current') THEN loan_amount 
        END) AS good_loan_amount,
        SUM(CASE 
            WHEN loan_status = 'Charged Off' THEN loan_amount 
        END) AS bad_loan_amount
    FROM
        loan
    GROUP BY
        CASE 
            WHEN annual_income < 60000 THEN 'Low Income'
            WHEN annual_income BETWEEN 60000 AND 100000 THEN 'Moderate'
            ELSE 'High Income'
        END
)

SELECT 
    income_category,
    good_loan_applications,
    bad_loan_applications,
    good_loan_amount,
    bad_loan_amount
FROM 
    LoanSummary;

--2.5. Top 5 Bad Loan Purposes by Total Loan Amount
SELECT top 5
    purpose, 
    SUM(loan_amount) AS total_loan_amount
FROM 
    loan
WHERE 
    loan_status = 'Charged Off'
GROUP BY 
    purpose
ORDER BY 
    total_loan_amount DESC

-- 2.7. Loan Group by Verification Status
SELECT 
    verification_status,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END) AS bad_loans_total_amount,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN loan_amount ELSE 0 END) AS good_loans_total_amount,
    SUM(loan_amount) AS total_loans_amount
FROM 
    loan
GROUP BY 
    verification_status
ORDER BY 
    total_loans_amount DESC;

-- 2.6. Loan Group by Term

SELECT 
    term,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END) AS bad_loans_total_amount,
    SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN loan_amount ELSE 0 END) AS good_loans_total_amount,
    SUM(loan_amount) AS total_loans_amount,
    ROUND((SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END) * 100.0) / SUM(loan_amount), 2) AS default_rate
FROM 
    loan
GROUP BY 
    term
ORDER BY 
    default_rate DESC;

	-- 2.7. Loan Status Summary
WITH LoanSummary AS (
    SELECT
        loan_status,
        COUNT(id) AS Loan_Applications,
        SUM(total_payment) AS Total_Payment,
        SUM(loan_amount) AS Total_Loan,
        ROUND(AVG(int_rate * 100), 2) AS Avg_Interest_Rate,
        ROUND(AVG(dti * 100), 2) AS Avg_DTI,
        ROUND(AVG(annual_income), 2) AS Avg_Income,
        ROUND((AVG(annual_income) / AVG(loan_amount)), 2) AS Income_to_Loan_Percentage
    FROM
        loan
    GROUP BY
        loan_status
)

SELECT 
    loan_status,
    Loan_Applications,
    Total_Payment,
    Total_Loan,
    Avg_Interest_Rate,
    Avg_DTI,
    Avg_Income,
    Income_to_Loan_Percentage
FROM 
    LoanSummary;
