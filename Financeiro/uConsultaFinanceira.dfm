object FormConsultaFinanceira: TFormConsultaFinanceira
  Left = 0
  Top = 0
  Caption = 'Consultas e Relat'#243'rio Financeiro'
  ClientHeight = 520
  ClientWidth = 780
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlFiltro: TPanel
    Left = 0
    Top = 0
    Width = 780
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    TabOrder = 0
    object lblDataInicial: TLabel
      Left = 8
      Top = 8
      Width = 24
      Height = 15
      Caption = 'De'
    end
    object lblDataFinal: TLabel
      Left = 240
      Top = 8
      Width = 20
      Height = 15
      Caption = 'At'#233
    end
    object dtpDataInicial: TDateTimePicker
      Left = 8
      Top = 20
      Width = 120
      Height = 23
      Date = 45900.000000000000000000
      Format = 'dd/MM/yyyy'
      Kind = dtkDate
      TabOrder = 0
    end
    object dtpDataFinal: TDateTimePicker
      Left = 240
      Top = 20
      Width = 120
      Height = 23
      Date = 45900.000000000000000000
      Format = 'dd/MM/yyyy'
      Kind = dtkDate
      TabOrder = 1
    end
    object btnBuscar: TButton
      Left = 372
      Top = 20
      Width = 100
      Height = 23
      Caption = 'Buscar'
      TabOrder = 2
      OnClick = btnBuscarClick
    end
  end
  object grdConsulta: TDBGrid
    Left = 0
    Top = 48
    Width = 780
    Height = 424
    Align = alClient
    DataSource = dsConsulta
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 472
    Width = 780
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 2
    object lblTotais: TLabel
      Left = 8
      Top = 16
      Width = 3
      Height = 15
    end
    object btnImprimir: TButton
      Left = 552
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Imprimir'
      TabOrder = 0
      OnClick = btnImprimirClick
    end
    object btnFechar: TButton
      Left = 664
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
  object dsConsulta: TDataSource
    Left = 720
    Top = 24
  end
end
