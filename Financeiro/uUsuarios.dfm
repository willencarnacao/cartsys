object FormUsuarios: TFormUsuarios
  Left = 0
  Top = 0
  Caption = 'Usu'#225'rios'
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
  object grdUsuarios: TDBGrid
    Left = 0
    Top = 0
    Width = 820
    Height = 432
    Align = alClient
    DataSource = dsUsuarios
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
    Width = 820
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 1
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
    object btnRedefinirSenha: TButton
      Left = 224
      Top = 8
      Width = 150
      Height = 32
      Caption = 'Redefinir senha'
      TabOrder = 2
      OnClick = btnRedefinirSenhaClick
    end
    object btnDesbloquear: TButton
      Left = 382
      Top = 8
      Width = 120
      Height = 32
      Caption = 'Desbloquear'
      TabOrder = 3
      OnClick = btnDesbloquearClick
    end
    object btnFechar: TButton
      Left = 712
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 4
      OnClick = btnFecharClick
    end
  end
  object dsUsuarios: TDataSource
    Left = 760
    Top = 24
  end
end
