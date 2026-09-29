object FormLogin: TFormLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'CartSys - Login'
  ClientHeight = 290
  ClientWidth = 524
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlLogin: TPanel
    Left = 0
    Top = 0
    Width = 524
    Height = 340
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 358
    ExplicitHeight = 332
    object lblTitulo: TLabel
      Left = 24
      Top = 20
      Width = 65
      Height = 25
      Caption = 'CartSys'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI Semibold'
      Font.Style = []
      ParentFont = False
    end
    object lblLogin: TLabel
      Left = 24
      Top = 70
      Width = 40
      Height = 15
      Caption = 'Usu'#225'rio'
    end
    object lblSenha: TLabel
      Left = 24
      Top = 120
      Width = 32
      Height = 15
      Caption = 'Senha'
    end
    object lblCodigo: TLabel
      Left = 24
      Top = 170
      Width = 126
      Height = 15
      Caption = 'C'#243'digo do autenticador'
    end
    object edtLogin: TEdit
      Left = 24
      Top = 90
      Width = 312
      Height = 23
      TabOrder = 0
    end
    object edtSenha: TEdit
      Left = 24
      Top = 140
      Width = 312
      Height = 23
      PasswordChar = '*'
      TabOrder = 1
    end
    object edtCodigo: TEdit
      Left = 24
      Top = 190
      Width = 120
      Height = 23
      TabOrder = 2
      OnKeyPress = edtCodigoKeyPress
    end
    object btnEntrar: TButton
      Left = 24
      Top = 232
      Width = 312
      Height = 32
      Caption = 'Entrar'
      Default = True
      TabOrder = 3
      OnClick = btnEntrarClick
    end
  end
  object pnlPareamento: TPanel
    Left = 0
    Top = 0
    Width = 524
    Height = 340
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    ExplicitWidth = 358
    ExplicitHeight = 332
    object lblParInfo: TLabel
      Left = 24
      Top = 16
      Width = 672
      Height = 56
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'Abra o Microsoft Authenticator, adicione uma conta e aponte a c'#226 +
        'mera para o QR Code.'#13#10'Se preferir, digite a chave abaixo.'
      WordWrap = True
    end
    object imgQr: TImage
      Left = 216
      Top = 76
      Width = 288
      Height = 288
      Center = True
      IncrementalDisplay = False
      Proportional = False
      Stretch = False
    end
    object lblParChaveTitulo: TLabel
      Left = 24
      Top = 280
      Width = 174
      Height = 15
      Caption = 'Chave para inserir manualmente:'
    end
    object lblParChave: TLabel
      Left = 24
      Top = 296
      Width = 472
      Height = 32
      AutoSize = False
      Caption = 'XXXXXXXXXXXXXXXX'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object lblParCodigo: TLabel
      Left = 24
      Top = 336
      Width = 204
      Height = 15
      Caption = 'Digite o c'#243'digo gerado pelo aplicativo:'
    end
    object memoUri: TMemo
      Left = 24
      Top = 420
      Width = 472
      Height = 40
      TabStop = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      Visible = False
    end
    object edtCodigoPareamento: TEdit
      Left = 24
      Top = 354
      Width = 120
      Height = 23
      TabOrder = 1
      OnKeyPress = edtCodigoKeyPress
    end
    object btnConfirmarPareamento: TButton
      Left = 24
      Top = 508
      Width = 472
      Height = 32
      Caption = 'Confirmar e entrar'
      Default = True
      TabOrder = 2
      OnClick = btnConfirmarPareamentoClick
    end
  end
end
