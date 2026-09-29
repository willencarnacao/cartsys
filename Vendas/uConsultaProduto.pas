unit uConsultaProduto;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, FireDAC.Comp.Client, uConsulta, uProdutoDAO;

type
  TFormConsultaProduto = class(TFormConsulta)
  private
    FoDAO: TProdutoDAO;
  protected
    function CriarConsulta(const psFiltro: string): TFDQuery; override;
  public
    class function Consultar(poDAO: TProdutoDAO; out piId: Int64;
      out psCodigo, psDescricao, psUnidade: string; out pnPreco: Currency): Boolean;
  end;

implementation

function TFormConsultaProduto.CriarConsulta(const psFiltro: string): TFDQuery;
begin
  Result := FoDAO.ListarAtivos(psFiltro);
end;

class function TFormConsultaProduto.Consultar(poDAO: TProdutoDAO; out piId: Int64;
  out psCodigo, psDescricao, psUnidade: string; out pnPreco: Currency): Boolean;
var
  oForm: TFormConsultaProduto;
begin
  oForm := TFormConsultaProduto.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.Caption := 'Consulta de produtos';
    Result := oForm.ShowModal = mrOk;
    if Result then
    begin
      piId := oForm.ObterIdSelecionado;
      psCodigo := oForm.ObterCodigoSelecionado;
      psDescricao := oForm.ObterDescricaoSelecionada;
      psUnidade := oForm.FoQuery.FieldByName('UNIDADE').AsString;
      pnPreco := oForm.FoQuery.FieldByName('PRECO_VENDA').AsCurrency;
    end;
  finally
    oForm.Free;
  end;
end;

end.
