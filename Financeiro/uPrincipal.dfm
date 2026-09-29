object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'CartSys - Financeiro'
  ClientHeight = 360
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object pnlMenu: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 341
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 32
    Padding.Top = 32
    Padding.Right = 32
    TabOrder = 0
    object btnQuitacao: TButton
      Left = 32
      Top = 32
      Width = 356
      Height = 40
      Caption = 'Quita'#231#227'o / Cancelamento de Vendas'
      TabOrder = 0
      OnClick = btnQuitacaoClick
    end
    object btnConsultas: TButton
      Left = 32
      Top = 80
      Width = 356
      Height = 40
      Caption = 'Consultas e Relat'#243'rio Financeiro'
      TabOrder = 1
      OnClick = btnConsultasClick
    end
    object btnDashboard: TButton
      Left = 32
      Top = 128
      Width = 356
      Height = 40
      Caption = 'Dashboard'
      TabOrder = 2
      OnClick = btnDashboardClick
    end
    object btnUsuarios: TButton
      Left = 32
      Top = 176
      Width = 356
      Height = 40
      Caption = 'Usu'#225'rios (cadastro / desbloqueio)'
      TabOrder = 3
      OnClick = btnUsuariosClick
    end
    object btnSair: TButton
      Left = 32
      Top = 248
      Width = 356
      Height = 32
      Caption = 'Sair'
      TabOrder = 4
      OnClick = btnSairClick
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 341
    Width = 420
    Height = 19
    Panels = <
      item
        Width = 400
      end>
  end
end
