unit uRelPedido;

interface

uses
  System.SysUtils, Data.DB, FireDAC.Comp.Client, uTipos;

procedure VisualizarPedido(poCab, poItens: TFDQuery);
procedure ExportarPedidoPdf(poCab, poItens: TFDQuery; const psArquivo: string);

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

procedure MontarPedido(poCab, poItens: TFDQuery; poReport: TppReport; poPipe: TppDBPipeline);
var
  oHeader: TppHeaderBand;
  oDetail: TppDetailBand;
  oSumario: TppSummaryBand;
  oRodape: TppFooterBand;
  oTitulo, oInfo: TppLabel;
  oDB: TppDBText;
  oLinha: TppLine;
  oPagina: TppSystemVariable;
  sEndereco, sStatus: string;
begin
  poReport.DataPipeline := poPipe;
  poReport.Units := utMillimeters;
  poReport.PrinterSetup.PaperName := 'A4';
  poReport.AllowPrintToFile := True;

  oHeader := TppHeaderBand.Create(poReport);
  oHeader.Report := poReport;
  oHeader.Height := 52;

  oTitulo := TppLabel.Create(poReport);
  oTitulo.Band := oHeader;
  oTitulo.Caption := TXT_CONFIRMACAO_PEDIDO;
  AplicarFonteRelatorio(oTitulo.Font, 14, True);
  oTitulo.Left := 10;
  oTitulo.Top := 4;
  oTitulo.Width := 160;
  oTitulo.Height := 8;

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oHeader;
  oInfo.Caption := Format(TXT_PEDIDO_CABECALHO,
    [poCab.FieldByName('ID').AsLargeInt,
     FormatDateTime('dd/mm/yyyy hh:nn', poCab.FieldByName('DT_EMISSAO').AsDateTime)]);
  AplicarFonteRelatorio(oInfo.Font, 10);
  oInfo.Left := 10;
  oInfo.Top := 14;
  oInfo.Width := 140;
  oInfo.Height := 5;

  sStatus := ConverterStatusVenda(TVendaStatus(poCab.FieldByName('STATUS').AsInteger));

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oHeader;
  oInfo.Caption := 'Status: ' + sStatus;
  AplicarFonteRelatorio(oInfo.Font, 10);
  oInfo.Left := 155;
  oInfo.Top := 14;
  oInfo.Width := 45;
  oInfo.Height := 5;

  sEndereco := Trim(poCab.FieldByName('LOGRADOURO').AsString);
  if Trim(poCab.FieldByName('NUMERO').AsString) <> '' then
    sEndereco := sEndereco + ', ' + Trim(poCab.FieldByName('NUMERO').AsString);
  if Trim(poCab.FieldByName('BAIRRO').AsString) <> '' then
    sEndereco := sEndereco + ' - ' + Trim(poCab.FieldByName('BAIRRO').AsString);
  if Trim(poCab.FieldByName('CIDADE').AsString) <> '' then
    sEndereco := sEndereco + ' - ' + Trim(poCab.FieldByName('CIDADE').AsString);
  if Trim(poCab.FieldByName('UF').AsString) <> '' then
    sEndereco := sEndereco + '/' + Trim(poCab.FieldByName('UF').AsString);

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oHeader;
  oInfo.Caption := 'Cliente: ' + poCab.FieldByName('CLIENTE').AsString +
    '    Doc.: ' + poCab.FieldByName('CPF_CNPJ').AsString;
  AplicarFonteRelatorio(oInfo.Font, 9);
  oInfo.Left := 10;
  oInfo.Top := 22;
  oInfo.Width := 190;
  oInfo.Height := 5;

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oHeader;
  oInfo.Caption := TXT_ENDERECO + sEndereco;
  AplicarFonteRelatorio(oInfo.Font, 9);
  oInfo.Left := 10;
  oInfo.Top := 28;
  oInfo.Width := 190;
  oInfo.Height := 5;

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oHeader;
  oInfo.Caption := 'Vendedor: ' + poCab.FieldByName('VENDEDOR').AsString;
  AplicarFonteRelatorio(oInfo.Font, 9);
  oInfo.Left := 10;
  oInfo.Top := 34;
  oInfo.Width := 190;
  oInfo.Height := 5;

  AdicionarRotuloCabecalho(oHeader, poReport, 'C'#$00F3'd.', 10, 43, 22);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Descri'#$00E7#$00E3'o', 33, 43, 62);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Un.', 96, 43, 12);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Qtd', 110, 43, 16, True);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Pre'#$00E7'o', 128, 43, 22, True);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Desc.', 152, 43, 18, True);
  AdicionarRotuloCabecalho(oHeader, poReport, 'Total', 172, 43, 26, True);

  oLinha := TppLine.Create(poReport);
  oLinha.Band := oHeader;
  oLinha.Left := 10;
  oLinha.Top := 48;
  oLinha.Width := 190;

  oDetail := TppDetailBand.Create(poReport);
  oDetail.Report := poReport;
  oDetail.Height := 6;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'CODIGO';
  oDB.Left := 10;
  oDB.Top := 0.5;
  oDB.Width := 22;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'DESCRICAO';
  oDB.Left := 33;
  oDB.Top := 0.5;
  oDB.Width := 62;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'UNIDADE';
  oDB.Left := 96;
  oDB.Top := 0.5;
  oDB.Width := 12;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'QUANTIDADE';
  oDB.Left := 110;
  oDB.Top := 0.5;
  oDB.Width := 16;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;
  oDB.DisplayFormat := '#,##0.000';
  oDB.TextAlignment := taRightJustified;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'PRECO_UNIT';
  oDB.Left := 128;
  oDB.Top := 0.5;
  oDB.Width := 22;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;
  oDB.DisplayFormat := '#,##0.00';
  oDB.TextAlignment := taRightJustified;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'VL_DESCONTO';
  oDB.Left := 152;
  oDB.Top := 0.5;
  oDB.Width := 18;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;
  oDB.DisplayFormat := '#,##0.00';
  oDB.TextAlignment := taRightJustified;

  oDB := TppDBText.Create(poReport);
  oDB.Band := oDetail;
  oDB.DataPipeline := poPipe;
  oDB.DataField := 'VL_TOTAL';
  oDB.Left := 172;
  oDB.Top := 0.5;
  oDB.Width := 26;
  oDB.Height := 5;
  oDB.Font.Name := 'Arial';
  oDB.Font.Size := 8;
  oDB.Font.Charset := ANSI_CHARSET;
  oDB.AutoSize := False;
  oDB.DisplayFormat := '#,##0.00';
  oDB.TextAlignment := taRightJustified;

  oSumario := TppSummaryBand.Create(poReport);
  oSumario.Report := poReport;
  oSumario.Height := 22;

  oLinha := TppLine.Create(poReport);
  oLinha.Band := oSumario;
  oLinha.Left := 10;
  oLinha.Top := 2;
  oLinha.Width := 190;

  oInfo := TppLabel.Create(poReport);
  oInfo.Band := oSumario;
  oInfo.Caption := Format('Itens: %s     Desconto: %s     Total: %s',
    [FormatCurr('R$ #,##0.00', poCab.FieldByName('VL_ITENS').AsCurrency),
     FormatCurr('R$ #,##0.00', poCab.FieldByName('VL_DESCONTO').AsCurrency),
     FormatCurr('R$ #,##0.00', poCab.FieldByName('VL_TOTAL').AsCurrency)]);
  AplicarFonteRelatorio(oInfo.Font, 10, True);
  oInfo.Left := 10;
  oInfo.Top := 6;
  oInfo.Width := 190;
  oInfo.Height := 6;

  if Trim(poCab.FieldByName('OBSERVACAO').AsString) <> '' then
  begin
    oInfo := TppLabel.Create(poReport);
    oInfo.Band := oSumario;
    oInfo.Caption := 'Obs.: ' + poCab.FieldByName('OBSERVACAO').AsString;
    AplicarFonteRelatorio(oInfo.Font, 8);
    oInfo.Left := 10;
    oInfo.Top := 14;
    oInfo.Width := 190;
    oInfo.Height := 5;
  end;

  oRodape := TppFooterBand.Create(poReport);
  oRodape.Report := poReport;
  oRodape.Height := 10;

  oPagina := TppSystemVariable.Create(poReport);
  oPagina.Band := oRodape;
  oPagina.VarType := vtPageSetDesc;
  oPagina.Left := 160;
  oPagina.Top := 2;
  oPagina.Font.Name := 'Arial';
  oPagina.Font.Size := 8;
  oPagina.Font.Charset := ANSI_CHARSET;
end;

procedure VisualizarPedido(poCab, poItens: TFDQuery);
var
  oDS: TDataSource;
  oPipe: TppDBPipeline;
  oReport: TppReport;
begin
  if not Assigned(poCab) or poCab.IsEmpty then
    raise Exception.Create(TXT_PEDIDO_NAO_ENCONTRADO);

  oDS := TDataSource.Create(nil);
  oPipe := TppDBPipeline.Create(nil);
  oReport := TppReport.Create(nil);
  try
    oDS.DataSet := poItens;
    oPipe.DataSource := oDS;
    oPipe.UserName := 'plkItens';
    MontarPedido(poCab, poItens, oReport, oPipe);
    oReport.DeviceType := dtScreen;
    oReport.ShowPrintDialog := False;
    oReport.Print;
  finally
    oReport.Free;
    oPipe.Free;
    oDS.Free;
  end;
end;

procedure ExportarPedidoPdf(poCab, poItens: TFDQuery; const psArquivo: string);
var
  oDS: TDataSource;
  oPipe: TppDBPipeline;
  oReport: TppReport;
begin
  if not Assigned(poCab) or poCab.IsEmpty then
    raise Exception.Create(TXT_PEDIDO_NAO_ENCONTRADO);

  oDS := TDataSource.Create(nil);
  oPipe := TppDBPipeline.Create(nil);
  oReport := TppReport.Create(nil);
  try
    oDS.DataSet := poItens;
    oPipe.DataSource := oDS;
    oPipe.UserName := 'plkItens';
    MontarPedido(poCab, poItens, oReport, oPipe);
    oReport.DeviceType := dtPDF;
    oReport.TextFileName := psArquivo;
    oReport.ShowPrintDialog := False;
    oReport.ShowCancelDialog := False;
    oReport.Print;
  finally
    oReport.Free;
    oPipe.Free;
    oDS.Free;
  end;
end;

end.
