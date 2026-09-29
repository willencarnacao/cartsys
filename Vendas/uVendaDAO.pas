unit uVendaDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param, uTipos;

type
  TItemVenda = record
    ProdutoId: Int64;
    Quantidade: Double;
    PrecoUnit: Currency;
    Desconto: Currency;
    PercDesconto: Double;
  end;

  TVendaDAO = class
  private
    FoConexao: TFDConnection;
    procedure GarantirColunaPercDesconto;
    procedure RecalcularItens(piVendaId: Int64; const poItens: TArray<TItemVenda>);
  public
    constructor Create(poConexao: TFDConnection);
    function Listar(const psFiltro: string = ''): TFDQuery;
    function CarregarCabecalho(piVendaId: Int64): TFDQuery;
    function CarregarItens(piVendaId: Int64): TFDQuery;
    function Inserir(piClienteId, piUsuarioId: Int64; pdtVencimento: TDateTime;
      pnDesconto: Currency; const psObservacao: string;
      const poItens: TArray<TItemVenda>): Int64;
    procedure Atualizar(piVendaId, piClienteId: Int64; pdtVencimento: TDateTime;
      pnDesconto: Currency; const psObservacao: string;
      const poItens: TArray<TItemVenda>);
    procedure Confirmar(piVendaId: Int64);
    procedure Excluir(piVendaId: Int64);
    procedure CancelarDigitacao(piVendaId, piUsuarioId: Int64; const psMotivo: string);
  end;

implementation

uses
  Data.DB, System.Variants, uDados;

constructor TVendaDAO.Create(poConexao: TFDConnection);
begin
  inherited Create;
  FoConexao := poConexao;
  GarantirColunaPercDesconto;
end;

procedure TVendaDAO.GarantirColunaPercDesconto;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'SELECT 1 FROM RDB$RELATION_FIELDS ' +
      ' WHERE TRIM(RDB$RELATION_NAME) = ''VENDA_ITEM'' ' +
      '   AND TRIM(RDB$FIELD_NAME) = ''PERC_DESCONTO''';
    oQry.Open;
    if not oQry.IsEmpty then
      Exit;
  finally
    oQry.Free;
  end;
  FoConexao.ExecSQL(
    'ALTER TABLE VENDA_ITEM ADD PERC_DESCONTO NUMERIC(9,4) DEFAULT 0 NOT NULL');
end;

function TVendaDAO.Listar(const psFiltro: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT V.ID, C.NOME AS CLIENTE, V.DT_EMISSAO, V.STATUS, ' +
    '       CAST(CASE V.STATUS WHEN 1 THEN ''' + TXT_EM_DIGITACAO + ''' WHEN 2 THEN ''Pendente'' ' +
    '            WHEN 3 THEN ''Quitada'' WHEN 4 THEN ''Cancelada'' ELSE ''Desconhecido'' END ' +
    '            AS VARCHAR(20)) AS STATUS_DESC, ' +
    '       V.VL_TOTAL ' +
    '  FROM VENDA V ' +
    '  JOIN CLIENTE C ON C.ID = V.CLIENTE_ID ' +
    ' WHERE (CAST(:pTem AS INTEGER) = 0 OR UPPER(C.NOME) LIKE :pLike ' +
    '        OR CAST(V.ID AS VARCHAR(20)) = :pId) ' +
    ' ORDER BY V.ID DESC';
  Result.ParamByName('pTem').AsInteger := Ord(Trim(psFiltro) <> '');
  Result.ParamByName('pLike').AsString := '%' + UpperCase(Trim(psFiltro)) + '%';
  Result.ParamByName('pId').AsString := Trim(psFiltro);
  Result.Open;
end;

function TVendaDAO.CarregarCabecalho(piVendaId: Int64): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT V.ID, V.CLIENTE_ID, C.NOME AS CLIENTE, C.EMAIL, C.CPF_CNPJ, ' +
    '       C.LOGRADOURO, C.NUMERO, C.BAIRRO, C.CIDADE, C.UF, ' +
    '       V.USUARIO_ID, U.NOME AS VENDEDOR, V.DT_EMISSAO, V.DT_VENCIMENTO, ' +
    '       V.STATUS, V.VL_ITENS, V.VL_DESCONTO, V.VL_TOTAL, V.OBSERVACAO, ' +
    '       V.DT_CONFIRMACAO ' +
    '  FROM VENDA V ' +
    '  JOIN CLIENTE C ON C.ID = V.CLIENTE_ID ' +
    '  JOIN USUARIO U ON U.ID = V.USUARIO_ID ' +
    ' WHERE V.ID = :pId';
  Result.ParamByName('pId').AsLargeInt := piVendaId;
  Result.Open;
end;

function TVendaDAO.CarregarItens(piVendaId: Int64): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT I.ID, I.SEQ, I.PRODUTO_ID, P.CODIGO, P.DESCRICAO, P.UNIDADE, ' +
    '       I.QUANTIDADE, I.PRECO_UNIT, I.VL_DESCONTO, I.PERC_DESCONTO, I.VL_TOTAL ' +
    '  FROM VENDA_ITEM I ' +
    '  JOIN PRODUTO P ON P.ID = I.PRODUTO_ID ' +
    ' WHERE I.VENDA_ID = :pId ' +
    ' ORDER BY I.SEQ';
  Result.ParamByName('pId').AsLargeInt := piVendaId;
  Result.Open;
end;

procedure TVendaDAO.RecalcularItens(piVendaId: Int64; const poItens: TArray<TItemVenda>);
var
  oQry: TFDQuery;
  iItem: Integer;
begin
  if Length(poItens) = 0 then
    raise EArgumentException.Create('Informe ao menos um item.');

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'DELETE FROM VENDA_ITEM WHERE VENDA_ID = :pVenda';
    oQry.ParamByName('pVenda').AsLargeInt := piVendaId;
    oQry.ExecSQL;

    oQry.SQL.Text :=
      'INSERT INTO VENDA_ITEM (VENDA_ID, SEQ, PRODUTO_ID, QUANTIDADE, PRECO_UNIT, VL_DESCONTO, PERC_DESCONTO) ' +
      'VALUES (:pVenda, :pSeq, :pProd, :pQtd, :pPreco, :pDesc, :pPerc)';
    for iItem := 0 to High(poItens) do
    begin
      if poItens[iItem].Quantidade <= 0 then
        raise EArgumentException.Create('Quantidade precisa ser maior que zero.');
      if poItens[iItem].PrecoUnit < 0 then
        raise EArgumentException.Create('Pre'#$00E7'o unit'#$00E1'rio inv'#$00E1'lido.');
      if poItens[iItem].Desconto < 0 then
        raise EArgumentException.Create('Desconto do item n'#$00E3'o pode ser negativo.');

      oQry.ParamByName('pVenda').AsLargeInt := piVendaId;
      oQry.ParamByName('pSeq').AsInteger := iItem + 1;
      oQry.ParamByName('pProd').AsLargeInt := poItens[iItem].ProdutoId;
      oQry.ParamByName('pQtd').AsFloat := poItens[iItem].Quantidade;
      oQry.ParamByName('pPreco').AsCurrency := poItens[iItem].PrecoUnit;
      oQry.ParamByName('pDesc').AsCurrency := poItens[iItem].Desconto;
      oQry.ParamByName('pPerc').AsFloat := poItens[iItem].PercDesconto;
      oQry.ExecSQL;
    end;
  finally
    oQry.Free;
  end;
end;

function TVendaDAO.Inserir(piClienteId, piUsuarioId: Int64; pdtVencimento: TDateTime;
  pnDesconto: Currency; const psObservacao: string;
  const poItens: TArray<TItemVenda>): Int64;
var
  oQry: TFDQuery;
begin
  if piClienteId <= 0 then
    raise EArgumentException.Create('Selecione o cliente.');
  if pnDesconto < 0 then
    raise EArgumentException.Create('Desconto da venda n'#$00E3'o pode ser negativo.');

  FoConexao.StartTransaction;
  try
    oQry := TFDQuery.Create(nil);
    try
      oQry.Connection := FoConexao;
      oQry.SQL.Text :=
        'INSERT INTO VENDA (CLIENTE_ID, USUARIO_ID, DT_VENCIMENTO, VL_DESCONTO, OBSERVACAO, STATUS) ' +
        'VALUES (:pCli, :pUsu, :pVenc, :pDesc, :pObs, 1) RETURNING ID';
      oQry.ParamByName('pCli').AsLargeInt := piClienteId;
      oQry.ParamByName('pUsu').AsLargeInt := piUsuarioId;
      if pdtVencimento > 0 then
        oQry.ParamByName('pVenc').AsDate := pdtVencimento
      else
        LimparParametro(oQry.ParamByName('pVenc'), ftDate);
      oQry.ParamByName('pDesc').AsCurrency := pnDesconto;
      oQry.ParamByName('pObs').Value := TextoOuNulo(psObservacao);
      oQry.Open;
      Result := oQry.FieldByName('ID').AsLargeInt;
    finally
      oQry.Free;
    end;

    RecalcularItens(Result, poItens);
    FoConexao.Commit;
  except
    FoConexao.Rollback;
    raise;
  end;
end;

procedure TVendaDAO.Atualizar(piVendaId, piClienteId: Int64; pdtVencimento: TDateTime;
  pnDesconto: Currency; const psObservacao: string; const poItens: TArray<TItemVenda>);
var
  oQry: TFDQuery;
begin
  if piClienteId <= 0 then
    raise EArgumentException.Create('Selecione o cliente.');

  FoConexao.StartTransaction;
  try
    oQry := TFDQuery.Create(nil);
    try
      oQry.Connection := FoConexao;
      oQry.SQL.Text :=
        'UPDATE VENDA SET CLIENTE_ID = :pCli, DT_VENCIMENTO = :pVenc, ' +
        '  VL_DESCONTO = :pDesc, OBSERVACAO = :pObs ' +
        ' WHERE ID = :pId AND STATUS = :pStatus';
      oQry.ParamByName('pCli').AsLargeInt := piClienteId;
      if pdtVencimento > 0 then
        oQry.ParamByName('pVenc').AsDate := pdtVencimento
      else
        LimparParametro(oQry.ParamByName('pVenc'), ftDate);
      oQry.ParamByName('pDesc').AsCurrency := pnDesconto;
      oQry.ParamByName('pObs').Value := TextoOuNulo(psObservacao);
      oQry.ParamByName('pId').AsLargeInt := piVendaId;
      oQry.ParamByName('pStatus').AsInteger := Ord(vsEmDigitacao);
      oQry.ExecSQL;
      if oQry.RowsAffected = 0 then
        raise Exception.Create('S'#$00F3' '#$00E9' poss'#$00ED'vel alterar venda em digita'#$00E7#$00E3'o.');
    finally
      oQry.Free;
    end;

    RecalcularItens(piVendaId, poItens);
    FoConexao.Commit;
  except
    FoConexao.Rollback;
    raise;
  end;
end;

procedure TVendaDAO.Confirmar(piVendaId: Int64);
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'UPDATE VENDA SET STATUS = :pNovo WHERE ID = :pId AND STATUS = :pAtual';
    oQry.ParamByName('pNovo').AsInteger := Ord(vsPendente);
    oQry.ParamByName('pId').AsLargeInt := piVendaId;
    oQry.ParamByName('pAtual').AsInteger := Ord(vsEmDigitacao);
    oQry.ExecSQL;
    if oQry.RowsAffected = 0 then
      raise Exception.Create('A venda precisa estar em digita'#$00E7#$00E3'o e ter itens para confirmar.');
  finally
    oQry.Free;
  end;
end;

procedure TVendaDAO.Excluir(piVendaId: Int64);
var
  oQry: TFDQuery;
begin
  FoConexao.StartTransaction;
  try
    oQry := TFDQuery.Create(nil);
    try
      oQry.Connection := FoConexao;
      oQry.SQL.Text := 'DELETE FROM VENDA_ITEM WHERE VENDA_ID = :pId';
      oQry.ParamByName('pId').AsLargeInt := piVendaId;
      oQry.ExecSQL;

      oQry.SQL.Text := 'DELETE FROM VENDA WHERE ID = :pId AND STATUS = :pStatus';
      oQry.ParamByName('pId').AsLargeInt := piVendaId;
      oQry.ParamByName('pStatus').AsInteger := Ord(vsEmDigitacao);
      oQry.ExecSQL;
      if oQry.RowsAffected = 0 then
        raise Exception.Create('S'#$00F3' '#$00E9' poss'#$00ED'vel excluir venda em digita'#$00E7#$00E3'o.');
    finally
      oQry.Free;
    end;
    FoConexao.Commit;
  except
    FoConexao.Rollback;
    raise;
  end;
end;

procedure TVendaDAO.CancelarDigitacao(piVendaId, piUsuarioId: Int64; const psMotivo: string);
var
  oQry: TFDQuery;
begin
  if Trim(psMotivo) = '' then
    raise EArgumentException.Create('Informe o motivo do cancelamento.');

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'UPDATE VENDA SET STATUS = :pNovo, MOTIVO_CANCELAMENTO = :pMotivo, ' +
      '  USUARIO_CANCEL_ID = :pUsu WHERE ID = :pId AND STATUS = :pAtual';
    oQry.ParamByName('pNovo').AsInteger := Ord(vsCancelada);
    oQry.ParamByName('pMotivo').AsString := Trim(psMotivo);
    oQry.ParamByName('pUsu').AsLargeInt := piUsuarioId;
    oQry.ParamByName('pId').AsLargeInt := piVendaId;
    oQry.ParamByName('pAtual').AsInteger := Ord(vsEmDigitacao);
    oQry.ExecSQL;
    if oQry.RowsAffected = 0 then
      raise Exception.Create('S'#$00F3' '#$00E9' poss'#$00ED'vel cancelar venda em digita'#$00E7#$00E3'o por aqui.');
  finally
    oQry.Free;
  end;
end;

end.
