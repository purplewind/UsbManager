object frmShareManger: TfrmShareManger
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #31649#29702
  ClientHeight = 296
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000627D4000FF781C00908C4E0082AB6800D6A85500F2BB7200FFC25E00F5C0
    78008E8E8E00949494009D9D9D00A1958200A4A4A300AAA8A400ACACAC00B6B4
    AC00B1B1B100B8B8B800DEBA8900E1C18500FBC69A00FFCF9F00FED79200FFE3
    AD00BDC1C200C2C2C200CDCDCD00CDD7C500D4D2CC00D1D1D100D8D6D100D9D9
    D900DDDCD800E5E0C900FFEFC200F6E5CA00E9E7DE00FAE8D000F9EADD00F8F4
    D800E3E3E300EAE9E100EEEDE600FEFEFE000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000FFFFFF000000
    110F0F0D0D0B0B0B0A0A0A09090900001A0A0A0D111A1B1B120F0B0A0A0A0000
    1E0A0A0A0D121A1B1A120D0A0A0D0000200A1E201E1E1B1B1B1A1A1A0A120000
    20201A1C0103041327112C291B1A000000000E22050614082712192C0A000000
    00000E24262627262610292C0B00000000000D0E0E0E0E0E0F0E192C0B00001B
    0F0B0D1B0E2C29291623172C0D001E0F1D251D0D0F2C19190218072C0D00111F
    2A2A2A1F0F2C29291524282C0F000F2A2A0C0C2A112C19191919192C0F001120
    2A0C2A20112C2C2C2C2C2C2C11001E12200C211012121111121111111E000000
    120F11000000000000000000000000000000000000000000000000000000C000
    0000C0000000C0000000C0000000C0000000F0010000F0010000F00100008001
    00000001000000010000000100000001000000010000C7FF0000FFFF0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object vstHistory: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 464
    Height = 255
    Align = alClient
    CheckImageKind = ckXP
    Header.AutoSizeIndex = 1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs]
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnChecked = vstHistoryChecked
    OnGetText = vstHistoryGetText
    OnPaintText = vstHistoryPaintText
    OnGetImageIndex = vstHistoryGetImageIndex
    Columns = <
      item
        Position = 0
        Width = 200
        WideText = #30446#24405#21517
      end
      item
        Position = 1
        Width = 260
        WideText = #30446#24405#36335#24452
      end>
  end
  object plButtons: TPanel
    Left = 0
    Top = 255
    Width = 464
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 125
      Top = 9
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 251
      Top = 9
      Width = 75
      Height = 25
      Cancel = True
      Caption = #21462#28040
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
