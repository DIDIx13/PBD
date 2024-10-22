--------------------------------------------------------
-- PBD-01.X01
--------------------------------------------------------
SET define OFF;
SET serveroutput ON;
--Ou dans SQLDeveloper : Menu Affichage>Sortie SGBD et connecter la sortie au schéma.
--------------------------------------------------------
-- Exercice 1
--------------------------------------------------------
BEGIN
 FOR i IN 1..10 LOOP
  IF Mod(i, 2) = 0 THEN
   Dbms_Output.put_line('P' || To_Char(i, '99'));
  ELSE
   Dbms_Output.put_line('I' || To_Char(i, '99'));
  END IF;
 END LOOP;
END;
/
--------------------------------------------------------
-- Exercice 2
--------------------------------------------------------
--Création de la table
CREATE TABLE heures(
 numero  NUMBER(10) CONSTRAINT pk_heures PRIMARY KEY,
 libelle VARCHAR2(20)
);
--Création de la séquence
CREATE SEQUENCE seq_heures;

--Bloc PL/SQL
DECLARE
 minutes_max INTEGER := 3;
 chaine      VARCHAR2(50);
BEGIN
 FOR heures IN 7..22 LOOP
  chaine := '';
  IF heures = 22 THEN
   minutes_max := 0;
  END IF;
  FOR minutes IN 0..minutes_max LOOP
   chaine := Trim(To_Char(heures, '09')) || 'h' || Trim(To_Char(15 * minutes, '09'));
   IF chaine = '12h00' THEN
    chaine := 'midi';
   END IF;
   INSERT INTO heures (numero, libelle)
   VALUES (seq_heures.Nextval, chaine);
  END LOOP;
 END LOOP;
END;
/

--Solution alternative avec des dates
DECLARE
 i DATE;
BEGIN
 i := To_Date('07:00', 'HH24:MI');
 WHILE i <= To_Date('22:00', 'HH24:MI')LOOP
  IF i = To_Date('12:00', 'HH24:MI') THEN
   INSERT INTO heures(numero, libelle)
   VALUES (seq_heures.nextval, 'midi');
  ELSE
   INSERT INTO heures (numero, libelle) 
   VALUES (seq_heures.nextval, To_Char(i, 'HH24') || 'h' || To_Char(i, 'MI'));
  END IF;
 i := i + 1/24/4;
 END LOOP;
END;

--------------------------------------------------------
-- Exercice 3
--------------------------------------------------------
CREATE OR REPLACE PROCEDURE PBD01X01_03(
 p_heure_debut IN NUMBER DEFAULT 7,
 p_heure_fin   IN NUMBER DEFAULT 22
) IS
 minutes_max INTEGER := 3;
 chaine      VARCHAR2(50);
BEGIN
 FOR heures IN p_heure_debut..p_heure_fin LOOP
  chaine := '';
  IF heures = p_heure_fin THEN
   minutes_max := 0;
  END IF;
  FOR minutes IN 0..minutes_max LOOP
   chaine := Trim(To_Char(heures,'09')) || 'h' || Trim(To_Char(15 * minutes,'09'));
   IF chaine = '12h00' THEN
    chaine := 'midi';
   END IF;
   INSERT INTO heures ( numero, libelle)
   VALUES (seq_heures.Nextval, chaine);
  END LOOP;
 END LOOP;
END PBD01X01_03;

/*Pour tester
 EXEC PBD01X01_03(p_heure_debut => 10, p_heure_fin => 14);
*/