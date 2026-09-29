object FormCadVenda: TFormCadVenda
  Left = 0
  Top = 0
  Caption = 'Venda'
  ClientHeight = 560
  ClientWidth = 840
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  KeyPreview = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 15
  object pnlCab: TPanel
    Left = 0
    Top = 0
    Width = 840
    Height = 120
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblCliente: TLabel
      Left = 16
      Top = 12
      Width = 37
      Height = 15
      Caption = 'Cliente'
    end
    object lblVenc: TLabel
      Left = 520
      Top = 12
      Width = 64
      Height = 15
      Caption = 'Vencimento'
    end
    object lblDesconto: TLabel
      Left = 680
      Top = 12
      Width = 80
      Height = 15
      Caption = 'Desconto (R$)'
    end
    object lblObs: TLabel
      Left = 16
      Top = 60
      Width = 64
      Height = 15
      Caption = 'Observa'#231#227'o'
    end
    object lblStatus: TLabel
      Left = 680
      Top = 60
      Width = 40
      Height = 15
      Caption = 'Status'
    end
    object edtClienteCodigo: TEdit
      Left = 16
      Top = 28
      Width = 140
      Height = 23
      TabOrder = 0
      ReadOnly = True
    end
    object btnCliente: TButton
      Left = 156
      Top = 27
      Width = 25
      Height = 25
      Hint = 'Consulta (F4)'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnClienteClick
    end
    object edtClienteNome: TEdit
      Left = 184
      Top = 28
      Width = 320
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 2
    end
    object dtpVenc: TDateTimePicker
      Left = 520
      Top = 28
      Width = 144
      Height = 23
      Date = 45900.000000000000000000
      Format = 'dd/MM/yyyy'
      Kind = dtkDate
      ShowCheckbox = True
      TabOrder = 3
    end
    object edtDesconto: TEdit
      Left = 680
      Top = 28
      Width = 140
      Height = 23
      TabOrder = 4
    end
    object edtObs: TEdit
      Left = 16
      Top = 76
      Width = 648
      Height = 23
      TabOrder = 5
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 120
    Width = 840
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblProduto: TLabel
      Left = 16
      Top = 4
      Width = 42
      Height = 15
      Caption = 'Produto'
    end
    object lblQtd: TLabel
      Left = 360
      Top = 4
      Width = 21
      Height = 15
      Caption = 'Qtd'
    end
    object lblPreco: TLabel
      Left = 440
      Top = 4
      Width = 29
      Height = 15
      Caption = 'Pre'#231'o'
    end
    object lblDescItem: TLabel
      Left = 544
      Top = 4
      Width = 40
      Height = 15
      Caption = 'Desc. %'
    end
    object edtProdutoCodigo: TEdit
      Left = 16
      Top = 24
      Width = 90
      Height = 23
      TabOrder = 0
      ReadOnly = True
    end
    object btnProduto: TButton
      Left = 106
      Top = 23
      Width = 25
      Height = 25
      Hint = 'Consulta (F4)'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnProdutoClick
    end
    object edtProdutoNome: TEdit
      Left = 134
      Top = 24
      Width = 214
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 2
    end
    object edtQtd: TEdit
      Left = 360
      Top = 24
      Width = 68
      Height = 23
      TabOrder = 3
      Text = '1'
      OnExit = edtItemExit
    end
    object edtPreco: TEdit
      Left = 440
      Top = 24
      Width = 92
      Height = 23
      TabOrder = 4
      OnExit = edtItemExit
    end
    object edtDescItem: TEdit
      Left = 544
      Top = 24
      Width = 80
      Height = 23
      TabOrder = 5
      Text = '0'
      OnExit = edtItemExit
    end
    object btnAddItem: TButton
      Left = 636
      Top = 22
      Width = 80
      Height = 25
      Caption = 'Incluir'
      TabOrder = 6
      OnClick = btnAddItemClick
    end
    object btnRemItem: TButton
      Left = 724
      Top = 22
      Width = 96
      Height = 25
      Caption = 'Remover'
      TabOrder = 7
      OnClick = btnRemItemClick
    end
  end
  object grdItens: TDBGrid
    Left = 0
    Top = 176
    Width = 840
    Height = 292
    Align = alClient
    DataSource = dsItens
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = False
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 468
    Width = 840
    Height = 64
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblTotal: TLabel
      Left = 16
      Top = 20
      Width = 36
      Height = 15
      Caption = 'Total:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
    end
    object btnSalvar: TButton
      Left = 408
      Top = 16
      Width = 120
      Height = 28
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnImprimir: TButton
      Left = 556
      Top = 16
      Width = 120
      Height = 28
      Caption = 'Imprimir'
      TabOrder = 1
      OnClick = btnImprimirClick
    end
    object btnFechar: TButton
      Left = 704
      Top = 16
      Width = 120
      Height = 28
      Caption = 'Fechar'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object dsItens: TDataSource
    Left = 792
    Top = 200
  end
end
