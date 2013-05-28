unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ExtCtrls,
  Vcl.Buttons, RzTabs, UFrameDriverBtn, IniFiles, Vcl.Menus, auHTTP,
  auAutoUpgrader, idhttp, shellapi, Generics.Collections;

const
  hfck_Index = wm_user + $1000;
  hfck_Name = 'UsbManager';

type

    // Frame信息
  TUsbFrameInfo = class
  public
    UsbID, UsbPath : string;
    NetworkPath, LocalPath : string;
    LocalWidth, LocalHistoryHeigh : Integer;
    HistoryList : TStringList;
  public
    constructor Create( _UsbID : string );
    procedure SetPathInfo( _UsbPath, _NetworkPath, _LocalPath : string );
    procedure SetPosition( _LocalWidth, _LocalHistoryHeigh : Integer );
    procedure AddHistory( Path : string );
    destructor Destroy; override;
  end;
  TUsbFrameList = class( TObjectList<TUsbFrameInfo> )end;

  TfrmMain = class(TForm)
    ilFile16: TImageList;
    plMain: TPanel;
    plToolBar: TPanel;
    PcMain: TRzPageControl;
    plCenter: TPanel;
    plPicture: TPanel;
    ilDriver: TImage;
    tiApp: TTrayIcon;
    pmTrayIcon: TPopupMenu;
    Exit1: TMenuItem;
    About1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    miCloseHide: TMenuItem;
    miCloseExit: TMenuItem;
    ilMainForm: TImageList;
    auMain: TauAutoUpgrader;
    tmrSave: TTimer;
    PcDisable: TRzPageControl;
    tsNormal: TRzTabSheet;
    tsDisable: TRzTabSheet;
    plDisable: TPanel;
    ilDisable: TImage;
    PlDisableShow: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miCloseExitClick(Sender: TObject);
    procedure miCloseHideClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tiAppClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure tmrSaveTimer(Sender: TObject);
  private
    procedure WMDeviceChange(var Msg: TMessage); message WM_DEVICECHANGE;
    procedure WMQueryEndSession(var Message: TMessage);message WM_QUERYENDSESSION;
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure createparams(var params: tcreateparams); override;
    procedure restorerequest(var Msg: TMessage); message hfck_Index;
  private
    IsAppExit, IsHideApp : Boolean;
    procedure ShowMainForm;
    procedure HideMainForm;
  private
    UsbFrameList : TUsbFrameList;
    procedure LoadIni;
    procedure SaveIni;
  private
    procedure RefreshUsb;
    procedure ShowUsbList( IsLoading : Boolean );
    procedure ShowUsbDisable;
  private
    procedure MainFormIni;
    procedure MainFormUnini;
    procedure CreateAppDataDir;
    procedure SavePicture;
  public
    procedure AppStart;
  end;

{$Region ' 程序运行时 ' }

    // 记录运行信息
  TAppStartHandle = class
  public
    procedure Update;
  private
    procedure AppRunMark;
  end;

    // PcID
  MyComputerID = class
  public
    class function get : string;
  private
    class function getNewPcID : string;
    class function Read : string;
    class procedure Save( PcID : string );
  end;

{$EndRegion}

{$Region ' 界面 接口 ' }

    // 导航 ToolBar
  TFacePageButtonApi = class
  public
    plToolBar : TPanel;
  public
    constructor Create;
  public
    function ReadIsExist( DriverID : string ): Boolean;
    procedure Add( DriverID, DriverPath : string );
    procedure Enter( DriverID : string );
    procedure Remove( DriverID : string );
  public
    function ReadDriverIDList : TStringList;
    function ReadSelectDriver : string;
    function ReadFirstDriver : string;
  private
    function ReadButton( DriverID : string ): TSpeedButton;
    procedure SbButtonClick( Sender : TObject );
  end;

    // 导航页面
  TFacePageDriverApi = class
  private
    PcMain : TRzPageControl;
  private
    LastControlPath : string;
  public
    constructor Create;
  public
    function ReadIsExist( DriverID : string ): Boolean;
    procedure Add( DriverID, DriverPath : string );
    procedure Enter( DriverID : string );
    procedure Remove( DriverID : string );
  public
    function ControlPage( DriverID : string ): Boolean;
  private
    function ReadPage( DriverID : string ): TRzTabSheet;
  end;

{$EndRegion}

{$Region ' 用户 界面 ' }

    // 导航按钮
  UserPageButtonApi = class
  public
    class procedure AddDriver( DriverID, DriverPath : string );
    class procedure SelectDriver( DriverID : string );
    class procedure SelectFirstDriver;
    class procedure RemoveDriver( DriverID : string );
  end;

    // 内容页面
  UserPageDriverApi = class
  public
    class procedure AddDriver( DriverID, DriverPath : string );
    class procedure SelectDriver( DriverID : string );
    class procedure RemoveDriver( DriverID : string );
  public
    class procedure RefreshDriver( DriverID : string );
  end;

{$EndRegion}

{$Region ' 拖动文件 ' }

    // 拖动文件
  TDropFilesHandle = class
  public
    Msg: TMessage;
    FileList : TStringList;
  public
    constructor Create( _Msg: TMessage );
    procedure Update;
    destructor Destroy; override;
  end;

{$EndRegion}

const
  Ini_MainForm = 'MainForm';
  Ini_ShareCount = 'ShareCount';
  Ini_DriverID = 'DriverID';
  Ini_DriverPath = 'DriverPath';
  Ini_MainFormWidth = 'MainFormWidth';
  Ini_MainFormHeigh = 'MainFormHeigh';
  Ini_MainFormHide = 'MainFormHide';
  Ini_SelectPath = 'SelectPath';

  Ini_App = 'App';
  Ini_AppPcID = 'AppPcID';

const
  MarkApp_PcID = 'PcID';
  MarkApp_Edition = 'Edition';

var
  FacePageButtonApi : TFacePageButtonApi;
  FacePageDriverApi : TFacePageDriverApi;

var
  frmMain: TfrmMain;

implementation

uses UMyUtils, UFrameDriver, UMyFaceThread, UFileThread, UFormShareManage,
     UFileWatchThread, UFormAbout, UMyUrl;

{$R *.dfm}

procedure TfrmMain.About1Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMain.AppStart;
var
  i: Integer;
  AppRunMarkHandle : TAppStartHandle;
begin
try
    // 切换导航图标位置
  for i := 0 to plToolBar.ControlCount - 1 do
    plToolBar.Controls[i].Left := 10000 - ( i * 100 );

    // 记录运行信息
  AppRunMarkHandle := TAppStartHandle.Create;
  AppRunMarkHandle.Update;
  AppRunMarkHandle.Free;
except
end;
end;

procedure TfrmMain.CreateAppDataDir;
begin
  try
    ForceDirectories( MyAppData.getLoginPath );
    ForceDirectories( MyAppData.getIconFolderPath );
    ForceDirectories( MyAppData.getIconPicturePath );
  except
  end;
end;

procedure TfrmMain.createparams(var params: tcreateparams);
begin
  try
    inherited createparams(params);
    params.WinClassName := hfck_Name;
  except
  end;
end;

procedure TfrmMain.DropFiles(var Msg: TMessage);
var
  DropFilesHandle : TDropFilesHandle;
begin
  DropFilesHandle := TDropFilesHandle.Create( Msg );
  DropFilesHandle.Update;
  DropFilesHandle.Free;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  IsAppExit := True;
  Close;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := IsAppExit or not IsHideApp;
  if not CanClose then
    HideMainForm;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MainFormIni;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  MainFormUnini;
end;

procedure TfrmMain.HideMainForm;
begin
  ShowWindow(Self.Handle, SW_HIDE);
end;

procedure TfrmMain.LoadIni;
var
  IniFile : TIniFile;
  ShareCount, i, j: Integer;
  DriverID, DriverPath : string;
  LocalWidth, LocalHistoryHeigh : Integer;
  FrameCaption : string;
  LocalFolder, NetworkFolder : string;
  HistoryCount : Integer;
  History : string;
  UsbFrameInfo : TUsbFrameInfo;
begin
  IniFile := TIniFile.Create( MyAppData.getConfigPath );
try
    // 读取所有共享目录
  ShareCount := IniFile.ReadInteger( Ini_MainForm, Ini_ShareCount, 0 );
  for i := 0 to ShareCount - 1 do
  begin
    DriverID := IniFile.ReadString( Ini_MainForm, Ini_DriverID + IntToStr(i), '' );
    if DriverID = '' then
      Continue;
    DriverPath := IniFile.ReadString( Ini_MainForm, Ini_DriverPath + IntToStr(i), '' );
    FrameCaption := Ini_FrameDriver + IntToStr( i );
    LocalFolder := IniFile.ReadString( FrameCaption, Ini_LocalFolder, '' );
    NetworkFolder := IniFile.ReadString( FrameCaption, Ini_NetworkFolder, DriverPath );
    LocalWidth := IniFile.ReadInteger( FrameCaption, Ini_LocalWidth, 0 );
    LocalHistoryHeigh := IniFile.ReadInteger( FrameCaption, Ini_LocalHistoryHeigh, 0 );

    UsbFrameInfo := TUsbFrameInfo.Create( DriverID );
    UsbFrameInfo.SetPathInfo( DriverPath, NetworkFolder, LocalFolder );
    UsbFrameInfo.SetPosition( LocalWidth, LocalHistoryHeigh );
    UsbFrameList.Add( UsbFrameInfo );

      // 读取本地历史
    HistoryCount := IniFile.ReadInteger( FrameCaption, Ini_LocalHistoryCount, 0 );
    for j := HistoryCount - 1 downto 0 do
    begin
      History := IniFile.ReadString( FrameCaption, Ini_LocalHistory + IntToStr( j ), '' );
      if History <> '' then
        UsbFrameInfo.AddHistory( History );
    end;

    UserFrameDriverApi.LoadFromData( UsbFrameInfo );
  end;

    // 读取共享路径
  DriverID := IniFile.ReadString( Ini_MainForm, Ini_SelectPath, '' );
  if ( DriverID <> '' ) and FacePageButtonApi.ReadIsExist( DriverID ) then  // 选择上一次
    UserPageButtonApi.SelectDriver( DriverID )
  else
    UserPageButtonApi.SelectFirstDriver;  // 选择默认的

    // 读取窗口信息
  frmMain.Width := IniFile.ReadInteger( Ini_MainForm, Ini_MainFormWidth, frmMain.Width );
  frmMain.Height := IniFile.ReadInteger( Ini_MainForm, Ini_MainFormHeigh, frmMain.Height );

    // 是否隐藏窗口
  IsHideApp := IniFile.ReadBool( Ini_MainForm, Ini_MainFormHide, False );
  frmMain.miCloseHide.Checked := IsHideApp;
  frmMain.miCloseExit.Checked := not IsHideApp;
except
end;
  IniFile.Free;
end;

procedure TfrmMain.MainFormIni;
begin
  CreateAppDataDir;
  SavePicture;

  MyIcon := TMyIcon.Create;
  My16IconUtil.Set16IconName( ilFile16 );

  FacePageButtonApi := TFacePageButtonApi.Create;
  FacePageDriverApi := TFacePageDriverApi.Create;
  FaceFrameDriverApi := TFaceFrameDriverApi.Create;
  FaceLocalDriverApi := TFaceLocalDriverApi.Create;
  FaceNetworkDriverApi := TFaceNetworkDriverApi.Create;
  FaceLocalStatusApi := TFaceLocalStatusApi.Create;
  FaceNetworkStatusApi := TFaceNetworkStatusApi.Create;
  FaceFileJobApi := TFaceFileJobApi.Create;
  FaceLocalHistoryApi := TFaceLocalHistoryApi.Create;

  MyFaceJobHandler := TMyFaceJobHandler.Create;
  MyFileJobHandler := TMyFileJobHandler.Create;
  MyFileWatch := TMyFileWatch.Create;

  UsbFrameList := TUsbFrameList.Create;
  RefreshUsb;
  LoadIni;


    // 拖放文件消息
  DragAcceptFiles(Handle, True);

  IsAppExit := False;
end;

procedure TfrmMain.MainFormUnini;
begin
  SaveIni;
  UsbFrameList.Free;

  MyFileWatch.Stop;
  MyFaceJobHandler.Stop;
  MyFileJobHandler.Stop;

  FaceLocalHistoryApi.Free;
  FaceFileJobApi.Free;
  FaceNetworkStatusApi.Free;
  FaceLocalStatusApi.Free;
  FaceLocalDriverApi.Free;
  FaceNetworkDriverApi.Free;
  FaceFrameDriverApi.Free;
  FacePageDriverApi.Free;
  FacePageButtonApi.Free;
  MyIcon.Free;

  MyFileWatch.Free;
  MyFileJobHandler.Free;
  MyFaceJobHandler.Free;
end;

procedure TfrmMain.miCloseExitClick(Sender: TObject);
begin
  IsHideApp := False;
  miCloseHide.Checked := False;
  miCloseExit.Checked := True;
end;


procedure TfrmMain.miCloseHideClick(Sender: TObject);
begin
  IsHideApp := True;
  miCloseExit.Checked := False;
  miCloseHide.Checked := True;
end;

procedure TfrmMain.N1Click(Sender: TObject);
begin
  auMain.CheckUpdate;
end;

procedure TfrmMain.RefreshUsb;
begin
  if MyFilePath.getExistUsb then
    ShowUsbList( True )
  else
    ShowUsbDisable;
end;

procedure TfrmMain.ShowUsbList( IsLoading : Boolean );
var
  OldUsbList : TStringList;
  NewUsbList : TStringList;
  i, PathIndex: Integer;
  UsbPath, UsbID, DriverID : string;
  j: Integer;
begin
  OldUsbList := FacePageButtonApi.ReadDriverIDList;
  NewUsbList := MyFilePath.getUseList;

try
    // 寻找已删除的路径
  for i := 0 to OldUsbList.Count - 1 do
  begin
    UsbID := OldUsbList[i];
    PathIndex := -1;
    for j := 0 to NewUsbList.Count - 1 do
    begin
      UsbPath := NewUsbList[j];
      if MyFilePath.getDriverID( UsbPath ) = UsbID then
      begin
        PathIndex := j;
        Break;
      end;
    end;
    if PathIndex >= 0 then
      NewUsbList.Delete( PathIndex )
    else
      UserPageButtonApi.RemoveDriver( UsbID );
  end;

    // 新增的路径
  for i := 0 to NewUsbList.Count - 1 do
  begin
    UsbPath := NewUsbList[i];
    UsbID := MyFilePath.getDriverID( UsbPath );
    UserPageButtonApi.AddDriver( UsbID, UsbPath );
    for j := 0 to UsbFrameList.Count - 1 do
      if UsbFrameList[j].UsbID = UsbID then
      begin
        UserFrameDriverApi.LoadFromData( UsbFrameList[j] );
        Break;
      end;
    if not IsLoading then
      UserPageButtonApi.SelectDriver( UsbID );
  end;
except
end;

  NewUsbList.Free;
  OldUsbList.Free;

  PcDisable.ActivePage := tsNormal;
end;

procedure TfrmMain.ShowUsbDisable;
begin
  PcDisable.ActivePage := tsDisable;
end;

procedure TfrmMain.restorerequest(var Msg: TMessage);
begin
  try
    if not IsAppExit then
      ShowMainForm;
  except
  end;
end;

procedure TfrmMain.SaveIni;
var
  IniFile : TIniFile;
  i : Integer;
  DriverIDList : TStringList;
  DriverID, FrameCaption : string;
  j: Integer;
  IsExist : Boolean;
  UsbFrameInfo : TUsbFrameInfo;
begin
  IniFile := TIniFile.Create( MyAppData.getConfigPath );
try
    // 保存驱动器列表
  DriverIDList := FacePageButtonApi.ReadDriverIDList;
  for i := 0 to DriverIDList.Count - 1 do
  begin
    DriverID := DriverIDList[i];
    IsExist := False;
    for j := 0 to UsbFrameList.Count - 1 do
    begin
      if UsbFrameList[j].UsbID = DriverID then
      begin
        UsbFrameInfo := UsbFrameList[j];
        IsExist := True;
        Break;
      end;
    end;
    if not IsExist then
    begin
      UsbFrameInfo := TUsbFrameInfo.Create( DriverID );
      UsbFrameList.Add( UsbFrameInfo );
    end;
    UserFrameDriverApi.SaveToData( UsbFrameInfo );
  end;
  DriverIDList.Free;

    // 保存历史列表
  IniFile.WriteInteger( Ini_MainForm, Ini_ShareCount, UsbFrameList.Count );
  for i := 0 to UsbFrameList.Count - 1 do
  begin
    UsbFrameInfo := UsbFrameList[i];
      // 保存基本信息
    IniFile.WriteString( Ini_MainForm, Ini_DriverID + IntToStr(i), UsbFrameInfo.UsbID );
    IniFile.WriteString( Ini_MainForm, Ini_DriverPath + IntToStr(i), UsbFrameInfo.UsbPath );
    FrameCaption := Ini_FrameDriver + IntToStr( i );
    IniFile.WriteString( FrameCaption, Ini_LocalFolder, UsbFrameInfo.LocalPath );
    IniFile.WriteString( FrameCaption, Ini_NetworkFolder, UsbFrameInfo.NetworkPath );
    IniFile.WriteInteger( FrameCaption, Ini_LocalWidth, UsbFrameInfo.LocalWidth );
    IniFile.WriteInteger( FrameCaption, Ini_LocalHistoryHeigh, UsbFrameInfo.LocalHistoryHeigh );
      // 保存历史信息
    IniFile.WriteInteger( FrameCaption, Ini_LocalHistoryCount, UsbFrameInfo.HistoryList.Count );
    for j := 0 to UsbFrameInfo.HistoryList.Count - 1 do
      IniFile.WriteString( FrameCaption, Ini_LocalHistory + IntToStr( j ), UsbFrameInfo.HistoryList[j] );
  end;

    // 当前选择的路径
  IniFile.WriteString( Ini_MainForm, Ini_SelectPath, FacePageButtonApi.ReadSelectDriver );

    // 窗口信息
  IniFile.WriteInteger( Ini_MainForm, Ini_MainFormWidth, frmMain.Width );
  IniFile.WriteInteger( Ini_MainForm, Ini_MainFormHeigh, frmMain.Height );
  IniFile.WriteBool( Ini_MainForm, Ini_MainFormHide, frmMain.IsHideApp );
except
end;
  IniFile.Free;
end;


procedure TfrmMain.SavePicture;
var
  FilePath : string;
begin
  FilePath := MyAppData.getNetworkDriver;
  if FileExists( FilePath ) then
    Exit;
  ilDriver.Picture.SaveToFile( FilePath );
end;

procedure TfrmMain.ShowMainForm;
begin
  if not Self.Visible then
    Self.Visible := True;
  ShowWindow(Self.Handle, SW_RESTORE);
  SetForegroundWindow(Self.Handle);
end;

procedure TfrmMain.tiAppClick(Sender: TObject);
begin
  if not IsAppExit then
    ShowMainForm;
end;

procedure TfrmMain.tmrSaveTimer(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmMain.WMDeviceChange(var Msg: TMessage);
var
  IsDriverChanged : Boolean;
begin
  try
    IsDriverChanged := ( Msg.WParam = 32768 ) or ( Msg.WParam = 32772 );
    if IsDriverChanged then
      ShowUsbList( False );
  except
  end;
end;

procedure TfrmMain.WMQueryEndSession(var Message: TMessage);
begin
  try
    SaveIni;
    Message.Result := 1;
  except
  end;
end;

{ TFacePageDriverApi }

procedure TFacePageDriverApi.Add(DriverID, DriverPath: string);
var
  NewPage : TRzTabSheet;
  FrameDriver : TFrameDriver;
begin
  NewPage := TRzTabSheet.Create( PcMain );
  NewPage.Parent := PcMain;
  NewPage.PageControl := PcMain;
  NewPage.Hint := DriverID;
  NewPage.TabVisible := False;

  FrameDriver := TFrameDriver.Create( NewPage );
  FrameDriver.Parent := NewPage;
  FrameDriver.IniFrame;
  FrameDriver.SetControlPath( DriverID, DriverPath );
  FrameDriver.SetLocalPath( '' );
  FrameDriver.SetNetworkPath( DriverPath );
end;

function TFacePageDriverApi.ControlPage(DriverID: string): Boolean;
var
  Page : TRzTabSheet;
  i : Integer;
  c : TControl;
  f : TFrameDriver;
begin
    // 已选择
  if DriverID = LastControlPath then
  begin
    Result := True;
    Exit;
  end;

    // 遍历
  Result := False;
  Page := ReadPage( DriverID );
  if not Assigned( Page ) then
    Exit;
  for i := 0 to Page.ControlCount - 1 do
  begin
    c := Page.Controls[i];
    if c is TFrameDriver then
    begin
      f := c as TFrameDriver;
      FaceFrameDriverApi.Activate( f );
      LastControlPath := DriverID;
      Result := True;
    end;
  end;
end;

constructor TFacePageDriverApi.Create;
begin
  PcMain := frmMain.PcMain;
  LastControlPath := '';
end;

procedure TFacePageDriverApi.Enter(DriverID: string);
var
  Page : TRzTabSheet;
begin
  Page := ReadPage( DriverID );
  if Assigned( Page ) then
    PcMain.ActivePage := Page;
end;

function TFacePageDriverApi.ReadIsExist(DriverID: string): Boolean;
begin
  Result := Assigned( ReadPage( DriverID ) );
end;

function TFacePageDriverApi.ReadPage(DriverID: string): TRzTabSheet;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to PcMain.PageCount - 1 do
    if PcMain.Pages[i].Hint = DriverID then
    begin
      Result := PcMain.Pages[i];
      Break;
    end;
end;

procedure TFacePageDriverApi.Remove(DriverID: string);
var
  PageIndex : Integer;
  Page : TRzTabSheet;
begin
    // 删除的页面是控制页面
  if LastControlPath = DriverID then
    LastControlPath := '';

    // 获取页面
  Page := ReadPage( DriverID );
  if not Assigned( Page ) then
    Exit;
  if ( PcMain.ActivePage = Page ) and ( PcMain.PageCount > 1 ) then  // 删除页面切换
  begin
    if PcMain.ActivePageIndex = ( PcMain.PageCount - 1 ) then
      PageIndex := PcMain.ActivePageIndex - 1
    else
      PageIndex := PcMain.ActivePageIndex + 1;
    if ( PageIndex >= 0 ) and ( PageIndex < PcMain.PageCount ) then
      UserPageButtonApi.SelectDriver( PcMain.Pages[ PageIndex ].Hint ); // 页面跳转
  end;
  Page.Free;
end;

{ TFacePageButtonApi }

procedure TFacePageButtonApi.Add(DriverID, DriverPath: string);
var
  sbDriver : TSpeedButton;
  DriverName : string;
begin
  DriverName := MyFilePath.getDriverName( DriverPath );
  if Length( Ansistring( DriverName ) ) > 16 then
  begin
    DriverName := '(' + copy( Ansistring( DriverName ), 1, 10 ) + '..)';
    DriverName := Copy( DriverPath, 1, length( DriverPath ) - 1 ) + DriverName;
  end;

  sbDriver := TSpeedButton.Create( plToolBar );
  sbDriver.Parent := plToolBar;
  sbDriver.Align := alLeft;
  sbDriver.Width := 100;
  sbDriver.Layout := blGlyphTop;
  sbDriver.Caption := DriverName;
  sbDriver.Hint := DriverID;
  sbDriver.GroupIndex := 1;
  sbDriver.Glyph.LoadFromFile( MyAppData.getNetworkDriver );
  sbDriver.OnClick := SbButtonClick;
end;

constructor TFacePageButtonApi.Create;
begin
  plToolBar := frmMain.plToolBar;
end;

procedure TFacePageButtonApi.Enter(DriverID: string);
var
  sbDriver : TSpeedButton;
begin
  sbDriver := ReadButton( DriverID );
  if Assigned( sbDriver ) then
    sbDriver.Down := True;
end;

function TFacePageButtonApi.ReadButton(DriverID: string): TSpeedButton;
var
  i: Integer;
  c : TControl;
  sbDriver : TSpeedButton;
begin
  Result := nil;
  for i := 0 to plToolBar.ControlCount - 1 do
  begin
    c := plToolBar.Controls[i];
    if not ( c is TSpeedButton ) then
      Continue;
    sbDriver := c as TSpeedButton;
    if sbDriver.Hint = DriverID then
    begin
      Result := sbDriver;
      Break;
    end;
  end;
end;

function TFacePageButtonApi.ReadDriverIDList: TStringList;
var
  i: Integer;
  c : TControl;
  sbDriver : TSpeedButton;
begin
  Result := TStringList.Create;
  for i := 0 to plToolBar.ControlCount - 1 do
  begin
    c := plToolBar.Controls[i];
    if not ( c is TSpeedButton ) then
      Continue;
    sbDriver := c as TSpeedButton;
    if sbDriver.Tag = 1 then  // 添加按钮
      Continue;
    Result.Add( sbDriver.Hint );
  end;
end;

function TFacePageButtonApi.ReadFirstDriver: string;
var
  i: Integer;
  c : TControl;
  sbDriver : TSpeedButton;
begin
  Result := '';
  for i := plToolBar.ControlCount - 1 downto 0 do
  begin
    c := plToolBar.Controls[i];
    if not ( c is TSpeedButton ) then
      Continue;
    sbDriver := c as TSpeedButton;
    Result := sbDriver.Hint;
    Break;
  end;
end;

function TFacePageButtonApi.ReadIsExist(DriverID: string): Boolean;
begin
  Result := Assigned( ReadButton( DriverID ) );
end;

function TFacePageButtonApi.ReadSelectDriver: string;
var
  i: Integer;
  c : TControl;
  sbDriver : TSpeedButton;
begin
  Result := '';
  for i := 0 to plToolBar.ControlCount - 1 do
  begin
    c := plToolBar.Controls[i];
    if not ( c is TSpeedButton ) then
      Continue;
    sbDriver := c as TSpeedButton;
    if sbDriver.Down then
    begin
      Result := sbDriver.Hint;
      Break;
    end;
  end;
end;

procedure TFacePageButtonApi.Remove(DriverID: string);
var
  sbDriver : TSpeedButton;
begin
  sbDriver := ReadButton( DriverID );
  if Assigned( sbDriver ) then
    sbDriver.Free;
end;


procedure TFacePageButtonApi.SbButtonClick(Sender: TObject);
var
  sbDriver : TSpeedButton;
begin
  if not ( Sender is TSpeedButton ) then
    Exit;
  sbDriver := Sender as TSpeedButton;
  UserPageButtonApi.SelectDriver( sbDriver.Hint );
end;

{ UserPageButtonApi }

class procedure UserPageButtonApi.AddDriver(DriverID, DriverPath: string);
begin
    // 添加 ToolButton
  if not FacePageButtonApi.ReadIsExist( DriverID ) then
    FacePageButtonApi.Add( DriverID, DriverPath );

    // 添加页面
  UserPageDriverApi.AddDriver( DriverID, DriverPath );
end;

class procedure UserPageButtonApi.RemoveDriver(DriverID: string);
begin
    // 删除按钮
  FacePageButtonApi.Remove( DriverID );

    // 删除页面
  UserPageDriverApi.RemoveDriver( DriverID );
end;

class procedure UserPageButtonApi.SelectDriver(DriverID: string);
begin
    // 选择 ToolButton
  FacePageButtonApi.Enter( DriverID );

    // 选择页面
  UserPageDriverApi.SelectDriver( DriverID );
end;

class procedure UserPageButtonApi.SelectFirstDriver;
var
  FirstDriver : string;
begin
  FirstDriver := FacePageButtonApi.ReadFirstDriver;
  if FirstDriver <> '' then
    SelectDriver( FirstDriver );
end;

{ UserPageDriverApi }

class procedure UserPageDriverApi.AddDriver(DriverID, DriverPath: string);
begin
    // 页面已存在
  if not FacePageDriverApi.ReadIsExist( DriverID ) then
    FacePageDriverApi.Add( DriverID, DriverPath );
end;

class procedure UserPageDriverApi.RefreshDriver(DriverID: string);
begin
    // 加载页面
  UserLocalDriverApi.RefreshFolder( DriverID );
  UserNetworkDriverApi.RefreshFolder( DriverID );
end;

class procedure UserPageDriverApi.RemoveDriver(DriverID: string);
begin
  FacePageDriverApi.Remove( DriverID );
end;

class procedure UserPageDriverApi.SelectDriver(DriverID: string);
begin
    // 进入页面
  FacePageDriverApi.Enter( DriverID );

    // 刷新页面
  UserFrameDriverApi.SelectFrame( DriverID );
  UserLocalDriverApi.RefreshFolder( DriverID );
  UserNetworkDriverApi.RefreshFolder( DriverID );
end;

{ MyComputerID }

class function MyComputerID.get: string;
begin
    // 读取 PcID
  Result := Read;

    // 读取 成功
  if Result <> '' then
    Exit;

    // 新建一个 PcID
  Result := getNewPcID;

    // 保存 PcID
  Save( Result );
end;

class function MyComputerID.getNewPcID: string;
var
  PcID, s : string;
  i : Integer;
  n : Integer;
  c : Char;
begin
  PcID := '';
  Randomize;
  for i := 1 to 8 do
  begin
    n := Random( 36 );
    if n < 10 then
      s := IntToStr( n )
    else
    begin
      n := n - 10 + 65;
      c := Char(n);
      s := c;
    end;
    PcID := PcID + s;
  end;
  Result := PcID;
end;

class function MyComputerID.Read: string;
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create( MyAppData.getConfigPath );
  try
    Result := IniFile.ReadString( Ini_App, Ini_AppPcID, '' );
  except
  end;
  IniFile.Free;
end;

class procedure MyComputerID.Save(PcID: string);
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create( MyAppData.getConfigPath );
  try
    IniFile.WriteString( Ini_App, Ini_AppPcID, PcID );
  except
  end;
  IniFile.Free;
end;

{ TAppLanguageEditionCheck }

procedure TAppStartHandle.AppRunMark;
var
  PcID, EditionStr : string;
  HttpMark : TIdHTTP;
  Params : TStringList;
begin
  PcID := MyComputerID.get;
  EditionStr := 'UsbManager';
  Params := TStringList.Create;
  Params.Add( MarkApp_PcID + '=' + PcID );
  Params.Add( MarkApp_Edition + '=' + EditionStr );
  HttpMark := TIdHTTP.Create( nil );
  HttpMark.HandleRedirects := True;
  HttpMark.ConnectTimeout := 60000;
  HttpMark.ReadTimeout := 60000;
  try
    HttpMark.Post( Url_MarkApp, Params );
  except
  end;
  HttpMark.Free;
  Params.Free;
end;

procedure TAppStartHandle.Update;
begin
MyThreadUtil.Run(
procedure
begin
    // 记录本机运行信息
  AppRunMark;
end);
end;

{ TDropFilesHandle }

constructor TDropFilesHandle.Create(_Msg: TMessage);
var
  FilesCount: Integer; // 文件总数
  i: Integer;
  FileName: array [0 .. 255] of Char;
  FilePath: string;
begin
  Msg := _Msg;
  FileList := TStringList.Create;

  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);
  try
    // 获取文件名
    for i := 0 to FilesCount - 1 do
    begin
      DragQueryFile(Msg.WParam, i, FileName, 256);
      FilePath := FileName;
      FileList.Add(FilePath);
    end;
  except
  end;
  DragFinish(Msg.WParam); // 释放
end;

destructor TDropFilesHandle.Destroy;
begin
  FileList.Free;
  inherited;
end;

procedure TDropFilesHandle.Update;
begin
  UserLocalDriverApi.CopyNow( FacePageButtonApi.ReadSelectDriver, FileList );
end;


{ TUsbFrameInfo }

procedure TUsbFrameInfo.AddHistory(Path: string);
begin
  HistoryList.Add( Path );
end;

constructor TUsbFrameInfo.Create(_UsbID: string);
begin
  UsbID := _UsbID;
  HistoryList := TStringList.Create;
end;

destructor TUsbFrameInfo.Destroy;
begin
  HistoryList.Free;
  inherited;
end;

procedure TUsbFrameInfo.SetPathInfo(_UsbPath, _NetworkPath, _LocalPath: string);
begin
  UsbPath := _UsbPath;
  NetworkPath := _NetworkPath;
  LocalPath := _LocalPath;
end;

procedure TUsbFrameInfo.SetPosition(_LocalWidth, _LocalHistoryHeigh: Integer);
begin
  LocalWidth := _LocalWidth;
  LocalHistoryHeigh := _LocalHistoryHeigh;
end;

end.
