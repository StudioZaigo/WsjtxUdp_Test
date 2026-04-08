# WsjtxUDP Class for Delphi

WSJT-X の UDP サーバーからのメッセージを受信し、  
Delphi で扱いやすい形式に変換するためのクラスです。

---

## 🚀 Features

- WSJT-X の各種 UDP メッセージを解析
- Heartbeat / Status / Decode / QSO Logged / ADIF などに対応
- Hex 表示機能（ADIF 内容も含む）
- Heartbeat 停止検出
- Delphi でそのまま使えるイベントドリブン構造

---

## 📡 Supported WSJT-X Messages

| Message Type | Class | Description |
|--------------|--------|-------------|
| 0 | `TWSJTXHeartbeatMessage` | Heartbeat |
| 1 | `TWSJTXStatusMessage` | Status |
| 2 | `TWSJTXDecodeMessage` | Decode |
| 3 | `TWSJTXClearMessage` | Clear |
| 5 | `TWSJTXQSOLoggedMessage` | QSO Logged |
| 6 | `TWSJTXCloseMessage` | Close |
| 12 | `TWSJTXLoggedADIFMessage` | Logged ADIF |
| — | `FWSJTXStoppedHeartbeatMessage` | Heartbeat 停止通知 |

> 基本的には WSJT-X のメッセージ形式に準拠していますが、  
> 一部は独自拡張を含みます。

---

## 🧩 Properties

| Property | Type | Description |
|----------|------|-------------|
| `Active` | Boolean | Open/Close 状態 |
| `Port` | TIdPort | UDP ポート番号（Default: 2237） |
| `HexMessageEnable` | Boolean | Hex 表示の有効化 |
| `HexMessage` | String | 受信メッセージの Hex 表示 |
| `HeartbeetTimeout` | Cardinal | Heartbeat 停止判定秒（Default: 45） |

---

## 🔔 Events

| Event | Description |
|-------|-------------|
| `OnHeartbeat` | Heartbeat 受信 |
| `OnStatus` | Status 受信 |
| `OnDecode` | Decode 受信 |
| `OnClear` | Clear 受信 |
| `OnQSOLogged` | QSO Logged 受信 |
| `OnClose` | Close 受信 |
| `OnLoggedADIF` | ADIF 受信 |
| `OnStoppedHeartbeat` | Heartbeat 停止検出 |

---

## 🛠 Methods

| Method | Description |
|--------|-------------|
| `Open()` | 受信開始 |
| `Open(Port: TIdPort)` | 指定ポートで受信開始 |
| `Close()` | 受信停止 |

---

## 📄 Sample

プロジェクト **WsjtxUdp_Test** の `unit1` を参照してください。

### UI Buttons

- **Start**：受信開始  
- **Stop**：受信停止  
- **File Output**：`WSJT-X Log.txt` に出力  
- **Clear**：表示クリア  
- **HexMess**：Hex 表示（ADIF 内容も含む）

---

## 📜 License

 MIT

- Open Source Initiative OSI - The MIT License:Licensing - 原文        https://opensource.org/license/mit

- The MIT License:Licensing (GitHub) - オープンソースグループ・ジャパンによる日本語参考訳     https://licenses.opensource.jp/MIT/MIT.html


