-- ============================================================================
-- Question 2 - Rfam Database Queries
-- Public Database Documentation:
-- https://docs.rfam.org/en/latest/database.html
--
-- Connection:
-- mysql -u rfamro -h mysql-rfam-public.ebi.ac.uk -P 4497 Rfam
-- ============================================================================


-- ============================================================================
-- Question 2(a)
-- How many types of Acacia plants are present in the taxonomy table?
-- ============================================================================

SELECT COUNT(DISTINCT species) AS acacia_species_count
FROM taxonomy
WHERE species LIKE 'Acacia %';


-- View the list of Acacia species

SELECT DISTINCT species
FROM taxonomy
WHERE species LIKE 'Acacia %'
ORDER BY species;


-- ============================================================================
-- Question 2(b)
-- Which type of wheat has the longest DNA sequence?
-- Wheat belongs to the genus Triticum.
-- ============================================================================

SELECT
    t.species AS wheat_type,
    r.rfamseq_acc,
    r.length AS sequence_length_bp
FROM rfamseq r
JOIN taxonomy t
    ON r.ncbi_id = t.ncbi_id
WHERE t.species LIKE 'Triticum %'
ORDER BY r.length DESC
LIMIT 1;


-- Display the longest DNA sequence for every wheat species

SELECT
    t.species,
    MAX(r.length) AS longest_sequence_length
FROM rfamseq r
JOIN taxonomy t
    ON r.ncbi_id = t.ncbi_id
WHERE t.species LIKE 'Triticum %'
GROUP BY t.species
ORDER BY longest_sequence_length DESC;


-- ============================================================================
-- Question 2(c)
-- Family accession ID, family name and maximum DNA sequence length
-- Only families with sequence length > 1,000,000
-- Ordered by sequence length (largest first)
-- Page 9 with 15 results per page
-- OFFSET = (9 - 1) × 15 = 120
-- ============================================================================

SELECT
    f.rfam_acc AS family_accession,
    f.rfam_id AS family_name,
    MAX(r.length) AS max_sequence_length
FROM family f
JOIN full_region fr
    ON fr.rfam_acc = f.rfam_acc
JOIN rfamseq r
    ON r.rfamseq_acc = fr.rfamseq_acc
WHERE fr.is_significant = 1
GROUP BY
    f.rfam_acc,
    f.rfam_id
HAVING MAX(r.length) > 1000000
ORDER BY max_sequence_length DESC
LIMIT 15 OFFSET 120;