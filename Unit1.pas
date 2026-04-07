unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils,
  WsjtxUdp, Vcl.ExtCtrls, Vcl.Buttons;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    BitBtn1: TBitBtn;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private 宣言 }
    WsjtxUdp: TWsjtxUdp;
    procedure RecvHeartbeatMessage(Sender: tObject);
    procedure RecvStatusMessage(Sender: tObject);
    procedure RecvDecodeMessage(Sender: tObject);
    procedure RecvClearMessage(Sender: tObject);
    procedure RecvQsoLoggedMessage(Sender: tObject);
    procedure RecvCloseMessage(Sender: tObject);
    procedure RecvLoggedAdifMessage(Sender: tObject);
    procedure RecvStoppedHeartbeatMessage(Sender: tObject);
    procedure AddHexMessage;
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  WSjtxUdp.HexMessageEnable := Not WSjtxUdp.HexMessageEnable;
  if WSjtxUdp.HexMessageEnable then
    BitBtn1.Font.Color := clWindowText
  else
    BitBtn1.Font.Color := clGreen;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  WSjtxUdp.Port := 2237;
  WSjtxUdp.Open();

  Button1.Enabled  := False;
  Button2.Enabled  := True;
  BitBtn1.Enabled  := true;

  WSjtxUdp.OnHeartbeat   := RecvHeartbeatMessage;
  WSjtxUdp.OnDecode      := RecvDecodeMessage;
  WSjtxUdp.OnStatus      := RecvStatusMessage;
  WSjtxUdp.OnClear       := RecvClearMessage;
  WSjtxUdp.OnQsoLogged   := RecvQsoLoggedMessage;
  WSjtxUdp.OnClose       := RecvCloseMessage;
  WSjtxUdp.OnLoggedAdif  := RecvLoggedAdifMessage;
  WSjtxUdp.OnstOppedHeartbeat := RecvStoppedHeartbeatMessage;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  WSjtxUdp.Close;

  Button1.Enabled  := true;
  Button2.Enabled  := False;
  BitBtn1.Enabled  := False;
end;


procedure TForm1.Button3Click(Sender: TObject);
var
  CurrentDir: string;begin
begin
    // 指定されたファイル名にMemo1の内容を保存
    CurrentDir := TPath.GetDirectoryName(ParamStr(0));
    Memo1.Lines.SaveToFile(CurrentDir + '\WSJT-X Log.txt', TEncoding.UTF8);
  end;
end;


procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Clear;
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(WsjtxUdp);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  WsjtxUdp := TWSjtxUdp.Create();

  Panel1.Caption    := '';
  Memo1.Clear;
  Button1.Enabled   := true;
  Button2.Enabled   := False;
  BitBtn1.Enabled   := False;
end;


procedure TForm1.RecvHeartbeatMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXHeartbeatMessage do
    begin
    s := Format('Heartbeat--ProgramId:%s Version:%s Revision:%s LastHeartbee:', [ProgramID, Version, Revision]);
    s := s + FormatDateTime('hh:nn:ss.zzz', LastHeartbeat);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;


procedure TForm1.RecvStatusMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXStatusMessage do
    begin
    s := Format('Status--ProgramId:%s Freq:%d Mode:%s DxCall:%s DxGrid:', [ProgramId, DialFreq, Mode, DxCall, DxGrid]);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;


procedure TForm1.RecvClearMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXClearMessage do
    begin
    s := format('Clear--ProgramId:%s New:', [ProgramId]);
    s := s + IntToStr(Window);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;

procedure TForm1.RecvCloseMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXCloseMessage do
    begin
    s := format('Clear--ProgramId:%s New:', [ProgramId]);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;

procedure TForm1.RecvDecodeMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXDecodeMessage do
    begin
    s := format('Decode--ProgramId:%s New:', [ProgramId]);
    s := s + BoolToStr(NewFlag);
    s := s + ' Time:' + FormatDateTime('hh:nn:ss.zzz', Time);
    s := s + format(' snr:%d Mode:%s Message:%s', [Snr, Mode, MessageText]);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;


procedure TForm1.RecvQsoLoggedMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXQsoLoggedMessage do
    begin
    s := format('LoggedQso--ProgramId:%s ', [ProgramId]);
    s := s + 'DateTimeOff:' + FormatDateTime('yyyy/mm/dd hh:nn:ss.zzz', DateTimeOff);
    s := s + Format(' DxCall:%s DxGrid:%s TxFreq:%u Mode:%s ReportSent:%s ReportRcvd:%s',
         [DxCall, DxGrid, TxFreq, Mode, ReportSent, ReportRecieved]);
    memo1.Lines.add(s);
    end;
  AddHexMessage
end;


procedure TForm1.RecvLoggedAdifMessage(Sender: tObject);
var
  s: string;
begin
  with WSjtxUdp.WSJTXLoggedAdifMessage do
    begin
    s := Format('LoggedAdif--ProgramId:%s Call:%s GridSquare:%s Mode:%s Rst_Sent:%s RstRcvd:%s QsoDate:',
         [ProgramId, Call, gridsquare, Mode, rst_Sent, rst_rcvd]);
    s := s + FormatDateTime('yyyy/mm/dd', qso_date);
    s := s + ' Time_On:' + FormatDateTime('hh:nn', Time_On);
    s := s + format(' Band:%s Freq:%7.3f', [Band, Freq]);
    memo1.Lines.add(s);
    end;
  AddHexMessage;
end;


procedure TForm1.RecvStoppedHeartbeatMessage(Sender: tObject);
begin
  with WSjtxUdp.WSJTXStoppedHeartbeatMessage do
    begin
     Winapi.Windows.Beep(523,300);    // Play the note C for 300ms.
  end;

  Button2Click(Button2);
end;

procedure TForm1.AddHexMessage();
begin
  if WSjtxUdp.HexMessageEnable then
    memo1.Lines.add(WSjtxUdp.HexMessage);
end;

end.
