unit uProdutoDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TProdutoDAO = class
  private
    FoConexao: TFDConnection;
  public
    constructor Create(poConexao: TFDConnection);
    function Listar(const psFiltro: string = ''): TFDQuery;
    function ListarAtivos(const psFiltro: string = ''): TFDQuery;
    function CodigoExiste(const psCodigo: string; piIdIgnorar: Int64 = 0): Boolean;
    function Inserir(const psCodigo, psDescricao, psUnidade: string; pnPreco: Currency): Int64;
    procedure Atualizar(piId: Int64; const psCodigo, psDescricao, psUnidade: string;
      pnPreco: Currency; pbAtivo: Boolean);
    procedure Inativar(piId: Int64);
  end;

implementation

uses
  Data.DB, uDados;

constructor TProdutoDAO.Create(poConexao: TFDConnection);
begin
  inherited Create;
  FoConexao := poConexao;
end;

function TProdutoDAO.Listar(const psFiltro: string): TFDQuery;
var
  sFiltro: string;
begin
  sFiltro := '%' + SemAcento(psFiltro) + '%';
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, CODIGO, DESCRICAO, UNIDADE, PRECO_VENDA, ATIVO ' +
    '  FROM PRODUTO ' +
    ' WHERE (CAST(:pTem AS INTEGER) = 0 OR ' + SqlSemAcento('CODIGO') + ' LIKE :pLike ' +
    '        OR ' + SqlSemAcento('DESCRICAO') + ' LIKE :pLike2) ' +
    ' ORDER BY ID';
  Result.ParamByName('pTem').AsInteger := Ord(Trim(psFiltro) <> '');
  Result.ParamByName('pLike').AsString := sFiltro;
  Result.ParamByName('pLike2').AsString := sFiltro;
  Result.Open;
end;

function TProdutoDAO.ListarAtivos(const psFiltro: string): TFDQuery;
var
  sFiltro: string;
begin
  sFiltro := '%' + SemAcento(psFiltro) + '%';
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, CODIGO, DESCRICAO, UNIDADE, PRECO_VENDA ' +
    '  FROM PRODUTO ' +
    ' WHERE ATIVO = 1 ' +
    '   AND (CAST(:pTem AS INTEGER) = 0 OR ' + SqlSemAcento('CODIGO') + ' LIKE :pLike ' +
    '        OR ' + SqlSemAcento('DESCRICAO') + ' LIKE :pLike2) ' +
    ' ORDER BY DESCRICAO';
  Result.ParamByName('pTem').AsInteger := Ord(Trim(psFiltro) <> '');
  Result.ParamByName('pLike').AsString := sFiltro;
  Result.ParamByName('pLike2').AsString := sFiltro;
  Result.Open;
end;

function TProdutoDAO.CodigoExiste(const psCodigo: string; piIdIgnorar: Int64): Boolean;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT 1 FROM PRODUTO WHERE CODIGO = :pCod AND ID <> :pId';
    oQry.ParamByName('pCod').AsString := Trim(psCodigo);
    oQry.ParamByName('pId').AsLargeInt := piIdIgnorar;
    oQry.Open;
    Result := not oQry.IsEmpty;
  finally
    oQry.Free;
  end;
end;

function TProdutoDAO.Inserir(const psCodigo, psDescricao, psUnidade: string;
  pnPreco: Currency): Int64;
var
  oQry: TFDQuery;
begin
  if Trim(psCodigo) = '' then
    raise EArgumentException.Create('C'#$00F3'digo '#$00E9' obrigat'#$00F3'rio.');
  if Trim(psDescricao) = '' then
    raise EArgumentException.Create('Descri'#$00E7#$00E3'o '#$00E9' obrigat'#$00F3'ria.');
  if pnPreco < 0 then
    raise EArgumentException.Create('Pre'#$00E7'o n'#$00E3'o pode ser negativo.');
  if CodigoExiste(psCodigo) then
    raise EArgumentException.CreateFmt('J'#$00E1' existe produto com o c'#$00F3'digo "%s".', [psCodigo]);

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'INSERT INTO PRODUTO (CODIGO, DESCRICAO, UNIDADE, PRECO_VENDA, ATIVO) ' +
      'VALUES (:pCod, :pDesc, :pUn, :pPreco, 1) RETURNING ID';
    oQry.ParamByName('pCod').AsString := Trim(psCodigo);
    oQry.ParamByName('pDesc').AsString := Trim(psDescricao);
    if Trim(psUnidade) = '' then
      oQry.ParamByName('pUn').AsString := 'UN'
    else
      oQry.ParamByName('pUn').AsString := UpperCase(Trim(psUnidade));
    oQry.ParamByName('pPreco').AsCurrency := pnPreco;
    oQry.Open;
    Result := oQry.FieldByName('ID').AsLargeInt;
  finally
    oQry.Free;
  end;
end;

procedure TProdutoDAO.Atualizar(piId: Int64; const psCodigo, psDescricao,
  psUnidade: string; pnPreco: Currency; pbAtivo: Boolean);
var
  sUn: string;
begin
  if Trim(psCodigo) = '' then
    raise EArgumentException.Create('C'#$00F3'digo '#$00E9' obrigat'#$00F3'rio.');
  if Trim(psDescricao) = '' then
    raise EArgumentException.Create('Descri'#$00E7#$00E3'o '#$00E9' obrigat'#$00F3'ria.');
  if pnPreco < 0 then
    raise EArgumentException.Create('Pre'#$00E7'o n'#$00E3'o pode ser negativo.');
  if CodigoExiste(psCodigo, piId) then
    raise EArgumentException.CreateFmt('J'#$00E1' existe produto com o c'#$00F3'digo "%s".', [psCodigo]);

  if Trim(psUnidade) = '' then
    sUn := 'UN'
  else
    sUn := UpperCase(Trim(psUnidade));

  FoConexao.ExecSQL(
    'UPDATE PRODUTO SET CODIGO = :pCod, DESCRICAO = :pDesc, UNIDADE = :pUn, ' +
    '  PRECO_VENDA = :pPreco, ATIVO = :pAtivo WHERE ID = :pId',
    [Trim(psCodigo), Trim(psDescricao), sUn, pnPreco, Ord(pbAtivo), piId]);
end;

procedure TProdutoDAO.Inativar(piId: Int64);
begin
  FoConexao.ExecSQL('UPDATE PRODUTO SET ATIVO = 0 WHERE ID = :pId', [piId]);
end;

end.
