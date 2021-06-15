DELIMITER $$
	CREATE FUNCTION ComprobarTrigger() RETURNS int
		BEGIN 
				DECLARE unCodigo int;
        		DECLARE unCodigo2 int;
				SELECT count(cod) INTO unCodigo FROM citas_test;
        		SELECT count(cod) INTO unCodigo2 FROM citas;
        		IF unCodigo > unCodigo2 THEN RETURN unCodigo;
				END IF;
				RETURN 0;
		END$$
//-----------------------------------------------------------------------------------------------
CREATE TRIGGER insertarRegistro
AFTER
INSERT
ON citas_test FOR EACH ROW
BEGIN
			DECLARE done int default false;
			DECLARE cCod int;
			DECLARE res int;
			DECLARE cDia date;
			DECLARE cHora time;
			DECLARE cLugar varchar(50);
			DECLARE cDescr varchar(200);
			DECLARE cCitas CURSOR FOR SELECT cod, dia, hora, lugar, descr FROM citas_test;	
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

			readagain: LOOP
			FETCH cCitas INTO cCod, cDia, cHora, cLugar, cDescr;
			IF done THEN
			LEAVE readagain;
			END IF;
			IF cCodigo <> new.cod THEN
			INSERT INTO citas (cod, dia, hora, lugar, descr)
			VALUES (cCodigo, cDia, cHora, cLugar, cDescr);
			END IF;
			END LOOP;
            
			CLOSE cCitas;
			SELECT ComprobarTrigger() INTO res;
			INSERT INTO tests (tipo, fecha, resultado) VALUES ("insercion", sysdate(), res);
			DELETE FROM citas WHERE cod > 0;
END$$

DELIMITER ;