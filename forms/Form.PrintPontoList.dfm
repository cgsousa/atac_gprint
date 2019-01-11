object frm_PrintPontoList: Tfrm_PrintPontoList
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Pontos de Produ'#231#227'o'
  ClientHeight = 452
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
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    634
    452)
  PixelsPerInch = 96
  TextHeight = 14
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 412
    Width = 634
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    ExplicitLeft = 5
    DesignSize = (
      634
      40)
    object btn_Close: TJvFooterBtn
      Left = 526
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Fechar'
      TabOrder = 0
      ButtonIndex = 0
      SpaceInterval = 6
      ExplicitLeft = 556
    end
    object btn_New: TJvFooterBtn
      Left = 8
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Novo'
      TabOrder = 1
      OnClick = btn_NewClick
      Alignment = taLeftJustify
      ButtonIndex = 1
      SpaceInterval = 6
    end
    object btn_Upd: TJvFooterBtn
      Left = 112
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Alterar'
      TabOrder = 2
      OnClick = btn_UpdClick
      Alignment = taLeftJustify
      ButtonIndex = 2
      SpaceInterval = 6
    end
    object btn_Can: TJvFooterBtn
      Left = 218
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Inativar'
      TabOrder = 3
      Alignment = taLeftJustify
      ButtonIndex = 3
      SpaceInterval = 6
    end
  end
  object vst_Grid1: TVirtualStringTree
    Left = 5
    Top = 5
    Width = 621
    Height = 401
    Anchors = [akLeft, akTop, akRight, akBottom]
    DefaultNodeHeight = 20
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    RootNodeCount = 20
    TabOrder = 1
    TreeOptions.AnimationOptions = [toAnimatedToggle]
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toCenterScrollIntoView]
    OnChange = vst_Grid1Change
    OnColumnDblClick = vst_Grid1ColumnDblClick
    OnCreateEditor = vst_Grid1CreateEditor
    OnEditing = vst_Grid1Editing
    OnGetText = vst_Grid1GetText
    OnPaintText = vst_Grid1PaintText
    OnInitNode = vst_Grid1InitNode
    Columns = <
      item
        Alignment = taCenter
        Position = 0
        WideText = 'Id'
      end
      item
        Position = 1
        Width = 200
        WideText = 'Descri'#231#227'o'
      end
      item
        Position = 2
        Width = 121
        WideText = 'Impressora principal'
      end
      item
        Position = 3
        Width = 121
        WideText = 'Impressora auxiliar'
      end>
  end
end
