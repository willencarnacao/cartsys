unit uRelFinanceiro;

interface

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, uTipos;

procedure GerarRelatorioFinanceiro(poQuery: TFDQuery; pdtDataInicial, pdtDataFinal: TDateTime);

implementation

uses
  Winapi.Windows, System.Classes, Vcl.Graphics, ppTypes, ppComm, ppRelatv, ppProd, ppClass, ppReport, ppCtrls,
  ppPrnabl, ppBands, ppCache, ppDB, ppDBPipe, ppVar, ppPDFDevice;

procedure AplicarFonteRelatorio(poFonte: TFont; piTamanho: Integer; pbNegrito: Boolean = False);
begin
  poFonte.Name := 'Arial';
  poFonte.Charset := ANSI_CHARSET;
  poFonte.Size := piTamanho;
  if pbNegrito then
    poFonte.Style := [fsBold]
  else
    poFonte.Style := [];
end;

procedure AdicionarRotuloCabecalho(poBand: TppBand; poOwner: TComponent; const psTexto: string;
  pnLeft, pnTop, pnWidth: Double; pbDir: Boolean = False);
var
  oRotulo: TppLabel;
begin
  oRotulo := TppLabel.Create(poOwner);
  oRotulo.Band := poBand;
  oRotulo.Caption := psTexto;
  oRotulo.AutoSize := False;
  oRotulo.WordWrap := False;
  oRotulo.Left := pnLeft;
  oRotulo.Top := pnTop;
  oRotulo.Width := pnWidth;
  oRotulo.Height := 4;
  AplicarFonteRelatorio(oRotulo.Font, 8, True);
  if pbDir then
    oRotulo.TextAlignment := taRightJustified;
end;

procedure GerarRelatorioFinanceiro(poQuery: TFDQuery; pdtDataInicial, pdtDataFinal: TDateTime);
var
  oDS: TDataSource;
  oPipe: TppDBPipeline;
  oReport: TppReport;
  oHeader: TppHeaderBand;
  oDetail: TppDetailBand;
  oRodape: TppFooterBand;
  oTitulo, oPeriodo: TppLabel;
  oDB: TppDBText;
  oLinha: TppLine;
  oPagina: TppSystemVariable;
begin
  if not Assigned(poQuery) or not poQuery.Active then
    raise Exception.Create(TXT_SEM_DADOS_REL);

  oDS := TDataSource.Create(nil);
  oPipe := TppDBPipeline.Create(nil);
  oReport := TppReport.Create(nil);
  try
    oDS.DataSet := poQuery;
    oPipe.DataSource := oDS;
    oPipe.UserName := 'plkFin';

    oReport.DataPipeline := oPipe;
    oReport.Units := utMillimeters;
    oReport.PrinterSetup.PaperName := 'A4';
    oReport.AllowPrintToFile := True;

    oHeader := TppHeaderBand.Create(oReport);
    oHeader.Report := oReport;
    oHeader.Height := 28;

    oTitulo := TppLabel.Create(oReport);
    oTitulo.Band := oHeader;
    oTitulo.Caption := TXT_REL_FINANCEIRO;
    AplicarFonteRelatorio(oTitulo.Font, 14, True);
    oTitulo.Left := 10;
    oTitulo.Top := 4;
    oTitulo.Width := 180;
    oTitulo.Height := 8;

    oPeriodo := TppLabel.Create(oReport);
    oPeriodo.Band := oHeader;
    oPeriodo.Caption := Format(TXT_PERIODO, [DateToStr(pdtDataInicial), DateToStr(pdtDataFinal)]);
    AplicarFonteRelatorio(oPeriodo.Font, 9);
    oPeriodo.Left := 10;
    oPeriodo.Top := 13;
    oPeriodo.Width := 120;
    oPeriodo.Height := 5;

    AdicionarRotuloCabecalho(oHeader, oReport, 'Venda', 10, 21, 18);
    AdicionarRotuloCabecalho(oHeader, oReport, 'Cliente', 30, 21, 70);
    AdicionarRotuloCabecalho(oHeader, oReport, 'Status', 102, 21, 25);
    AdicionarRotuloCabecalho(oHeader, oReport, 'Emiss'#$00E3'o', 128, 21, 28);
    AdicionarRotuloCabecalho(oHeader, oReport, 'Total', 158, 21, 32, True);

    oLinha := TppLine.Create(oReport);
    oLinha.Band := oHeader;
    oLinha.Left := 10;
    oLinha.Top := 26;
    oLinha.Width := 190;

    oDetail := TppDetailBand.Create(oReport);
    oDetail.Report := oReport;
    oDetail.Height := 6;

    oDB := TppDBText.Create(oReport);
    oDB.Band := oDetail;
    oDB.DataPipeline := oPipe;
    oDB.DataField := 'ID';
    oDB.Left := 10;
    oDB.Top := 0.5;
    oDB.Width := 18;
    oDB.Height := 5;
    oDB.Font.Name := 'Arial';
    oDB.Font.Size := 8;
    oDB.Font.Charset := ANSI_CHARSET;
    oDB.AutoSize := False;

    oDB := TppDBText.Create(oReport);
    oDB.Band := oDetail;
    oDB.DataPipeline := oPipe;
    oDB.DataField := 'CLIENTE';
    oDB.Left := 30;
    oDB.Top := 0.5;
    oDB.Width := 70;
    oDB.Height := 5;
    oDB.Font.Name := 'Arial';
    oDB.Font.Size := 8;
    oDB.Font.Charset := ANSI_CHARSET;
    oDB.AutoSize := False;

    oDB := TppDBText.Create(oReport);
    oDB.Band := oDetail;
    oDB.DataPipeline := oPipe;
    oDB.DataField := 'STATUS_DESC';
    oDB.Left := 102;
    oDB.Top := 0.5;
    oDB.Width := 25;
    oDB.Height := 5;
    oDB.Font.Name := 'Arial';
    oDB.Font.Size := 8;
    oDB.Font.Charset := ANSI_CHARSET;
    oDB.AutoSize := False;

    oDB := TppDBText.Create(oReport);
    oDB.Band := oDetail;
    oDB.DataPipeline := oPipe;
    oDB.DataField := 'DT_EMISSAO';
    oDB.Left := 128;
    oDB.Top := 0.5;
    oDB.Width := 28;
    oDB.Height := 5;
    oDB.Font.Name := 'Arial';
    oDB.Font.Size := 8;
    oDB.Font.Charset := ANSI_CHARSET;
    oDB.AutoSize := False;
    oDB.DisplayFormat := 'dd/mm/yyyy';

    oDB := TppDBText.Create(oReport);
    oDB.Band := oDetail;
    oDB.DataPipeline := oPipe;
    oDB.DataField := 'VL_TOTAL';
    oDB.Left := 158;
    oDB.Top := 0.5;
    oDB.Width := 32;
    oDB.Height := 5;
    oDB.Font.Name := 'Arial';
    oDB.Font.Size := 8;
    oDB.Font.Charset := ANSI_CHARSET;
    oDB.AutoSize := False;
    oDB.DisplayFormat := '$#,##0.00';
    oDB.TextAlignment := taRightJustified;

    oRodape := TppFooterBand.Create(oReport);
    oRodape.Report := oReport;
    oRodape.Height := 10;

    oPagina := TppSystemVariable.Create(oReport);
    oPagina.Band := oRodape;
    oPagina.VarType := vtPageSetDesc;
    oPagina.Left := 160;
    oPagina.Top := 2;
    oPagina.Font.Name := 'Arial';
    oPagina.Font.Size := 8;
    oPagina.Font.Charset := ANSI_CHARSET;

    oReport.DeviceType := dtScreen;
    oReport.ShowPrintDialog := False;
    oReport.Print;
  finally
    oReport.Free;
    oPipe.Free;
    oDS.Free;
  end;
end;

end.
