object frm_Print00List: Tfrm_Print00List
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Lista  de Iimpressoras'
  ClientHeight = 452
  ClientWidth = 664
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
    664
    452)
  PixelsPerInch = 96
  TextHeight = 14
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 412
    Width = 664
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    DesignSize = (
      664
      40)
    object btn_Close: TJvFooterBtn
      Left = 556
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btn_CloseClick
      ButtonIndex = 0
      SpaceInterval = 6
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
      Visible = False
      Alignment = taLeftJustify
      ButtonIndex = 3
      SpaceInterval = 6
    end
    object btn_PPList: TJvFooterBtn
      Left = 324
      Top = 5
      Width = 121
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Pontos Produ'#231#227'o'
      TabOrder = 4
      Visible = False
      Alignment = taLeftJustify
      ButtonIndex = 4
      SpaceInterval = 6
    end
  end
  object vst_Grid1: TVirtualStringTree
    Left = 5
    Top = 5
    Width = 651
    Height = 401
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    RootNodeCount = 20
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowDropmark, toShowHorzGridLines, toShowTreeLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnChange = vst_Grid1Change
    OnGetText = vst_Grid1GetText
    Columns = <
      item
        Alignment = taCenter
        Position = 0
        WideText = 'Id'
      end
      item
        Position = 1
        Width = 121
        WideText = 'Modelo'
      end
      item
        Position = 2
        Width = 55
        WideText = 'Avan'#231'os'
      end
      item
        Position = 3
        WideText = 'Check'
      end
      item
        Position = 4
        Width = 65
        WideText = 'Tentativas'
      end
      item
        Position = 5
        Width = 65
        WideText = 'Expandido'
      end
      item
        Position = 6
        WideText = 'Corte'
      end>
  end
end
