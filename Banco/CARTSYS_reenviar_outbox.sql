SET SQL DIALECT 3;
SET NAMES UTF8;

-- Devolve à fila uma venda cujo envio encerrou (status 3).
-- Troque o 0 pelo ID da venda. STATUS 1 = pendente.
-- Só zerar TENTATIVAS não basta: o Vendas ignora status 3.
--
-- isql -q -i CARTSYS_reenviar_outbox.sql localhost:C:\CartSys\Database\CARTSYS.FDB -user SYSDBA -password masterkey

UPDATE EMAIL_OUTBOX
   SET TENTATIVAS = 0,
       STATUS = 1,
       ULTIMO_ERRO = NULL
 WHERE VENDA_ID = 0
   AND STATUS = 3
   AND DT_ENVIO IS NULL;
