object FormCadUsuario: TFormCadUsuario
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Usu'#225'rio'
  ClientHeight = 330
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object lblLogin: TLabel
    Left = 24
    Top = 20
    Width = 33
    Height = 15
    Caption = 'Login'
  end
  object lblNome: TLabel
    Left = 24
    Top = 68
    Width = 33
    Height = 15
    Caption = 'Nome'
  end
  object lblEmail: TLabel
    Left = 24
    Top = 116
    Width = 33
    Height = 15
    Caption = 'E-mail'
  end
  object edtLogin: TEdit
    Left = 24
    Top = 40
    Width = 332
    Height = 23
    TabOrder = 0
  end
  object edtNome: TEdit
    Left = 24
    Top = 88
    Width = 332
    Height = 23
    TabOrder = 1
  end
  object edtEmail: TEdit
    Left = 24
    Top = 136
    Width = 332
    Height = 23
    TabOrder = 2
  end
  object chkAdmin: TCheckBox
    Left = 24
    Top = 172
    Width = 160
    Height = 17
    Caption = 'Administrador'
    TabOrder = 3
  end
  object chkAtivo: TCheckBox
    Left = 196
    Top = 172
    Width = 160
    Height = 17
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object chkVendas: TCheckBox
    Left = 24
    Top = 196
    Width = 160
    Height = 17
    Caption = 'Acessa Vendas'
    TabOrder = 5
  end
  object chkFinanceiro: TCheckBox
    Left = 196
    Top = 196
    Width = 160
    Height = 17
    Caption = 'Acessa Financeiro'
    TabOrder = 6
  end
  object btnSalvar: TButton
    Left = 24
    Top = 280
    Width = 160
    Height = 32
    Caption = 'Salvar'
    Default = True
    TabOrder = 7
    OnClick = btnSalvarClick
  end
  object btnCancelar: TButton
    Left = 196
    Top = 280
    Width = 160
    Height = 32
    Caption = 'Cancelar'
    Cancel = True
    ModalResult = 2
    TabOrder = 8
  end
end
