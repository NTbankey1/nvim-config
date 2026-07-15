#!/usr/bin/env bash
# ============================================================
# Mail Setup Script: aerc + mbsync + notmuch
# ============================================================
# Chạy script này để cấu hình email workflow cho Neovim.
# Hỗ trợ: Gmail, Outlook, ProtonMail (via bridge), v.v.
# ============================================================

set -e

# ---- Màu sắc ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERR]${NC}  $*"; exit 1; }

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}  Mail Setup: aerc + mbsync + notmuch ${NC}"
echo -e "${BLUE}======================================${NC}\n"

# ---- Kiểm tra tools ----
for cmd in aerc mbsync notmuch; do
  if command -v "$cmd" &>/dev/null; then
    ok "$cmd đã được cài"
  else
    err "$cmd chưa được cài. Chạy: sudo dnf install aerc isync notmuch"
  fi
done

echo ""

# ---- Thu thập thông tin ----
read -rp "Email address: " EMAIL
read -rp "Tên hiển thị (display name): " FULLNAME
read -rp "IMAP host (vd: imap.gmail.com): " IMAP_HOST
read -rp "IMAP port [993]: " IMAP_PORT
IMAP_PORT="${IMAP_PORT:-993}"
read -rp "SMTP host (vd: smtp.gmail.com): " SMTP_HOST
read -rp "SMTP port [587]: " SMTP_PORT
SMTP_PORT="${SMTP_PORT:-587}"

# Tên account (lấy từ phần trước @)
ACCOUNT_NAME="${EMAIL%@*}"
MAILDIR="$HOME/Mail/$ACCOUNT_NAME"

echo ""
info "Tạo thư mục Mail: $MAILDIR"
mkdir -p "$MAILDIR"

# ============================================================
# 1. CẤU HÌNH MBSYNC (~/.mbsyncrc)
# ============================================================
info "Tạo ~/.mbsyncrc ..."

MBSYNC_CONFIG="$HOME/.mbsyncrc"

if [[ -f "$MBSYNC_CONFIG" ]]; then
  warn "~/.mbsyncrc đã tồn tại, backup -> ~/.mbsyncrc.bak"
  cp "$MBSYNC_CONFIG" "${MBSYNC_CONFIG}.bak"
fi

cat > "$MBSYNC_CONFIG" <<MBSYNC
# mbsync config - được tạo bởi setup_mail.sh
# Tài liệu: https://isync.sourceforge.io/mbsync.html

IMAPAccount $ACCOUNT_NAME
Host $IMAP_HOST
Port $IMAP_PORT
User $EMAIL
# Mật khẩu: dùng PassCmd để không lưu plain text
# Với Gmail: tạo App Password tại myaccount.google.com/apppasswords
# Sau đó lưu vào keyring:
#   secret-tool store --label="mbsync $EMAIL" service mbsync account $EMAIL
PassCmd "secret-tool lookup service mbsync account $EMAIL"
SSLType IMAPS
SSLVersions TLSv1.2

IMAPStore ${ACCOUNT_NAME}-remote
Account $ACCOUNT_NAME

MaildirStore ${ACCOUNT_NAME}-local
SubFolders Verbatim
Path $MAILDIR/
Inbox $MAILDIR/INBOX

Channel $ACCOUNT_NAME
Far :${ACCOUNT_NAME}-remote:
Near :${ACCOUNT_NAME}-local:
Patterns *
Create Both
Expunge None
SyncState *
MBSYNC

ok "~/.mbsyncrc đã tạo"

# ============================================================
# 2. LƯU MẬT KHẨU VÀO KEYRING
# ============================================================
echo ""
info "Lưu mật khẩu vào GNOME keyring (secret-tool)..."
warn "Với Gmail: dùng App Password (không phải mật khẩu thường)"
warn "Bật 2FA rồi tạo App Password tại: myaccount.google.com/apppasswords"
echo ""

if command -v secret-tool &>/dev/null; then
  read -rsp "Nhập mật khẩu/App Password cho $EMAIL: " MAIL_PASS
  echo ""
  echo -n "$MAIL_PASS" | secret-tool store --label="mbsync $EMAIL" service mbsync account "$EMAIL"
  ok "Mật khẩu đã lưu vào keyring"
else
  warn "secret-tool không có sẵn. Cài: sudo dnf install libsecret"
  warn "Hoặc dùng PassCmd với pass/gpg trong ~/.mbsyncrc"
fi

# ============================================================
# 3. CẤU HÌNH NOTMUCH (~/.notmuch-config)
# ============================================================
echo ""
info "Khởi tạo notmuch..."

if [[ ! -f "$HOME/.notmuch-config" ]]; then
  notmuch config set database.path "$HOME/Mail"
  notmuch config set user.name "$FULLNAME"
  notmuch config set user.primary_email "$EMAIL"
  ok "notmuch đã cấu hình"
else
  warn "~/.notmuch-config đã tồn tại, bỏ qua"
fi

# ============================================================
# 4. CẤU HÌNH AERC (~/.config/aerc/)
# ============================================================
echo ""
info "Tạo cấu hình aerc..."

AERC_DIR="$HOME/.config/aerc"
mkdir -p "$AERC_DIR"

# accounts.conf
AERC_ACCOUNTS="$AERC_DIR/accounts.conf"
if [[ -f "$AERC_ACCOUNTS" ]]; then
  warn "accounts.conf đã tồn tại, backup -> accounts.conf.bak"
  cp "$AERC_ACCOUNTS" "${AERC_ACCOUNTS}.bak"
fi

cat > "$AERC_ACCOUNTS" <<AERC_ACC
[$FULLNAME]
source        = notmuch://$HOME/Mail
outgoing      = smtp+plain://${EMAIL}:$(secret-tool lookup service mbsync account "$EMAIL" 2>/dev/null || echo 'YOUR_PASSWORD')@${SMTP_HOST}:${SMTP_PORT}
default       = INBOX
from          = $FULLNAME <$EMAIL>
copy-to       = Sent
query-map     = $AERC_DIR/queries.conf
AERC_ACC

# queries.conf
cat > "$AERC_DIR/queries.conf" <<QUERIES
inbox=tag:inbox
unread=tag:unread
starred=tag:flagged
sent=folder:Sent
QUERIES

# aerc.conf (cấu hình cơ bản)
if [[ ! -f "$AERC_DIR/aerc.conf" ]]; then
  cat > "$AERC_DIR/aerc.conf" <<AERC_CONF
[ui]
index-format=%D %-17.17n %Z %s
timestamp-format=2006-01-02 15:04
sidebar-width=24
mouse-enabled=true

[viewer]
pager=less -R
alternatives=text/plain,text/html

[compose]
editor=nvim
AERC_CONF
fi

ok "aerc đã cấu hình"

# ============================================================
# 5. SYNC LẦN ĐẦU
# ============================================================
echo ""
info "Đồng bộ mail lần đầu (có thể mất vài phút)..."
read -rp "Bắt đầu sync ngay? [Y/n]: " DO_SYNC
DO_SYNC="${DO_SYNC:-Y}"

if [[ "$DO_SYNC" =~ ^[Yy]$ ]]; then
  info "Chạy mbsync -a ..."
  mbsync -a && ok "mbsync hoàn tất" || warn "mbsync gặp lỗi, kiểm tra ~/.mbsyncrc"
  
  info "Chạy notmuch new ..."
  notmuch new && ok "notmuch index hoàn tất" || warn "notmuch new gặp lỗi"
fi

# ============================================================
# TỔNG KẾT
# ============================================================
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Cài đặt hoàn tất!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${CYAN}Trong Neovim:${NC}"
echo -e "    <leader>me   →  Mở aerc email client"
echo -e "    <leader>mS   →  Sync mail (mbsync + notmuch)"
echo -e "    <leader>mf   →  Tìm kiếm mail (telescope)"
echo ""
echo -e "  ${YELLOW}Lần đầu mở aerc:${NC} chạy :aerc trong terminal"
echo ""
