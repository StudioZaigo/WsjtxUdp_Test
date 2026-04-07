unit WsjtxUdp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  IdSocketHandle, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer, IdUDPClient,
  Winsock,  IdGlobal,  Dialogs, System.DateUtils,  system.UITypes, MMSystem, Vcl.ExtCtrls,
  System.Generics.Collections, System.RegularExpressions;

type
  TWSJTXMessageParser = class
  public
//    function Parse(const Bytes: TBytes): TObject;  // The returned class is a message class.
  end;

type
  TWSJTXMessage = class
  public
    MessageType: Cardinal;
  end;

type
  TWSJTXHeartbeatMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    MaxShemaNo: uint32;
    Version: string;
    revision: string;
    LastHeartbeat: ttime;
  end;

  TWSJTXStatusMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    DialFreq: Int64;
    Mode: string;
    DxCall: string;
    Report: string;
    TxMode: string;
    TxEnabled: Boolean;
    Transmitting: Boolean;
    Decoding: boolean;
    RxDf: UInt32;
    TxDf: Uint32;
    DeCall: string;
    DeGrid: string;
    DxGrid: string;
  end;

  TWSJTXDecodeMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    NewFlag: Boolean;
    Time: TDateTime;
    SNR: Int32;           // S/N比
    DeltaTime: Double;
    DeltaFreq: Cardinal;
    Mode: string;
    MessageText: string;
    LowConfidence: Boolean;
    OffAir: Boolean;
  end;

  TWSJTXClearMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    Window: UInt8;
  end;

  TWSJTXQSOLoggedMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    DateTimeOff: TdateTime;
    DxCall: string;
    DxGrid: string;
    TxFreq: uint64;
    Mode: string;
    ReportSent: string;
    ReportRecieved: string;
    TxPower: string;
    Comments: string;
    Name: string;
    DateTimeOn: TDateTIme;
  end;

  TWSJTXCloseMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
  end;

  TWSJTXLoggedAdifMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    AdifText: string;
    call: string;
    gridsquare: string;
    mode: string;
    rst_Sent: string;
    rst_rcvd: string;
    qso_date: TDate;
    time_on: TTime;
    qso_date_off: TDate;
    time_off: TTime;
    band: string;
    freq: Double;
    station_callsign: string;
    my_gridsquare: string;
  end;

  TWSJTXStoppedHeartbeatMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    StopTime: TTime;
  end;

 type
  TWsjtxUdp = class(TObject)
    procedure UDPServerUDPRead(AThread: TIdUDPListenerThread;
      AData: array of Byte; ABinding: TIdSocketHandle);

  private
  { Private 宣言 }
    UDPServer: TIdUDPServer;
    Timer1: TTimer;

    FModeMap: TDictionary<string, string>;

    FPort: TIdPort;
    FIpAddress: string;
    FHexMessage: string;
    FHeartbeatTimeout: Cardinal;
//    FActive: boolean;

    FOnHeartbeat:         TNotifyEvent;
    FOnStatus:            TNotifyEvent;
    FOnDecode:            TNotifyEvent;
    FOnClear:             TNotifyEvent;
    FOnQSOLogged:         TNotifyEvent;
    FOnClose:             TNotifyEvent;
    FOnLoggedADIF:        TNotifyEvent;
    FOnStoppedHeartbeat:  TNotifyEvent;

    FWSJTXHeartbeatMessage:         TWSJTXHeartbeatMessage;
    FWSJTXStatusMessage:            TWSJTXStatusMessage;
    FWSJTXDecodeMessage:            TWSJTXDecodeMessage;
    FWSJTXClearMessage:             TWSJTXClearMessage;
    FWSJTXQSOLoggedMessage:         TWSJTXQSOLoggedMessage;
    FWSJTXCloseMessage:             TWSJTXCloseMessage;
    FWSJTXLoggedADIFMessage:        TWSJTXLoggedADIFMessage;
    FWSJTXStoppedHeartbeatMessage:  TWSJTXStoppedHeartbeatMessage;
    FOmitDuplicate: boolean;
    FHexMessageEnable: boolean;
    FActive: boolean;

    procedure SetIpAddress(const Value: string);
    procedure SetPort(const Value: TIdPort);
    procedure SetOnHeartbeat(const Value: TNotifyEvent);
    procedure SetOnStatus(const Value: TNotifyEvent);
    procedure SetOnDecode(const Value: TNotifyEvent);
    procedure SetOnClear(const Value: TNotifyEvent);
    procedure SetOnQSOLogged(const Value: TNotifyEvent);
    procedure SetOnLoggedAdif(const Value: TNotifyEvent);
    procedure SetOnClose(const Value: TNotifyEvent);
    procedure SetOnStoppedHeartbeat(const Value: TNotifyEvent);
    procedure SetHeartbeatTimeout(const Value: Cardinal);        // Seconds

    function MessageParser(const Bytes: TBytes): TWSJTXMessage;
    procedure ParseHeartbeat(Bytes: TBytes);
    procedure ParseStatus(const Bytes: TBytes);
    procedure ParseDecode(Bytes: TBytes);
    procedure ParseClear(Bytes: TBytes);
    procedure ParseQSOLogged(Bytes: TBytes);
    procedure ParseClose(Bytes: TBytes);
    procedure ParseLoggedADIF(Bytes: TBytes);

    procedure Timer1Timer(Sender: TObject);
    function QDateTimeToTDateTime(const Bytes: TBytes; var Pos: Integer): TdateTime;
    function ReadString(const Bytes: TBytes; var Pos: Integer): string;
    function ReadInt64BE(const Bytes: TBytes; var Pos: Integer): Int64;
    function ReadInt32BE(const Bytes: TBytes; var Pos: Integer): Int32;
    function ReadUInt32BE(const Bytes: TBytes; var Pos: Integer): Cardinal;
    function ReadAdifElement(Adif: string; Pattern: string): string;
    function MessToHex(const Bytes: TBytes): string;
    function ReadDoubleBE(const Bytes: TBytes; var Pos: Integer): Double;
    function ReadFloatBE(const Bytes: TBytes; var Pos: Integer): Single;
    function ReadBoolean(const Bytes: TBytes; var Pos: Integer): boolean;
    function DecodeModeSymbol(const Symbol: string): string;
    function ReadUInt8(const Bytes: TBytes; var Pos: Integer): byte;
    procedure SetOmitDuplicate(const Value: boolean);
    procedure SetHexMessageEnable(const Value: boolean);
    procedure setFActive(const Value: boolean);
//    procedure setFActive(const Value: boolean);

  public
  { Public 宣言 }
    constructor Create;
    destructor Destroy; override; // Do Override

    property WSJTXHeartbeatMessage:         TWSJTXHeartbeatMessage read FWSJTXHeartbeatMessage;
    property WSJTXStatusMessage:            TWSJTXStatusMessage read FWSJTXStatusMessage;
    property WSJTXDecodeMessage:            TWSJTXDecodeMessage read FWSJTXDecodeMessage;
    property WSJTXClearMessage:             TWSJTXClearMessage read FWSJTXClearMessage;
    property WSJTXQSOLoggedMessage:         TWSJTXQSOLoggedMessage read FWSJTXQSOLoggedMessage;
    property WSJTXCloseMessage:             TWSJTXCloseMessage read FWSJTXCloseMessage;
    property WSJTXLoggedADIFMessage:        TWSJTXLoggedADIFMessage read FWSJTXLoggedADIFMessage;
    property WSJTXStoppedHeartbeatMessage:  TWSJTXStoppedHeartbeatMessage read FWSJTXStoppedHeartbeatMessage;

    property OnHeartbeat: TNotifyEvent          read FOnHeartbeat write SetOnHeartbeat;
    property OnStatus: TNotifyEvent             read FOnStatus write SetOnStatus;
    property OnDecode: TNotifyEvent             read FOnDecode write SetOnDecode;
    property OnClear: TNotifyEvent              read FOnClear write SetOnClear;
    property OnQSOLogged: TNotifyEvent          read FOnQSOLogged write SetOnQSOLogged;
    property OnClose: TNotifyEvent              read FOnClose write SetOnClose;
    property OnLoggedADIF: TNotifyEvent         read FOnLoggedADIF write SetOnLoggedADIF;
    property OnStoppedHeartbeat: TNotifyEvent   read FOnStoppedHeartbeat write SetOnStoppedHeartbeat;

    property HexMessageEnable: boolean read FHexMessageEnable write SetHexMessageEnable;
    property HexMessage: string read FHexMessage;
    property HeartbeatTimeout: Cardinal read FHeartbeatTimeout write SetHeartbeatTimeout;
    property Active: boolean read FActive write setFActive;

    Property Port: TIdPort read FPort write SetPort;    // TIdPort is a Word (2-digit integer type)

    procedure Open(); overload;
    procedure Open(Port: TIDPort); overload;
    procedure Close();

 end;

implementation

{ TWsjtxUdp }

constructor TWsjtxUdp.Create;
begin
  inherited Create; // Always call the parent class constructor. [2]

  UDPServer := TIdUDPServer.Create();
  try
    FWSJTXHeartbeatMessage      := TWSJTXHeartbeatMessage.Create;
    FWSJTXStatusMessage         := TWSJTXStatusMessage.Create;
    FWSJTXDecodeMessage         := TWSJTXDecodeMessage.Create;
    FWSJTXQSOLoggedMessage      := TWSJTXQSOLoggedMessage.Create;
    FWSJTXCloseMessage          := TWSJTXCloseMessage.Create;
    FWSJTXLoggedADIFMessage     := TWSJTXLoggedADIFMessage.Create;
    FWSJTXStoppedHeartbeatMessage := TWSJTXStoppedHeartbeatMessage.Create;

    FModeMap := TDictionary<string, string>.Create;
    // WSJT-X Mode (1 character) → Actual mode name
    FModeMap.Add('~', 'FT8');
    FModeMap.Add('+', 'FT4');
    FModeMap.Add('@', 'JT65');
    FModeMap.Add('$', 'JT9');
    FModeMap.Add('#', 'WSPR');
    FModeMap.Add('%', 'Q65');
    FModeMap.Add('&', 'FST4');
    FModeMap.Add('*', 'FST4W');

    FHeartbeatTimeout := 60;  // Check Heartbeat timeout every 60 seconds (in seconds).
    FOmitDuplicate    := false;

    Timer1 := TTimer.Create(nil);
    Timer1.OnTimer := Timer1Timer;
    Timer1.Enabled := false;
    Timer1.Interval := 3000;    // Check heartbeat every 3 seconds.

    FHeartbeatTimeout:= 3 * 15;   //  Heartbeat Eat: 1 per 5 times

    UDPServer.DefaultPort := 2237;
    UDPServer.BroadcastEnabled := True;
    UDPServer.OnUDPRead := UDPServerUDPRead; // Events upon reception

  except
    FreeAndNil(UDPServer);
  end;

end;

destructor TWsjtxUdp.Destroy;
begin
  FreeAndNil(FWSJTXHeartbeatMessage);
  FreeAndNil(FWSJTXStatusMessage);
  FreeAndNil(FWSJTXDecodeMessage);
  FreeAndNil(FWSJTXDecodeMessage);
  FreeAndNil(FWSJTXClearMessage);
  FreeAndNil(FWSJTXLoggedADIFMessage);
  FreeAndNil(FWSJTXCloseMessage);
  FreeAndNil(FWSJTXStoppedHeartbeatMessage);

  FreeAndNil(FModeMap);

  FreeAndnil(Timer1);

  FreeAndNil(UDPServer);  // Release the resources you have secured.
  inherited Destroy;      // Call the destructor of the inherited class
end;

procedure TWsjtxUdp.Open();
begin
  FWSJTXHeartbeatMessage.LastHeartbeat := Time();
  Timer1.Enabled := true;
  UDPServer.Active := True;
end;

procedure TWsjtxUdp.Open(Port: TIDPort);
begin
  Timer1.Enabled := true;
  SetPort(Port);
  UDPServer.Active := True;
end;

procedure TWsjtxUdp.Close;
begin
  Timer1.Enabled := false;
  UDPServer.Active := False;
end;

procedure TWsjtxUdp.Timer1Timer(Sender: TObject);
var
  CurrentTime: TTime;
  ElapsedTime: TTime;
  Elapsedminutes: Cardinal;
begin
  if not Timer1.Enabled then exit;

  CurrentTime := Time();
  ElapsedTime := CurrentTime - FWSJTXHeartbeatMessage.LastHeartbeat;
  Elapsedminutes := trunc(ElapsedTime * 24 * 60 * 60);  // Convert to seconds
  with FWSJTXStoppedHeartbeatMessage do
    begin
    ProgramId := FWSJTXHeartbeatMessage.ProgramID;
    StopTime  := Time();
    end;
  if  Elapsedminutes >= FHeartbeatTimeout then
    begin
    if Assigned(FOnStoppedHeartbeat) then
//      FOnstoppedHeartbeat(FWSJTXStoppedHeartbeatMessage);
      FOnstoppedHeartbeat(nil);
    fWSJTXHeartbeatMessage.LastHeartbeat := Time();
    end;
end;


procedure TWsjtxUdp.SetHeartbeatTimeout(const Value: Cardinal);
begin
  FHeartbeatTimeout := Value;
end;


procedure TWsjtxUdp.SetHexMessageEnable(const Value: boolean);
begin
  FHexMessageEnable := Value;
end;


procedure TWsjtxUdp.SetIpAddress(const Value: string);
begin
  FIpAddress := Value;
end;


procedure TWsjtxUdp.SetOmitDuplicate(const Value: boolean);
begin
  FOmitDuplicate := Value;
end;


procedure TWsjtxUdp.SetOnClear(const Value: TNotifyEvent);
begin
  FOnClear := Value;
end;

procedure TWsjtxUdp.SetOnClose(const Value: TNotifyEvent);
begin
  FOnClose := Value;
end;

procedure TWsjtxUdp.SetOnDecode(const Value: TNotifyEvent);
begin
  FOnDecode := Value;
end;


procedure TWsjtxUdp.SetOnHeartbeat(const Value: TNotifyEvent);
begin
  FOnHeartbeat := Value;
end;


procedure TWsjtxUdp.SetOnStatus(const Value: TNotifyEvent);
begin
  FOnStatus := Value;
end;


procedure TWsjtxUdp.SetOnStoppedHeartbeat(const Value: TNotifyEvent);
begin
  FOnstoppedHeartbeat := Value;
end;

procedure TWsjtxUdp.SetOnQSOLogged(const Value: TNotifyEvent);
begin
  FOnQSOLogged := Value;
end;


procedure TWsjtxUdp.SetOnLoggedAdif(const Value: TNotifyEvent);
begin
  FOnLoggedAdif := Value;
end;


procedure TWsjtxUdp.SetPort(const Value: TIdPort);
begin
  if Value < 1024 then
    begin
    MessageDlg('UDP Port Error', mtError, [mbOK], 0, mbYes);
    exit;
    end;
  FPort := Value;
end;

procedure TWsjtxUdp.UDPServerUDPRead(AThread: TIdUDPListenerThread;
  AData: array of Byte; ABinding: TIdSocketHandle);
var
  Bytes: TBytes;
  Msg: TObject;
begin
  // Copy from AData to TBytes.
  SetLength(Bytes, Length(AData));
  Move(AData[0], Bytes[0], Length(AData));

  // Hand it to the parser.
  Msg := MessageParser(Bytes);

  // Event triggered depending on the type of message.
  if Msg is TWSJTXHeartbeatMessage then
    begin
    if Assigned(OnHeartbeat) then
      OnHeartbeat(Msg);
    end
  else if Msg is TWSJTXStatusMessage then
    begin
    if Assigned(OnStatus) then
      OnStatus(Msg);
    end
  else if Msg is TWSJTXDecodeMessage then
    begin
    if Assigned(OnDecode) then
      OnDecode(Msg);
    end
  else if Msg is TWSJTXClearMessage then
    begin
    if Assigned(OnClear) then
      OnClear(Msg);
    end
  else if Msg is TWSJTXQSOLoggedMessage then
    begin
    if Assigned(OnQSOLogged) then
      OnQSOLogged(Msg);
    end
  else if Msg is TWSJTXCloseMessage then
    begin
    if Assigned(OnClose) then
      OnClose(Msg);
    end
  else if Msg is TWSJTXLoggedADIFMessage then
    begin
    if Assigned(OnLoggedADIF) then
      OnLoggedADIF(Msg);
    end;
end;

function TWsjtxUdp.MessageParser(const Bytes: TBytes): TWSJTXMessage;
var
  MsgType: Cardinal;
  Pos: integer;
begin
  Pos := 8;
  MsgType := ReadUInt32BE(Bytes, Pos);

  case MsgType of
    0: begin ParseHeartbeat(Bytes); Result := FWSJTXHeartbeatMessage; end;
    1: begin ParseStatus(Bytes);    Result := FWsjtxStatusMessage; end;
    2: begin ParseDecode(Bytes);    Result := FWsjtxDecodeMessage; end;
    3: begin ParseClear(Bytes);     Result := FWsjtxClearMessage; end;
    5: begin ParseQSOLogged(Bytes); Result := FWSJTXQSOLoggedMessage; end;
    6: begin ParseClose(Bytes);     Result := FWSJTXCloseMessage; end;
   12: begin ParseLoggedADIF(Bytes);Result := FWSJTXLoggedADIFMessage;end;
  else
    Result := nil;
  end;
end;


procedure TWsjtxUdp.ParseHeartbeat(Bytes: TBytes);
var
  Pos: Integer;
begin
  Pos := 12;

  with FWSJTXHeartbeatMessage do
    begin
    ProgramID     := ReadString(Bytes, Pos);
    MaxShemaNo    := ReadUInt32BE(Bytes, Pos);
    Version       := ReadString(Bytes, Pos);
    revision      := ReadString(Bytes, Pos);

    LastHeartbeat := Time();
    end;
  FHexMessage := '';
  if HexMessageEnable then
    FHexMessage := MessToHex(Bytes);
end;

procedure TWsjtxUdp.ParseStatus(const Bytes: TBytes);
var
  Pos: Integer;
begin
  Pos := 12; // It is positioned after Magic + Schema + MsgType.

  with FWSJTXStatusMessage do
    begin
    ProgramID := ReadString(Bytes, Pos);   // ID(WSJT-X。JTDXの場合はJTDXか？)

//  Convert from a big ending to a little ending.
    DialFreq := ReadInt64BE(Bytes, Pos);        // Dial Frequency（Hz）

    Mode := ReadString(Bytes, Pos);        // Mode (FT-8, etc.)
    DxCall := ReadString(Bytes, Pos);      // Dx Call
    Report := ReadString(Bytes, Pos);      // Report
    TxMode := ReadString(Bytes, Pos);      // TxMode
    TxEnabled     := ReadBoolean(Bytes, Pos);   // Tx Enable
    Transmitting  := ReadBoolean(Bytes, Pos);   // Transmitting
    Decoding      := ReadBoolean(Bytes, Pos);   // Decoding

    RxDf          := ReadUInt32BE(Bytes, Pos);
    TxDf          := ReadUInt32BE(Bytes, Pos);

    DeCall := ReadString(Bytes, Pos);      // My Callsign
    DeGrid := ReadString(Bytes, Pos);      // My Grid Square
    DxGrid := ReadString(Bytes, Pos);      // Opponent's grid square
    end;

  FHexMessage := '';
  if HexMessageEnable then
    FHexMessage := MessToHex(Bytes);
end;

procedure TWsjtxUdp.ParseClear(Bytes: TBytes);
var
  Pos: Integer;
  qTime: cardinal;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  with FWSJTXClearMessage do
    begin
    ProgramID := ReadString(Bytes, Pos);     // ID (WSJT-X. If using JTDX, should it be JTDX?)
    Window    := ReadUInt8(Bytes, pos);
    end;
end;

procedure TWsjtxUdp.ParseClose(Bytes: TBytes);
var
  Pos: Integer;
  qTime: cardinal;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  with FWSJTXCloseMessage do
    begin
    ProgramID := ReadString(Bytes, Pos);     // ID (WSJT-X. If using JTDX, should it be JTDX?)
    end;
end;

procedure  TWsjtxUdp.ParseDecode(Bytes: TBytes);
var
  Pos: Integer;
  qTime: cardinal;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  with FWSJTXDecodeMessage do
    begin
    ProgramID := ReadString(Bytes, Pos);     // ID (WSJT-X. If using JTDX, should it be JTDX?)

    NewFlag := Bytes[Pos] <> 0;                   // New
    Inc(Pos, 1);

    qTime := ReadUInt32BE(Bytes, Pos);            // Time in milliseconds
    Time  := qTime / 86400000.0;                  // Convert from milliseconds to time format
    Time  := TTimeZone.Local.ToLocalTime(time);   // Convert from UTC to JST

    snr       := ReadInt32Be(Bytes, pos);
    DeltaTime := ReadDoubleBE(Bytes, pos);
    DeltaFreq := ReadUint32Be(Bytes, pos);

    Mode      := ReadString(Bytes, Pos);
    Mode      := DecodeModeSymbol(Mode);

    MessageText   := ReadString(Bytes, Pos);      // Message decoded by WSJT-X
                                                  // Examples: "E44K R3OZ 73", "CQ BY6PWC OM64", etc.
    LowConfidence := ReadBoolean(Bytes, Pos);
    OffAir        := ReadBoolean(Bytes, Pos);
    end;
  FHexMessage := '';
  if HexMessageEnable then
    FHexMessage := MessToHex(Bytes);
end;

procedure TWsjtxUdp.ParseQSOLogged(Bytes: TBytes);
var
  Pos: Integer;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  with FWSJTXQsoLoggedMessage do
    begin
    ProgramID     := ReadString(Bytes, Pos);
    DateTimeOff   := QDateTimeToTDateTime(Bytes, Pos);
    DateTimeOff   := TTimeZone.Local.ToLocalTime(DateTimeOff);   // Convert from UTC to JST
    DxCall        := ReadString(Bytes, Pos);
    DxGrid        := ReadString(Bytes, Pos);
    TxFreq        := ReadInt64BE(Bytes, Pos);
    Mode          := ReadString(Bytes, Pos);
    ReportSent    := ReadString(Bytes, Pos);
    ReportRecieved:= ReadString(Bytes, Pos);
    TxPower       := ReadString(Bytes, Pos);
    Comments      := ReadString(Bytes, Pos);
    Name          := ReadString(Bytes, Pos);
    DateTimeOn    := QDateTimeToTDateTime(Bytes, Pos);
    DateTimeOn    := TTimeZone.Local.ToLocalTime(DateTimeOn);   // Convert from UTC to JST
    end;
  FHexMessage := '';
  if HexMessageEnable then
    FHexMessage := MessToHex(Bytes);
end;

procedure TWsjtxUdp.ParseLoggedADIF(Bytes: TBytes);
var
  Pos: Integer;
  d: string;
  t: string;
  f: string;
  dt: TDateTime;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  with FWSJTXLoggedAdifMessage do
    begin
    ProgramID     := ReadString(Bytes, Pos);
    AdifText      := ReadString(Bytes, Pos);

    Call          := ReadAdifElement(AdifText, 'call');
    gridsquare    := ReadAdifElement(AdifText, 'gridsquare');
    mode          := ReadAdifElement(AdifText, 'mode');
    rst_sent      := ReadAdifElement(AdifText, 'rst_sent');
    rst_rcvd      := ReadAdifElement(AdifText, 'rst_rcvd');

    d             := ReadAdifElement(AdifText, 'qso_date');
    t             := ReadAdifElement(AdifText, 'time_on');
    dt            := StrToDateTime(copy(d,1,4) + '/' + copy(d, 5,2) + '/' + copy(d, 7,2)
                      + ' ' + copy(t,1,2) + ':' + copy(t, 3,2) +  ':00');
    dt            := TTimeZone.Local.ToLocalTime(dt);           // Convert from UTC to JST
    qso_date      := DateOf(dt);
    time_on       := Timeof(dt);

    d             := ReadAdifElement(AdifText, 'qso_date_off');
    t             := ReadAdifElement(AdifText, 'time_off');
    dt            := StrToDateTime(copy(d,1,4) + '/' + copy(d, 5,2) + '/' + copy(d, 7,2)
                      + ' ' + copy(t,1,2) + ':' + copy(t, 3,2) +  ':00');
    dt            := TTimeZone.Local.ToLocalTime(dt);           // Convert from UTC to JST
    qso_date_off  := DateOf(dt);
    time_off      := TimeOf(dt);

    band          := ReadAdifElement(AdifText, 'band');
    f             := ReadAdifElement(AdifText, 'freq');
    freq          := Trunc(StrToFloat(f) * 100) / 100;        // Round down 18.102018 to 18.10

    station_callsign  := ReadAdifElement(AdifText, 'station_callsign');
    my_gridsquare     := ReadAdifElement(AdifText, 'my_gridsquare');
    end;
  FHexMessage := '';
  if HexMessageEnable then
    FHexMessage := FWSJTXLoggedAdifMessage.AdifText + #13#10 + MessToHex(Bytes);
end;


function TWsjtxUdp.MessToHex(const Bytes: TBytes): string;
var
  hex: string;
  i: integer;
begin
  hex := '';
  for i := 0 to High(Bytes) do
    hex := hex + IntToHex(Bytes[i], 2) + ' ';
  result := hex;
end;

function TWsjtxUdp.ReadString(const Bytes: TBytes; var Pos: Integer): string;
var
  Len, i, n: Int32;
  SBytes: TBytes;
  s: string;
begin
  Move(Bytes[Pos], Len, 4);
  Len := ntohl(Len);
  if Len = -1 then
    begin
    result := '';
    exit;
    end;

  n := length(Bytes);
  if pos + 4 + Len > n  then
    begin
    result := '';
    exit;
    end;

  Inc(Pos, 4);

  SetLength(SBytes, Len);
  for i := 0 to Len - 1 do
    SBytes[i] := Bytes[Pos + i];

  Inc(Pos, Len);

  Result := TEncoding.UTF8.GetString(SBytes);
end;


function TWsjtxUdp.ReadInt64BE(const Bytes: TBytes; var Pos: Integer): Int64;
var
  n: int32;
  v: UInt64;
begin
  n := length(Bytes);
  if pos + 8 > n  then
    begin
    ShowMessage('ReadInt64BE Bytes length overflow');
    result := 0;
    exit;
    end;

  v :=
    (UInt64(Bytes[Pos + 0]) shl 56) or
    (UInt64(Bytes[Pos + 1]) shl 48) or
    (UInt64(Bytes[Pos + 2]) shl 40) or
    (UInt64(Bytes[Pos + 3]) shl 32) or
    (UInt64(Bytes[Pos + 4]) shl 24) or
    (UInt64(Bytes[Pos + 5]) shl 16) or
    (UInt64(Bytes[Pos + 6]) shl 8)  or
    (UInt64(Bytes[Pos + 7]) shl 0);

  Inc(Pos, 8);
  Result := Int64(v);
end;

function TWsjtxUdp.ReadInt32BE(const Bytes: TBytes; var Pos: Integer): Int32;
var
  n: int32;
  v: Int32;
begin
  n := length(Bytes);
  if pos + 4 > n  then
    begin
    ShowMessage('ReadUInt32BE Bytes length overflow');
    result := 0;
    exit;
    end;

  v :=
    (Cardinal(Bytes[Pos + 0]) shl 24) or
    (Cardinal(Bytes[Pos + 1]) shl 16) or
    (Cardinal(Bytes[Pos + 2]) shl 8)  or
    (Cardinal(Bytes[Pos + 3]) shl 0);

  Inc(Pos, 4);
  result := int32(v);
end;

function TWsjtxUdp.ReadUInt32BE(const Bytes: TBytes; var Pos: Integer): Cardinal;
var
  n: int32;
  v: UInt32;
begin
  n := length(Bytes);
  if pos + 4 > n  then
    begin
    ShowMessage('ReadUInt32BE Bytes length overflow');
    result := 0;
    exit;
    end;

  v :=
    (Cardinal(Bytes[Pos + 0]) shl 24) or
    (Cardinal(Bytes[Pos + 1]) shl 16) or
    (Cardinal(Bytes[Pos + 2]) shl 8)  or
    (Cardinal(Bytes[Pos + 3]) shl 0);

  Inc(Pos, 4);
  result := UInt32(v);
end;


function TWsjtxUdp.ReadUInt8(const Bytes: TBytes; var Pos: Integer): byte;
var
  n: int8;
  v: UInt8;
begin
  n := length(Bytes);
  if pos > n  then
    begin
    ShowMessage('ReadUInt8 Bytes length overflow');
    result := 0;
    exit;
    end;

  v :=
    (Cardinal(Bytes[Pos + 0]) shl 0);

  Inc(Pos, 1);
  result := int8(v);
end;

procedure TWsjtxUdp.setFActive(const Value: boolean);
begin
  FActive := Value;
end;


function TWsjtxUdp.ReadFloatBE(const Bytes: TBytes; var Pos: Integer): Single;
var
  n: Int32;
  v: UInt32;
  f: Single absolute v;
begin
  n := length(Bytes);
  if pos + 4 > n  then
    begin
    ShowMessage('ReadFloatBE Bytes length overflow');
    result := 0.0;
    exit;
    end;

  // Big-Endian → UInt32 に変換
  v :=
    (UInt32(Bytes[Pos + 0]) shl 24) or
    (UInt32(Bytes[Pos + 1]) shl 16) or
    (UInt32(Bytes[Pos + 2]) shl 8)  or
    (UInt32(Bytes[Pos + 3]) shl 0);

  Inc(Pos, 4);

  // Interpreting the bit pattern of UInt32 as a Single
  Result := f;
end;

function TWsjtxUdp.ReadDoubleBE(const Bytes: TBytes; var Pos: Integer): Double;
var
  n: Int32;
  v: UInt64;
  d: Double absolute v;
begin
  n := length(Bytes);
  if pos + 8 > n  then
    begin
    ShowMessage('ReadDoubleBE Bytes length overflow');
    result := 0.0;
    exit;
    end;

  v :=
    (UInt64(Bytes[Pos + 0]) shl 56) or
    (UInt64(Bytes[Pos + 1]) shl 48) or
    (UInt64(Bytes[Pos + 2]) shl 40) or
    (UInt64(Bytes[Pos + 3]) shl 32) or
    (UInt64(Bytes[Pos + 4]) shl 24) or
    (UInt64(Bytes[Pos + 5]) shl 16) or
    (UInt64(Bytes[Pos + 6]) shl 8)  or
    (UInt64(Bytes[Pos + 7]) shl 0);

  Inc(Pos, 8);

  Result := d;
end;

function TWsjtxUdp.ReadBoolean(const Bytes: TBytes; var Pos: Integer): boolean;
var
  n: Int32;
  b: boolean;
begin
  n := length(Bytes);
  if pos + 1 > n  then
    begin
    ShowMessage('ReadDoubleBE Bytes length overflow');
    result := False;
    exit;
    end;

  b := Bytes[Pos] <> 0;

  Inc(Pos, 1);

  Result := b;
end;


function TWsjtxUdp.ReadAdifElement(Adif: string; Pattern: string): string;
var
  p: string;
  m: TMatch;
begin
  p := '<' + Pattern + ':\d+>(?<Value>.*?)<';
  M := TRegEx.Match(Adif, P, [roIgnoreCase]);
  if M.Success then
    result := M.Groups['Value'].Value
  else
    result := '';
end;


function TWsjtxUdp.DecodeModeSymbol(const Symbol: string): string;
begin
  if FModeMap.ContainsKey(Symbol) then
    Result := FModeMap[Symbol]
  else
    Result := Symbol;  // Unknown modes are returned as is.
end;


function TWsjtxUdp.QDateTimeToTDateTime(const Bytes: TBytes; var Pos: Integer): TdateTime;
var
  d: Int64;
  t: Uint32;
  dt: tDateTime;
  timespec: uInt8;
//  offset: Uint32;
//  TimeZone: uInt8;
  JST: Extended;
begin
  d := ReadInt64BE(Bytes, Pos);

  t := ReadUInt32BE(Bytes, Pos);  // Time in milliseconds
  DT := (d - 2415020.5) + (t / 86400000.0);   // Convert from milliseconds to date and time format
  dt := DT + 1 + 3/24;                        // Question: Why is it off by 3 hours a day?
  timespec := Bytes[Pos];
  inc (Pos, 1);
//  offset := Byte(Pos);          // It differs from the QDateTime specification. Offset and TimeZone are not included.
//  inc (Pos, 1);
//
//  if offset = 3 then
//    begin
//    TimeZone := ReadUInt8(Bytes, Pos);;
//    end;

  JST := TTimeZone.Local.ToLocalTime(DT);    // It differs from the QDateTime specification. Offset and TimeZone are not included.

  result := JST;
end;



end.
