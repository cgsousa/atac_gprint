object frm_Print00Log: Tfrm_Print00Log
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsSingle
  Caption = '.::Gerenciador de Impress'#227'o::.'
  ClientHeight = 212
  ClientWidth = 634
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    634
    212)
  PixelsPerInch = 96
  TextHeight = 14
  object JvGradient1: TJvGradient
    Left = 0
    Top = 0
    Width = 634
    Height = 172
    Style = grVertical
    StartColor = clWhite
    EndColor = clInfoBk
    ExplicitTop = -1
    ExplicitHeight = 412
  end
  object pnl_Footer: TJvFooter
    Left = 0
    Top = 172
    Width = 634
    Height = 40
    Align = alBottom
    BevelStyle = bsRaised
    BevelVisible = True
    DesignSize = (
      634
      40)
    object btn_Start: TJvFooterBtn
      Left = 8
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Come'#231'ar'
      TabOrder = 1
      OnClick = btn_StartClick
      Alignment = taLeftJustify
      ButtonIndex = 0
      SpaceInterval = 6
    end
    object btn_Close: TJvFooterBtn
      Left = 526
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akRight, akBottom]
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btn_CloseClick
      ButtonIndex = 1
      SpaceInterval = 6
    end
    object btn_Stop: TJvFooterBtn
      Left = 112
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Parar'
      TabOrder = 2
      OnClick = btn_StopClick
      Alignment = taLeftJustify
      ButtonIndex = 2
      SpaceInterval = 6
    end
    object btn_Printers: TJvFooterBtn
      Left = 218
      Top = 5
      Width = 100
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Impressoras'
      TabOrder = 3
      OnClick = btn_PrintersClick
      Alignment = taLeftJustify
      ButtonIndex = 3
      SpaceInterval = 6
    end
    object btn_PProd: TJvFooterBtn
      Left = 324
      Top = 5
      Width = 121
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Pontos de Produ'#231#227'o'
      TabOrder = 4
      OnClick = btn_PProdClick
      Alignment = taLeftJustify
      ButtonIndex = 4
      SpaceInterval = 6
    end
  end
  object mmo_Log: TJvRichEdit
    Left = 8
    Top = 8
    Width = 618
    Height = 156
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clInfoBk
    Flat = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    Title = 'LOG'
    Lines.Strings = (
      'Processando...')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = False
  end
  object JvTrayIcon1: TJvTrayIcon
    IconIndex = 0
    Visibility = [tvVisibleTaskList, tvAutoHide, tvRestoreClick, tvMinimizeClick, tvAnimateToTray]
    Left = 416
    Top = 80
  end
  object JvAppInstances1: TJvAppInstances
    Active = False
    Left = 328
    Top = 48
  end
  object JvTimer1: TJvTimer
    Enabled = False
    OnTimer = JvTimer1Timer
    Left = 504
    Top = 112
  end
end
