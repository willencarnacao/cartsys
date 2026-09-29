object FormVendas: TFormVendas
  Left = 0
  Top = 0
  Caption = 'Vendas'
  ClientHeight = 500
  ClientWidth = 880
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
    Width = 880
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    TabOrder = 0
    object edtFiltro: TEdit
      Left = 8
      Top = 8
      Width = 280
      Height = 23
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 296
      Top = 8
      Width = 90
      Height = 23
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
  end
  object grdVendas: TDBGrid
    Left = 0
    Top = 40
    Width = 880
    Height = 412
    Align = alClient
    DataSource = dsVendas
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = grdVendasDblClick
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 452
    Width = 880
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 2
    object btnNovo: TButton
      Left = 8
      Top = 8
      Width = 90
      Height = 32
      Caption = 'Nova'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnAbrir: TButton
      Left = 104
      Top = 8
      Width = 90
      Height = 32
      Caption = 'Abrir'
      TabOrder = 1
      OnClick = btnAbrirClick
    end
    object btnConfirmar: TButton
      Left = 200
      Top = 8
      Width = 100
      Height = 32
      Caption = 'Confirmar'
      TabOrder = 2
      OnClick = btnConfirmarClick
    end
    object btnExcluir: TButton
      Left = 306
      Top = 8
      Width = 90
      Height = 32
      Caption = 'Excluir'
      TabOrder = 3
      OnClick = btnExcluirClick
    end
    object btnImprimir: TButton
      Left = 402
      Top = 8
      Width = 110
      Height = 32
      Caption = 'Imprimir pedido'
      TabOrder = 4
      OnClick = btnImprimirClick
    end
    object btnFechar: TButton
      Left = 772
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 5
      OnClick = btnFecharClick
    end
  end
  object dsVendas: TDataSource
    Left = 820
    Top = 48
  end
end
