object FormConsulta: TFormConsulta
  Left = 0
  Top = 0
  Caption = 'Consulta'
  ClientHeight = 420
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object pnlFiltro: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblFiltro: TLabel
      Left = 16
      Top = 6
      Width = 29
      Height = 15
      Caption = 'Filtro'
    end
    object edtFiltro: TEdit
      Left = 16
      Top = 22
      Width = 500
      Height = 23
      TabOrder = 0
      OnKeyPress = edtFiltroKeyPress
    end
    object btnBuscar: TButton
      Left = 524
      Top = 21
      Width = 100
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClick
    end
  end
  object grdConsulta: TDBGrid
    Left = 0
    Top = 48
    Width = 640
    Height = 316
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
    OnDblClick = grdConsultaDblClick
    OnKeyDown = grdConsultaKeyDown
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 364
    Width = 640
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnSelecionar: TButton
      Left = 16
      Top = 12
      Width = 140
      Height = 32
      Caption = 'Selecionar'
      TabOrder = 0
      OnClick = btnSelecionarClick
    end
    object btnCancelar: TButton
      Left = 164
      Top = 12
      Width = 140
      Height = 32
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object dsConsulta: TDataSource
    Left = 584
    Top = 200
  end
end
