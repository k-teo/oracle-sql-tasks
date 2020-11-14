CREATE TABLE Functions(
 function VARCHAR2(10) CONSTRAINT functions_function_pk PRIMARY KEY,
 min_mice NUMBER(3) CONSTRAINT functions_min_mice_ch CHECK (min_mice > 5),
 max_mice NUMBER(3),
 CONSTRAINT functions_max_mice_ch CHECK (max_mice<200 AND max_mice>=min_mice)
);

CREATE TABLE Enemies(
 enemy_name VARCHAR2(15) CONSTRAINT enemies_enemy_name_pk  PRIMARY KEY,
 hostility_degree NUMBER(2) CONSTRAINT enemies_hostility_degree CHECK (hostility_degree>=1 AND hostility_degree<=10), 
 species VARCHAR2(15),
 bride VARCHAR2(20)
);  

CREATE TABLE Cats (
 name VARCHAR2(15) CONSTRAINT cats_name_nn NOT NULL,
 gender VARCHAR2(1) CONSTRAINT cats_gender_nn NOT NULL
                    CONSTRAINT cats_gender_ch CHECK (gender IN ('M','W')),
 nickname VARCHAR2(15) CONSTRAINT cats_nickname_pk PRIMARY KEY,
 function VARCHAR2(10),
 chief VARCHAR2(15),
 in_herd_since DATE DEFAULT SYSDATE,
 mice_ration NUMBER(3),
 mice_extra NUMBER(3),         
 band_no NUMBER(2),
 CONSTRAINT cats_chief_fk FOREIGN KEY (chief) REFERENCES Cats (nickname),
 CONSTRAINT cats_function_fk FOREIGN KEY (function) REFERENCES Functions (function)
); 

CREATE TABLE Bands(
 band_no NUMBER(2) CONSTRAINT bands_band_no_pk PRIMARY KEY,
 name VARCHAR2(20) CONSTRAINT bands_name_nn NOT NULL,
 site VARCHAR2(15) UNIQUE,
 band_chief VARCHAR2(15) UNIQUE,
 CONSTRAINT bands_nad_chief_fk FOREIGN KEY (band_chief) REFERENCES Cats (nickname)
);

CREATE TABLE Incidents (
 nickname VARCHAR2(15),
 enemy_name VARCHAR2(15),
 incident_date DATE CONSTRAINT incidents_incident_date_nn NOT NULL,
 incident_desc VARCHAR2(50),
 CONSTRAINT incidents_com_pk PRIMARY KEY (nickname, enemy_name),
 CONSTRAINT incidents_nickname_fk FOREIGN KEY (nickname) REFERENCES Cats (nickname),
 CONSTRAINT incidents_enemy_name_fk FOREIGN KEY (enemy_name) REFERENCES Enemies (enemy_name)
);

ALTER TABLE Cats
ADD CONSTRAINT cats_bands_no_fk
FOREIGN KEY (band_no)
REFERENCES Bands (band_no);  