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
SELECT SUM(total_drug_cost),
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug INNER JOIN prescription ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;


--5a)
SELECT COUNT(cbsa)
FROM cbsa INNER JOIN fips_county ON cbsa.fipscounty = fips_county.fipscounty
WHERE state = 'TN';


--5b)
SELECT cbsaname, SUM(population)
FROM population INNER JOIN cbsa ON population.fipscounty = cbsa.fipscounty
GROUP BY cbsaname
ORDER BY SUM(population) DESC;


--5c)
SELECT county, SUM(population)
FROM (SELECT fipscounty
FROM population 
EXCEPT
SELECT fipscounty
FROM cbsa) AS nocbsa INNER JOIN fips_county ON nocbsa.fipscounty = fips_county.fipscounty
INNER JOIN population ON nocbsa.fipscounty = population.fipscounty
GROUP BY county
ORDER BY SUM(population) DESC;


--6a)
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;


--6b)
SELECT prescription.drug_name, total_claim_count, opioid_drug_flag
FROM prescription INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= 3000;

--6c)
SELECT prescription.drug_name, total_claim_count, opioid_drug_flag,
	nppes_provider_first_name, nppes_provider_last_org_name
FROM prescription INNER JOIN drug ON prescription.drug_name = drug.drug_name
	INNER JOIN prescriber ON prescription.npi = prescriber.npi
WHERE total_claim_count >= 3000;


--7a) replace with crossjoin?
SELECT prescriber.npi, /*nppes_provider_last_org_name, nppes_provider_first_name,
	nppes_provider_city, specialty_description,*/ drug.drug_name
FROM prescriber INNER JOIN prescription ON prescriber.npi = prescription.npi
	INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE (specialty_description = 'Pain Management') 
	AND (nppes_provider_city = 'NASHVILLE') 
	AND (opioid_drug_flag = 'Y')
ORDER BY npi DESC;


--7b)
SELECT npi, drug_name, SUM(total_claim_count) AS claims_per_drug
FROM prescription
GROUP BY npi, drug_name


--7c)
