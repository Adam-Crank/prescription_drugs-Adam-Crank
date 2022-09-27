--Prescription Drugs Project


--1a)
SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;


--1b)
SELECT prescriber.npi, nppes_provider_first_name, 
	nppes_provider_last_org_name, specialty_description, 
	SUM(total_claim_count) AS total_claims
FROM prescription INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi, prescriber.nppes_provider_first_name, 
	prescriber.nppes_provider_last_org_name, prescriber.specialty_description
ORDER BY total_claims DESC;
/* NOTE: because we know that provider first/last name and specialty correspond 
to exactly one npi, we add all of them to the 'GROUP BY' so that the table is 
properly generated. This will not necessarily be the case in every instance. */


--2a)
SELECT specialty_description, SUM(total_claim_count) AS total_claims
FROM prescription INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY specialty_description
ORDER BY total_claims DESC;


--2b) NOTE: opioid_drug_flag = N or Y
--prescriber <-npi-> prescription <-drug_name-> drug
SELECT specialty_description, SUM(total_claim_count) AS total_opioid_claims
FROM prescription INNER JOIN prescriber ON prescriber.npi = prescription.npi
				  INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_opioid_claims DESC;


--3a)
SELECT generic_name, total_drug_cost
FROM drug INNER JOIN prescription ON drug.drug_name = prescription.drug_name
ORDER BY total_drug_cost DESC;


--3b)
SELECT generic_name, ROUND(total_drug_cost/total_day_supply, 2) AS total_cost_per_day
FROM prescription INNER JOIN drug ON drug.drug_name = prescription.drug_name
ORDER BY total_cost_per_day DESC;


--4a)
SELECT drug_name, --opioid_drug_flag, antibiotic_drug_flag,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;


--4b)
SELECT 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug INNER JOIN prescription ON drug.drug_name = prescription.drug_name