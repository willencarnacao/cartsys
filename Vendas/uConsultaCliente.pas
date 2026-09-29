unit uConsultaCliente;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, FireDAC.Comp.Client, uConsulta, uClienteDAO;

type
  TFormConsultaCliente = class(TFormConsulta)
  private
    FoDAO: TClienteDAO;
  protected
    function CriarConsulta(const psFiltro: string): TFDQuery; override;
  public
    class function Consultar(poDAO: TClienteDAO; out piId: Int64;
      out psCodigo, psDescricao: string): Boolean;
  end;

implementation

function TFormConsultaCliente.CriarConsulta(const psFiltro: string): TFDQuery;
begin
  Result := FoDAO.ListarAtivos(psFiltro);
end;

class function TFormConsultaCliente.Consultar(poDAO: TClienteDAO; out piId: Int64;
  out psCodigo, psDescricao: string): Boolean;
var
  oForm: TFormConsultaCliente;
begin
  oForm := TFormConsultaCliente.Create(nil);
  try
    oForm.FoDAO := poDAO;
    oForm.Caption := 'Consulta de clientes';
    Result := oForm.ShowModal = mrOk;
    if Result then
    begin
      piId := oForm.ObterIdSelecionado;
      psCodigo := oForm.ObterCodigoSelecionado;
      psDescricao := oForm.ObterDescricaoSelecionada;
    end;
  finally
    oForm.Free;
  end;
end;

end.
