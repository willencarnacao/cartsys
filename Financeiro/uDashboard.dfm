object FormDashboard: TFormDashboard
  Left = 0
  Top = 0
  Caption = 'Dashboard'
  ClientHeight = 680
  ClientWidth = 900
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
  object pnlCards: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Top = 12
    Padding.Right = 12
    TabOrder = 0
    object pnlCardPendente: TPanel
      Left = 12
      Top = 12
      Width = 210
      Height = 96
      BevelOuter = bvLowered
      TabOrder = 0
      object lblCardPendenteTitulo: TLabel
        Left = 12
        Top = 10
        Width = 100
        Height = 15
        Caption = 'Pendentes (0)'
      end
      object lblCardPendenteValor: TLabel
        Left = 12
        Top = 40
        Width = 80
        Height = 25
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlCardRealizado: TPanel
      Left = 234
      Top = 12
      Width = 210
      Height = 96
      BevelOuter = bvLowered
      TabOrder = 1
      object lblCardRealizadoTitulo: TLabel
        Left = 12
        Top = 10
        Width = 100
        Height = 15
        Caption = 'Finalizados (0)'
      end
      object lblCardRealizadoValor: TLabel
        Left = 12
        Top = 40
        Width = 80
        Height = 25
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlCardTicket: TPanel
      Left = 456
      Top = 12
      Width = 210
      Height = 96
      BevelOuter = bvLowered
      TabOrder = 2
      object lblCardTicketTitulo: TLabel
        Left = 12
        Top = 10
        Width = 120
        Height = 15
        Caption = 'Ticket m'#233'dio'
      end
      object lblCardTicketValor: TLabel
        Left = 12
        Top = 40
        Width = 80
        Height = 25
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlCardCanceladas: TPanel
      Left = 678
      Top = 12
      Width = 210
      Height = 96
      BevelOuter = bvLowered
      TabOrder = 3
      object lblCardCanceladasTitulo: TLabel
        Left = 12
        Top = 10
        Width = 70
        Height = 15
        Caption = 'Canceladas'
      end
      object lblCardCanceladasValor: TLabel
        Left = 12
        Top = 40
        Width = 20
        Height = 25
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object pnlGrafico: TPanel
    Left = 0
    Top = 120
    Width = 900
    Height = 170
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Right = 12
    TabOrder = 1
    object lblGrafico: TLabel
      Left = 12
      Top = 4
      Width = 210
      Height = 15
      Caption = 'Projetado x realizado por m'#234's'
    end
    object pbMes: TPaintBox
      Left = 12
      Top = 24
      Width = 876
      Height = 138
      OnPaint = pbMesPaint
    end
  end
  object pnlListas: TPanel
    Left = 0
    Top = 290
    Width = 900
    Height = 342
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Right = 12
    TabOrder = 2
    object lblTopProdutos: TLabel
      Left = 12
      Top = 8
      Width = 89
      Height = 15
      Caption = 'Top 5 Produtos'
    end
    object lblTopClientes: TLabel
      Left = 312
      Top = 8
      Width = 84
      Height = 15
      Caption = 'Top 5 Clientes'
    end
    object lblForma: TLabel
      Left = 612
      Top = 8
      Width = 120
      Height = 15
      Caption = 'Por forma de pagamento'
    end
    object grdProdutos: TDBGrid
      Left = 12
      Top = 28
      Width = 288
      Height = 300
      DataSource = dsTopProdutos
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
    object grdClientes: TDBGrid
      Left = 312
      Top = 28
      Width = 288
      Height = 300
      DataSource = dsTopClientes
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
    object grdForma: TDBGrid
      Left = 612
      Top = 28
      Width = 276
      Height = 300
      DataSource = dsForma
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      ReadOnly = True
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 632
    Width = 900
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 3
    object btnAtualizar: TButton
      Left = 8
      Top = 8
      Width = 120
      Height = 32
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = btnAtualizarClick
    end
    object btnFechar: TButton
      Left = 792
      Top = 8
      Width = 100
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
  object dsTopProdutos: TDataSource
    Left = 720
    Top = 24
  end
  object dsTopClientes: TDataSource
    Left = 760
    Top = 24
  end
  object dsForma: TDataSource
    Left = 800
    Top = 24
  end
end
