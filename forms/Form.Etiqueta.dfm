object frm_ConfigEtq: Tfrm_ConfigEtq
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'Configura'#231#227'o/Impress'#227'o de etiquetas customizadas'
  ClientHeight = 372
  ClientWidth = 628
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 332
    Width = 628
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    DesignSize = (
      628
      40)
    object btn_Print: TJvFooterBtn
      Left = 416
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Imprimir'
      TabOrder = 1
      OnClick = btn_PrintClick
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -12
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      ButtonIndex = 0
      SpaceInterval = 6
    end
    object btn_Close: TJvFooterBtn
      Left = 520
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btn_CloseClick
      HotTrackFont.Charset = DEFAULT_CHARSET
      HotTrackFont.Color = clWindowText
      HotTrackFont.Height = -12
      HotTrackFont.Name = 'Tahoma'
      HotTrackFont.Style = []
      ButtonIndex = 1
      SpaceInterval = 6
    end
  end
  object gbx_Etq: TAdvGroupBox
    Left = 0
    Top = 0
    Width = 628
    Height = 188
    BorderColor = clActiveCaption
    Align = alTop
    Caption = ' Etiqueta   '
    TabOrder = 1
    object edt_MLeft: TAdvSpinEdit
      Left = 216
      Top = 57
      Width = 121
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Margem Esquerda:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 1
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_MTop: TAdvSpinEdit
      Left = 480
      Top = 57
      Width = 121
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Margem Superior:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 2
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_EtqW: TAdvSpinEdit
      Left = 216
      Top = 86
      Width = 121
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Largura:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 3
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_EtqH: TAdvSpinEdit
      Left = 480
      Top = 86
      Width = 121
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Altura:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 4
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_PagRows: TAdvSpinEdit
      Left = 216
      Top = 115
      Width = 121
      Height = 23
      Value = 0
      DateValue = 43028.745143645840000000
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Linhas por p'#225'ginas:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 5
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_PagCols: TAdvSpinEdit
      Left = 480
      Top = 115
      Width = 121
      Height = 23
      Value = 0
      DateValue = 43028.745143645840000000
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Etiquetas por linhas:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 6
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_Space: TAdvSpinEdit
      Left = 480
      Top = 144
      Width = 121
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Espa'#231'o entre etiquetas:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 7
      Visible = True
      Version = '1.6.0.0'
    end
    object cbx_Layout: TAdvComboBox
      Left = 120
      Top = 20
      Width = 481
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
        '3 x 1(105mm x 58mm)'
        '3 x 1(106mm x 22mm)'
        '1 x 1(110mm x 30mm)'
        '3 x 1(30mm x 15mm)'
        '1 x 1(90mm x 30mm)')
      LabelCaption = 'Leiaute:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 0
      OnSelect = cbx_LayoutSelect
    end
  end
  object gbx_Opt: TAdvGroupBox
    Left = 0
    Top = 188
    Width = 628
    Height = 125
    BorderColor = clActiveCaption
    Align = alTop
    Caption = ' Op'#231#245'es  '
    TabOrder = 2
    object cbx_Printers: TAdvComboBox
      Left = 216
      Top = 25
      Width = 249
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      LabelCaption = 'Impressoras:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 0
      OnSelect = cbx_PrintersSelect
    end
    object cbx_Forms: TAdvComboBox
      Left = 216
      Top = 53
      Width = 249
      Height = 22
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      DropWidth = 0
      Enabled = True
      ItemIndex = -1
      LabelCaption = 'Papel:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 1
    end
    object rg_Orient: TAdvOfficeRadioGroup
      Left = 480
      Top = 13
      Width = 121
      Height = 95
      CaptionPosition = cpTopCenter
      Version = '1.3.7.0'
      Caption = ' Orienta'#231#227'o '
      ParentBackground = False
      TabOrder = 2
      ItemIndex = 0
      Items.Strings = (
        'Retrato'
        'Paisagem'
        'Retrato 180'
        'Paisagem 180')
      Ellipsis = False
    end
    object edt_PageW: TAdvSpinEdit
      Left = 216
      Top = 81
      Width = 249
      Height = 23
      Precision = 2
      SpinType = sptFloat
      Value = 0
      HexValue = 0
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Limite:'
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clWindowText
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      TabOrder = 3
      Visible = True
      Version = '1.6.0.0'
    end
  end
end
