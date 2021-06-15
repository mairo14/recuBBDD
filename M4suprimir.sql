DELIMITER $$
	CREATE FUNCTION ComprobarTrigger() RETURNS int
		BEGIN 
				DECLARE unCodigo int;
				DECLARE unCodigo2 int;
				SELECT cod INTO unCodigo FROM citas_canceladas;
				SELECT cod INTO unCodigo2 FROM citas WHERE cod = unCodigo;
				IF unCodigo2 = unCodigo THEN RETURN 0;
				END IF;
				RETURN 1;
		END$$
//---------------------------------------------------------------------------------
CREATE TRIGGER borrarRegistro
AFTER
DELETE
ON citas_test FOR EACH ROW
BEGIN

		DECLARE done int default false;
		DECLARE cCod INT;
		DECLARE res int;
		DECLARE cDia date;
		DECLARE cHora time;
		DECLARE cLugar varchar(50);
		DECLARE cDescr varchar(200);
		DECLARE cCitas CURSOR FOR SELECT cod, dia, hora, lugar, descr FROM citas_test;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
		
		OPEN cCitas;
		readagain: LOOP
		FETCH cCitas INTO cCod, cDia, cHora, cLugar, cDescr;
		IF done THEN LEAVE readagain;
		END IF;
        	
		INSERT INTO citas (cod, dia, hora, lugar, descr) VALUES (cCod, cDia, cHora, cLugar, cDescr);
		END LOOP;
		CLOSE cCitas;
        
		INSERT INTO citas_canceladas (cod, dia, hora, lugar, descr) VALUES (old.cod, old.dia, old.hora, old.lugar, old.descr);
        
		SELECT ComprobarTrigger()  INTO res;
		INSERT INTO tests (tipo, fecha, resultado) VALUES ("delete", sysdate(), res);
            
		DELETE FROM citas WHERE cod > 0;
		DELETE FROM citas_canceladas WHERE cod > 0;
        	
END$$

DELIMITER ;