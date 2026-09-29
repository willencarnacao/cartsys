object FormClientes: TFormClientes
  Left = 0
  Top = 0
  Caption = 'Clientes'
  ClientHeight = 480
  ClientWidth = 820
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
    Width = 820
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
  object grdClientes: TDBGrid
    Left = 0
    Top = 40
    Width = 820
    Height = 392
    Align = alClient
    DataSource = dsClientes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 432
    Width = 820
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
      Width = 100
      Height = 32
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnEditar: TButton
      Left = 116
      Top = 8
      Width = 100
      Height = 32
      Caption = 'Editar'
      TabOrder = 1
      OnClick = btnEditarClick
    end
    object btnInativar: TButton
      Left = 224
      Top = 8
      Width = 100
      Height = 32
      Caption = 'Inativar'
      TabOrder = 2
      OnClick = btnInativarClick
    end
    object btnFechar: TButton
      Left = 712
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 3
      OnClick = btnFecharClick
    end
  end
  object dsClientes: TDataSource
    Left = 760
    Top = 48
  end
end
