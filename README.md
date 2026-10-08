# kirocc-windows

Dùng **Claude Code** (dòng lệnh và app Claude desktop) qua tài khoản **Kiro** trên Windows, bằng proxy [kirocc](https://github.com/d-kuro/kirocc).

Repo này chỉ chứa script PowerShell và hướng dẫn cho Windows. Bản thân kirocc là dự án của [d-kuro/kirocc](https://github.com/d-kuro/kirocc) (Apache-2.0), không được chép vào đây.

## 1. Build kirocc

Upstream chưa có bản dựng sẵn cho Windows, nên cần tự build bằng Go:

```powershell
winget install GoLang.Go
git clone https://github.com/d-kuro/kirocc $HOME\kirocc
cd $HOME\kirocc
go build -o kirocc.exe ./cmd/kirocc
```

Script tìm file `~\kirocc\kirocc.exe`. Nếu để chỗ khác, đặt biến môi trường `KIROCC_BIN`.

## 2. Đăng nhập Kiro

```powershell
kiro-cli login
```

Nếu đăng nhập bằng IAM Identity Center mà proxy báo `profileArn is required`, hãy `kiro-cli logout` rồi `kiro-cli login` lại để kiro-cli lưu profile. Cách khác: dùng Kiro API key (`ksk_...`) trong biến môi trường `KIRO_API_KEY`.

## 3. Cài script

```powershell
git clone https://github.com/KitTran1307/kirocc-windows
cd kirocc-windows
.\install.ps1
```

Script sẽ chép `kiro-start`, `kiro-claude`, `kiro-stop` vào `~\.local\bin` và thêm 3 lệnh vào PowerShell profile.

| Lệnh | Tác dụng |
|---|---|
| `kiro-start` | Bật proxy ở `http://127.0.0.1:3456` (chỉ nghe trên máy này) |
| `kiro-claude` | Chuyển Claude Code trong cửa sổ hiện tại sang Kiro. Chạy lại lần nữa để chuyển về |
| `kiro-stop` | Tắt proxy |

Biến tùy chọn: `KIROCC_PORT` (mặc định 3456), `KIRO_API_REGION` (mặc định `us-east-1`).

Lần chạy đầu tiên, proxy tạo một mật khẩu ngẫu nhiên và lưu ở `~\.local\bin\.run\api-key`, những lần sau dùng lại mật khẩu đó. Xóa file này nếu muốn đổi mật khẩu.

## 4. Dùng với Claude Code dòng lệnh

```powershell
kiro-start
kiro-claude
claude        # gõ /model, chọn model trong mục "From gateway"
```

## 5. Dùng với app Claude desktop

1. Chạy `kiro-start`, rồi chạy `Get-Content ~\.local\bin\.run\api-key | Set-Clipboard` để copy mật khẩu proxy.
2. Trong app: menu ☰ (góc trên bên trái) → **Help → Troubleshooting → Enable Developer Mode**. Khởi động lại app nếu chưa thấy menu Developer.
3. **Developer → Configure Third-Party Inference...**, mục **Connection**:
   - Inference provider: **Gateway**
   - Gateway base URL: `http://127.0.0.1:3456`
   - Gateway API key: dán mật khẩu vừa copy
   - Credential kind: **Static API key**
   - Gateway auth scheme: **Bearer**
4. Bấm **Apply Changes**. App sẽ khởi động lại.

Lưu ý:
- Chỉ tab **Code** dùng được. Tab Chat sẽ báo lỗi, vì kirocc chỉ nhận yêu cầu từ Claude Code.
- Proxy phải đang chạy mỗi khi mở app.
- Muốn quay về tài khoản claude.ai thì mở lại cửa sổ cấu hình ở bước 3 và bỏ chế độ Gateway.

## Tìm kiếm web (tùy chọn)

Lưu Exa API key vào `~\.local\bin\.run\exa-key`. Lần sau chạy `kiro-start`, proxy sẽ bật web search.

## Chi phí

Mỗi tin nhắn của Claude Code gửi kèm khoảng 30k token chỉ dẫn hệ thống, nên câu ngắn cũng tốn credit Kiro. Một câu thử ngắn tốn khoảng 0.67 credit.
