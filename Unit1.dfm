object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 678
  ClientWidth = 573
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 476
    Height = 678
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitWidth = 484
    ExplicitHeight = 681
  end
  object Panel1: TPanel
    Left = 476
    Top = 0
    Width = 97
    Height = 678
    Align = alRight
    Caption = 'Panel1'
    TabOrder = 1
    ExplicitLeft = 264
    ExplicitHeight = 691
    object Button1: TButton
      Left = 14
      Top = 16
      Width = 75
      Height = 49
      Caption = 'Start'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 14
      Top = 80
      Width = 75
      Height = 49
      Caption = 'Stop'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 14
      Top = 144
      Width = 75
      Height = 49
      Caption = 'File Output'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 14
      Top = 208
      Width = 75
      Height = 49
      Caption = 'Clear'
      TabOrder = 3
      OnClick = Button4Click
    end
    object BitBtn1: TBitBtn
      Left = 14
      Top = 592
      Width = 75
      Height = 49
      Caption = 'HexMess'
      TabOrder = 4
      OnClick = BitBtn1Click
    end
  end
  object Timer1: TTimer
    Left = 280
    Top = 344
  end
end
