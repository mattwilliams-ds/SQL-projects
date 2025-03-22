/*
SQL QUERIES FOR IDENTIFYING INDIVIDUAL BRIDGES BY ROAD CARRIED OR FEATURE CROSSED
 AS WELL AS QUERIES TO IDENTIFY BRIDGE BY HIGHEST DAILY TRAFFIC, HIGHEST TRAFFIC
 SORTED BY LOWEST RATINGS, AND MOVABLE BRIGES IN LESS THAN GOOD CONDITION
 
DEVELOPED BY MATTHEW WILLIAMS USING SQLITE

MARCH 22ND, 2025

*/


/* LOOKUP BRIDGE BY FEATURE CROSSED */
SELECT
	STRUCTURE_NUMBER_008 as "Structure ID",
	s.State as "State",
	FACILITY_CARRIED_007 as "Road Carried",
	FEATURES_DESC_006A as "Feature Crossed",
	DECK_COND_058 as "Deck Rating",
	SUPERSTRUCTURE_COND_059 as "Super Str Rating",
	SUBSTRUCTURE_COND_060 as "Sub Str Rating",
	round(power(DECK_COND_058*SUPERSTRUCTURE_COND_059*SUBSTRUCTURE_COND_060,0.333),1) as "Avg. Rating"
FROM nbi
JOIN States s ON nbi.STATE_CODE_001 = s.Code
WHERE   FEATURES_DESC_006A like '% BOSSE%'
	AND STRUCTURE_TYPE_043B != 19
	AND DECK_COND_058 != "NULL"


/* LOOKUP BRIDGE BY ROAD CARRIED */
SELECT
	STRUCTURE_NUMBER_008 as "Structure ID",
	s.State as "State",
	FACILITY_CARRIED_007 as "Road Carried",
	FEATURES_DESC_006A as "Feature Crossed",
	DECK_COND_058 as "Deck Rating",
	SUPERSTRUCTURE_COND_059 as "Super Str Rating",
	SUBSTRUCTURE_COND_060 as "Sub Str Rating",
	round(power(DECK_COND_058*SUPERSTRUCTURE_COND_059*SUBSTRUCTURE_COND_060,0.333),1) as "Avg. Rating"
FROM nbi
JOIN States s ON nbi.STATE_CODE_001 = s.Code
WHERE   FACILITY_CARRIED_007 LIKE '%US 287%'
	AND STRUCTURE_TYPE_043B != 19
LIMIT 10


/* IDENTIFY BRIDGES WITH HIGHEST AVERAGE DAILY TRAFFIC */
SELECT DISTINCT
	STRUCTURE_NUMBER_008 as "Structure ID",
	FACILITY_CARRIED_007 as "Road Carried",
	s.State as "State",
	ADT_029 as "Average Daily Traffic",
	str.Structure_Type as "Structure Type"
FROM nbi
JOIN States s ON nbi.STATE_CODE_001 = s.Code
JOIN structure_type str on nbi.STRUCTURE_TYPE_043B = str.Code
WHERE   ADT_029 != 999999 -- Exclude nan values
	AND ADT_029 != 777777 -- Exclude nan values
ORDER by ADT_029 DESC
LIMIT 10


/* IDENTIFY BRIDGES WITH HIGHEST AVERAGE DAILY TRAFFIC WITH RATINGS BELOW 5.0 */
SELECT DISTINCT
	STRUCTURE_NUMBER_008 as "Structure ID",
	s.State as "State",
	FACILITY_CARRIED_007 as "Road Carried",
	ADT_029 as "Average Daily Traffic",
	str.Structure_Type as "Structure Type",
	round(power(DECK_COND_058*SUPERSTRUCTURE_COND_059*SUBSTRUCTURE_COND_060,0.333),1) as "Avg_Rating"
FROM nbi
JOIN States s ON nbi.STATE_CODE_001 = s.Code
JOIN structure_type str on nbi.STRUCTURE_TYPE_043B = str.Code
WHERE     ADT_029 != 999999  -- Exclude nan value
      AND ADT_029 != 777777  -- Exclude nan value
	  AND Avg_Rating < 5.0
	  AND Avg_Rating > 0.0
	  AND STRUCTURE_TYPE_043B != 19
	  AND DECK_COND_058 != "NULL"
ORDER by ADT_029 DESC
LIMIT 10

/* IDENTIFY ALL MOVABLE BRIDGES WITH AN AVERAGE BRIDGE RATING LESS THAN 5.0
   SORT BY BRIDGE TYPE AND AGE OF STRUCTURE
   REPORT MAX SPAN LENGTH, PIER PROTECTION, BRIDGE RATINGS, AND MOST RECENT
    IMPROVEMENT
*/
SELECT
	str.Structure_Type,
	States.State,
	FACILITY_CARRIED_007 as "Road Carried",
	FEATURES_DESC_006A as "Feature Crossed",
	2024 - YEAR_BUILT_027 as Age,
	round(MAX_SPAN_LEN_MT_048*3.2808, 1) as "Max Span Length (ft)", -- Convert span length to feet
	pp.Description as "Pier Protection",
	DECK_COND_058 as "Deck Rating",
	SUPERSTRUCTURE_COND_059 as "Superstructure Rating",
	SUBSTRUCTURE_COND_060 as "Substructure Rating",
	SCOUR_CRITICAL_113 as "Scour Critical",
	round(power(DECK_COND_058*SUPERSTRUCTURE_COND_059*SUBSTRUCTURE_COND_060*SCOUR_CRITICAL_113,0.25),1) as "Avg_Rating",
	YEAR_OF_IMP_097 as "Last Improved"
FROM
	nbi
JOIN States ON nbi.STATE_CODE_001 = States.Code
JOIN structure_type str on nbi.STRUCTURE_TYPE_043B = str.Code
JOIN pier_protection as pp on nbi.PIER_PROTECTION_111 = pp.Code
WHERE  (STRUCTURE_TYPE_043B = 15
	 OR STRUCTURE_TYPE_043B = 16
	 OR STRUCTURE_TYPE_043B = 17)
	AND 0.0 < Avg_Rating
	AND Avg_Rating < 5.0
ORDER BY str.structure_type, AGE DESC