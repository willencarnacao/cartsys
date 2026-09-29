object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'CartSys - Vendas'
  ClientHeight = 368
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlMenu: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 349
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 32
    Padding.Top = 32
    Padding.Right = 32
    TabOrder = 0
    object btnClientes: TButton
      Left = 32
      Top = 32
      Width = 356
      Height = 40
      Caption = 'Clientes'
      TabOrder = 0
      OnClick = btnClientesClick
    end
    object btnProdutos: TButton
      Left = 32
      Top = 80
      Width = 356
      Height = 40
      Caption = 'Produtos'
      TabOrder = 1
      OnClick = btnProdutosClick
    end
    object btnVendas: TButton
      Left = 32
      Top = 128
      Width = 356
      Height = 40
      Caption = 'Vendas'
      TabOrder = 2
      OnClick = btnVendasClick
    end
    object btnEmail: TButton
      Left = 32
      Top = 176
      Width = 356
      Height = 40
      Caption = 'E-mail (SMTP)'
      TabOrder = 3
      OnClick = btnEmailClick
    end
    object btnSair: TButton
      Left = 32
      Top = 240
      Width = 356
      Height = 32
      Caption = 'Sair'
      TabOrder = 4
      OnClick = btnSairClick
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 349
    Width = 420
    Height = 19
    Panels = <
      item
        Width = 400
      end>
  end
end
