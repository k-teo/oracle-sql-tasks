/*  Task 1. Find the names of enemies who participated in incidents in 2009. */
SELECT enemy_name "Enemy", incident_desc "Fault description"
  FROM Incidents
 WHERE EXTRACT(YEAR FROM incident_date) = 2009;

/*  Task 2. Find all females cats who joined the herd between September 1, 2005. and July 31, 2007. */
SELECT name "Name", function "Function", TO_CHAR(in_herd_since, 'YYYY-MM-DD') "With us from"
  FROM Cats 
 WHERE gender = 'W' 
   AND in_herd_since BETWEEN TO_DATE('2005-09-01', 'YYYY-MM-DD') AND TO_DATE('2007-08-01', 'YYYY-MM-DD'); 

/*  Task 3. Display the names, species and degrees of hostility of incorruptible enemies. 
    Results sort in ascending order of hostility degree. */
SELECT enemy_name "Enemy", species "Species", hostility_degree "Hostility degree"
  FROM Enemies
 WHERE bride IS NULL
 ORDER BY hostility_degree;

/*  Task 4. Display data on male cats collected in one column of the form:
    JACEK called CAKE (fun. CATCHING) has been catching mice in band 2 since 2008-12-01
    The results should be ordered in descending order date entry to the herd. In the case 
    of the same date joining the herd, sort the results alphabetically by nickname. */
SELECT name || ' called ' || nickname || ' (fun. ' || function || ') has been catching mice in band ' || band_no || ' since ' || TO_CHAR(in_herd_since, 'YYYY-MM-DD') "ALL_ABOUT_MALE_CATS"
  FROM Cats
 WHERE gender = 'M'
 ORDER BY in_herd_since DESC, nickname;

/*  Task 5. Find the first occurrence of the letter A and the first occurrence of the letter L in each nickname 
    and then replace the letters found with # and %, respectively. Use functions that work on strings. 
    Only consider nicknames that contain both letters. */
SELECT nickname, REGEXP_REPLACE(REGEXP_REPLACE(nickname, 'A', '#', 1, 1), 'L', '%', 1, 1) "After replacing A nad L" 
  FROM Cats
 WHERE nickname LIKE '%A%L%' 
    OR nickname LIKE '%L%A%';


/*  Task 6. Display the names of cats with at least 11 years of experience 
    (which additionally joined the herd from March 1 to September 30), dates of their joining the herd, initial ration of mice 
    (current ration, due to its increase after half a year of joining of cat to the herd, is 10% higher than the initial ration), 
    the date of the mentioned increase by 10% and the current mice ration. Use appropriate functions working on dates. 
    In the solution presented below, the current date is 04.04.2020. */
SELECT name, TO_CHAR(in_herd_since, 'YYYY-MM-DD') "In herd",ROUND(mice_ration * 0.9) "Ate", TO_CHAR(ADD_MONTHS(in_herd_since, 6), 'YYYY-MM-DD') "Increase", mice_ration "Eat"
  FROM Cats
 WHERE in_herd_since <= ADD_MONTHS(SYSDATE /*EXAMPLE: TO_DATE('2020/04/04', 'YYYY/MM/DD')*/, -132) 
   AND EXTRACT(MONTH FROM in_herd_since) BETWEEN 3 AND 9
 ORDER BY mice_ration DESC;


/*  Task 7. Display names, quarterly mice rations, and quarterly rations extra of all cats in which the ration of mice 
    is greater than twice the ration extra but not smaller than 55. */
SELECT name, NVL(mice_ration * 3, 0) "MICE QUARTERLY", NVL(mice_extra * 3, 0) "EXTRA QUARTERLY"
  FROM Cats
 WHERE mice_ration >= 55 
   AND mice_ration > NVL(mice_extra, 0) * 2
 ORDER BY 2 DESC, 1;


/*  Task 8. Display for each cat (name) the following information about the total annual consumption of mice: 
    the value of total consumption if it exceeds 660, 'Limit' if it is equal to 660, 'Below 660' 
    if it is less than 660. Do not use set operators (UNION , INTERSECT, MINUS). */
SELECT name, DECODE(FLOOR((mice_ration+NVL(mice_extra, 0)) * 12 / 660), 0, 'Below 660', 
             DECODE(CEIL((mice_ration+NVL(mice_extra, 0)) * 12 / 660), 1, 'Limit', ((mice_ration+NVL(mice_extra, 0)) * 12) )) "Eats annually"
  FROM Cats
 ORDER BY name;


/*  Task 9. After a few months suspending the issuance of mice, caused by the crisis,  
    the Tiger resumed today payments on a  in accordance with the principle that cats that joined the herd in the first half of the month (with15 day) 
    receive the first ration of mice (after the break) on last Wednesday of this month, while cats that joined the herd after 15 day of the month receive 
    their first ration of mice (after the break) on the last Wednesday of the next month. In the following months, mice are issued to all cats 
    on the last Wednesday of  month. Display for each cat its nickname, date of entry to the herd and date of the first ration of mice after the break, 
    assuming that the current date is October 27 and 29, 2020. */
SELECT nickname, in_herd_since "IN HERD", DECODE(FLOOR(EXTRACT(DAY FROM in_herd_since)/16), 
                                      0, DECODE(FLOOR(EXTRACT(DAY FROM (NEXT_DAY(LAST_DAY (TO_DATE(10, 'MM')) - 7, TO_CHAR(TO_DATE('10-02-1999', 'DD-MM-YYYY'),'DAY'))))
                                                /EXTRACT( DAY FROM TO_DATE('27-10-2020' /*'29-10-2020'*/, 'DD-MM-YYYY'))), 
                                         0, NEXT_DAY(LAST_DAY (TO_DATE(10 + 1, 'MM')) - 7, TO_CHAR(TO_DATE('10-02-1999', 'DD-MM-YYYY'),'DAY')),
                                            NEXT_DAY(LAST_DAY (TO_DATE(10, 'MM')) - 7, TO_CHAR(TO_DATE('10-02-1999', 'DD-MM-YYYY'),'DAY'))),
                                        NEXT_DAY(LAST_DAY (TO_DATE(10+1, 'MM')) - 7, TO_CHAR(TO_DATE('10-02-1999', 'DD-MM-YYYY'),'DAY'))) "PAYMENT"

  FROM Cats
 ORDER BY 2;

/*  Task 10. Attribute named nickname in the Cats table is the primary key of this table. 
    Check if all the nicknames are really different. Do the same for the attribute named chief. */
SELECT nickname || DECODE(1, COUNT(*), ' - unique', ' - non-unique') "Uniqueness of the nickname"
  FROM Cats
 GROUP BY nickname
 ORDER BY 1;

SELECT chief || DECODE(1, COUNT(*), ' - unique', ' - non-unique') "Uniqueness of the nickname"
  FROM Cats
 WHERE chief IS NOT NULL
 GROUP BY chief
 ORDER BY 1;


/*  Task 11. Find nicknames of cats with at least two enemies. */
SELECT nickname, COUNT(DISTINCT enemy_name) "Number of enemies" 
  FROM Incidents
 GROUP BY nickname
HAVING COUNT(enemy_name) > 1
 ORDER BY 1;


/*  Task 12. Find the maximum total ration (total ration = sum of mice ration and mice extra) of mice for all function groups 
    (excluding BOSS function and male cats) in which have an average total ration of mice greater than 50. */
SELECT 'Number of cats = ' || COUNT(*) ||' as ' || function || ' and eats max. ' || MAX(mice_ration + NVL(mice_extra, 0)) || ' mice per month' " "
  FROM Cats
 WHERE function != 'BOSS' and gender != 'M'
 GROUP BY function
HAVING AVG(mice_ration + NVL(mice_extra, 0)) > 50
 ORDER BY 1;


/*  Task 13. Display the minimum ration of mice for each band by gender. */
SELECT band_no "Band no", gender "Gender", MIN(mice_ration) "Minimum ration"
  FROM Cats
 GROUP BY band_no, gender;   


/*  Task 14. Display information about male cats having in the hierarchy of superiors the male chief with function THUG 
    (also display the data of this supervisor). The data of cats subordinate to a particular chief are to be displayed 
    according to their place in the hierarchy of subordination. */
 SELECT level, nickname, function, band_no
   FROM Cats
  WHERE gender = 'M' 
CONNECT BY PRIOR nickname = chief
  START WITH function IN ('THUG');


/*  Task 15. Present information about the subordination of cats possessing an extra payment (mice_extra) so that 
    the name of the cat standing highest in the hierarchy is displayed with the smallest indentation and the remaining
    names with the indentation appropriate to the place in the hierarchy. */
 SELECT DECODE(level, 1, '0          ',
                      2, '===>1          ',
                      3, '===>===>2          ') || name "Hierarchy", 
        NVL(chief, 'Master yourself') "Nickname of the chief", function
   FROM Cats
  WHERE mice_extra IS NOT NULL
CONNECT BY PRIOR nickname = chief
  START WITH function IN ('BOSS');


/*  Task 16. Display the path of all chiefs  specified by nicknames, from concrete cat nickname through all successive superiors 
    to the main chief. Do it for male cats, without mice extra, belonging to herd more than eleven years 
    (in the solution below, the current date is assumed  as 06.04.2020). */
 SELECT DECODE(level, 1, nickname,
                      2, '     ' || nickname,
                      3, '          ' || nickname) "Path of chiefs"
   FROM Cats
CONNECT BY nickname = PRIOR chief 
  START WITH ADD_MONTHS(TO_DATE('2020/04/06', 'YYYY/MM/DD'), -132) >= in_herd_since AND gender = 'M' AND mice_extra IS NULL;

 SELECT SYS_CONNECT_BY_PATH('', '==>') || (level - 1) || '      ' || name "HIERARCHY_GROUP", NVL(chief, 'master') "nickname of chief", function 
   FROM Cats 
  WHERE mice_extra IS NOT NULL 
CONNECT BY PRIOR nickname = chief
  START WITH function IN ('BOSS');

/*  Task 17. Display nicknames, rations of mice and band names for cats with a ration of mice 
    greater than 50 which operate in FIELD area. Take into account the fact that there are cats 
    with the right to hunt in the whole area "served" by the herd. Do not use subqueries. */
SELECT C.nickname "Hunts in the field", C.mice_ration "Ration of mice", B.name "Band"
  FROM Cats C 
  JOIN Bands B 
    ON C.band_no = B.band_no
 WHERE C.mice_ration > 50 
   AND B.site IN ('FIELD', 'WHOLE AREA')
 ORDER BY 2 DESC ;


/*  Task 18. Display, without using a subquery, the names and dates of joining the herd of cats 
    that joined the herd before the cat named "JACEK". Sort the results descending by date of joining the herd. */
SELECT C2.name "Name", TO_CHAR(c2.in_herd_since, 'YYYY-MM-DD') "Hunt since"
  FROM Cats C1 
  JOIN Cats C2 
    ON C1.name = 'JACEK'
 WHERE C1.in_herd_since > C2.in_herd_since
 ORDER BY 2 DESC;