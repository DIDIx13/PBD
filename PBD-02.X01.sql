-- PBD-02.X01 
-- Exercice 1
-- a.
CREATE OR REPLACE PROCEDURE liste_camps IS
    v_nb_inscrits NUMBER;
    v_lieu VARCHAR2(100);

    CURSOR c_camps IS
        SELECT COUNT(inscrits.numero) AS nb_inscrits, camps.lieu
        FROM camps
        LEFT JOIN inscrits ON inscrits.num_camp = camps.numero
        GROUP BY camps.lieu
        ORDER BY camps.lieu;

BEGIN
    OPEN c_camps;
    LOOP
        FETCH c_camps INTO v_nb_inscrits, v_lieu;
        EXIT WHEN c_camps%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_lieu || ' ' || v_nb_inscrits);
    END LOOP;
    CLOSE c_camps;
END;

EXEC liste_camps;

-- b.

CREATE OR REPLACE PROCEDURE liste_camps IS
    CURSOR c_camps IS
        SELECT COUNT(inscrits.numero) AS nb_inscrits, camps.lieu
        FROM camps
        LEFT JOIN inscrits ON inscrits.num_camp = camps.numero
        GROUP BY camps.lieu
        ORDER BY camps.lieu;

BEGIN
    FOR rec IN c_camps LOOP
        DBMS_OUTPUT.PUT_LINE(rec.lieu || ' ' || rec.nb_inscrits);
    END LOOP;
END;

EXEC liste_camps;

-- Exercice 2

CREATE OR REPLACE PROCEDURE liste_non_inscrits IS
    CURSOR c_non_inscrits IS
        SELECT eleves.nom, eleves.prenom, classes.code AS classe
        FROM eleves
        JOIN classes ON eleves.num_classe = classes.numero
        LEFT JOIN inscrits ON eleves.numero = inscrits.num_eleve
        WHERE classes.obligation = 'O' AND inscrits.num_eleve IS NULL
        ORDER BY eleves.nom;

BEGIN
    DBMS_OUTPUT.PUT_LINE('<NON_INSCRITS>');
    FOR rec IN c_non_inscrits LOOP
        DBMS_OUTPUT.PUT_LINE('  <NON_INSCRIT>');
        DBMS_OUTPUT.PUT_LINE('    <NOM>' || rec.nom || '</NOM>');
        DBMS_OUTPUT.PUT_LINE('    <PRENOM>' || rec.prenom || '</PRENOM>');
        DBMS_OUTPUT.PUT_LINE('    <CLASSE>' || rec.classe || '</CLASSE>');
        DBMS_OUTPUT.PUT_LINE('  </NON_INSCRIT>');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('</NON_INSCRITS>');
END;

EXEC liste_non_inscrits;

-- Exercice 3

CREATE OR REPLACE PROCEDURE liste_participants(
    p_num_camp NUMBER
) IS
    v_lieu VARCHAR2(100);
    v_prix NUMBER;
    v_obliges NUMBER := 0;
    v_facultatifs NUMBER := 0;

    CURSOR c_participants IS
        SELECT eleves.numero, eleves.nom, eleves.prenom, classes.code AS classe, classes.obligation
        FROM eleves
        JOIN classes ON eleves.num_classe = classes.numero
        JOIN inscrits ON eleves.numero = inscrits.num_eleve
        WHERE inscrits.num_camp = p_num_camp
        ORDER BY eleves.nom;

BEGIN
    -- Récupérer les informations du camp
    SELECT lieu, prix
    INTO v_lieu, v_prix
    FROM camps
    WHERE numero = p_num_camp;

    -- Afficher les informations du camp
    DBMS_OUTPUT.PUT_LINE('Lieu : ' || v_lieu);
    DBMS_OUTPUT.PUT_LINE('Prix : ' || v_prix);

    -- Afficher l'en-tête des participants
    DBMS_OUTPUT.PUT_LINE('-Mat.- -Nom- -Prénom- -Classe-');

    -- Afficher la liste des participants
    FOR rec IN c_participants LOOP
        DBMS_OUTPUT.PUT_LINE(rec.numero || ' ' || rec.nom || ' ' || rec.prenom || ' ' || rec.classe);

        IF rec.obligation = 'O' THEN
            v_obliges := v_obliges + 1;
        ELSE
            v_facultatifs := v_facultatifs + 1;
        END IF;
    END LOOP;

    -- Afficher les compteurs
    DBMS_OUTPUT.PUT_LINE('Nb de participants obligatoires : ' || v_obliges);
    DBMS_OUTPUT.PUT_LINE('Nb de participants facultatifs : ' || v_facultatifs);
    DBMS_OUTPUT.PUT_LINE('Total : ' || (v_obliges + v_facultatifs));
END;

EXEC liste_participants(1);

-- Exercice 4

CREATE OR REPLACE FUNCTION get_nb_inscriptions(
    p_num_camp NUMBER
) RETURN NUMBER IS
    v_nb_inscriptions NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_nb_inscriptions
    FROM inscrits
    WHERE num_camp = p_num_camp;

    RETURN v_nb_inscriptions;
END;

SELECT
    numero,
    lieu,
    prix,
    get_nb_inscriptions(p_num_camp => numero) AS nb_inscription
FROM camps;