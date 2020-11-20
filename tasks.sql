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
