program UsbManager;

uses
  ExceptionLog,
  Vcl.Forms,
  Windows,
  UMainForm in 'UMainForm.pas' {frmMain},
  UMyUtils in 'UMyUtils.pas',
  UFrameDriver in 'UFrameDriver.pas' {FrameDriver: TFrame},
  UThreadUtil in 'UThreadUtil.pas',
  UMyFaceThread in 'UMyFaceThread.pas',
  UFileSearch in 'UFileSearch.pas',
  Vcl.Themes,
  Vcl.Styles,
  UFileThread in 'UFileThread.pas',
  UFormZip in 'UFormZip.pas' {frmZip},
  dirnotify in 'dirnotify.pas',
  UFileWatchThread in 'UFileWatchThread.pas',
  UFormConflict in 'UFormConflict.pas' {frmConflict},
  UFormAbout in 'UFormAbout.pas' {frmAbout},
  UMyUrl in 'UMyUrl.pas';

{$R *.res}

var
  myhandle : Integer;
begin
    // �����ڴ�й©
  ReportMemoryLeaksOnShutdown := DebugHook<>0;

    // ��ֹ�������ͬʱ����
  myhandle := findwindow( hfck_Name, nil );
  if myhandle > 0 then  // ������ͬһ�� �û� ID �Ѿ�����, �ָ�֮ǰ�Ĵ���
  begin
    postmessage( myhandle,hfck_index,0,0 );
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Iceberg Classico');
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmZip, frmZip);
  Application.CreateForm(TfrmConflict, frmConflict);
  Application.CreateForm(TfrmAbout, frmAbout);
  frmMain.AppStart;
  Application.Run;
end.
