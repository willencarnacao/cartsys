object FormConfigEmail: TFormConfigEmail
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'E-mail (SMTP)'
  ClientHeight = 544
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object lblAviso: TLabel
    Left = 24
    Top = 16
    Width = 352
    Height = 30
    Caption = 'A senha '#233' gravada criptografada. Ela n'#227'o volta para o CartSys.ini.'
    WordWrap = True
  end
  object lblServidor: TLabel
    Left = 24
    Top = 52
    Width = 46
    Height = 15
    Caption = 'Servidor'
  end
  object edtServidor: TEdit
    Left = 24
    Top = 72
    Width = 352
    Height = 23
    TabOrder = 0
  end
  object lblPorta: TLabel
    Left = 24
    Top = 104
    Width = 28
    Height = 15
    Caption = 'Porta'
  end
  object edtPorta: TEdit
    Left = 24
    Top = 124
    Width = 80
    Height = 23
    TabOrder = 1
    Text = '587'
  end
  object lblUsuario: TLabel
    Left = 24
    Top = 156
    Width = 41
    Height = 15
    Caption = 'Usu'#225'rio'
  end
  object edtUsuario: TEdit
    Left = 24
    Top = 176
    Width = 352
    Height = 23
    TabOrder = 2
  end
  object lblSenha: TLabel
    Left = 24
    Top = 208
    Width = 33
    Height = 15
    Caption = 'Senha'
  end
  object edtSenha: TEdit
    Left = 24
    Top = 228
    Width = 352
    Height = 23
    PasswordChar = '*'
    TabOrder = 3
  end
  object lblSenhaDica: TLabel
    Left = 24
    Top = 256
    Width = 352
    Height = 30
    Caption = 'Em branco mant'#233'm a senha j'#225' salva. No Gmail, use uma senha de app.'
    WordWrap = True
  end
  object chkTls: TCheckBox
    Left = 24
    Top = 292
    Width = 97
    Height = 17
    Caption = 'Usar TLS'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object lblNome: TLabel
    Left = 24
    Top = 320
    Width = 113
    Height = 15
    Caption = 'Nome do remetente'
  end
  object edtNome: TEdit
    Left = 24
    Top = 340
    Width = 352
    Height = 23
    TabOrder = 5
  end
  object lblRemetente: TLabel
    Left = 24
    Top = 372
    Width = 114
    Height = 15
    Caption = 'E-mail do remetente'
  end
  object edtRemetente: TEdit
    Left = 24
    Top = 392
    Width = 352
    Height = 23
    TabOrder = 6
  end
  object lblTeste: TLabel
    Left = 24
    Top = 424
    Width = 92
    Height = 15
    Caption = 'E-mail para teste'
  end
  object edtTeste: TEdit
    Left = 24
    Top = 444
    Width = 352
    Height = 23
    TabOrder = 7
  end
  object btnSalvar: TButton
    Left = 24
    Top = 492
    Width = 110
    Height = 32
    Caption = 'Salvar'
    Default = True
    TabOrder = 8
    OnClick = btnSalvarClick
  end
  object btnTeste: TButton
    Left = 142
    Top = 492
    Width = 130
    Height = 32
    Caption = 'Enviar teste'
    TabOrder = 9
    OnClick = btnTesteClick
  end
  object btnFechar: TButton
    Left = 280
    Top = 492
    Width = 96
    Height = 32
    Caption = 'Fechar'
    Cancel = True
    ModalResult = 2
    TabOrder = 10
  end
end
