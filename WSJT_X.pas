unit WSJT_X;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  IdSocketHandle, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer, IdUDPClient,
  Winsock,  IdGlobal,
   System.DateUtils,
   System.RegularExpressions;

type
  TWSJTXMessageParser = class
  public
    function Parse(const Bytes: TBytes): TObject;  // 返すのはメッセージクラス
  end;

type
  TWSJTXMessage = class
  public
    MessageType: Cardinal;
  end;

type
  TWSJTXHeartBeet = class(TWSJTXMessage)
  public
    ProgramID: string;
    MaxShemaNo: uint32;
    Version: string;
    revision: string;
    LastHeartbeet: ttime;
  end;

  TWSJTXDecodeMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    NewFlag: Boolean;
    Time: TDateTime;
    SNR: Integer;
    DeltaTime: Double;
    DeltaFreq: Cardinal;
    Mode: string;
    MessageText: string;
    LowConfidence: Boolean;
    OffAir: Boolean;
  end;

  TWSJTXStatusMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    DialFreq: Int64;
    Mode: string;
    Callsign: string;
    Report: string;
    TxEnabled: Boolean;
    Transmitting: Boolean;
    GridLoc: string;
  end;

  TWSJTXQSOLoggedMessage = class(TWSJTXMessage)
  public
    ProgramID: string;
    DateTimeOff: string;
    DxCall: string;
    DxGrid: string;
    TxFreq: string;
    Mode: string;
    RptSent: string;
    RptRcvd: string;
    Comments: string;
    Name: string;
  end;

  TWSJTXLoggedADIF = class(TWSJTXMessage)
  public
    ProgramID: string;
    ADIFText: string;
  end;

 type
  TWSJT_X = class(TObject)
    procedure UDPServerUDPRead(AThread: TIdUDPListenerThread;
      AData: array of Byte; ABinding: TIdSocketHandle);

  private
    UDPServer: TIdUDPServer;
    FUDP: TIdUDPServer;
    FParser: TWSJTXMessageParser;



//    FLoggedADIF: TLoggedADIF;
//    FDecord: TDecord;
//    FHertbeet: Theartbeet;
//    FQsoLogged: TQsoLogged;
//    FStatus: tStatus;
    Fport: string;
    FIpAddress: string;
    FHexText: string;
    FMess: string;
    FOnDecode: TNotifyEvent;
    FOnQSOLogged: TNotifyEvent;
    FOnStatus: TNotifyEvent;
  procedure UDPRead(AData: TBytes; AIP: string);
    procedure SetIpAddress(const Value: string);
    procedure SetPort(const Value: string);
    procedure HandleClear(Bytes: TBytes);
    procedure HandleClose(Bytes: TBytes);
    procedure HandleDecode(Bytes: TBytes);
    procedure HandleHeartbeat(Bytes: TBytes);
    procedure HandleLoggedADIF(Bytes: TBytes);
    procedure HandleQSOLogged(Bytes: TBytes);
    procedure HandleStatus(const Bytes: TBytes);
    procedure AddBytesMemo(const Bytes: TBytes);
    function ConvertQDateTimeToTDateTime(const Bytes: TBytes;
      var Pos: Integer): TdateTime;
    function ReadInt64BE(const Bytes: TBytes; var Pos: Integer): Int64;
    function ReadUInt32BE(const Bytes: TBytes; var Pos: Integer): Cardinal;
    function ReadWSJTXString(const Bytes: TBytes; var Pos: Integer): string;
    procedure SetOnDecode(const Value: TNotifyEvent);
    procedure SetOnQSOLogged(const Value: TNotifyEvent);
    procedure SetOnStatus(const Value: TNotifyEvent);
  { Private 宣言 }

  public
  { Public 宣言 }
    constructor Create;
    destructor Destroy; override; // オーバーライドする

//    property Heartbeet: Theartbeet read FHertbeet;
//    property Status: tStatus read FStatus;
//    property Decord: TDecord read FDecord;
//    property QsoLogged: TQsoLogged read FQsoLogged;
//    property LoggedADIF: TLoggedADIF read FLoggedADIF;
    property Mess: string read FMess;
    property HexTest: string read FHexText;
      property OnDecode: TNotifyEvent read FOnDecode write SetOnDecode;
  property OnStatus: TNotifyEvent read FOnStatus write SetOnStatus;
  property OnQSOLogged: TNotifyEvent read FOnQSOLogged write SetOnQSOLogged;


    property IpAddress: string read FIpAddress write SetIpAddress;
    Property Port: string read Fport write SetPort;

 end;



implementation

{ TWSJT_X }

constructor TWSJT_X.Create;
begin
  inherited Create; // 親クラスのコンストラクタを必ず呼ぶ [2]

  UDPServer := UDPServer.Create();
  try
    UDPServer.DefaultPort := 2237;
    UDPServer.BroadcastEnabled := True;
    UDPServer.OnUDPRead := UDPServerUDPRead; // 受信時のイベント
//    UDPServer.Active := True;

  except
    FreeAndNil(UDPServer);
  end;

end;

destructor TWSJT_X.Destroy;
begin
  FreeAndNil(UDPServer); // 確保したリソースを解放
  inherited Destroy; // 最後に継承元のデストラクタを呼ぶ
end;

procedure TWSJT_X.SetIpAddress(const Value: string);
begin
  FIpAddress := Value;
end;

procedure TWSJT_X.SetOnDecode(const Value: TNotifyEvent);
begin
  FOnDecode := Value;
end;

procedure TWSJT_X.SetOnQSOLogged(const Value: TNotifyEvent);
begin
  FOnQSOLogged := Value;
end;

procedure TWSJT_X.SetOnStatus(const Value: TNotifyEvent);
begin
  FOnStatus := Value;
end;

procedure TWSJT_X.SetPort(const Value: string);
begin

  Fport := Value;
end;

function TWSJTXMessageParser.Parse(const Bytes: TBytes): TWSJTXMessage;
var
  MsgType: Cardinal;
begin
  MsgType := ReadUInt32BE(Bytes, Pos): Cardinal;(Bytes, 8);

  case MsgType of
    0: Result := ParseHeartbeat(Bytes);
    1: Result := ParseStatus(Bytes);
    2: Result := ParseDecode(Bytes);
    3: Result := ParseClear(Bytes);
    4: Result := ParseQSOLogged(Bytes);
  else
    Result := nil;
  end;
end;

//procedure TWsjt_X.UDPServerUDPRead(AThread: TIdUDPListenerThread; AData: array of Byte; ABinding: TIdSocketHandle);
//var
//  Bytes: TBytes;
//  s: string;   i: Integer;
//  hex: string;
//  MsgType: Cardinal;
//begin
//  SetLength(Bytes, Length(AData));
//  Move(AData[0], Bytes[0], Length(AData));
//
//  Move(Bytes[8], MsgType, 4);
////  ネットワークバイトオーダー（ビッグエンディアン）の32ビット長整数を、ホストバイトオーダー（通常リトルエンディアン）に変換する関数
//  MsgType := ntohl(MsgType);
////
//  case MsgType of
//    $00000000: HandleHeartbeat(Bytes);
//    $00000001: HandleStatus(Bytes);
//    $00000002: HandleDecode(Bytes);
//    $00000003: HandleClear(Bytes);
//    $00000005: HandleQSOLogged(Bytes);
//    $00000006: HandleClose(Bytes);
//    $0000000C: HandleLoggedADIF(Bytes);
//  end;
//end;

procedure TWsjt_X.ParseHeartbeat(Bytes: TBytes);
begin
  FMess := 'HeartBeet';
end;

procedure TWsjt_X.HandleStatus(const Bytes: TBytes);
var
  Pos: Integer;
  id: cardinal;
  ProgramID, Mode, TxMsg, DxCall, Report, DxGrid: string;
  DialFreq: Int64;
  TxEnabled, Transmitting: Boolean;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  ProgramID := ReadWSJTXString(Bytes, Pos);   // ID(WSJT-X。JTDXの場合はJTDXか？)

//  Big EndingからLittle Endingへ変換する
  DialFreq := ReadInt64BE(Bytes, Pos);        // Dial Frequency（Hz）

  Mode := ReadWSJTXString(Bytes, Pos);        // Mode(FT-8など)

  DxCall := ReadWSJTXString(Bytes, Pos);      // Dx Call

  Report := ReadWSJTXString(Bytes, Pos);      // Report

  Transmitting := Bytes[Pos] <> 0;            // Tx Mode
  Inc(Pos, 1);

  TxEnabled := Bytes[Pos] <> 0;               // Tx Enable
  Inc(Pos, 1);

  // 以下同様に読み進める…
  FMess := 'Status: "' + ProgramID + '" "' + Inttostr(DialFreq) + '" "' + Mode + '" "' + DxCall + '" "' + Report + '"';
end;

procedure  TWsjt_X.HandleDecode(Bytes: TBytes);
var
  Pos: Integer;
  ProgramId: string;
  qTime: cardinal;
  qDT : Ttime;
begin
  Pos := 12; // Magic + Schema + MsgType の後
  ProgramID := ReadWSJTXString(Bytes, Pos);   // ID(WSJT-X。JTDXの場合はJTDXか？)

  inc(Pos, 1);    // Newの一けた分

  qTime := ReadUInt32BE(Bytes, Pos);  // ms単位の時間
  qDT := qTime / 86400000.0;          // ms単位から時刻型に変換

  Fmess := 'Decode: "' + ProgramID + '" "' + TimeToStr(qDT)+ '"';
end;

procedure TWsjt_X.HandleClear(Bytes: TBytes);
begin
  Fmess := 'Cleare'
end;

procedure TWsjt_X.HandleQSOLogged(Bytes: TBytes);
var
  Pos: Integer;
  ProgramID: string;
  DateTimeOff: TDateTime;
  DxCall: string;
  DxGrid: string;
  TxFreq: Uint64;
  Mode: string;
  RptSent: string;
  RptRcvd: string;
  TxPower: string;
  Comments: string;
  Name: string;
  DateTimeOn: TDateTime;
  OperatorCall: string;
  MyCall: string;
  MyGrid: string;
  ExchangeSent: string;
  ExchengRcvd: string;
  PropagationMode: string;
begin
  AddBytesMemo(Bytes);

  Pos := 12; // Magic + Schema + MsgType の後

  ProgramID     := ReadWSJTXString(Bytes, Pos);
  DateTimeOff   := ConvertQDateTimeToTDateTime(Bytes, Pos);
  DxCall        := ReadWSJTXString(Bytes, Pos);
  DxGrid        := ReadWSJTXString(Bytes, Pos);
  TxFreq        := ReadInt64BE(Bytes, Pos);
  Mode          := ReadWSJTXString(Bytes, Pos);
  RptSent       := ReadWSJTXString(Bytes, Pos);
  RptRcvd       := ReadWSJTXString(Bytes, Pos);
  TxPower       := ReadWSJTXString(Bytes, Pos);
  Comments      := ReadWSJTXString(Bytes, Pos);
  Name          := ReadWSJTXString(Bytes, Pos);
  DateTimeOn    := ConvertQDateTimeToTDateTime(Bytes, Pos);
  OperatorCall  := ReadWSJTXString(Bytes, Pos);
  MyCall        := ReadWSJTXString(Bytes, Pos);
  MyGrid        := ReadWSJTXString(Bytes, Pos);

  FMess := 'QSO Logged: "' + DxCall + '" "' + DxGrid + '" "' + Mode + '" "'
      + RptSent + '" "' + RptRcvd + '"';
end;

procedure TWsjt_X.HandleClose(Bytes: TBytes);
begin
  FMess := 'Close'

end;

procedure TWsjt_X.HandleLoggedADIF(Bytes: TBytes);
var
  Pos: Integer;
  ProgramID: string;
  AdifText: string;
  DateTimeOff: TDateTime;
  DxCall: string;
  DxGrid: string;
  Freq: string;
  Mode: string;
  RptSent: string;
  RptRcvd: string;
  TxPower: string;
  Comments: string;
  Name: string;
  DateOn: string;
  TimeOn: string;
  MyCall: string;
  MyGrid: string;
  ExchangeSent: string;
  ExchengRcvd: string;
  PropagationMode: string;
  Pattern: string;
  Match: TMatch;
  d: tdate;
  t: TTime;
  dt: TdateTime;
  f: Double;
begin
  Pos := 12; // Magic + Schema + MsgType の後

  ProgramID     := ReadWSJTXString(Bytes, Pos);
  AdifText      := ReadWSJTXString(Bytes, Pos);

  Pattern := '<call:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    DxCall := Match.Groups['Value'].Value;
  end;

  Pattern := '<qso_date_off:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    DateOn := Match.Groups['Value'].Value;
    D := StrToDate(copy(DateOn,1,4) + '/' + copy(DateOn, 5,2) + '/' + copy(dateon, 7,2));
  end;

  Pattern := '<time_off:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    TimeOn := Match.Groups['Value'].Value;
    T := StrToTime(copy(TimeOn,1,2) + ':' + copy(DateOn, 3,2) +  ':00');
  end;
  dt := d + t + 9/24;       // JSTに変換
  DateOn := DateToStr(dt);
  TimeOn := Copy(TimeToStr(dt), 1, 5);

  Pattern := '<mode:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    mode := Match.Groups['Value'].Value;
  end;

  Pattern := '<freq:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    f := StrToFloat(Match.Groups['Value'].Value);
    Freq := FormatFloat('0.00', f);
  end;

  Pattern := '<rst_sent:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    RptSent := Match.Groups['Value'].Value;
  end;

  Pattern := '<RptRcvd:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    RptRcvd := Match.Groups['Value'].Value;
  end;

  Pattern := '<gridsqure:\d+>(?<Value>.*?)<';
  Match := TRegEx.Match(AdifText, Pattern, [roIgnoreCase]);
  if Match.Success then
  begin
    DxGrid := Match.Groups['Value'].Value;
    if DxGrid = '0' then DxGrid := '';
  end;

  Memo1.Lines.Add('QSO Logged: "' + dxcall + '" "' + Freq + '"');

end;


procedure TWsjt_X.AddBytesMemo(const Bytes: TBytes);
var
  hex: string;
  i: integer;
begin

  hex := '';
  for i := 0 to High(Bytes) do
    hex := hex + IntToHex(Bytes[i], 2) + ' ';
  FHexText := hex;

  Mess := 'HEX: ' + hex;
end;

function TWsjt_X.ReadWSJTXString(const Bytes: TBytes; var Pos: Integer): string;
var
  Len, i: Integer;
  SBytes: TBytes;
begin
  Move(Bytes[Pos], Len, 4);
  Len := ntohl(Len);

  Inc(Pos, 4);

  SetLength(SBytes, Len);
  for i := 0 to Len - 1 do
    SBytes[i] := Bytes[Pos + i];

  Inc(Pos, Len);

  Result := TEncoding.UTF8.GetString(SBytes);
end;

function TWsjt_X.ReadInt64BE(const Bytes: TBytes; var Pos: Integer): Int64;
var
  v: UInt64;
begin
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

function TWsjt_X.ReadUInt32BE(const Bytes: TBytes; var Pos: Integer): Cardinal;
var
  v: UInt32;
begin
  v :=
    (Cardinal(Bytes[Pos + 0]) shl 24) or
    (Cardinal(Bytes[Pos + 1]) shl 16) or
    (Cardinal(Bytes[Pos + 2]) shl 8)  or
    (Cardinal(Bytes[Pos + 3]) shl 0);

  Inc(Pos, 4);
  result := int32(v);
end;


function TWsjt_X.ConvertQDateTimeToTDateTime(const Bytes: TBytes; var Pos: Integer): TdateTime;
var
  DateTimeStr: string;
  d:  UInt64;
  t: Uint32;
  dt: tDateTime;
  timespec: uInt8;
  offset: uInt32;
//  timezone: Uint8;
begin
  d := ReadInt64BE(Bytes, Pos);
  inc(Pos, 8);

  t := ReadUInt32BE(Bytes, Pos);  // ms単位の時間
  DT := d + t / 86400000.0;          // ms単位から時刻型に変換

  timespec := Byte(Pos);
  inc (Pos, 1);

  offset := ReadUInt32BE(Bytes, Pos);

//  if offset = 3 then
//    begin
//    timezone := Byte(Pos);
//    inc (Pos, 1);
//    end;

  result := DT;
end;

end.
