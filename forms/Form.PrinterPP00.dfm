object frm_PrinterPP00: Tfrm_PrinterPP00
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configura ponto Produ'#231#227'o/Impress'#227'o'
  ClientHeight = 572
  ClientWidth = 794
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    794
    572)
  PixelsPerInch = 96
  TextHeight = 14
  object JvGradient1: TJvGradient
    Left = 0
    Top = 0
    Width = 794
    Height = 532
    Style = grVertical
    StartColor = clWindow
    EndColor = clSilver
    ExplicitTop = -1
  end
  object lbl_Alert: TLabel
    Left = 8
    Top = 51
    Width = 200
    Height = 14
    Alignment = taCenter
    AutoSize = False
    Caption = 'F2 altera descri'#231#227'o'
    Color = clInfoBk
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -9
    Font.Name = 'Arial'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = False
    Layout = tlCenter
    Visible = False
  end
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 532
    Width = 794
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    DesignSize = (
      794
      40)
    object btn_Close: TJvFooterBtn
      Left = 686
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btn_CloseClick
      ButtonIndex = 0
      SpaceInterval = 6
    end
    object btn_Apply: TJvFooterBtn
      Left = 8
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Gravar'
      TabOrder = 0
      OnClick = btn_ApplyClick
      Alignment = taLeftJustify
      ButtonIndex = 1
      SpaceInterval = 6
    end
    object btn_New: TJvFooterBtn
      Left = 112
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Novo'
      TabOrder = 2
      OnClick = btn_NewClick
      Alignment = taLeftJustify
      ButtonIndex = 2
      SpaceInterval = 6
    end
    object btn_Cancel: TJvFooterBtn
      Left = 218
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Cancelar'
      TabOrder = 3
      OnClick = btn_CancelClick
      Alignment = taLeftJustify
      ButtonIndex = 3
      SpaceInterval = 6
    end
    object btn_Delete: TJvFooterBtn
      Left = 324
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Remover'
      TabOrder = 4
      OnClick = btn_DeleteClick
      Alignment = taLeftJustify
      ButtonIndex = 4
      SpaceInterval = 6
    end
  end
  object cbx_PPro: TAdvComboBox
    Left = 8
    Top = 21
    Width = 200
    Height = 24
    Color = clWindow
    Version = '1.5.1.0'
    Visible = True
    Style = csDropDownList
    EmptyTextStyle = []
    FocusBorder = True
    FocusBorderColor = clHighlight
    DropWidth = 0
    Enabled = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = -1
    LabelCaption = 'Ponto de Produ'#231#227'o:'
    LabelPosition = lpTopLeft
    LabelMargin = 2
    LabelTransparent = True
    LabelFont.Charset = DEFAULT_CHARSET
    LabelFont.Color = clNavy
    LabelFont.Height = -13
    LabelFont.Name = 'Tahoma'
    LabelFont.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = cbx_PProChange
    OnEnter = cbx_PProEnter
    OnExit = cbx_PProExit
    OnKeyDown = cbx_PProKeyDown
  end
  object gbx_PrintDef: TAdvGroupBox
    Left = 8
    Top = 87
    Width = 778
    Height = 177
    Caption = ' Impressora/Porta '
    TabOrder = 2
    DesignSize = (
      778
      177)
    object cbx_Modelo: TAdvComboBox
      Left = 47
      Top = 31
      Width = 200
      Height = 24
      AutoComplete = False
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      FocusBorder = True
      FocusBorderColor = clHighlight
      DropWidth = 0
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = -1
      LabelCaption = 'Modelo'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object cbx_NPorta: TAdvComboBox
      Left = 47
      Top = 84
      Width = 200
      Height = 24
      AutoComplete = False
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      FocusBorder = True
      FocusBorderColor = clHighlight
      CharCase = ecUpperCase
      DropWidth = 0
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = -1
      Items.Strings = (
        '')
      LabelCaption = 'Porta:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      ParentFont = False
      TabOrder = 1
      OnSelect = cbx_NPortaSelect
    end
    object cbx_Host: TAdvComboBox
      Left = 47
      Top = 136
      Width = 200
      Height = 24
      AutoComplete = False
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      EmptyTextStyle = []
      FocusBorder = True
      FocusBorderColor = clHighlight
      CharCase = ecUpperCase
      DropWidth = 0
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = -1
      LabelCaption = 'Computador:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object edt_MaxTenta: TAdvSpinEdit
      Left = 277
      Top = 32
      Width = 121
      Height = 26
      Value = 0
      DateValue = 43202.671895613430000000
      HexValue = 0
      CheckMinValue = True
      CheckMaxValue = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Tentativas:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MaxValue = 9
      ParentFont = False
      TabOrder = 3
      Visible = True
      Version = '1.6.0.0'
    end
    object edt_NumCopy: TAdvSpinEdit
      Left = 277
      Top = 84
      Width = 121
      Height = 26
      Value = 1
      FloatValue = 1.000000000000000000
      TimeValue = 0.041666666666666660
      HexValue = 0
      CheckMinValue = True
      CheckMaxValue = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      IncrementFloat = 0.100000000000000000
      IncrementFloatPage = 1.000000000000000000
      LabelCaption = 'Copias:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      MaxValue = 9
      MinValue = 1
      ParentFont = False
      TabOrder = 4
      Visible = True
      Version = '1.6.0.0'
    end
    object btn_NumTenta: TAdvGlowButton
      Left = 404
      Top = 31
      Width = 100
      Height = 30
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -11
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 6
      OnClick = btn_NumTentaClick
      Appearance.ColorChecked = 16111818
      Appearance.ColorCheckedTo = 16367008
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 16111818
      Appearance.ColorDownTo = 16367008
      Appearance.ColorHot = 16117985
      Appearance.ColorHotTo = 16372402
      Appearance.ColorMirrorHot = 16107693
      Appearance.ColorMirrorHotTo = 16775412
      Appearance.ColorMirrorDown = 16102556
      Appearance.ColorMirrorDownTo = 16768988
      Appearance.ColorMirrorChecked = 16102556
      Appearance.ColorMirrorCheckedTo = 16768988
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
    end
    object cbx_Tipo: TAdvComboBox
      Left = 277
      Top = 140
      Width = 121
      Height = 24
      AutoComplete = False
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      FocusBorder = True
      FocusBorderColor = clHighlight
      CharCase = ecUpperCase
      DropWidth = 0
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'PADR'#195'O'
        'AUXILIAR'
        'IMPRESS'#195'O PARCIAL')
      LabelCaption = 'Documento:'
      LabelPosition = lpTopLeft
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -11
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      ParentFont = False
      TabOrder = 5
      Text = 'PADR'#195'O'
    end
    object btn_PrintPag: TAdvGlowButton
      Left = 665
      Top = 134
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'P'#225'gina Teste'
      Notes.Strings = (
        'F3')
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -8
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 7
      OnClick = btn_PrintPagClick
      Appearance.BorderColor = 14727579
      Appearance.BorderColorHot = 10079963
      Appearance.BorderColorDown = 4548219
      Appearance.Color = 15653832
      Appearance.ColorTo = 16178633
      Appearance.ColorChecked = 7915518
      Appearance.ColorCheckedTo = 11918331
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 7778289
      Appearance.ColorDownTo = 4296947
      Appearance.ColorHot = 15465983
      Appearance.ColorHotTo = 11332863
      Appearance.ColorMirror = 15586496
      Appearance.ColorMirrorTo = 16245200
      Appearance.ColorMirrorHot = 5888767
      Appearance.ColorMirrorHotTo = 10807807
      Appearance.ColorMirrorDown = 946929
      Appearance.ColorMirrorDownTo = 5021693
      Appearance.ColorMirrorChecked = 10480637
      Appearance.ColorMirrorCheckedTo = 5682430
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
      Appearance.GradientHot = ggVertical
      Appearance.GradientMirrorHot = ggVertical
      Appearance.GradientDown = ggVertical
      Appearance.GradientMirrorDown = ggVertical
      Appearance.GradientChecked = ggVertical
    end
  end
  object cbx_PPGrupo: TAdvComboBox
    Left = 312
    Top = 21
    Width = 200
    Height = 24
    Color = clWindow
    Version = '1.5.1.0'
    Visible = True
    Style = csDropDownList
    EmptyTextStyle = []
    FocusBorder = True
    FocusBorderColor = clHighlight
    DropWidth = 0
    Enabled = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = -1
    LabelCaption = 'Ponto de Agrupamento:'
    LabelPosition = lpTopLeft
    LabelMargin = 2
    LabelTransparent = True
    LabelFont.Charset = DEFAULT_CHARSET
    LabelFont.Color = clNavy
    LabelFont.Height = -13
    LabelFont.Name = 'Tahoma'
    LabelFont.Style = []
    ParentFont = False
    TabOrder = 3
    TabStop = False
  end
  object vst_Grid1: TVirtualStringTree
    Left = 8
    Top = 277
    Width = 765
    Height = 249
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    BevelInner = bvNone
    BevelKind = bkTile
    BorderStyle = bsNone
    Colors.DropTargetColor = 7063465
    Colors.DropTargetBorderColor = 4958089
    Colors.FocusedSelectionColor = clActiveCaption
    Colors.FocusedSelectionBorderColor = clActiveCaption
    Colors.GridLineColor = clBtnShadow
    Colors.UnfocusedSelectionBorderColor = clBtnShadow
    DefaultNodeHeight = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Trebuchet MS'
    Font.Style = []
    Header.AutoSizeIndex = 0
    Header.Background = clBtnHighlight
    Header.Height = 21
    Header.Options = [hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
    Header.ParentFont = True
    Header.Style = hsPlates
    ParentFont = False
    RootNodeCount = 10
    TabOrder = 4
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoTristateTracking]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHotTrack, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnBeforeCellPaint = vst_Grid1BeforeCellPaint
    OnChange = vst_Grid1Change
    OnGetText = vst_Grid1GetText
    Columns = <
      item
        Alignment = taRightJustify
        CaptionAlignment = taCenter
        Color = 15000804
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coFixed, coAllowFocus, coUseCaptionAlignment]
        Position = 0
        WideText = 'Id'
      end
      item
        Color = clWindow
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 1
        Width = 121
        WideText = 'Modelo(ESC/POS)'
      end
      item
        Color = clWindow
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 2
        Width = 121
        WideText = 'Porta'
      end
      item
        Color = clWindow
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 3
        Width = 121
        WideText = 'Computador'
      end
      item
        Color = clWindow
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 4
        Width = 121
        WideText = 'Documento'
      end
      item
        Position = 5
        Width = 121
        WideText = 'Terminal'
      end>
  end
  object AdvGroupBox1: TAdvGroupBox
    Left = 536
    Top = 3
    Width = 250
    Height = 86
    Transparent = False
    Caption = ' Computadores: '
    TabOrder = 5
    object cbx_HostList: TAdvComboBox
      Left = 14
      Top = 18
      Width = 223
      Height = 24
      AutoComplete = False
      Color = clWindow
      Version = '1.5.1.0'
      Visible = True
      Style = csDropDownList
      EmptyTextStyle = []
      CharCase = ecUpperCase
      DropWidth = 0
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = -1
      LabelMargin = 2
      LabelTransparent = True
      LabelFont.Charset = DEFAULT_CHARSET
      LabelFont.Color = clNavy
      LabelFont.Height = -13
      LabelFont.Name = 'Tahoma'
      LabelFont.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object btn_ClearPorts: TAdvGlowButton
      Left = 14
      Top = 48
      Width = 100
      Height = 30
      Caption = 'Limpa Portas'
      Notes.Strings = (
        'F4')
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -8
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 1
      OnClick = btn_ClearPortsClick
      Appearance.BorderColor = 14727579
      Appearance.BorderColorHot = 10079963
      Appearance.BorderColorDown = 4548219
      Appearance.Color = 15653832
      Appearance.ColorTo = 16178633
      Appearance.ColorChecked = 7915518
      Appearance.ColorCheckedTo = 11918331
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 7778289
      Appearance.ColorDownTo = 4296947
      Appearance.ColorHot = 15465983
      Appearance.ColorHotTo = 11332863
      Appearance.ColorMirror = 15586496
      Appearance.ColorMirrorTo = 16245200
      Appearance.ColorMirrorHot = 5888767
      Appearance.ColorMirrorHotTo = 10807807
      Appearance.ColorMirrorDown = 946929
      Appearance.ColorMirrorDownTo = 5021693
      Appearance.ColorMirrorChecked = 10480637
      Appearance.ColorMirrorCheckedTo = 5682430
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
      Appearance.GradientHot = ggVertical
      Appearance.GradientMirrorHot = ggVertical
      Appearance.GradientDown = ggVertical
      Appearance.GradientMirrorDown = ggVertical
      Appearance.GradientChecked = ggVertical
    end
    object btn_ClearPrints: TAdvGlowButton
      Left = 122
      Top = 48
      Width = 115
      Height = 30
      Caption = 'Limpa Documentos'
      Notes.Strings = (
        'F5')
      NotesFont.Charset = DEFAULT_CHARSET
      NotesFont.Color = clWindowText
      NotesFont.Height = -8
      NotesFont.Name = 'Tahoma'
      NotesFont.Style = []
      TabOrder = 2
      OnClick = btn_ClearPrintsClick
      Appearance.BorderColor = 14727579
      Appearance.BorderColorHot = 10079963
      Appearance.BorderColorDown = 4548219
      Appearance.Color = 15653832
      Appearance.ColorTo = 16178633
      Appearance.ColorChecked = 7915518
      Appearance.ColorCheckedTo = 11918331
      Appearance.ColorDisabled = 15921906
      Appearance.ColorDisabledTo = 15921906
      Appearance.ColorDown = 7778289
      Appearance.ColorDownTo = 4296947
      Appearance.ColorHot = 15465983
      Appearance.ColorHotTo = 11332863
      Appearance.ColorMirror = 15586496
      Appearance.ColorMirrorTo = 16245200
      Appearance.ColorMirrorHot = 5888767
      Appearance.ColorMirrorHotTo = 10807807
      Appearance.ColorMirrorDown = 946929
      Appearance.ColorMirrorDownTo = 5021693
      Appearance.ColorMirrorChecked = 10480637
      Appearance.ColorMirrorCheckedTo = 5682430
      Appearance.ColorMirrorDisabled = 11974326
      Appearance.ColorMirrorDisabledTo = 15921906
      Appearance.GradientHot = ggVertical
      Appearance.GradientMirrorHot = ggVertical
      Appearance.GradientDown = ggVertical
      Appearance.GradientMirrorDown = ggVertical
      Appearance.GradientChecked = ggVertical
    end
  end
  object DCP_sha11: TDCP_sha1
    Id = 2
    Algorithm = 'SHA1'
    HashSize = 160
    Left = 736
    Top = 184
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
    Left = 736
    Top = 120
  end
end
