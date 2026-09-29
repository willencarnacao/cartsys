object FormQuitacaoBaixa: TFormQuitacaoBaixa
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Quitar venda'
  ClientHeight = 280
  ClientWidth = 340
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
  object lblVenda: TLabel
    Left = 24
    Top = 16
    Width = 60
    Height = 20
    Caption = 'Venda #0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI Semibold'
    Font.Style = []
    ParentFont = False
  end
  object lblValor: TLabel
    Left = 24
    Top = 56
    Width = 82
    Height = 15
    Caption = 'Valor recebido'
  end
  object lblForma: TLabel
    Left = 24
    Top = 104
    Width = 100
    Height = 15
    Caption = 'Forma de pagamento'
  end
  object lblObs: TLabel
    Left = 24
    Top = 152
    Width = 111
    Height = 15
    Caption = 'Observa'#231#227'o (opcional)'
  end
  object edtValor: TEdit
    Left = 24
    Top = 76
    Width = 292
    Height = 23
    TabOrder = 0
  end
  object cmbForma: TComboBox
    Left = 24
    Top = 124
    Width = 292
    Height = 23
    Style = csDropDownList
    TabOrder = 1
  end
  object edtObs: TEdit
    Left = 24
    Top = 172
    Width = 292
    Height = 23
    TabOrder = 2
  end
  object btnConfirmar: TButton
    Left = 24
    Top = 228
    Width = 140
    Height = 32
    Caption = 'Confirmar'
    Default = True
    TabOrder = 3
    OnClick = btnConfirmarClick
  end
  object btnCancelar: TButton
    Left = 176
    Top = 228
    Width = 140
    Height = 32
    Caption = 'Cancelar'
    Cancel = True
    ModalResult = 2
    TabOrder = 4
  end
end
