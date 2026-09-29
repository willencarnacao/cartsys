unit uConsulta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Data.DB, FireDAC.Comp.Client, uGrade, uTipos;

type
  TFormConsulta = class(TForm)
    pnlFiltro: TPanel;
    lblFiltro: TLabel;
    edtFiltro: TEdit;
    btnBuscar: TButton;
    grdConsulta: TDBGrid;
    dsConsulta: TDataSource;
    pnlBotoes: TPanel;
    btnSelecionar: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnSelecionarClick(Sender: TObject);
    procedure edtFiltroKeyPress(Sender: TObject; var Key: Char);
    procedure grdConsultaDblClick(Sender: TObject);
    procedure grdConsultaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure Recarregar;
    procedure ConfirmarSelecao;
  protected
    FoQuery: TFDQuery;
    function ObterCampoCodigo: string; virtual;
    function ObterCampoDescricao: string; virtual;
    function CriarConsulta(const psFiltro: string): TFDQuery; virtual;
    procedure AjustarColunas; virtual;
  public
    function ObterIdSelecionado: Int64;
    function ObterCodigoSelecionado: string;
    function ObterDescricaoSelecionada: string;
  end;

implementation

{$R *.dfm}

procedure TFormConsulta.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  PrepararGrade(grdConsulta);
  edtFiltro.Hint := 'Digite para filtrar. F4 no cadastro abre esta tela.';
end;

procedure TFormConsulta.FormDestroy(Sender: TObject);
begin
  dsConsulta.DataSet := nil;
  FreeAndNil(FoQuery);
end;

procedure TFormConsulta.FormShow(Sender: TObject);
begin
  Recarregar;
  ActiveControl := edtFiltro;
end;

function TFormConsulta.ObterCampoCodigo: string;
begin
  Result := 'CODIGO';
end;

function TFormConsulta.ObterCampoDescricao: string;
begin
  Result := 'DESCRICAO';
end;

function TFormConsulta.CriarConsulta(const psFiltro: string): TFDQuery;
begin
  Result := nil;
end;

procedure TFormConsulta.AjustarColunas;
var
  iCampo: Integer;
  sNome: string;
begin
  if FoQuery = nil then
    Exit;
  for iCampo := 0 to FoQuery.FieldCount - 1 do
  begin
    sNome := FoQuery.Fields[iCampo].FieldName;
    FoQuery.Fields[iCampo].Visible := SameText(sNome, ObterCampoCodigo) or
      SameText(sNome, ObterCampoDescricao);
  end;
  NomearCampo(FoQuery, ObterCampoCodigo, TXT_CODIGO);
  NomearCampo(FoQuery, ObterCampoDescricao, TXT_DESCRICAO);
  if FoQuery.FindField(ObterCampoCodigo) <> nil then
    FoQuery.FieldByName(ObterCampoCodigo).DisplayWidth := 18;
  if FoQuery.FindField(ObterCampoDescricao) <> nil then
    FoQuery.FieldByName(ObterCampoDescricao).DisplayWidth := 50;
end;

procedure TFormConsulta.Recarregar;
begin
  dsConsulta.DataSet := nil;
  FreeAndNil(FoQuery);
  FoQuery := CriarConsulta(Trim(edtFiltro.Text));
  dsConsulta.DataSet := FoQuery;
  AjustarColunas;
end;

procedure TFormConsulta.ConfirmarSelecao;
begin
  if (FoQuery = nil) or FoQuery.IsEmpty then
  begin
    MessageDlg('Selecione um registro.', mtWarning, [mbOK], 0);
    Exit;
  end;
  ModalResult := mrOk;
end;

function TFormConsulta.ObterIdSelecionado: Int64;
begin
  if (FoQuery = nil) or FoQuery.IsEmpty then
    Result := 0
  else
    Result := FoQuery.FieldByName('ID').AsLargeInt;
end;

function TFormConsulta.ObterCodigoSelecionado: string;
begin
  if (FoQuery = nil) or FoQuery.IsEmpty then
    Result := ''
  else
    Result := FoQuery.FieldByName(ObterCampoCodigo).AsString;
end;

function TFormConsulta.ObterDescricaoSelecionada: string;
begin
  if (FoQuery = nil) or FoQuery.IsEmpty then
    Result := ''
  else
    Result := FoQuery.FieldByName(ObterCampoDescricao).AsString;
end;

procedure TFormConsulta.btnBuscarClick(Sender: TObject);
begin
  Recarregar;
end;

procedure TFormConsulta.btnSelecionarClick(Sender: TObject);
begin
  ConfirmarSelecao;
end;

procedure TFormConsulta.edtFiltroKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    Recarregar;
  end;
end;

procedure TFormConsulta.grdConsultaDblClick(Sender: TObject);
begin
  ConfirmarSelecao;
end;

procedure TFormConsulta.grdConsultaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    ConfirmarSelecao;
  end;
end;

end.
