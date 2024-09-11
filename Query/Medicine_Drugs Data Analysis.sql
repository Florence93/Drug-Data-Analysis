
-- Remove 'mg' from column Strength 
UPDATE medicine_dataset
SET Strength = cast(REMOVE(Strength, ' mg','')AS UNSIGNED);

-- set Strength column to Integer 
ALTER TABLE medicine_dataset
MODIFY COLUMN Strength INT;

-- change 'name' column to medicine_column 
ALTER TABLE medicine_dataset
CHANGE COLUMN name medicine_name CHAR (100);

-- change 'dosage form' column to 'dosage_form'
ALTER TABLE medicine_dataset
CHANGE COLUMN `dosage form` dosage_form CHAR(100);

-- 1. Most Common Medicines in Each Category: 
-- Identify which specific medicines are most frequently listed within each therapeutic category.
WITH common_medicine as 
( SELECT category, medicine_name, count(*) as medi_count
from medicine_dataset
GROUP BY category, medicine_name
),
rank_med AS
(SELECT category,medicine_name, medi_count,
	ROW_NUMBER () OVER (PARTITION BY category ORDER BY medi_count DESC) AS `rank`
FROM common_medicine)

SELECT category, medicine_name, medi_count
FROM rank_med
where `rank` = 1;

-- 2. Average Strength by Dosage Form: Determine the average strength of medicines for each dosage form.
WITH average_med AS
( SELECT dosage_form, avg(strength) AS avg_strength
FROM medicine_dataset 
GROUP BY dosage_form
),
rank_avg AS
(SELECT dosage_form, avg_strength,
	ROW_NUMBER() OVER (PARTITION BY dosage_form ORDER BY avg_strength desc) as `rank`
FROM average_med
)

SELECT dosage_form, avg_strength
FROM rank_avg
where `rank` = 1;

-- 3. Distribution of Medicines by Manufacturer: Count how many different medicines each manufacturer produces.
WITH manufacturer AS
( SELECT manufacturer, count(*) as medicine_count
FROM medicine_dataset
GROUP BY manufacturer
),

rank_manufacturer AS
( select manufacturer, medicine_count,
	ROW_NUMBER () OVER (PARTITION BY manufacturer ORDER BY medicine_count desc) AS `rank`
    FROM manufacturer
)

SELECT manufacturer, medicine_count
FROM rank_manufacturer
where `rank` = 1;

-- 4. Count of Medicines by Indication: Find out how many medicines are available for each medical indication.
WITH med_indication AS
(SELECT indication, count(*) as medname_count
FROM medicine_dataset
GROUP BY indication
),

rank_indication AS
( SELECT indication, medname_count,
	ROW_NUMBER () OVER (PARTITION BY indication ORDER BY medname_count desc) AS `rank`
    FROM med_indication
)

SELECT indication, medname_count
FROM rank_indication
WHERE `rank` = 1;

-- 5. Prescription vs. Over-the-Counter Medicines by Category: 
-- Compare the number of prescription and over-the-counter medicines within each therapeutic category.
WITH med_classification AS
(select classification, count(*) as medname_count
FROM medicine_dataset
GROUP BY classification
),
rank_classification AS
(SELECT classification, medname_count,
	ROW_NUMBER() OVER (PARTITION BY classification ORDER BY medname_count desc) AS `rank`
    FROM med_classification
)

SELECT classification, medname_count
FROM rank_classification
WHERE `rank` = 1;

-- 6. Top Manufacturers for Specific Indications: 
-- Identify which manufacturers produce the most medicines for particular medical conditions.
WITH manu_indication AS
(SELECT indication, manufacturer, count(*) AS medname_count
	FROM medicine_dataset
    GROUP BY indication, manufacturer
),

rank_manu_indication AS 
(SELECT indication, manufacturer, medname_count,
	ROW_NUMBER() OVER (PARTITION BY indication ORDER BY medname_count desc) as `rank`
    FROM manu_indication
)

SELECT indication, manufacturer, medname_count
FROM rank_manu_indication
WHERE `rank` = 1;

-- 7. Strength Range for Each Dosage Form: Determine the range of strengths available for each dosage form.
SELECT dosage_form, min(Strength), max(strength)
FROM medicine_dataset
GROUP BY dosage_form;

-- 8. Medicines with the Highest and Lowest Strengths: Identify which medicines have the highest and lowest strengths.
-- Lowest
SELECT medicine_name, Strength
FROM medicine_dataset
WHERE Strength = (SELECT min(Strength) FROM medicine_dataset);

-- Highest
SELECT medicime_name, Strength
FROM medicine_dataset
WHERE Strength = (SELECT max(Strength) FROM medicine_dataset);

-- 9. Most Common Dosage Forms for Specific Categories: 
-- Find out which dosage forms are most commonly associated with each therapeutic category.

WITH dosage_category AS
(SELECT dosage_form, category, count(*) AS dosage_count
FROM medicine_dataset
GROUP BY dosage_form, category
),

rank_dosage_category AS
(SELECT dosage_form, category, dosage_count, 
	ROW_NUMBER () OVER (PARTITION BY category ORDER BY dosage_count desc) AS	`rank`
    FROM dosage_category
)

SELECT category, dosage_form, dosage_count
FROM rank_dosage_category
WHERE `rank` = 1;