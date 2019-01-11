object frm_Print00: Tfrm_Print00
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frm_Print00'
  ClientHeight = 248
  ClientWidth = 634
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  DesignSize = (
    634
    248)
  PixelsPerInch = 96
  TextHeight = 14
  object JvGradient1: TJvGradient
    Left = 0
    Top = 0
    Width = 634
    Height = 208
    Style = grVertical
    StartColor = clWindow
    EndColor = clSilver
    ExplicitTop = -1
    ExplicitHeight = 313
  end
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 208
    Width = 634
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    DesignSize = (
      634
      40)
    object btn_Apply: TJvFooterBtn
      Left = 422
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btn_ApplyClick
      ButtonIndex = 0
      SpaceInterval = 6
    end
    object btn_Close: TJvFooterBtn
      Left = 526
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btn_CloseClick
      ButtonIndex = 1
      SpaceInterval = 6
    end
    object btn_Print: TJvFooterBtn
      Left = 8
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Pag. Teste'
      TabOrder = 2
      Visible = False
      OnClick = btn_PrintClick
      Alignment = taLeftJustify
      ButtonIndex = 2
      SpaceInterval = 6
    end
  end
  object gbx_Active: TAdvGroupBox
    Left = 5
    Top = 7
    Width = 621
    Height = 195
    BorderColor = clActiveCaption
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Ativar/Inativar '
    TabOrder = 1
    OnCheckBoxClick = gbx_ActiveCheckBoxClick
    object cbx_Modelo: TAdvComboBox
      Left = 107
      Top = 78
      Width = 200
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      LabelCaption = 'Modo de impress'#227'o:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 0
      OnChange = gbx_ActiveCheckBoxClick
    end
    object cbx_NPorta: TAdvComboBox
      Left = 107
      Top = 123
      Width = 200
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = False
      Style = csDropDownList
      EmptyTextStyle = []
      CharCase = ecUpperCase
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      LabelCaption = 'Porta:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 1
      OnChange = gbx_ActiveCheckBoxClick
      OnSelect = cbx_NPortaSelect
    end
    object cbx_Avanc: TAdvComboBox
      Left = 336
      Top = 35
      Width = 100
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '15'
        '20'
        '25'
        '30')
      LabelCaption = 'Avan'#231'os:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 4
      OnChange = gbx_ActiveCheckBoxClick
    end
    object cbx_Tenta: TAdvComboBox
      Left = 336
      Top = 78
      Width = 100
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = False
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = 0
      Items.Strings = (
        '3')
      LabelCaption = 'Tentativas:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 5
      Text = '3'
      OnChange = gbx_ActiveCheckBoxClick
    end
    object cbx_Corte: TAdvComboBox
      Left = 336
      Top = 123
      Width = 100
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = 1
      Items.Strings = (
        'SIM'
        'N'#195'O')
      LabelCaption = 'Corte:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 6
      Text = 'N'#195'O'
      OnChange = gbx_ActiveCheckBoxClick
    end
    object chk_Check: TAdvOfficeCheckBox
      Left = 464
      Top = 35
      Width = 120
      Height = 20
      TabOrder = 7
      OnClick = gbx_ActiveCheckBoxClick
      Alignment = taLeftJustify
      Caption = 'Checagem'
      ReturnIsTab = False
      Version = '1.3.7.0'
    end
    object chk_Expand: TAdvOfficeCheckBox
      Left = 464
      Top = 78
      Width = 120
      Height = 20
      TabOrder = 8
      OnClick = gbx_ActiveCheckBoxClick
      Alignment = taLeftJustify
      Caption = 'Utilizar Expandido'
      ReturnIsTab = False
      Version = '1.3.7.0'
    end
    object edt_Host: TAdvEdit
      Left = 107
      Top = 166
      Width = 200
      Height = 20
      EmptyTextStyle = []
      LabelCaption = 'Computador:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      Lookup.Font.Charset = DEFAULT_CHARSET
      Lookup.Font.Color = clWindowText
      Lookup.Font.Height = -11
      Lookup.Font.Name = 'Arial'
      Lookup.Font.Style = []
      Lookup.Separator = ';'
      CharCase = ecUpperCase
      Color = clWindow
      TabOrder = 2
      Text = 'EDT_HOST'
      Visible = False
      OnChange = gbx_ActiveCheckBoxClick
      Version = '3.3.2.0'
    end
    object cbx_DefCol: TAdvComboBox
      Left = 464
      Top = 123
      Width = 100
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      Items.Strings = (
        '48'
        '38'
        '32')
      LabelCaption = 'Colunas:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 9
      OnChange = gbx_ActiveCheckBoxClick
    end
    object edt_Descri: TAdvEdit
      Left = 107
      Top = 35
      Width = 200
      Height = 20
      EmptyTextStyle = []
      LabelCaption = 'Modelo da impressora:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      Lookup.Font.Charset = DEFAULT_CHARSET
      Lookup.Font.Color = clWindowText
      Lookup.Font.Height = -11
      Lookup.Font.Name = 'Arial'
      Lookup.Font.Style = []
      Lookup.Separator = ';'
      CharCase = ecUpperCase
      Color = clWindow
      TabOrder = 3
      Text = 'EDT_HOST'
      Visible = True
      OnChange = gbx_ActiveCheckBoxClick
      Version = '3.3.2.0'
    end
  end
  object ACBrPosPrinter1: TACBrPosPrinter
    ConfigBarras.MostrarCodigo = False
    ConfigBarras.LarguraLinha = 0
    ConfigBarras.Altura = 0
    ConfigBarras.Margem = 0
    ConfigQRCode.Tipo = 2
    ConfigQRCode.LarguraModulo = 4
    ConfigQRCode.ErrorLevel = 0
    LinhasEntreCupons = 0
    Left = 32
    Top = 40
  end
end
