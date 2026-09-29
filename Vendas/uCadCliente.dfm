object FormCadCliente: TFormCadCliente
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Cliente'
  ClientHeight = 460
  ClientWidth = 420
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
  object lblNome: TLabel
    Left = 24
    Top = 12
    Width = 33
    Height = 15
    Caption = 'Nome'
  end
  object lblTipo: TLabel
    Left = 24
    Top = 56
    Width = 21
    Height = 15
    Caption = 'Tipo'
  end
  object lblDoc: TLabel
    Left = 220
    Top = 56
    Width = 54
    Height = 15
    Caption = 'CPF/CNPJ'
  end
  object lblEmail: TLabel
    Left = 24
    Top = 100
    Width = 33
    Height = 15
    Caption = 'E-mail'
  end
  object lblFone: TLabel
    Left = 24
    Top = 144
    Width = 46
    Height = 15
    Caption = 'Telefone'
  end
  object lblCep: TLabel
    Left = 220
    Top = 144
    Width = 21
    Height = 15
    Caption = 'CEP'
  end
  object lblLog: TLabel
    Left = 24
    Top = 188
    Width = 63
    Height = 15
    Caption = 'Logradouro'
  end
  object lblNum: TLabel
    Left = 320
    Top = 188
    Width = 15
    Height = 15
    Caption = 'N'#186
  end
  object lblBairro: TLabel
    Left = 24
    Top = 232
    Width = 32
    Height = 15
    Caption = 'Bairro'
  end
  object lblCidade: TLabel
    Left = 24
    Top = 276
    Width = 37
    Height = 15
    Caption = 'Cidade'
  end
  object lblUf: TLabel
    Left = 320
    Top = 276
    Width = 14
    Height = 15
    Caption = 'UF'
  end
  object edtNome: TEdit
    Left = 24
    Top = 28
    Width = 372
    Height = 23
    TabOrder = 0
  end
  object cmbTipo: TComboBox
    Left = 24
    Top = 72
    Width = 180
    Height = 23
    Style = csDropDownList
    TabOrder = 1
  end
  object edtDoc: TEdit
    Left = 220
    Top = 72
    Width = 176
    Height = 23
    TabOrder = 2
  end
  object edtEmail: TEdit
    Left = 24
    Top = 116
    Width = 372
    Height = 23
    TabOrder = 3
  end
  object edtFone: TEdit
    Left = 24
    Top = 160
    Width = 180
    Height = 23
    TabOrder = 4
  end
  object edtCep: TEdit
    Left = 220
    Top = 160
    Width = 176
    Height = 23
    TabOrder = 5
  end
  object edtLog: TEdit
    Left = 24
    Top = 204
    Width = 280
    Height = 23
    TabOrder = 6
  end
  object edtNum: TEdit
    Left = 320
    Top = 204
    Width = 76
    Height = 23
    TabOrder = 7
  end
  object edtBairro: TEdit
    Left = 24
    Top = 248
    Width = 372
    Height = 23
    TabOrder = 8
  end
  object edtCidade: TEdit
    Left = 24
    Top = 292
    Width = 280
    Height = 23
    TabOrder = 9
  end
  object cmbUf: TComboBox
    Left = 320
    Top = 292
    Width = 76
    Height = 23
    Style = csDropDownList
    TabOrder = 10
  end
  object chkAtivo: TCheckBox
    Left = 24
    Top = 328
    Width = 97
    Height = 17
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 11
  end
  object btnSalvar: TButton
    Left = 24
    Top = 408
    Width = 180
    Height = 32
    Caption = 'Salvar'
    Default = True
    TabOrder = 12
    OnClick = btnSalvarClick
  end
  object btnCancelar: TButton
    Left = 216
    Top = 408
    Width = 180
    Height = 32
    Caption = 'Cancelar'
    Cancel = True
    ModalResult = 2
    TabOrder = 13
  end
end
