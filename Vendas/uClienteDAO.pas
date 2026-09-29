unit uClienteDAO;

interface

uses
  System.SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TClienteDAO = class
  private
    FoConexao: TFDConnection;
  public
    constructor Create(poConexao: TFDConnection);
    function Listar(const psFiltro: string = ''): TFDQuery;
    function Carregar(piId: Int64): TFDQuery;
    function ListarAtivos(const psFiltro: string = ''): TFDQuery;
    function DocumentoExiste(const psDocumento: string; piIdIgnorar: Int64 = 0): Boolean;
    function Inserir(const psNome: string; pbPessoaJuridica: Boolean;
      const psDocumento, psEmail, psTelefone, psCep, psLogradouro, psNumero,
      psBairro, psCidade, psUF: string): Int64;
    procedure Atualizar(piId: Int64; const psNome: string; pbPessoaJuridica: Boolean;
      const psDocumento, psEmail, psTelefone, psCep, psLogradouro, psNumero,
      psBairro, psCidade, psUF: string; pbAtivo: Boolean);
    procedure Inativar(piId: Int64);
  end;

implementation

uses
  Data.DB, System.Variants, uDocumento, uDados;

constructor TClienteDAO.Create(poConexao: TFDConnection);
begin
  inherited Create;
  FoConexao := poConexao;
end;

function TClienteDAO.Listar(const psFiltro: string): TFDQuery;
var
  sNome, sDoc: string;
begin
  sNome := '%' + SemAcento(psFiltro) + '%';
  sDoc := SoDigitos(psFiltro);
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, NOME, TIPO_PESSOA, CPF_CNPJ, EMAIL, TELEFONE, CIDADE, UF, ATIVO ' +
    '  FROM CLIENTE ' +
    ' WHERE (CAST(:pTem AS INTEGER) = 0 OR ' + SqlSemAcento('NOME') + ' LIKE :pLike ' +
    '        OR (CAST(:pTemDoc AS INTEGER) = 1 AND CPF_CNPJ LIKE :pDoc)) ' +
    ' ORDER BY ID';
  Result.ParamByName('pTem').AsInteger := Ord(Trim(psFiltro) <> '');
  Result.ParamByName('pLike').AsString := sNome;
  Result.ParamByName('pTemDoc').AsInteger := Ord(sDoc <> '');
  Result.ParamByName('pDoc').AsString := '%' + sDoc + '%';
  Result.Open;
end;

function TClienteDAO.Carregar(piId: Int64): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, NOME, TIPO_PESSOA, CPF_CNPJ, EMAIL, TELEFONE, CEP, LOGRADOURO, ' +
    '       NUMERO, BAIRRO, CIDADE, UF, ATIVO FROM CLIENTE WHERE ID = :pId';
  Result.ParamByName('pId').AsLargeInt := piId;
  Result.Open;
end;

function TClienteDAO.ListarAtivos(const psFiltro: string): TFDQuery;
var
  sNome, sDoc: string;
begin
  sNome := '%' + SemAcento(psFiltro) + '%';
  sDoc := SoDigitos(psFiltro);
  Result := TFDQuery.Create(nil);
  Result.Connection := FoConexao;
  Result.SQL.Text :=
    'SELECT ID, CPF_CNPJ AS CODIGO, NOME AS DESCRICAO ' +
    '  FROM CLIENTE ' +
    ' WHERE ATIVO = 1 ' +
    '   AND (CAST(:pTem AS INTEGER) = 0 OR ' + SqlSemAcento('NOME') + ' LIKE :pLike ' +
    '        OR (CAST(:pTemDoc AS INTEGER) = 1 AND CPF_CNPJ LIKE :pDoc)) ' +
    ' ORDER BY NOME';
  Result.ParamByName('pTem').AsInteger := Ord(Trim(psFiltro) <> '');
  Result.ParamByName('pLike').AsString := sNome;
  Result.ParamByName('pTemDoc').AsInteger := Ord(sDoc <> '');
  Result.ParamByName('pDoc').AsString := '%' + sDoc + '%';
  Result.Open;
end;

function TClienteDAO.DocumentoExiste(const psDocumento: string; piIdIgnorar: Int64): Boolean;
var
  oQry: TFDQuery;
begin
  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text := 'SELECT 1 FROM CLIENTE WHERE CPF_CNPJ = :pDoc AND ID <> :pId';
    oQry.ParamByName('pDoc').AsString := SoDigitos(psDocumento);
    oQry.ParamByName('pId').AsLargeInt := piIdIgnorar;
    oQry.Open;
    Result := not oQry.IsEmpty;
  finally
    oQry.Free;
  end;
end;

function TClienteDAO.Inserir(const psNome: string; pbPessoaJuridica: Boolean;
  const psDocumento, psEmail, psTelefone, psCep, psLogradouro, psNumero, psBairro,
  psCidade, psUF: string): Int64;
var
  oQry: TFDQuery;
  sDoc: string;
  cTipo: Char;
begin
  if Trim(psNome) = '' then
    raise EArgumentException.Create('Nome '#$00E9' obrigat'#$00F3'rio.');

  sDoc := SoDigitos(psDocumento);
  if not ValidarDocumento(sDoc, pbPessoaJuridica) then
    raise EArgumentException.Create('CPF/CNPJ inv'#$00E1'lido.');
  if DocumentoExiste(sDoc) then
    raise EArgumentException.Create('J'#$00E1' existe cliente com este documento.');

  if pbPessoaJuridica then
    cTipo := 'J'
  else
    cTipo := 'F';

  oQry := TFDQuery.Create(nil);
  try
    oQry.Connection := FoConexao;
    oQry.SQL.Text :=
      'INSERT INTO CLIENTE (NOME, TIPO_PESSOA, CPF_CNPJ, EMAIL, TELEFONE, CEP, ' +
      '  LOGRADOURO, NUMERO, BAIRRO, CIDADE, UF, ATIVO) ' +
      'VALUES (:pNome, :pTipo, :pDoc, :pEmail, :pFone, :pCep, :pLog, :pNum, ' +
      '  :pBairro, :pCidade, :pUf, 1) RETURNING ID';
    oQry.ParamByName('pNome').AsString := Trim(psNome);
    oQry.ParamByName('pTipo').AsString := cTipo;
    oQry.ParamByName('pDoc').AsString := sDoc;
    oQry.ParamByName('pEmail').Value := TextoOuNulo(psEmail);
    oQry.ParamByName('pFone').Value := TextoOuNulo(psTelefone);
    oQry.ParamByName('pCep').Value := TextoOuNulo(SoDigitos(psCep));
    oQry.ParamByName('pLog').Value := TextoOuNulo(psLogradouro);
    oQry.ParamByName('pNum').Value := TextoOuNulo(psNumero);
    oQry.ParamByName('pBairro').Value := TextoOuNulo(psBairro);
    oQry.ParamByName('pCidade').Value := TextoOuNulo(psCidade);
    if Trim(psUF) = '' then
      oQry.ParamByName('pUf').Clear
    else
      oQry.ParamByName('pUf').AsString := UpperCase(Trim(psUF));
    oQry.Open;
    Result := oQry.FieldByName('ID').AsLargeInt;
  finally
    oQry.Free;
  end;
end;

procedure TClienteDAO.Atualizar(piId: Int64; const psNome: string;
  pbPessoaJuridica: Boolean; const psDocumento, psEmail, psTelefone, psCep,
  psLogradouro, psNumero, psBairro, psCidade, psUF: string; pbAtivo: Boolean);
var
  sDoc: string;
  cTipo: Char;
  vUf: Variant;
begin
  if Trim(psNome) = '' then
    raise EArgumentException.Create('Nome '#$00E9' obrigat'#$00F3'rio.');

  sDoc := SoDigitos(psDocumento);
  if not ValidarDocumento(sDoc, pbPessoaJuridica) then
    raise EArgumentException.Create('CPF/CNPJ inv'#$00E1'lido.');
  if DocumentoExiste(sDoc, piId) then
    raise EArgumentException.Create('J'#$00E1' existe cliente com este documento.');

  if pbPessoaJuridica then
    cTipo := 'J'
  else
    cTipo := 'F';

  if Trim(psUF) = '' then
    vUf := Null
  else
    vUf := UpperCase(Trim(psUF));

  FoConexao.ExecSQL(
    'UPDATE CLIENTE SET NOME = :pNome, TIPO_PESSOA = :pTipo, CPF_CNPJ = :pDoc, ' +
    '  EMAIL = :pEmail, TELEFONE = :pFone, CEP = :pCep, LOGRADOURO = :pLog, ' +
    '  NUMERO = :pNum, BAIRRO = :pBairro, CIDADE = :pCidade, UF = :pUf, ATIVO = :pAtivo ' +
    'WHERE ID = :pId',
    [Trim(psNome), cTipo, sDoc, TextoOuNulo(psEmail), TextoOuNulo(psTelefone),
     TextoOuNulo(SoDigitos(psCep)), TextoOuNulo(psLogradouro), TextoOuNulo(psNumero),
     TextoOuNulo(psBairro), TextoOuNulo(psCidade), vUf, Ord(pbAtivo), piId]);
end;

procedure TClienteDAO.Inativar(piId: Int64);
begin
  FoConexao.ExecSQL('UPDATE CLIENTE SET ATIVO = 0 WHERE ID = :pId', [piId]);
end;

end.
