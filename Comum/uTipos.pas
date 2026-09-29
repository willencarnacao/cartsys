unit uTipos;

interface

type

  TVendaStatus = (vsEmDigitacao = 1, vsPendente = 2, vsQuitada = 3, vsCancelada = 4);

  TFormaPagamento = (fpDinheiro = 1, fpPix = 2, fpCartao = 3, fpBoleto = 4);

  TResultadoLogin = (
    rlSucesso           = 1,
    rlSenhaInvalida     = 2,
    rlCodigoTotpInvalido = 3,
    rlUsuarioBloqueado  = 4,
    rlBloqueioAplicado  = 5,
    rlDesbloqueioAdmin  = 6
  );

const
  MODULO_VENDAS     = 'VENDAS';
  MODULO_FINANCEIRO = 'FINANCEIRO';

  MAX_TENTATIVAS_LOGIN = 3;

  PBKDF2_ITERACOES_PADRAO = 210000;
  PBKDF2_TAMANHO_HASH     = 32;
  PBKDF2_TAMANHO_SALT     = 16;

  TOTP_PASSO_SEGUNDOS = 30;
  TOTP_DIGITOS        = 6;
  TOTP_TOLERANCIA_PASSOS = 2;

  TXT_CODIGO = 'C'#$00F3'digo';
  TXT_DESCRICAO = 'Descri'#$00E7#$00E3'o';
  TXT_PRECO = 'Pre'#$00E7'o';
  TXT_EM_DIGITACAO = 'Em digita'#$00E7#$00E3'o';
  TXT_CARTAO = 'Cart'#$00E3'o';
  TXT_CONFIRMACAO_PEDIDO = 'CartSys - Confirma'#$00E7#$00E3'o de pedido';
  TXT_PEDIDO_CABECALHO = 'Pedido n'#$00BA' %d    Emiss'#$00E3'o: %s';
  TXT_ENDERECO = 'Endere'#$00E7'o: ';
  TXT_REL_FINANCEIRO = 'CartSys - Relat'#$00F3'rio financeiro de vendas';
  TXT_PERIODO = 'Per'#$00ED'odo: %s a %s';
  TXT_SEM_DADOS_REL = 'N'#$00E3'o h'#$00E1' dados para imprimir. Busque o per'#$00ED'odo primeiro.';
  TXT_PEDIDO_NAO_ENCONTRADO = 'Pedido n'#$00E3'o encontrado.';

function ConverterStatusVenda(const peStatus: TVendaStatus): string;
function ConverterFormaPagamento(const peForma: TFormaPagamento): string;

implementation

function ConverterStatusVenda(const peStatus: TVendaStatus): string;
begin
  case peStatus of
    vsEmDigitacao: Result := TXT_EM_DIGITACAO;
    vsPendente:    Result := 'Pendente';
    vsQuitada:     Result := 'Quitada';
    vsCancelada:   Result := 'Cancelada';
  else
    Result := 'Desconhecido';
  end;
end;

function ConverterFormaPagamento(const peForma: TFormaPagamento): string;
begin
  case peForma of
    fpDinheiro: Result := 'Dinheiro';
    fpPix:      Result := 'PIX';
    fpCartao:   Result := TXT_CARTAO;
    fpBoleto:   Result := 'Boleto';
  else
    Result := 'Desconhecido';
  end;
end;

end.
