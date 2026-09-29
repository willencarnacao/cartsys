unit uGrade;

interface

uses
  Data.DB, Vcl.DBGrids;

procedure PrepararGrade(poGrade: TDBGrid);
procedure NomearCampo(poDataSet: TDataSet; const psCampo, psTitulo: string);
procedure AplicarFormatoMoeda(poDataSet: TDataSet; const psCampo: string);

implementation

procedure PrepararGrade(poGrade: TDBGrid);
begin
  poGrade.ReadOnly := True;
  poGrade.Options := poGrade.Options + [dgTitles, dgColLines, dgRowLines, dgRowSelect] -
    [dgEditing];
end;

procedure NomearCampo(poDataSet: TDataSet; const psCampo, psTitulo: string);
var
  oCampo: TField;
begin
  if not Assigned(poDataSet) then
    Exit;
  oCampo := poDataSet.FindField(psCampo);
  if oCampo <> nil then
    oCampo.DisplayLabel := psTitulo;
end;

procedure AplicarFormatoMoeda(poDataSet: TDataSet; const psCampo: string);
var
  oCampo: TField;
begin
  if not Assigned(poDataSet) then
    Exit;
  oCampo := poDataSet.FindField(psCampo);
  if oCampo is TNumericField then
    TNumericField(oCampo).DisplayFormat := '#,##0.00';
end;

end.
