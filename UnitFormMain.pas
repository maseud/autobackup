unit UnitFormMain;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Types, System.Classes, System.Zip
  , Vcl.StdCtrls, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Forms, Vcl.Menus
  , FileCtrl, DateUtils, Registry;

type
  TFormMain = class(TForm)
    ButtonAdd: TButton;
    ListBox1: TListBox;
    ButtonRemove: TButton;
    TrayIcon1: TTrayIcon;
    MainMenu1: TMainMenu;
    PopupMenuTray: TPopupMenu;
    PopupMenuListBox: TPopupMenu;
    Remove1: TMenuItem;
    Show1: TMenuItem;
    Hide1: TMenuItem;
    Exit2: TMenuItem;
    Hide2: TMenuItem;
    Exit1: TMenuItem;
    TimerBaloon: TTimer;
    StatusBar1: TStatusBar;
    File1: TMenuItem;
    Backupnow1: TMenuItem;
    OpenFolder1: TMenuItem;
    procedure ButtonAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonRemoveClick(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnZipProgressEvent(Sender: TObject; FileName: string;
      Header: TZipHeader; Position: Int64);
    procedure BackupNow1Click(Sender: TObject);
    procedure OpenFolder1Click(Sender: TObject);
    procedure TrayIcon1BalloonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure SetAutoStart(bRegister: Boolean);
const
  RegKey = '\Software\Microsoft\Windows\CurrentVersion\Run';
  // or: RegKey = '\Software\Microsoft\Windows\CurrentVersion\RunOnce';
var
  Registry: TRegistry;
  AppName, AppTitle: string;
  str: String;
begin
  AppName := ParamStr(0);
  AppTitle := 'AutoBackup';

  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey(RegKey, False) then
    begin
      str := Registry.ReadString(AppTitle);
      if AppName <> str then
      begin
        if bRegister = False then
          Registry.DeleteValue(AppTitle)
        else
          Registry.WriteString(AppTitle, AppName);
      end;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TFormMain.ButtonAddClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := '';
  if FileCtrl.SelectDirectory('Select Folder', Dir, Dir) then
    if ListBox1.Items.IndexOf(Dir) < 0 then
    begin
      ListBox1.Items.Add(Dir);
      ListBox1.Items.SaveToFile(ChangeFileExt(ParamStr(0), '.txt'));
    end;
end;

procedure TFormMain.ButtonRemoveClick(Sender: TObject);
begin
  if (ListBox1.ItemIndex>-1) then
  begin
    ListBox1.Items.Delete(ListBox1.ItemIndex);
    ListBox1.Items.SaveToFile(ChangeFileExt(ParamStr(0), '.txt'));
  end;
end;

procedure TFormMain.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Hide;
  CanClose := false;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  TrayIcon1.Icon := Application.Icon;
  SetAutoStart(True);
  if (FileExists(ChangeFileExt(ParamStr(0), '.txt'))) then
  begin
    ListBox1.Items.LoadFromFile(ChangeFileExt(ParamStr(0), '.txt'));
    Hide;
  end;
end;

procedure TFormMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Hide;
end;

procedure TFormMain.Hide1Click(Sender: TObject);
begin
  FormMain.Hide;
end;

procedure TFormMain.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ListBox1.ItemIndex := ListBox1.ItemAtPos(Point(X, Y), false);
end;

procedure TFormMain.Show1Click(Sender: TObject);
begin
  FormMain.Show;
end;

procedure TFormMain.TrayIcon1BalloonClick(Sender: TObject);
begin
  TrayIcon1.BalloonHint := '';
end;

function FileTime(FileName: TFileName): TDateTime;
var
  FileAttributeData: TWin32FileAttributeData;
  FileTime: TFileTime;
  SystemTime, LocalTime: TSystemTime;
begin
  GetFileAttributesEx(PWideChar(FileName), GetFileExInfoStandard, @FileAttributeData);
  FileTime := FileAttributeData.ftLastWriteTime;
  FileTimeToSystemTime(FileTime, SystemTime);
  SystemTimeToTzSpecificLocalTime(nil, SystemTime, LocalTime);
  Result := SystemTimeToDateTime(LocalTime);
end;

function FilesAreEqual(const File1, File2: TFileName): Boolean;
const
  BlockSize = 1048576; // 1 MegaBytes
var
  fs1, fs2: TFileStream;
  L1, L2: Integer;
  B1, B2: array of Byte;
begin
  Result := false;
  try
    SetLength(B1, BlockSize);
    SetLength(B2, BlockSize);
    fs1 := TFileStream.Create(File1, fmOpenRead or fmShareDenyWrite);
    try
      fs2 := TFileStream.Create(File2, fmOpenRead or fmShareDenyWrite);
      try
        if fs1.Size = fs2.Size then
        begin
          while fs1.Position < fs1.Size do
          begin
            L1 := fs1.Read(B1[1], BlockSize);
            L2 := fs2.Read(B2[1], BlockSize);
            if L1 <> L2 then
              Exit;
            if not CompareMem(@B1[1], @B2[1], L1) then Exit;
          end;
          Result := true;
        end;
      finally
        fs2.Free;
      end;
    finally
      fs1.Free;
    end;
  except
  end;
end;

procedure CopyOverwrite(OldFileName, NewFileName: TFileName);
begin
  if FileExists(OldFileName) then
  begin
    CopyFile(PWideChar(OldFileName), PWideChar(NewFileName), false);
    While Not FilesAreEqual(OldFileName, NewFileName) do
      Sleep(100);
  end;
end;

function _F(FileName: TFileName; Number: Integer): String;
begin
   Result := FileName+'_'+IntToStr(Number)+'.zip';
end;

procedure RotateFile(FileName: TFileName; Count: Integer = 20);
var
  I,J: Integer;
begin
  I := 1;
  while ( FileExists(_F(FileName,I)) AND (I<=Count) ) do
    Inc(I);

  if I=1 then
    CopyOverwrite(FileName+'.zip', _F(FileName,1))
  else
    if not (FilesAreEqual(FileName+'.zip', _F(FileName,I-1)) ) then
    begin
      if I>Count then
      begin
        I := Count;

        for J := 2 to 7 do
          if HoursBetween(FileTime(_F(FileName,J-1)) , FileTime(_F(FileName,j))) > ((8-J)*23) then
            CopyOverwrite(_F(FileName,J), _F(FileName,J-1));
        for J := 8 to Count do
          if MinutesBetween(FileTime(_F(FileName,J-1)) , FileTime(_F(FileName,j))) > ((Count+1-J)*7) then
            CopyOverwrite(_F(FileName,J), _F(FileName,J-1));
      end;
      CopyOverwrite(FileName+'.zip', _F(FileName,I));
    end;
end;

procedure TFormMain.BackupNow1Click(Sender: TObject);
var
  I: Integer;
  FZip: TZipFile;
  DirName: String;
begin
  for I := 0 to ListBox1.Items.Count-1 do
  begin
    DirName := ListBox1.Items.Strings[I];
    FZip := TZipFile.Create;
    try
      FZip.ZipDirectoryContents(DirName+'.zip', DirName, zcDeflate, OnZipProgressEvent);
      FZip.Close;
    finally
      FZip.Free;
    end;
    RotateFile(DirName);
  end;
  StatusBar1.SimpleText := 'Last backup at ' + TimeToStr(Now());
  TrayIcon1.BalloonHint := 'Save your work and take a rest';
  TrayIcon1.ShowBalloonHint;
end;

procedure TFormMain.OnZipProgressEvent(Sender: TObject; FileName: string;
  Header: TZipHeader; Position: Int64);
var
  percent: Float64;
begin
  percent := (Position * 100) div Header.UncompressedSize;
  StatusBar1.SimpleText := 'Compressing ' + FloatToStr(percent) + '% ' + FileName;
  Application.ProcessMessages;
end;

procedure TFormMain.OpenFolder1Click(Sender: TObject);
begin
  if (ListBox1.ItemIndex>-1) then
    ShellExecute(Application.Handle, nil, PChar(ExtractFilePath(ListBox1.Items.Strings[ListBox1.ItemIndex])), nil, nil, sw_Show);
end;

end.
