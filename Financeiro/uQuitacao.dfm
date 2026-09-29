object FormQuitacao: TFormQuitacao
  Left = 0
  Top = 0
  Caption = 'Quita'#231#227'o / Cancelamento de Vendas'
  ClientHeight = 480
  ClientWidth = 760
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
  object grdQuitacao: TDBGrid
    Left = 0
    Top = 0
    Width = 760
    Height = 432
    Align = alClient
    DataSource = dsPendentes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 432
    Width = 760
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 1
    object btnQuitar: TButton
      Left = 8
      Top = 8
      Width = 120
      Height = 32
      Caption = 'Quitar'
      TabOrder = 0
      OnClick = btnQuitarClick
    end
    object btnCancelar: TButton
      Left = 136
      Top = 8
      Width = 120
      Height = 32
      Caption = 'Cancelar venda'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
    object btnAtualizar: TButton
      Left = 264
      Top = 8
      Width = 120
      Height = 32
      Caption = 'Atualizar'
      TabOrder = 2
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 652
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 3
      OnClick = btnFecharClick
    end
  end
  object dsPendentes: TDataSource
    Left = 700
    Top = 24
  end
end
