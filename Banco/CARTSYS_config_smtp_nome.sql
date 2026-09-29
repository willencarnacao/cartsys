SET SQL DIALECT 3;
SET NAMES UTF8;

-- Acrescenta CONFIG_SMTP.NOME (nome do remetente) numa base já criada.
--
-- isql -q -i CARTSYS_config_smtp_nome.sql localhost:C:\CartSys\Database\CARTSYS.FDB -user SYSDBA -password masterkey
-- Ajuste o caminho do .fdb se o seu for outro.

SET TERM ^ ;

EXECUTE BLOCK AS
BEGIN
  IF (NOT EXISTS (
        SELECT 1 FROM RDB$RELATIONS
         WHERE TRIM(RDB$RELATION_NAME) = 'CONFIG_SMTP')) THEN
  BEGIN
    EXECUTE STATEMENT
      'CREATE TABLE CONFIG_SMTP (' ||
      '  ID            SMALLINT NOT NULL,' ||
      '  SERVIDOR      VARCHAR(200) DEFAULT '''' NOT NULL,' ||
      '  PORTA         INTEGER DEFAULT 587 NOT NULL,' ||
      '  USUARIO       VARCHAR(200) DEFAULT '''' NOT NULL,' ||
      '  SENHA_CIFRADA VARCHAR(1000) DEFAULT '''' NOT NULL,' ||
      '  USAR_TLS      SMALLINT DEFAULT 1 NOT NULL,' ||
      '  REMETENTE     VARCHAR(200) DEFAULT '''' NOT NULL,' ||
      '  NOME          VARCHAR(120) DEFAULT '''' NOT NULL,' ||
      '  CONSTRAINT PK_CONFIG_SMTP PRIMARY KEY (ID))';
  END
  ELSE
  BEGIN
    IF (NOT EXISTS (
          SELECT 1 FROM RDB$RELATION_FIELDS
           WHERE TRIM(RDB$RELATION_NAME) = 'CONFIG_SMTP'
             AND TRIM(RDB$FIELD_NAME) = 'NOME')) THEN
    BEGIN
      EXECUTE STATEMENT
        'ALTER TABLE CONFIG_SMTP ADD NOME VARCHAR(120) DEFAULT '''' NOT NULL';
    END
  END
END^

SET TERM ; ^
