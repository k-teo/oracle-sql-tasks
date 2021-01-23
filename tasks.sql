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


/*  Task 19. For cats with function CAT and NICE, display the names of all their chiefs in order compatible of their hierarchy. 
    Solve the task on three ways: */ 

/*  a)	using only joins */
SELECT C.name  "Name", C.function "Function", NVL(C1.name, ' ') "Chief 1", NVL(C2.name, ' ') "Chief 2", NVL(C3.name, ' ') "Chief 3"
  FROM Cats C 
  LEFT JOIN CATS C1 
    ON C.chief = C1.nickname 
  LEFT JOIN Cats C2 
    ON C1.chief = C2.nickname 
  LEFT JOIN Cats C3 
    ON C2.chief = C3.nickname
 WHERE C.function IN ('CAT', 'NICE');
    
/*  b)	using a tree with CONNECT_BY_ROOT operator and pivot tables */
SELECT name, function, NVL(chief1, ' ') "Chief 1", NVL(chief2, ' ') "Chief 2", NVL(chief3, ' ') "Chief 3"
  FROM 
       (SELECT name, function, level AS lvl, CONNECT_BY_ROOT name AS roots
          FROM Cats 
         WHERE function IN ('CAT', 'NICE')
       CONNECT BY chief = PRIOR nickname)
 PIVOT
       (MAX(roots) 
        FOR lvl
         IN (2 AS chief1, 3 AS chief2, 4 AS chief3));

/*  c)	using the tree with CONNECT_BY_ROOT operator and  SYS_CONNECT_BY_PATH function */
SELECT M.name, M.function, M.chiefs
  FROM
       (SELECT name, function, ' | ' || REVERSE(LTRIM(SYS_CONNECT_BY_PATH(REVERSE(name), ' | '), ' | ') ) AS chiefs, LEVEL AS lvl
          FROM Cats
         WHERE function IN ('CAT', 'NICE')
       CONNECT BY PRIOR nickname = chief) M
WHERE lvl = 
       (SELECT MAX(lvl)
          FROM
               (SELECT name, function, LEVEL AS lvl
                FROM Cats
                WHERE function IN ('CAT', 'NICE')
                CONNECT BY PRIOR nickname = chief)
        WHERE name = M.name
        GROUP BY name);


/*  Task 20. Display the names of all the female cats who participated in the incidents after 01.01.2007. 
    Additionally, display the names of the bands to which the female cats belong, names of their enemies 
    along with their degree of hostility and date of the incident. */
SELECT C.name "Name of female cat", B.name "Band name", I.enemy_name "Enemy name", E.hostility_degree "Enemy rating", 
       TO_CHAR(I.incident_date, 'YYYY-MM-DD') "Incident date"
  FROM Cats C, Bands B, Incidents I, Enemies E
 WHERE C.band_no = B.band_no 
   AND C.nickname = I.nickname 
   AND I.enemy_name = E.enemy_name 
   AND C.gender = 'W' 
   AND I.incident_date > TO_DATE('2007/01/01', 'YYYY/MM/DD')
 ORDER BY 1, 5;


/*  Task 21. Determine how many cats in each band have enemies. */
  WITH K AS 
      (SELECT C.nickname, B.name
         FROM Cats C 
         JOIN bands B 
           ON C.band_no = B.band_no)
SELECT K.name, Count(DISTINCT K.nickname)
  FROM K LEFT JOIN Incidents I ON K.nickname = I.nickname
 WHERE I.enemy_name IS NOT NULL
 GROUP BY K.name;


/*  Task 22. Find cats (with their functions) that have more than one enemy. */
WITH K AS
    (SELECT C.nickname, COUNT(I.enemy_name) AS Enemies
       FROM Cats C 
       LEFT JOIN Incidents I 
         ON C.nickname = I.nickname
      GROUP BY C.nickname)
SELECT C.function, K.nickname, K.enemies
  FROM K 
  JOIN Cats C 
    ON K.nickname = C.nickname
 WHERE K.enemies > 1;


/*  Task 23. Display the names of the cats that get the mice extra along with their total annual mouse consumption. 
    Additionally, if their annual ration of mice exceeds 864, display the text "above 864", if it is 864, the text "864", 
    if this ration is less than 864, the text "below 864". Sort the results in descending order of annual mouse dose. 
    Use the set operator UNION for the solution of task. */
SELECT name "Name", (mice_extra + mice_ration) * 12 "Annual dose", 'above 864' "Dose"
  FROM Cats 
 WHERE mice_extra IS NOT NULL 
   AND (mice_extra + mice_ration) * 12 > 864
 
 UNION ALL
 
SELECT name, (mice_extra + mice_ration) * 12, '864'
  FROM Cats 
 WHERE mice_extra IS NOT NULL 
   AND (mice_extra + mice_ration) * 12 = 864
   
 UNION ALL
 
SELECT name, (mice_extra + mice_ration) * 12, 'below 864'
  FROM Cats 
 WHERE mice_extra IS NOT NULL 
   AND (mice_extra + mice_ration) * 12 < 864
 ORDER BY 2 DESC;


/*  Task 24. Find bands that don't have members. Display their numbers, names and operating areas. 
    Solve the problem in two ways: without subqueries and set operators and using set operators. */
/*  Without subqueries and set operations */
SELECT B.band_no, B.name, B.site
  FROM Bands B 
  LEFT JOIN Cats C 
    ON B.band_no = C.band_no
 WHERE C.nickname IS NULL;

/*  With set operations */   
SELECT B.band_no, B.name, B.site
  FROM Bands B 
  LEFT JOIN Cats C 
    ON B.band_no = C.band_no
    
 MINUS
 
SELECT B.band_no, B.name, B.site
  FROM Bands B 
  JOIN Cats C 
    ON B.band_no = C.band_no;

/*  Task 25. Find cats whose ration of mice is not less than tripled the highest ration of cats 
    operating in ORCHARD performing the function NICE. Do not use the MAX function. */
SELECT C.name, C.function, C.mice_ration
  FROM Cats C 
  JOIN Bands B 
    ON (C.band_no = B.band_no)
 WHERE mice_ration >= (SELECT *
                         FROM (SELECT C.mice_ration
                                 FROM Cats C 
                                 JOIN Bands B 
                                   ON (C.band_no = B.band_no)
                                WHERE B.site IN ('ORCHARD', 'WHOLE AREA') 
                                  AND C.function = 'NICE'
                        ORDER BY 1 DESC)
                        WHERE ROWNUM = 1) * 3
   AND B.site IN ('ORCHARD', 'WHOLE AREA');
                    
/*  Task 26. Find the functions (apart from function BOSS) with which the highest and lowest average 
    total ration of mice is associated. Do not use set operators (UNION, INTERSECT, MINUS). */
SELECT function, average
  FROM (SELECT function, ROUND(AVG(mice_ration+NVL(mice_extra, 0))) AS average, COUNT(*) AS maxRow
          FROM Cats
         GROUP BY function
         ORDER BY 2)
 WHERE ROWNUM = 1 
    OR ROWNUM = maxRow;

/*  Task 27. Find cats occupying the first n places in terms of the total number of mice consumed 
    (cats with the same consumption occupy the same place!). Solve the task using the following three ways: */
/*  a)	using correlated subquery */
SELECT nickname, mice_ration + NVL(mice_extra, 0)
  FROM Cats
 WHERE mice_ration + NVL(mice_extra, 0) >= (SELECT DISTINCT  mice_ration + NVL(mice_extra, 0) AS mice
                                              FROM Cats
                                             ORDER BY 1 DESC
                                            OFFSET 5 ROWS
                                             FETCH NEXT 1 ROW ONLY)
ORDER BY 2 DESC;

    
/*  b)	using the ROWNUM pseudo-column */
SELECT nickname, mice_ration + NVL(mice_extra, 0)
  FROM Cats
 WHERE mice_ration + NVL(mice_extra, 0) IN 
       (SELECT *
          FROM(SELECT DISTINCT mice_ration + NVL(mice_extra, 0)
                 FROM Cats
                ORDER BY 1 DESC)
         WHERE ROWNUM <= 6);

/*  c)	using the join operation of Cats relation with Cats relation. */
SELECT C1.nickname, C1.mice_ration + NVL(C1.mice_extra, 0)
  FROM Cats C1 
  JOIN Cats C2 
    ON C2.nickname = (SELECT nickname
                        FROM Cats
                       WHERE mice_ration + NVL(mice_extra, 0) =
                                (SELECT DISTINCT mice_ration + NVL(mice_extra, 0)
                                   FROM Cats
                                  ORDER BY 1 DESC
                                 OFFSET 5 ROWS
                                  FETCH NEXT 1 ROW ONLY)
                       ORDER BY 1
                       FETCH NEXT 1 ROW ONLY)
 WHERE C1.mice_ration + NVL(C1.mice_extra, 0) >= C2.mice_ration + NVL(C2.mice_extra, 0)
 ORDER BY 2 DESC;

 
/*  */
SELECT nickname, mice_ration + NVL(mice_extra, 0)
  FROM Cats
 ORDER BY 2 DESC
 FETCH NEXT 6 ROWS WITH TIES;

/*  Task 28. Determine the years for which the number of entries to the herd is closest (from above and from below) 
    of the average number of entries for all years (the average of the values determining the number of entries in individual years). 
    Do not use views. */
WITH 
repetitions AS 
    (SELECT TO_CHAR(Y1) AS y, COUNT(*) AS re
       FROM (SELECT EXTRACT(YEAR FROM in_herd_since) AS Y1
               FROM Cats)
      GROUP BY Y1),
average AS
    (SELECT 'Average', ROUND(AVG(re), 7) AS av
       FROM repetitions),
bigger AS
    (SELECT R.y, R.re
       FROM repetitions R, average A
      WHERE R.re > A.av
      ORDER BY 2 
      FETCH NEXT 1 ROW WITH TIES ),
smaller AS
    (SELECT R.y, R.re
       FROM repetitions R, average A
      WHERE R.re < A.av
      ORDER BY 2 DESC
      FETCH NEXT 1 ROW WITH TIES ),
finalList AS
    (SELECT *
       FROM bigger
       
      UNION
      
     SELECT *
       FROM smaller
       
      UNION 
      
     SELECT *
       FROM average)
SELECT *
  FROM finalList
 ORDER BY 2;  


/*  Task 29. For male cats, for whom the total ration of mice does not exceed the average in their band, 
    determine the following data: name of cat, his total mice consumption, number of members of his band, 
    average of total consumption for his band. Do not use views. Solve task in three ways: */
SELECT C1.name "Name", MIN(C1.mice_ration + NVL(C1.mice_extra, 0)) "Eats", C1.band_no "Band no", TO_CHAR(AVG(C2.mice_ration + NVL(C2.mice_extra, 0))) "Average in band"
  FROM Cats C1 
  JOIN Cats C2 
    ON C1.band_no = C2.band_no
 WHERE C1.gender = 'M'
 GROUP BY C1.name, C1.band_no
HAVING MIN(C1.mice_ration + NVL(C1.mice_extra, 0)) < AVG(C2.mice_ration + NVL(C2.mice_extra, 0))
 ORDER BY 4;

/*  b)	with joining and the only subquery in the FROM clause */ 
SELECT C.name "Name", C.mice_ration + NVL(C.mice_extra, 0) "Eats", S.band_no "Band no", S.average "Average in Band"
  FROM Cats C 
  JOIN   
        (SELECT band_no, COUNT(*) AS amount, AVG(mice_ration + NVL(mice_extra, 0)) AS average
           FROM Cats
          GROUP BY band_no) S ON C.band_no = S.band_no
 WHERE C.mice_ration + NVL(C.mice_extra, 0) < S.average AND gender = 'M'
 ORDER BY 4;

/*  c)	without joining and with two subqueries: one in the SELECT clause and one in the WHERE clause. */   
SELECT C.name "Name", C.mice_ration "Eats", C.band_no "Band no", 
       (SELECT AVG(mice_ration + NVL(mice_extra, 0))
          FROM Cats
         WHERE C.band_no = band_no
         GROUP BY band_no) "Average in band"
  FROM Cats C
 WHERE (C.mice_ration + NVL(C.mice_extra, 0)) <
       (SELECT AVG(mice_ration + NVL(mice_extra, 0))
          FROM Cats
         WHERE C.band_no = band_no
         GROUP BY band_no)
   AND C.gender = 'M'
 ORDER BY 4;

/*  Task. 30. Generate a list of cats containing the cats with the longest and the shortest membership in their bands. Apply a set operator. */
SELECT C.name, TO_CHAR(in_herd_since, 'YYYY-MM-DD') || ' <--- SHORTEST TIME IN THE BAND ' || B.name  "THE DATE OF JOINING THE HERD" 
  FROM Cats C 
  JOIN Bands B 
    ON C.band_no = B.band_no 
 WHERE in_herd_since IN (SELECT MAX(in_herd_since) 
                           FROM Cats 
                          GROUP BY band_no) 
 
UNION ALL 
 
SELECT C.name, TO_CHAR(in_herd_since, 'YYYY-MM-DD') ||  ' <--- LONGEST TIME IN THE BAND ' || B.name 
  FROM Cats C 
  JOIN Bands B 
    ON C.band_no = B.band_no 
 WHERE in_herd_since IN (SELECT MIN(in_herd_since) 
                           FROM Cats 
                          GROUP BY band_no) 
 
UNION ALL 
 
SELECT name, TO_CHAR(in_herd_since, 'YYYY-MM-DD') 
  FROM Cats 
 WHERE in_herd_since NOT IN (SELECT MIN(in_herd_since) 
                             FROM Cats 
                             GROUP BY band_no) 
   AND in_herd_since NOT IN (SELECT MAX(in_herd_since) 
                             FROM Cats 
                             GROUP BY band_no) 
 ORDER BY 1

/*  Task. 31. Define the view choosing the following data: name of the band, average, maximum and minimum ration of mice in the band, 
    total number of cats in the band and number of cats in the band with extra ration. Using the defined view, select the following data about the cat, 
    whose nickname is provided interactively from the keyboard: nickname, name, function, ration of mice, minimum and maximum ration of mice in his band, 
    and the date of  joining the herd. Contents of the view: */
CREATE VIEW Mice_in_bands (band_name, average_cons, max_cons, min_cons, cat, cat_with_extra) AS 
SELECT B.name, AVG(mice_ration), MAX(mice_ration), MIN(mice_ration), COUNT(*), COUNT(mice_extra)    
  FROM Cats 
  JOIN Bands B USING(band_no)
 GROUP BY B.name;

SELECT * FROM Mice_in_bands;

/*declare nick varchar2(10); */

SELECT C.nickname, C.name, C.function, 'FROM ' || B.min_cons || ' TO ' || B.max_cons "CONSUMPTION LIMITS", C.in_herd_since "HUNT FROM"
  FROM Cats C 
  JOIN (SELECT band_no, band_name, max_cons, min_cons
          FROM Mice_in_bands 
          JOIN Bands 
            ON band_name = name) B 
            ON C.band_no = B.band_no
 WHERE C.nickname = '&nick';
                    

/*  Task 32. For three cats of longest memberships in the herd from combined bands BLACK KNIGHTS and PINTO HUNTERS  
    increase the allocation of mice by 10% of the minimum allocation in the entire herd or by 10 mice depending on 
    whether the increase applies to a female cat or a male cat. Ration of extra mice for these cats (of both genders) 
    ought to increase by 15% of the average ration extra in the cat's band. Display values before and after the increase 
    and then roll back the changes. */
CREATE VIEW Payment (nickname, gender, mice_ration, mice_extra,  band_no) AS 
SELECT C.nickname, C.gender, C.mice_ration, C.mice_extra, C.band_no 
  FROM Cats C  
  JOIN Bands B  
    ON C.band_no = B.band_no 
 WHERE B.name IN ('BLACK KNIGHTS', 'PINTO HUNTERS') 
   AND in_herd_since IN 
            (SELECT in_herd_since 
               FROM Cats  
              WHERE band_no = C.band_no 
              ORDER BY in_herd_since 
              FETCH NEXT 3 ROWS ONLY)

SELECT nickname, gender, mice_ration "Mice before pay increase", NVL(mice_extra, 0) "Extra before pay increase"
  FROM Payment;

UPDATE Payment
   SET mice_ration = mice_ration + DECODE(gender, 'W', 0.1 * (SELECT MIN(mice_ration) FROM Cats), 10),
       mice_extra = NVL(mice_extra, 0) + 0.15 * (SELECT AVG(NVL(mice_extra, 0)) 
                                                   FROM Cats 
                                                  WHERE Payment.band_no = band_no);

SELECT nickname, gender, mice_ration "Mice before pay increase", NVL(mice_extra, 0) "Extra before pay increase"
FROM Payment;

ROLLBACK;
DROP VIEW Payment;


/*  Task 33. Write a query that will calculate the sums of total mice consumption by cats performing each function, 
    broken down by cat's bands and genders. Summarize the rations for each function. Solve the task in two ways: */
/*  a)	using two (or three) SELECT queries and the DECODE function (or CASE) */
SELECT B.name, DECODE(C.gender, 'W', 'Female Cat', 'Male Cat') "GENDER", TO_CHAR(COUNT(*)) "HOW MANY",
       SUM(DECODE(C.function, 'BOSS', C.mice_ration + NVL(C.mice_extra, 0), 0)) "BOSS",
       SUM(DECODE(C.function, 'THUG', C.mice_ration + NVL(C.mice_extra, 0), 0)) "THUG",
       SUM(DECODE(C.function, 'CATCHING', C.mice_ration + NVL(C.mice_extra, 0), 0)) "CATCHING",
       SUM(DECODE(C.function, 'CATCHER', C.mice_ration + NVL(C.mice_extra, 0), 0)) "CATCHER",
       SUM(DECODE(C.function, 'CAT', C.mice_ration + NVL(C.mice_extra, 0), 0)) "CAT",
       SUM(DECODE(C.function, 'NICE', C.mice_ration + NVL(C.mice_extra, 0), 0)) "NICE",
       SUM(DECODE(C.function, 'DIVISIVE', C.mice_ration + NVL(C.mice_extra, 0), 0)) "DIVISIVE",
       (SUM(DECODE(C.function, 'BOSS', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'THUG', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'CATCHING', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'CATCHER', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'CAT', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'NICE', C.mice_ration + NVL(C.mice_extra, 0), 0))
       + SUM(DECODE(C.function, 'DIVISIVE', C.mice_ration + NVL(C.mice_extra, 0), 0))) "SUM"
  FROM Cats C 
  JOIN Bands B 
    ON C.band_no = B.band_no
 GROUP BY B.name, C.gender

 UNION ALL

SELECT 'Z Eats in total', ' ', ' ', SUM(BOSS), SUM(THUG), SUM(CATCHING), SUM(CATCHER), SUM(CAT), SUM(NICE), SUM(DIVISIVE), SUM(S)
  FROM 
       (SELECT B.name, C.gender, COUNT(*) "HOW MANY",
               SUM(DECODE(C.function, 'BOSS', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS BOSS,
               SUM(DECODE(C.function, 'THUG', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS THUG,
               SUM(DECODE(C.function, 'CATCHING', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS CATCHING,
               SUM(DECODE(C.function, 'CATCHER', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS CATCHER,
               SUM(DECODE(C.function, 'CAT', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS CAT,
               SUM(DECODE(C.function, 'NICE', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS NICE,
               SUM(DECODE(C.function, 'DIVISIVE', C.mice_ration + NVL(C.mice_extra, 0), 0)) AS DIVISIVE,
               (SUM(DECODE(C.function, 'BOSS', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'THUG', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'CATCHING', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'CATCHER', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'CAT', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'NICE', C.mice_ration + NVL(C.mice_extra, 0), 0))
               + SUM(DECODE(C.function, 'DIVISIVE', C.mice_ration + NVL(C.mice_extra, 0), 0))) AS "S"
          FROM Cats C JOIN Bands B ON C.band_no = B.band_no
         GROUP BY B.name, C.gender)
 ORDER BY 1, 2

/*  b)	using pivot tables */
SELECT B.name, DECODE(C.gender, 'W', 'Female Cat', 'Male Cat') "GENDER", TO_CHAR(COUNT(*)) "EATS", 
       NVL(SUM(boss), 0) "BOSS", 
       NVL(SUM(thug), 0) "THUG", 
       NVL(SUM(catching), 0) "CATCHING", 
       NVL(SUM(catcher), 0) "CATCHER", 
       NVL(SUM(cat), 0) "CAT", 
       NVL(SUM(nice), 0) "NICE", 
       NVL(SUM(divisive), 0) "DIVISIVE",
       NVL(SUM(boss), 0) + NVL(SUM(thug), 0) + NVL(SUM(catching), 0) + NVL(SUM(cat), 0) + NVL(SUM(catcher), 0) + NVL(SUM(nice), 0) + NVL(SUM(divisive), 0) "SUM"
  FROM 
       (SELECT * FROM Cats
         PIVOT
               (MAX(mice_ration+NVL(mice_extra,0)) FOR
               function IN ('BOSS' boss,'THUG' thug,'CATCHING' catching,'CATCHER' catcher,'CAT' cat, 'NICE' nice, 'DIVISIVE' divisive))) C
  JOIN Bands B 
    ON C.band_no = B.band_no
 GROUP BY B.name, gender

 UNION ALL

SELECT 'Z Eats in total', ' ', ' ', SUM(BOSS), SUM(THUG), SUM(CATCHING), SUM(CATCHER), SUM(CAT), SUM(NICE), SUM(DIVISIVE), SUM(S)
FROM
     (SELECT B.name, gender, COUNT(*), 
             NVL(SUM(boss), 0) AS BOSS, 
             NVL(SUM(thug), 0) AS THUG, 
             NVL(SUM(catching), 0) AS CATCHING, 
             NVL(SUM(cat), 0) AS CAT, 
             NVL(SUM(catcher), 0) AS CATCHER, 
             NVL(SUM(nice), 0) AS NICE, 
             NVL(SUM(divisive), 0) AS DIVISIVE,
             NVL(SUM(boss), 0) + NVL(SUM(thug), 0) + NVL(SUM(catching), 0) + NVL(SUM(cat), 0) + NVL(SUM(catcher), 0) + NVL(SUM(nice), 0) + NVL(SUM(divisive), 0) AS S
        FROM 
             (SELECT * 
                FROM Cats
               PIVOT (MAX(mice_ration+NVL(mice_extra,0)) 
                      FOR function 
                       IN ('BOSS' boss,'THUG' thug,'CATCHING' catching,'CATCHER' catcher,'CAT' cat, 'NICE' nice, 'DIVISIVE' divisive))) C
     JOIN Bands B 
       ON C.band_no = B.band_no
    GROUP BY B.name, gender)
 ORDER BY 1, 2;


/*  Task 34. Write a PL/SQL block that selects cats performing the function given on the keyboard. 
    The only effect of block operation is to be a message informing whether or not a cat performing 
    the given function has been found (if a cat is found, display the name of the appropriate function).*/  
    
DECLARE
    v_function Cats.function%TYPE := '&function';
    f Cats.function%TYPE;
BEGIN
    SELECT function
      INTO f
      FROM Cats
     WHERE function = v_function;
DBMS_OUTPUT.PUT_LINE(v_function || ' - function found once');
EXCEPTION
    WHEN TOO_MANY_ROWS THEN DBMS_OUTPUT.PUT_LINE(v_function || ' - function found more than once');
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(v_function || ' - function not found');
END;
/

/*  Task 35. Write a PL/SQL block that displays the following information about the cat with a nickname 
    entered from the keyboard (depending on the actual data):
    -	'total annual mice ration > 700'
    -	'name contains the letter A'
    -	'May is the month of joining the herd'
    -	'does not match the criteria'.
    The above information is listed according to its hierarchy of importance. Precede each entry with the cat's name.
*/

DECLARE
    v_nickname Cats.nickname%TYPE := '&nickname';
    cat Cats%ROWTYPE;
BEGIN
    SELECT *
      INTO cat
      FROM Cats
     WHERE nickname = v_nickname;
     
     DBMS_OUTPUT.PUT_LINE(cat.nickname);
     
     CASE
          WHEN ((cat.mice_ration + NVL(cat.mice_extra, 0)) * 12 > 700) THEN DBMS_OUTPUT.PUT_LINE(cat.name || ' Total annual mice ration > 700');
          WHEN (cat.name LIKE '%A%') THEN DBMS_OUTPUT.PUT_LINE(cat.name || ' Name contains the letter A');
          WHEN (EXTRACT(MONTH FROM cat.in_herd_since) = 5 ) THEN DBMS_OUTPUT.PUT_LINE(cat.name || ' May is the month of joining the herd');
          ELSE DBMS_OUTPUT.PUT_LINE(cat.nickname || ' Does not match any criteria');
      END CASE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(v_nickname);
                            DBMS_OUTPUT.PUT_LINE(cat.nickname || ' Does not match any criteria');
END;
/

/*  Task 36. Due to the high efficiency in hunting mice, SZEFUNIO decided to reward his subordinates. 
    So he announced that he increases the individual mice ration of each cat by 10%, in order from the cat 
    with the lowest ration to the cat with the highest ration. He also determined that the process of increasing 
    the mice rations should be completed when the sum of all rations of all cats exceeds 1050. If for a cat, 
    the mouse ration after the increase exceeds the maximum value due to the function (max_mice from the Functions relation), 
    the mouse allocation after the increase should be equal to this value (max_mice). Write a PL/SQL block with a cursor 
    that performs this task. The block is to operate until the sum of all rations actually exceeds 1050 
    (the number of "increase cycles" may be greater than 1 and thus the individual increase may be greater than 10%). 
    Display the sum of mouse rations on the screen after completing the task along with the number of 
    modifications in the Cats relation. Finally, roll back all changes. */
DECLARE
    CURSOR food 
        IS 
    SELECT nickname, mice_ration, max_mice
      FROM Cats 
      JOIN Functions 
     USING (function)
     ORDER BY mice_ration
       FOR UPDATE OF mice_ration;
     
    counter NUMBER := 0;
    sum_ration NUMBER := 0;
    current_cat food%ROWTYPE;
BEGIN
    OPEN food;
    
        LOOP
            FETCH food INTO current_cat;
            
            IF food%NOTFOUND = TRUE THEN
                CLOSE food;
                OPEN food;
                CONTINUE;
            END IF;
            
            SELECT SUM(mice_ration)
              INTO sum_ration
              FROM Cats;
            
            EXIT WHEN (sum_ration > 1050);
            
            IF current_cat.mice_ration * 1.1 < current_cat.max_mice THEN
                UPDATE Cats
                   SET mice_ration = 1.1 * mice_ration
                 WHERE nickname = current_cat.nickname;
                 counter := counter + 1;
            ELSIF current_cat.mice_ration < current_cat.max_mice THEN
                UPDATE Cats
                   SET mice_ration = current_cat.max_mice
                 WHERE nickname = current_cat.nickname;
                 counter := counter + 1;
            END IF;
        END LOOP;
    
    CLOSE food;
    DBMS_OUTPUT.PUT_LINE('Total ration ' || sum_ration || ' Changes - ' || counter);
END;
/

ROLLBACK;


/*  Task 37. Write a block that selects five cats with the highest total mouse allocation 
    using FOR loop with cursor. Display the result on the screen. */
DECLARE
    CURSOR food
        IS
    SELECT nickname, (mice_ration + NVL(mice_extra, 0)) AS eats
      FROM Cats
     ORDER BY 2 DESC
     FETCH NEXT 5 ROWS ONLY;
BEGIN
    DBMS_OUTPUT.PUT_LINE(RPAD('NAME', 10) || RPAD('|', 3) || 'EATS');
    DBMS_OUTPUT.PUT_LINE('----------------');
    FOR cat IN food LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(cat.nickname, 10) || RPAD('|', 3) || cat.eats);
    END LOOP;
END;
/

/*  Task 38. Write a block that will implement version a. or b. of task 19 in a universal way 
    (without having to take into account knowledge about the depth of the tree). The input value is 
    to be the maximum number of supervisors to display. */

DECLARE
    CURSOR cats_chief
        IS
    SELECT name, chief
      FROM Cats
     WHERE function = 'CAT' OR function = 'NICE'
     ORDER BY 2 DESC;
     header_row VARCHAR2(2000) := '';
     chief_row VARCHAR2(2000);
     break_row VARCHAR2(2000) := '----------';
     supervisors_num NUMBER := '&num';
     current_chief cats_chief%ROWTYPE;
     max_chief NUMBER := 0;
BEGIN
    header_row := RPAD('Name', 8) || RPAD('|', 3);
    FOR cat IN cats_chief LOOP
        current_chief := cat;
        FOR i IN 1..supervisors_num LOOP
            IF (i > max_chief) THEN
                    max_chief := i;
            END IF;
            SELECT name, chief
                  INTO current_chief
                  FROM Cats
                 WHERE nickname = current_chief.chief;
            EXIT WHEN current_chief.chief IS NULL;
        END LOOP;
    END LOOP;
    FOR j IN 1..max_chief LOOP
        header_row := header_row || 'Chief ' || RPAD(j, 2) || RPAD('|', 3);
        break_row := break_row || '-----------';
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(header_row);
    DBMS_OUTPUT.PUT_LINE(break_row);
    
    FOR cat IN cats_chief LOOP
        current_chief := cat;
        chief_row := RPAD(cat.name, 8);
        FOR i IN 1..max_chief LOOP
            IF current_chief.chief IS NOT NULL THEN
                SELECT name, chief
                  INTO current_chief
                  FROM Cats
                 WHERE nickname = current_chief.chief;
                chief_row := chief_row || RPAD('|', 3) || RPAD(current_chief.name, 8);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE(chief_row || RPAD('|', 3));
    END LOOP;
END;
/

/*  Task 39. Write a PL/SQL block loading three parameters representing the band number, band name and hunting site. 
    The script is to prevent entering existing parameter values by handling the appropriate exceptions. Entering 
    the band number <= 0 is also an exceptional situation. In the event of an exceptional situation, an appropriate 
    message should be displayed on the screen. If the parameters are correct, create a new band in the Bands relation. 
    The change should be roll backed at the end. */
CREATE 
UNIQUE INDEX unique_names 
    ON Bands(name);
DECLARE
    v_band_number NUMBER := '&band_num';
    v_band_name VARCHAR2(20) := '&name';
    v_hunting_site VARCHAR2(20) := '&site';
    is_unique NUMBER;
    error_message VARCHAR(200) := '';
    LOWER_THAN_ZERO EXCEPTION;
BEGIN
    IF (v_band_number <= 0) THEN 
        RAISE LOWER_THAN_ZERO;
    END IF;
    
    SELECT COUNT(*) 
      INTO is_unique 
      FROM Bands
     WHERE band_no = v_band_number;
    IF (is_unique > 0) THEN 
        error_message := v_band_number || ',';
    END IF;
    SELECT COUNT(*) 
      INTO is_unique 
      FROM Bands 
     WHERE name = v_band_name;
    IF (is_unique > 0) THEN 
        error_message := error_message || v_band_name || ', '; 
    END IF;
    SELECT COUNT(*) 
      INTO is_unique 
      FROM Bands 
     WHERE site = v_hunting_site;
    IF (is_unique > 0) THEN 
        error_message := error_message || v_hunting_site; 
    END IF;
    INSERT 
      INTO Bands 
    VALUES (v_band_number, v_band_name, v_hunting_site, NULL);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE(error_message || ' ' || 'Already exists');
    WHEN LOWER_THAN_ZERO THEN DBMS_OUTPUT.PUT_LINE('<= 0 !');
END;
/

ROLLBACK;

/*  Task 40. Convert block from Task 39 into a procedure named new_band, stored in the database. */
CREATE OR REPLACE PROCEDURE new_band(v_band_number IN Bands.band_no%TYPE, v_band_name IN Bands.name%TYPE, v_hunting_site IN Bands.site%TYPE)
    IS
        is_unique NUMBER;
        error_message VARCHAR(200) := '';
        LOWER_THAN_ZERO EXCEPTION;
    BEGIN
        IF (v_band_number <= 0) THEN 
            RAISE LOWER_THAN_ZERO;
        END IF;
        
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands
         WHERE band_no = v_band_number;
        IF (is_unique > 0) THEN 
            error_message := v_band_number || ', ';
        END IF;
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands 
         WHERE name = v_band_name;
        IF (is_unique > 0) THEN 
            error_message := error_message || v_band_name || ', '; 
        END IF;
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands 
         WHERE site = v_hunting_site;
        IF (is_unique > 0) THEN 
            error_message := error_message || v_hunting_site; 
        END IF;
        INSERT 
          INTO Bands 
        VALUES (v_band_number, v_band_name, v_hunting_site, NULL);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE(error_message || ' ' || 'Already exists');
        WHEN LOWER_THAN_ZERO THEN DBMS_OUTPUT.PUT_LINE('<= 0 !');
END new_band; 
/

---------------------
EXEC new_band(7,'PINTO HUNTERS','HILLOCK');
EXEC new_band(0,'NEW','CELLAR');
EXEC new_band(6,'NEW','CELLAR');

SELECT * 
  FROM Bands;


/*  Task 41. Define a trigger that ensures that the number of the new band will always be 1 greater than 
    the highest number of the existing band. Check the result of the trigger operation using the procedure from Task 40. */

CREATE OR REPLACE TRIGGER band_no_trigger
BEFORE INSERT
    ON Bands
   FOR EACH ROW
DECLARE 
    last_index Bands.band_no%TYPE;
BEGIN
    SELECT MAX(band_no)
      INTO last_index
      FROM Bands;
    :NEW.band_no := last_index + 1;
END;
/

---------------------
EXEC new_band(7,'NEW','CELLAR');

SELECT * 
  FROM Bands;
  
/*  Task 42. Female cats with function Nice decided to take care of their maters. So they hired IT to enter 
    the virus into the Tiger's system. Now, with every attempt to change the mice ration for Nice for a plus 
    (for minus there is no question at all) by a value less than 10% of the mice ration of Tiger, 
    the regret of Nice caused by this must be comforted by an increase of their ration by this value as well as 
    an increase in extra mice by 5. Additionally, Tiger is to be punished by the loss of these 10%. However, 
    if the increase is satisfactory for Nice, the Tiger ration extra of mice is to increase by 5.

    Propose two solutions of this task that will bypass the basic limitation for a row trigger activated 
    by a DML command, ie the inability to read or change the relation on which the operation (DML command) 
    activates this trigger. In the first (classic) solution, use several triggers and memory in the form 
    of a package specification dedicated to the task, in the second, use the COMPOUND trigger.

    Provide examples of how triggers work, and then remove any changes they make. */

--1
CREATE OR REPLACE PACKAGE virus_package AS
    tiger_ration Cats.mice_ration%TYPE;
    is_tiger_update NUMBER := 0;
    cat_function Cats.function%TYPE;
END;
/

CREATE OR REPLACE TRIGGER virus_bs_trigger
BEFORE UPDATE 
    OF mice_ration
    ON Cats
BEGIN
    SELECT mice_ration
      INTO virus_package.tiger_ration
      FROM Cats
     WHERE nickname = 'TIGER';
END;
/

CREATE OR REPLACE TRIGGER virus_ber_trigger
BEFORE UPDATE 
    OF mice_ration
    ON Cats
   FOR EACH ROW
  WHEN (NEW.function = 'NICE')
BEGIN
    virus_package.cat_function := 'NICE';
    IF (:NEW.mice_ration < :OLD.mice_ration) THEN
        :NEW.mice_ration := :OLD.mice_ration;
    ELSIF (:NEW.mice_ration - :OLD.mice_ration < 0.1 * virus_package.tiger_ration) THEN
        :NEW.mice_extra := :NEW.mice_extra + 5;
        virus_package.is_tiger_update := -1;
    ELSE
        virus_package.is_tiger_update := 1;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER virus_as_trigger
 AFTER UPDATE 
    OF mice_ration
    ON Cats
BEGIN
    IF (virus_package.cat_function = 'NICE') THEN
        virus_package.cat_function := 'BOSS';
        IF (virus_package.is_tiger_update = -1) THEN
            UPDATE Cats
               SET mice_ration = mice_ration * 0.9
             WHERE nickname = 'TIGER';
        ELSIF (virus_package.is_tiger_update = 1) THEN
            UPDATE Cats
               SET mice_extra = mice_extra + 5 
             WHERE nickname = 'TIGER';
        END IF;
        virus_package.is_tiger_update := 0;
    END IF;
END;
/


--2
CREATE OR REPLACE TRIGGER compound_virus_trigger
   FOR UPDATE 
    OF mice_ration
    ON Cats
  WHEN (NEW.function = 'NICE')
COMPOUND TRIGGER
    tiger_ration Cats.mice_ration%TYPE;
    is_tiger_update NUMBER := 0;
   
    BEFORE STATEMENT IS
    BEGIN
        SELECT mice_ration
          INTO tiger_ration
          FROM Cats
         WHERE nickname = 'TIGER';
    END BEFORE STATEMENT;
   
    BEFORE EACH ROW IS
    BEGIN
        IF (:NEW.mice_ration < :OLD.mice_ration) THEN
            :NEW.mice_ration := :OLD.mice_ration;
        ELSIF (:NEW.mice_ration - :OLD.mice_ration < 0.1 * tiger_ration) THEN
            :NEW.mice_extra := :NEW.mice_extra + 5;
            is_tiger_update := -1;
        ELSE
            is_tiger_update := 1;
        END IF;
    END BEFORE EACH ROW;
   
    AFTER STATEMENT IS
    BEGIN
        IF (is_tiger_update = -1) THEN
            UPDATE Cats
               SET mice_ration = mice_ration * 0.9
             WHERE nickname = 'TIGER';
        ELSIF (is_tiger_update = 1) THEN
            UPDATE Cats
               SET mice_extra = mice_extra + 5 
             WHERE nickname = 'TIGER';
        END IF;
    END AFTER STATEMENT;
END compound_virus_trigger;

-----------------------------------
UPDATE Cats 
   SET mice_ration = mice_ration + 5
 WHERE nickname = 'MISS';  

UPDATE Cats 
   SET mice_ration = mice_ration + 16
 WHERE nickname = 'MISS';  
 
 UPDATE Cats 
   SET mice_ration = mice_ration - 5
 WHERE nickname = 'MISS';  

ROLLBACK;
DROP TRIGGER virus_bs_trigger;
DROP TRIGGER virus_ber_trigger;
DROP TRIGGER virus_as_trigger;
DROP TRIGGER compound_virus_trigger;

/*  Task 43. Write a block that will carry out Task 33 in a universal way 
    (without having to take into account knowledge of the functions performed by cats). */
DECLARE
    CURSOR bands_names
        IS
    SELECT band_no, name
      FROM Bands
     WHERE band_chief IS NOT NULL;
      
    CURSOR functions
        IS
    SELECT DISTINCT function
      FROM Cats;
      
      count_cats NUMBER;
      v_sum NUMBER;
      total_sum NUMBER;
      m_functions VARCHAR2(2000);
      f_functions VARCHAR2(2000);
      header_line VARCHAR2(2000);
      func_name VARCHAR2(200);
      last_line VARCHAR2(200);
BEGIN
    header_line := RPAD('NAME', 15) || RPAD('GENDER', 15) || RPAD('HOW MANY', 15);
    FOR func IN functions LOOP
        SELECT DISTINCT function
          INTO func_name
          FROM Cats
         WHERE function = func.function;
        header_line := header_line || RPAD(func_name, 15);
    END LOOP;
    header_line := header_line || RPAD('SUM', 15);
    DBMS_OUTPUT.PUT_LINE(header_line);
    
    FOR band IN bands_names LOOP
            f_functions := RPAD(band.name, 15);
        
            SELECT NVL(COUNT(*), 0)
              INTO count_cats
              FROM Cats
             WHERE band_no = band.band_no
               AND gender = 'W';
               
            f_functions := f_functions || RPAD('Female', 15) || RPAD(count_cats, 15);
               
            FOR func IN functions LOOP
                SELECT NVL(SUM(mice_ration + NVL(mice_extra, 0)), 0)
                  INTO v_sum
                  FROM Cats
                 WHERE function = func.function
                   AND band_no = band.band_no
                   AND gender = 'W';

                f_functions := f_functions || RPAD(v_sum, 15);
            END LOOP;
            
            SELECT NVL(SUM(mice_ration + NVL(mice_extra, 0)), 0)
              INTO v_sum
              FROM Cats
             WHERE band_no = band.band_no
               AND gender = 'W';
            
            f_functions := f_functions || RPAD(v_sum, 15);
            m_functions := RPAD(band.name, 15);
        
            SELECT NVL(COUNT(*), 0)
              INTO count_cats
              FROM Cats
             WHERE band_no = band.band_no
               AND gender = 'M';
               
            m_functions := m_functions || RPAD('Male', 15) || RPAD(count_cats, 15);
               
            FOR func IN functions LOOP
                SELECT NVL(SUM(mice_ration + NVL(mice_extra, 0)), 0)
                  INTO v_sum
                  FROM Cats
                 WHERE function = func.function
                   AND band_no = band.band_no
                   AND gender = 'M';

                m_functions := m_functions || RPAD(v_sum, 15);
                
            END LOOP;
            
            SELECT NVL(SUM(mice_ration + NVL(mice_extra, 0)), 0)
              INTO v_sum
              FROM Cats
             WHERE band_no = band.band_no
               AND gender = 'M';
               
            m_functions := m_functions || RPAD(v_sum, 15);
            
            DBMS_OUTPUT.PUT_LINE(f_functions);
            DBMS_OUTPUT.PUT_LINE(m_functions);
    END LOOP;
    
    last_line := RPAD('EATS IN TOTAL', 45);
    total_sum := 0;
    FOR func IN functions LOOP
        SELECT NVL(SUM(mice_ration + NVL(mice_extra, 0)), 0)
          INTO v_sum
          FROM Cats
         WHERE function = func.function;
        total_sum := total_sum + v_sum;
        last_line := last_line || RPAD(v_sum, 15);
    END LOOP;
    last_line := last_line || RPAD(total_sum, 15);
    DBMS_OUTPUT.PUT_LINE(last_line);
    
END;


/*  Task 44. The tiger was concerned about the inexplicable reduction in mice supplies. 
    So he decided to introduce a head tax that would top up the pantry. So he ordered 
    that every cat is obliged to donate 5% (rounded up) of their total mice income. In addition, from what will remain:
    - cats without subordinates give two mice for their incompetence during applying for promotion,
    - cats without enemies give one mouse for too much agreeableness,
    - cats pay an additional tax, the form of which is determined by the contractor of the task.
    Write a function whose parameter is the cat's nickname, determining the cat's head tax due. 
    This function together with the procedure from the Task 40 should be included 
    in the one package and then used to determine the tax for all cats. */

CREATE OR REPLACE PACKAGE taxes_package AS
     FUNCTION get_tax(cat_nickname Cats.nickname%TYPE) RETURN NUMBER;
    PROCEDURE new_band (v_band_number IN Bands.band_no%TYPE, v_band_name IN Bands.name%TYPE, v_hunting_site IN Bands.site%TYPE);
END; 
/

CREATE OR REPLACE PACKAGE BODY taxes_package IS 
FUNCTION get_tax(cat_nickname Cats.nickname%TYPE) RETURN NUMBER
AS
    sum_taxes NUMBER;
    counter NUMBER;
BEGIN
    SELECT ROUND(SUM(mice_ration+NVL(mice_extra,0)) * 0.05) 
      INTO sum_taxes
      FROM Cats 
     WHERE nickname = cat_nickname;
     
    SELECT COUNT(*) 
      INTO counter 
      FROM Cats 
     WHERE chief = cat_nickname;
     
    IF counter = 0 THEN 
        sum_taxes := sum_taxes + 2;
    END IF;
     
    SELECT COUNT(*) 
      INTO counter 
      FROM Cats C 
      JOIN Incidents I 
        ON C.nickname = I.nickname 
     WHERE C.nickname = cat_nickname;
       
    IF counter = 0 THEN 
        sum_taxes := sum_taxes + 1;
    END IF;
    RETURN sum_taxes;
END; 

PROCEDURE new_band (v_band_number IN Bands.band_no%TYPE, v_band_name IN Bands.name%TYPE, v_hunting_site IN Bands.site%TYPE)
    IS
        is_unique NUMBER;
        error_message VARCHAR(200) := '';
        LOWER_THAN_ZERO EXCEPTION;
    BEGIN
        IF (v_band_number <= 0) THEN 
            RAISE LOWER_THAN_ZERO;
        END IF;
        
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands
         WHERE band_no = v_band_number;
        IF (is_unique > 0) THEN 
            error_message := v_band_number || ', ';
        END IF;
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands 
         WHERE name = v_band_name;
        IF (is_unique > 0) THEN 
            error_message := error_message || v_band_name || ', '; 
        END IF;
        SELECT COUNT(*) 
          INTO is_unique 
          FROM Bands 
         WHERE site = v_hunting_site;
        IF (is_unique > 0) THEN 
            error_message := error_message || v_hunting_site; 
        END IF;
        INSERT 
          INTO Bands 
        VALUES (v_band_number, v_band_name, v_hunting_site, NULL);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN DBMS_OUTPUT.PUT_LINE(error_message || ' ' || 'Already exists');
        WHEN LOWER_THAN_ZERO THEN DBMS_OUTPUT.PUT_LINE('<= 0 !');
    END new_band; 
END;
/  

--------------
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('TIGER', 10)|| taxes_package.get_tax('TIGER'));
END;
/

/*  Task 45. The Tiger noticed strange changes in the value of his private mice ration (see Task 42). 
    He was not worried about the positive changes but those in the negative were, in his opinion, inadmissible. 
    So he motivated one of his spies to act and thanks to this he discovered Nice's evil practices (Task 42). 
    So he instructed his computer scientist to construct a mechanism which would write in the Extra_additions relation 
    (see Lectures - part 2)  -10 mice for each Nice (minus ten) when changing to plus any of the Nice mice ration made 
    by an operator other than he himself. Propose such a mechanism, in lieu of the computer scientist. In the solution 
    use the LOGIN_USER function (which returns the user name activating the trigger) and elements of dynamic SQL. */

CREATE TABLE Extra_additions(
    id NUMBER PRIMARY KEY,
    nickname VARCHAR2(15) CONSTRAINT fk_extra_cats REFERENCES Cats(nickname),
    mice_extra NUMBER
);
/

   CREATE SEQUENCE counter
    START WITH 1
INCREMENT BY 1;
/

CREATE OR REPLACE TRIGGER antivirus_trigger
 AFTER UPDATE OF mice_ration
    ON Cats
   FOR EACH ROW
  WHEN (OLD.function = 'NICE')
DECLARE
    login VARCHAR2(30) := LOGIN_USER;
BEGIN
    IF(:NEW.mice_ration > :OLD.mice_ration AND login <> 'TIGER') THEN
        INSERT 
        INTO Extra_additions 
        VALUES (counter.NEXTVAL, :OLD.nickname, -10);
    END IF;
END;
/

---------------------------
UPDATE Cats 
   SET mice_ration = mice_ration + 5
 WHERE nickname = 'MISS';  
 
SELECT *
  FROM Extra_additions;

DROP TABLE Extra_additions;
DROP TRIGGER antivirus_trigger;
DROP SEQUENCE counter;

/*  Task 46. Write a trigger which will prevent the cat from being allocated a number of mice outside the range 
    (min_mice, max_mice) specified for each function in the Functions relation. Each attempt to go beyond the applicable 
    range is to be additionally monitored in a separate relation (who, when, which cat, which operation). */

CREATE TABLE Mice_regulation(
    id NUMBER PRIMARY KEY,
    update_time DATE,
    nickname VARCHAR2(15) CONSTRAINT fk_regulation_cats REFERENCES Cats(nickname),
    is_upper_bound VARCHAR2(1) CONSTRAINT bound_nn NOT NULL
                               CONSTRAINT regulation_bound_ch CHECK (is_upper_bound IN ('T','F'))
);
/

CREATE SEQUENCE mice_regulation_id
    START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER mice_range_trigger
BEFORE UPDATE 
    OF mice_ration
    ON Cats
   FOR EACH ROW
DECLARE
   cat_ration Functions%ROWTYPE;
BEGIN
    SELECT function, min_mice, max_mice
      INTO cat_ration
      FROM Functions
     WHERE function = :OLD.function;
     
    IF (:NEW.mice_ration > cat_ration.max_mice) THEN
        
        :NEW.mice_ration := cat_ration.max_mice;
        INSERT 
          INTO Mice_regulation 
        VALUES (mice_regulation_id.NEXTVAL, SYSDATE, :OLD.nickname, 'T');
    ELSIF (:NEW.mice_ration < cat_ration.min_mice) THEN
        :NEW.mice_ration := cat_ration.min_mice;
        INSERT 
          INTO Mice_regulation 
        VALUES (mice_regulation_id.NEXTVAL, SYSDATE, :OLD.nickname, 'F');
    END IF;
END;
/

-----------------------
UPDATE Cats 
   SET mice_ration = 0
 WHERE nickname = 'BALD';  

UPDATE Cats 
   SET mice_ration = 300
 WHERE nickname = 'BALD';  

SELECT *
  FROM Mice_regulation;

ROLLBACK;

DROP TRIGGER mice_range_trigger;