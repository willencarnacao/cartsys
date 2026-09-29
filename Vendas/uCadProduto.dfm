object FormCadProduto: TFormCadProduto
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Produto'
  ClientHeight = 280
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
  object lblCodigo: TLabel
    Left = 24
    Top = 16
    Width = 39
    Height = 15
    Caption = 'C'#243'digo'
  end
  object lblDescricao: TLabel
    Left = 24
    Top = 64
    Width = 53
    Height = 15
    Caption = 'Descri'#231#227'o'
  end
  object lblUnidade: TLabel
    Left = 24
    Top = 112
    Width = 43
    Height = 15
    Caption = 'Unidade'
  end
  object lblPreco: TLabel
    Left = 160
    Top = 112
    Width = 71
    Height = 15
    Caption = 'Pre'#231'o de venda'
  end
  object edtCodigo: TEdit
    Left = 24
    Top = 36
    Width = 332
    Height = 23
    TabOrder = 0
  end
  object edtDescricao: TEdit
    Left = 24
    Top = 84
    Width = 332
    Height = 23
    TabOrder = 1
  end
  object edtUnidade: TEdit
    Left = 24
    Top = 132
    Width = 120
    Height = 23
    TabOrder = 2
  end
  object edtPreco: TEdit
    Left = 160
    Top = 132
    Width = 196
    Height = 23
    TabOrder = 3
  end
  object chkAtivo: TCheckBox
    Left = 24
    Top = 164
    Width = 97
    Height = 17
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object btnSalvar: TButton
    Left = 24
    Top = 228
    Width = 160
    Height = 32
    Caption = 'Salvar'
    Default = True
    TabOrder = 5
    OnClick = btnSalvarClick
  end
  object btnCancelar: TButton
    Left = 196
    Top = 228
    Width = 160
    Height = 32
    Caption = 'Cancelar'
    Cancel = True
    ModalResult = 2
    TabOrder = 6
  end
end
