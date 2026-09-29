# CartSys

Dois programas, ERP Vendas e ERP Financeiro, no mesmo banco Firebird 3. O Financeiro quita a venda. O e-mail do pedido sai pelo Vendas, e só enquanto esse programa estiver aberto.

```
CartSys/
├─ Banco/
│   ├─ CARTSYS_schema_firebird3.sql
│   ├─ CARTSYS_dados_teste.sql
│   ├─ CARTSYS_config_smtp_nome.sql
│   ├─ CARTSYS_reenviar_outbox.sql
│   └─ CartSys.ini.exemplo
├─ Comum/
├─ Vendas/          ERP_Vendas.dpr
├─ Financeiro/      ERP_Financeiro.dpr
└─ Docs/
```

## O que instalar

- Delphi 10.3, 12 ou 13, com FireDAC
- Firebird 3.0
- ReportBuilder, para o PDF do pedido e o relatório financeiro
- Indy, que já vem no Delphi

O TLS dessa versão do Indy usa OpenSSL 1.0.2 de 32 bits. Copie `libeay32.dll` e `ssleay32.dll` para a pasta do `ERP_Vendas.exe`. As DLLs `libssl-1_1` e `libcrypto-1_1` não servem aqui.

As grades são `TDBGrid`. O trial do DevExpress não compilou no Delphi 13 Community, então o projeto ficou no VCL nativo.

## Banco

No `CREATE DATABASE` de `Banco/CARTSYS_schema_firebird3.sql`, ajuste o caminho do `.fdb` e crie a base com o `isql` do Firebird 3:

```
isql -q -i CARTSYS_schema_firebird3.sql
```

Confira o usuário `SYSDBA`, a senha e se o serviço está no ar.

Se a Community recusar conexão por TCP, no INI use `Modo=Embedded` e deixe `fbclient.dll` (ou `fbembed.dll`) ao lado dos dois executáveis. Os dois abrem o mesmo `.fdb`.

Num banco criado antes da tela de e-mail, rode `Banco/CARTSYS_config_smtp_nome.sql` para criar `CONFIG_SMTP` ou acrescentar a coluna `NOME`. Se a tabela ou a coluna ainda não existirem, o Vendas também as cria ao abrir a tela.

## CartSys.ini

Copie `Banco/CartSys.ini.exemplo` para `CartSys.ini`. A busca começa na pasta do executável, aceita o nome do `.exe` com extensão `.ini` e sobe até três pastas.

`[Banco] Caminho` é o arquivo `.fdb`.

`[Totp] ChaveMestraBase64` são 32 bytes em Base64. Gere uma vez por instalação. A mesma chave confere o TOTP e decifra a senha do SMTP. Trocar depois quebra os dois. O valor do exemplo serve para desenvolvimento.

A seção `[Smtp]` do exemplo só é lida enquanto `CONFIG_SMTP` não tem linha. Depois do primeiro salvamento na tela, vale o banco, e a chave `Senha` some do INI que o Vendas carregou.

## E-mail da quitação

A configuração fica em Vendas, no botão E-mail (SMTP): servidor, porta, usuário, senha, TLS, nome do remetente e e-mail do remetente.

O nome é o que aparece no remetente e pode ter acento. O e-mail do remetente precisa ser um endereço, no formato `nome@provedor.com`. Se nesse campo entrar só um nome, a tela passa o texto para o nome e pede o endereço.

A senha vai cifrada para `CONFIG_SMTP.SENHA_CIFRADA`, com a chave mestra do TOTP. A tela não a mostra de novo. Campo em branco mantém a senha já salva.

No Gmail, a senha da conta (a do navegador) não funciona no SMTP. O Google pede uma senha de app: 16 caracteres, criados à parte, só para o programa.

1. Ative a verificação em duas etapas da conta, se ainda não estiver ativa.
2. Abra [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords) e crie uma senha para o CartSys.
3. Copie os 16 caracteres, sem espaços.
4. Na tela, usuário e e-mail do remetente são o Gmail. O nome é quem envia. A senha é a senha de app. Servidor `smtp.gmail.com`, porta `587`, Usar TLS marcado.
5. Use Enviar teste. Se a mensagem chegar, salve.

O teste não entra na fila. Ele só confere usuário, senha e TLS. Sem as duas DLLs do OpenSSL, a mensagem é que o OpenSSL não foi encontrado.

### Como a fila anda

Não há um serviço do Windows à parte. O processamento fica dentro do Vendas, depois do login. A fila é lida ao abrir o programa, quando o Firebird dispara o evento `VENDA_QUITADA`, e de novo a cada 60 segundos. Salvar a configuração de e-mail também dispara uma leitura na hora.

Na quitação (status 2 para 3), o trigger grava `EMAIL_OUTBOX` na mesma transação, com status 1 (pendente), e dispara o evento. Cancelar a venda não gera e-mail. Com o Vendas fechado, a linha espera no banco e sai na próxima abertura.

Só entra na leitura o que está pendente e com menos de 5 tentativas. O Vendas gera o PDF do pedido e manda para o e-mail do cliente.

SMTP ainda incompleto não conta tentativa: a linha segue pendente e, havendo alguma, o Vendas avisa uma vez. Falha de envio (senha recusada, servidor fora, DLL ausente) grava o texto em `ULTIMO_ERRO` e soma uma tentativa. Na quinta falha o status passa para 3 e essa linha deixa de ser lida. Cliente sem e-mail também vai para o status 3 na hora, com o erro de cliente sem e-mail cadastrado.

Uma linha já encerrada não volta sozinha. Para tentar de novo, ponha `STATUS` em 1 e `TENTATIVAS` em 0. O script `Banco/CARTSYS_reenviar_outbox.sql` faz isso; troque o `VENDA_ID` antes de executar.

## Primeiro usuário

Com a tabela `USUARIO` vazia:

```
ERP_Financeiro.exe /setup
```

Informe login, nome e, se quiser, e-mail. Anote a senha temporária e a chave TOTP. Esse usuário entra nos dois módulos.

## Login

Usuário e senha, depois o código de 6 dígitos do autenticador. No primeiro acesso a tela mostra a chave e a URI `otpauth://` para parear o aplicativo. Senha temporária pede troca antes de continuar.

Três erros seguidos, de senha ou de código, bloqueiam o usuário. O desbloqueio fica em Financeiro, em Usuários, e só o admin faz isso.

Sem `ACESSA_VENDAS` a pessoa não entra no Vendas. Sem `ACESSA_FINANCEIRO`, não entra no Financeiro.

## Uso

1. No Vendas, cadastre cliente e produto. O e-mail do cliente é o destino do pedido quitado.
2. Monte a venda, salve e confirme na lista. Confirmada, ela aparece no Financeiro como pendente e não se edita nem se exclui.
3. No Financeiro, quite ou cancele. Cancelar pede motivo. Quitar gera o recebimento e, se o cliente tiver e-mail, a linha da fila descrita acima.

## Relatórios e dashboard

A confirmação de pedido sai pela tela da venda ou pela lista. No Financeiro, a consulta por período imprime o relatório.

O dashboard mostra pendentes, quitadas, ticket médio, canceladas, barras de projetado e realizado, os cinco produtos e os cinco clientes de maior valor, e o total por forma de pagamento. Projetado é o que ainda está pendente. Realizado é o que já foi quitado. Essa tela não filtra período; o filtro fica na consulta financeira.

## Compilar

Abra `CartSys.groupproj` e compile os dois `.dpr`. Coloque o `CartSys.ini` onde a busca achar (pasta do executável ou até três níveis acima) e as DLLs do OpenSSL ao lado do `ERP_Vendas.exe`. Rode o `/setup` uma vez e depois abra os programas normalmente.

## Dados de teste

Com o administrador já criado:

```
isql -q -i Banco\CARTSYS_dados_teste.sql localhost:C:\CartSys\Database\CARTSYS.FDB -user SYSDBA -password masterkey
```

Troque o caminho se o `.fdb` estiver em outro lugar. O script não duplica o que já existe. Entram clientes e produtos com acento, vendas em digitação, pendentes, quitadas em meses diferentes (dinheiro, PIX, cartão e boleto) e uma cancelada.
