object FormTrocaSenha: TFormTrocaSenha
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Troca de senha'
  ClientHeight = 300
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object lblInfo: TLabel
    Left = 24
    Top = 16
    Width = 312
    Height = 30
    Caption = 'Sua senha '#233' tempor'#225'ria. Defina uma senha definitiva para continuar.'
    WordWrap = True
  end
  object lblAtual: TLabel
    Left = 24
    Top = 56
    Width = 68
    Height = 15
    Caption = 'Senha atual'
  end
  object lblNova: TLabel
    Left = 24
    Top = 104
    Width = 64
    Height = 15
    Caption = 'Nova senha'
  end
  object lblConfirma: TLabel
    Left = 24
    Top = 152
    Width = 110
    Height = 15
    Caption = 'Confirmar nova senha'
  end
  object edtAtual: TEdit
    Left = 24
    Top = 76
    Width = 312
    Height = 23
    PasswordChar = '*'
    TabOrder = 0
  end
  object edtNova: TEdit
    Left = 24
    Top = 124
    Width = 312
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object edtConfirma: TEdit
    Left = 24
    Top = 172
    Width = 312
    Height = 23
    PasswordChar = '*'
    TabOrder = 2
  end
  object btnSalvar: TButton
    Left = 24
    Top = 248
    Width = 150
    Height = 32
    Caption = 'Salvar e entrar'
    Default = True
    TabOrder = 3
    OnClick = btnSalvarClick
  end
  object btnCancelar: TButton
    Left = 186
    Top = 248
    Width = 150
    Height = 32
    Caption = 'Cancelar'
    Cancel = True
    ModalResult = 2
    TabOrder = 4
  end
end
