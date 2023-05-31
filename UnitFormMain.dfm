object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'OMD Auto Backup'
  ClientHeight = 242
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  DesignSize = (
    788
    242)
  TextHeight = 15
  object ButtonAdd: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Hint = 'Add a folder to the backup list'
    Caption = '&Add'
    TabOrder = 0
    OnClick = ButtonAddClick
  end
  object ListBox1: TListBox
    Left = 89
    Top = 8
    Width = 691
    Height = 209
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 15
    PopupMenu = PopupMenuListBox
    Sorted = True
    TabOrder = 1
    OnDblClick = OpenFolder1Click
    OnMouseDown = ListBox1MouseUp
    OnMouseUp = ListBox1MouseUp
    ExplicitWidth = 687
    ExplicitHeight = 208
  end
  object ButtonRemove: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Hint = 'Remove a folder from the backup list'
    Caption = '&Remove'
    TabOrder = 2
    OnClick = ButtonRemoveClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 223
    Width = 788
    Height = 19
    Panels = <>
    ExplicitTop = 222
    ExplicitWidth = 784
  end
  object TrayIcon1: TTrayIcon
    BalloonTimeout = 2500
    PopupMenu = PopupMenuTray
    Visible = True
    OnBalloonClick = TrayIcon1BalloonClick
    OnClick = Show1Click
    Left = 432
    Top = 112
  end
  object MainMenu1: TMainMenu
    Left = 200
    Top = 32
    object File1: TMenuItem
      Caption = '&File'
      object Hide2: TMenuItem
        Caption = '&Hide'
        OnClick = Hide1Click
      end
      object Backupnow1: TMenuItem
        Caption = '&Backup Now'
        OnClick = BackupNow1Click
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
  end
  object PopupMenuTray: TPopupMenu
    Left = 432
    Top = 32
    object Show1: TMenuItem
      Caption = '&Show'
      Default = True
      OnClick = Show1Click
    end
    object Hide1: TMenuItem
      Caption = '&Hide'
      OnClick = Hide1Click
    end
    object Exit2: TMenuItem
      Caption = 'E&xit'
      OnClick = Exit1Click
    end
  end
  object PopupMenuListBox: TPopupMenu
    Left = 304
    Top = 32
    object OpenFolder1: TMenuItem
      Caption = '&Open Folder'
      OnClick = OpenFolder1Click
    end
    object Remove1: TMenuItem
      Caption = '&Remove'
      OnClick = ButtonRemoveClick
    end
  end
  object TimerBaloon: TTimer
    Interval = 900000
    OnTimer = BackupNow1Click
    Left = 120
    Top = 32
  end
end
