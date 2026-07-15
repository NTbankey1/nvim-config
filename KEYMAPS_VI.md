# Hướng Dẫn Chi Tiết Keymap (Phím Tắt) - Cấu Hình Neovim

Đây là tài liệu chuyên sâu hướng dẫn toàn bộ các phím tắt (keymaps) trong cấu hình Neovim của bạn. Cấu hình này sử dụng phím `<Space>` (Phím cách) làm phím **Leader** chính.

> **Mẹo nhỏ:** Khi bạn nhấn `<Space>`, một bảng chọn (Which-key menu) sẽ hiện lên gợi ý các phím tiếp theo, vì vậy bạn không cần phải học thuộc lòng toàn bộ!

---

## 1. Các phím tắt cơ bản (Global Keybindings)

Những phím này hoạt động ở chế độ Bình thường (Normal mode) mà không cần nhấn phím Leader.

### Di chuyển & Giao diện (Navigation & UI)
| Phím | Chế độ | Tác dụng |
|------|--------|----------|
| `s` | Normal, Visual | **Nhảy đến bất kỳ đâu siêu tốc bằng Flash.nvim**. Nhấn `s` rồi gõ 1-2 ký tự của từ muốn nhảy đến. |
| `<C-h/j/k/l>` | Normal | Di chuyển con trỏ giữa các cửa sổ chia đôi (Split windows). |
| `<Tab>` | Normal | Chuyển sang Tab/Buffer tiếp theo. |
| `<S-Tab>` | Normal | Quay lại Tab/Buffer trước đó. |
| `<C-u>` / `<C-d>` | Normal | Cuộn nửa trang lên/xuống và **tự động căn giữa màn hình**. |
| `<A-Left/Right/h/l>`| Normal | Thay đổi kích thước cửa sổ chia đôi. |
| `m` | Normal | Căn giữa con trỏ lên góc trên của màn hình. |
| `Y` | Normal | Copy (Yank) từ vị trí con trỏ đến hết dòng. |

### Tìm kiếm cơ bản (Search)
| Phím | Chế độ | Tác dụng |
|------|--------|----------|
| `<CR>` (Enter) | Normal | Xóa highlight tìm kiếm sau khi dùng `/`. |
| `<C-p>` | Normal | Mở bảng tìm kiếm file nhanh (Telescope). |
| `<C-s>` | Normal | Gợi ý sửa lỗi chính tả bằng bảng Telescope. |

### Chỉnh sửa Code
| Phím | Chế độ | Tác dụng |
|------|--------|----------|
| `<C-;>` | Normal/Visual| Comment / Bỏ comment dòng code hiện tại. |
| `<A-j>` / `<A-k>`| N/V | Di chuyển dòng/đoạn code đang chọn lên hoặc xuống. |
| `<` / `>` | Visual | Tăng/giảm thụt lề (Indent) mà vẫn giữ nguyên vùng chọn. |

---

## 2. Các phím tắt với Leader (`<Space>`)

Được nhóm theo các phím cái (prefix).

### Nhóm Quản lý Chung (Top-level)
| Phím | Tác dụng |
|------|----------|
| `<Space>e` | Mở / Đóng cây thư mục bên trái (File Explorer / Neo-tree). |
| `<Space>q` | Đóng file hiện hành (Close Editor - giống VSCode). |
| `<Space>qq` | Lưu và Thoát (Quit All) Neovim. |
| `<Space>b` | Xem danh sách file đang mở (Show All Buffers - Telescope). |
| `<Space>u` | Mở lịch sử Undo để xem lại các thay đổi cũ. |
| `<Space>/` | Tìm kiếm text trong toàn bộ dự án (Find in Files). |
| `<Space>fm` | Format Document (Định dạng code tự động). |
| `<Space>rn` | Rename (Đổi tên biến/hàm). |

### Nhóm Window (Quản lý Cửa sổ) — `<Space>w` 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>ww` | Lưu file hiện hành (Save). |
| `<Space>wv` | Chia đôi màn hình theo chiều **dọc** (Vertical split). |
| `<Space>ws` | Chia đôi màn hình theo chiều **ngang** (Horizontal split). |
| `<Space>wc` | Đóng cửa sổ hiện tại (Close window). |
| `<Space>wo` | Đóng **tất cả các cửa sổ khác** (Close others). |
| `<Space>w=` | Cân bằng kích thước các cửa sổ (Equalize). |
| `<Space>wm` | Phóng to cửa sổ hiện tại (Maximize). |

### Nhóm Trợ lý AI - Claude Code qua proxy `cc-hr` (`<Space>a`)
Toàn bộ các tính năng AI đều được tích hợp sâu qua trình bọc `cc-hr` của bạn (sử dụng Headroom & proxy để vượt lỗi đăng nhập và tối ưu hiệu năng).
| Phím | Tác dụng |
|------|----------|
| `<C-Enter>` | Bật thanh công cụ chọn AI Tool (Menu Claude Code / OpenCode). |
| `<Space>al` | **Gọi AI Agent (Mở cc-hr)** / Gửi đoạn code đang bôi đen cho Claude xử lý. |
| `<Space>ac` | Mở / Đóng sidebar Claude Code. |
| `<Space>aa` | ⭐ **Quick Ask** — gửi code 30 dòng quanh cursor + diagnostics cho Claude. Code workflow chính. |
| `<Space>af` | ⭐ **Auto-fix errors** — gửi toàn bộ file + lỗi (ERROR/WARN) cho Claude tự động sửa. |
| `<Space>ae` | ⭐ **Explain code** — gửi toàn bộ file cho Claude giải thích kiến trúc, luồng dữ liệu. |
| `<Space>an` | 🆕 **Tạo phiên cc-hr MỚI** — Kill proxy cũ → Khởi proxy mới → Tự mở Claude. |
| `<Space>as` | ⭐ **Claude System Manager (Deep)** — scan bộ nhớ + menu 7 tùy chọn dọn dẹp. |
| `<Space>aw` | Tạo Git worktree mới kèm phiên Claude độc lập. |
| `<Space>ar` | Khôi phục phiên làm việc (Restore session) lần cuối. |
| `<Space>ak` | Dọn dẹp/Tắt (Kill) các phiên AI chạy ngầm. |
| `<Space>ad` | Hỏi AI về các lỗi (Diagnostics) hiển thị trong file. |
| `<Space>aH` | Kiểm tra trạng thái hệ thống AI (Health check proxy port 8787). |

### Nhóm Tìm Kiếm Nâng Cao - Find (`<Space>f`)
| Phím | Tác dụng |
|------|----------|
| `<Space>ff` | Tìm kiếm một từ/đoạn text trong toàn bộ dự án. |
| `<Space>fa` | Tìm kiếm file (bao gồm cả file ẩn). |
| `<Space>fb` | Tìm kiếm trong các file đang mở (Buffers). |
| `<Space>fw` | Tìm từ đang nằm dưới con trỏ trong toàn bộ dự án. |
| `<Space>fp` | Copy đường dẫn của file hiện hành. |
| `<Space>fo`| ⭐ **Open file under cursor (Claude paths)** — mở file từ Claude Code output, xử lý `file:line:col`. |

### Nhóm Quản lý Git - `<Space>g` (NÂNG CẤP)
> Tự động tìm git repo từ file đang mở, hoạt động không cần GitHub.
> **Auto git init**: Khi mở thư mục dự án chưa có git, Neovim tự hỏi "Init git?" — chọn Yes, tự động `git init` + commit đầu tiên. Luôn có git tracking!

#### ⚡ Overview & Repo Operations
| Phím | Tác dụng |
|------|----------|
| `<Space>gg` | Mở giao diện LazyGit để commit, push, quản lý branch. |
| `<Space>gs` | **Changed files** — list mọi file đã thay đổi + preview diff (dùng Snacks picker). ⭐ |
| `<Space>g.` | **Review all changes** — alias của `gs`, xem toàn bộ thay đổi trong dự án. |
| `<Space>gN` | **Changed files (tree)** — cây thư mục chỉ hiện file đã sửa (dùng Neo-tree). |
| `<Space>gi` | ⭐ **Init git repo (chủ động)** — init + .gitignore thông minh (Python/Node/Rust/Go/Nix) + commit đầu. Dùng khi bạn muốn git cho dự án. |
| | **Auto-init khi mở project mới:** tự hỏi 1 lần. Chọn "skip forever" = không bao giờ hỏi lại. |
| `<Space>gb` | Chuyển nhánh (Switch branch). |
| `<Space>gc` | Xem lịch sử Commit toàn bộ dự án. |
| `<Space>gC` | **Xem lịch sử riêng file hiện tại** (File history / bcommits). |
| `<Space>gS` | Quản lý Git stash. |
| `<Space>gl` | Xem ai viết dòng code này (Line blame). |
| `<Space>gt` | Bật/tắt blame từng dòng (Toggle blame). |

#### 🔧 Hunk Operations (Thay đổi từng đoạn)
| Phím | Tác dụng |
|------|----------|
| `<Space>gj` | Nhảy đến thay đổi tiếp theo (Next hunk). |
| `<Space>gh` | Nhảy về thay đổi trước đó (Prev hunk). |
| `<Space>gd` | Xem diff hunk hiện tại (So sánh với bản đã staged). |
| `<Space>gD` | **Xem diff cả file vs HEAD** (So sánh với commit cuối). |
| `<Space>gp` | Xem trước thay đổi ở cửa sổ nhỏ (Preview hunk). |
| `<Space>ga` | Stage hunk (thêm vào commit). |
| `<Space>gu` | Unstage hunk (bỏ stage). |
| `<Space>gx` | Reset hunk (hoàn tác thay đổi của hunk đó). |

#### 🔙 Review & Restore (Xem thay đổi + Quay lại bản gốc) ⭐
| Phím | Tác dụng |
|------|----------|
| `<Space>gR` | **Restore file về bản gốc** (git checkout) — có hộp thoại xác nhận. Dùng khi AI code sai ý. |

#### 🤖 Claude Worktree Management
| Phím | Tác dụng |
|------|----------|
| `<Space>gw` | Tạo worktree mới kèm phiên Claude riêng. |
| `<Space>gv` | Xem danh sách worktree Claude. |
| `<Space>gr` | Khôi phục worktree Claude. |

---

### Nhóm Hỗ trợ Code - LSP & Lint (`<Space>i` & VSCode Standard NÂNG CẤP)

> **Lưu ý**: Tất cả các lệnh LSP đều tự động kiểm tra server trước khi chạy. Nếu file không có LSP, sẽ báo "No LSP server active" thay vì crash.

#### Global VSCode-standard (không cần `<Space>`)
| Phím | Tác dụng |
|------|----------|
| `gd` | Go to Definition (Nhảy đến định nghĩa). |
| `gh` | Show Hover (Xem tài liệu dưới con trỏ). |
| `gi` | Go to Implementation (Nhảy đến thực thi hàm). |
| `gq` | Quick Fix (Mở gợi ý sửa lỗi). |
| `gr` | Reference Search (Tìm nơi gọi hàm). |
| `gt` | Go to Type Definition (Nhảy đến định nghĩa Type). |
| `go` / `gO` | Document Symbols / Workspace Symbols. |
| `<Space>rn` | Rename (Đổi tên biến/hàm hàng loạt). |

#### Navigation — Go To / Peek
| Phím | Tác dụng |
|------|----------|
| `<Space>id` | Go to definition. |
| `<Space>iD` | Go to declaration. |
| `<Space>iT` | **🆕 Go to type definition** (mới, bổ sung từ `gt`). |
| `<Space>ii` | Go to implementations. |
| `<Space>ir` | Find references. |

#### Jump History — Quay lại vị trí cũ 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>i[` | **Jump back** — quay lại vị trí code trước đó (sau khi `<Space>id`/`<Space>iT`). |
| `<Space>i]` | **Jump forward** — tiến tới vị trí tiếp theo. |

#### Symbols — Document & Workspace 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>io` | **Document symbols** — danh sách symbol trong file hiện tại. |
| `<Space>iO` | **Workspace symbols** — tìm symbol trong toàn bộ dự án. |

#### Diagnostics — Inspection & Navigation
| Phím | Tác dụng |
|------|----------|
| `<Space>il` | Xem chi tiết lỗi ở dòng hiện hành. |
| `<Space>ib` | Danh sách lỗi trong buffer hiện tại. |
| `<Space>iP` | **🆕 Danh sách lỗi toàn bộ dự án** (Workspace diagnostics). |
| `<Space>in` / `ip` | Nhảy đến lỗi tiếp theo / trước đó. |
| `<Space>j` / `<Space>k` | Alias: lỗi tiếp theo / trước đó. |
| `<Space>l` | Problems Focus (mở Telescope diagnostics). |
| `<Space>iy` | Copy toàn bộ lỗi ra clipboard. |

#### Actions — Code & Text
| Phím | Tác dụng |
|------|----------|
| `<Space>ic` | Code action (sửa lỗi tự động). |
| `<Space>iR` | Rename symbol (đổi tên hàng loạt). |
| `<Space>ih` | **Hover documentation** — xem tài liệu/chú thích hàm. |
| `<Space>iF` | **🆕 Format code** — định dạng code (giống `<leader>fm`). |

#### Linting
| Phím | Tác dụng |
|------|----------|
| `<Space>iL` | Lint file hiện tại. |
| `<Space>iB` | Bật/tắt linting cho buffer. |
| `<Space>ig` | Bật/tắt linting toàn cục. |

#### LSP Management
| Phím | Tác dụng |
|------|----------|
| `<Space>is` | Restart LSP server. |
| `<Space>it` | Toggle LSP (bật/tắt LSP cho buffer). |

#### Mở file ngoài 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>iI` | **Mở file bằng app phù hợp** — `.md` → Brave preview. `.docx`/`.odt` → **LibreOffice** (xem đẹp, có sơ đồ). `.png/pdf/html` → app mặc định. ⭐ |
| | **Chú ý: `.docx`/`.odt`** — có 2 cách: `<Space>iI` = xem đẹp trong LibreOffice. Mở trực tiếp = chuyển sang markdown để Claude sửa, `:w` lưu lại thành `.docx`. |
| `<Space>iK` | Đóng file/app ngoài (hướng dẫn tắt thủ công). |

### Nhóm Chạy Code / Build - Run (`<Space>r`)
| Phím | Tác dụng |
|------|----------|
| `<Space>rc` | Dọn sạch bộ nhớ đệm plugin (`~/.cache/nvim`). |
| `<Space>rd` | Bật/tắt chế độ Debug (hiển thị notifications chi tiết). |
| `<Space>rl` | Hiển thị tất cả lỗi của Linter trong dự án. |
| `<Space>rh` | Bật/tắt tô sáng biến cục bộ (Highlight locals). |
| `<Space>rk` | Xóa file và buffer hiện hành khỏi danh sách. |
| `<Space>rK` | Xóa toàn bộ plugins và lock file (cài lại từ đầu). |
| `<Space>rm` | Chạy Model Checker. |
| `<Space>rM` | Xem lịch sử thông báo của Snacks Notifier. |
| `<Space>rp` | Chạy file Python hiện hành (`.py` tương ứng). |
| `<Space>rr` | Sắp xếp lại danh sách đánh dấu đầu dòng (Autolist). |
| `<Space>rR` | Tải lại toàn bộ cấu hình Neovim. |
| `<Space>re` | Mở thư mục snippets để chỉnh sửa. |
| `<Space>rs` | Kết nối SSH đến server từ xa. |
| `<Space>rz` | Bật/tắt chế độ ngăn ngủ (Sleep Inhibit). |
| `<Space>rg` | Mở URL dưới con trỏ trong trình duyệt. |

### Nhóm Lean 4 — `<Space>L` 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>Lb` | Build dự án Lean 4 (`lake build`). |
| `<Space>Li` | Bật/tắt Lean Infoview. |

### Nhóm Fold (Nếp gấp Code) — `<Space>z` 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>zF` | Bật/tắt toàn bộ nếp gấp (Toggle all folds). |
| `<Space>zo` | Bật/tắt nếp gấp dưới con trỏ. |
| `<Space>zt` | Chuyển phương thức gấp code (Folding method). |

### Nhóm Tabs (WezTerm) — `<Space>T` 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>TN` | Chuyển đến tab trước đó trong WezTerm. |
| `<Space>TP` | Chuyển đến tab tiếp theo trong WezTerm. |
| `<Space>TT` | Chuyển đến tab N (gõ số trước, VD: `2<Space>TT` = tab 2). |

### Nhóm Kill/Process — `<Space>K` 🆕
| Phím | Tác dụng |
|------|----------|
| `<Space>Kl` | Chạy tiến trình mới (Launch process). |
| `<Space>Kp` | Danh sách tiến trình đang chạy (Process picker). |
| `<Space>Kk` | Dừng tất cả tiến trình (Kill all). |

### Nhóm Gói Text & Ngoặc - Surround (`<Space>s`)
(Hoạt động qua nvim-surround)
| Phím | Tác dụng |
|------|----------|
| `<Space>ss` | Bọc vùng chữ bằng một ký tự nào đó (VD: ngoặc, nháy kép). |
| `<Space>sc` | Thay đổi loại ngoặc bọc ngoài (Change). |
| `<Space>sd` | Xóa ngoặc bọc ngoài (Delete). |

### Nhóm TODO Comments (`<Space>t`)
| Phím | Tác dụng |
|------|----------|
| `<Space>tt` | Mở bảng Telescope xem toàn bộ các dòng ghi chú TODO trong dự án. |
| `<Space>tn` / `tp`| Nhảy đến TODO tiếp theo / TODO trước đó. |

---

## 3. Các phím tắt đặc thù theo loại file (Tự động kích hoạt)

### Terminal Mode (Khi đang mở Terminal trong Neovim)
| Phím | Tác dụng |
|------|----------|
| `<Esc>` | Thoát chế độ gõ lệnh terminal về Normal Mode để di chuyển. |
| `<C-t>` | Ẩn/Hiện cửa sổ Terminal nổi. |
| `<C-h/j/k/l>` | Nhảy từ Terminal sang các cửa sổ code khác. |

### Dành cho file Markdown (`.md`)
| Phím | Chế độ | Tác dụng |
|------|--------|----------|
| `<C-n>` | Normal | Chuyển đổi trạng thái ô đánh dấu (checkbox) từ `[ ]` sang `[x]`. |
| `<CR>` | Insert | Tự động tạo gạch đầu dòng mới ở dòng tiếp theo. |
| `Tab`/`S-Tab` | Insert | Thụt lề và tự động đánh số lại danh sách. |
| `<Space>ml` | Normal | Dùng AI (Lectic) xử lý đoạn văn bản Markdown. |

### Dành cho Jupyter Notebook (`.ipynb`) và Python
Sử dụng phím `<Space>j` (Ví dụ: `<Space>je` để chạy cell hiện tại, `<Space>jn` chạy xong chuyển sang cell tiếp theo).

### Dành cho LaTeX / Typst (`.tex` / `.typ`)
Sử dụng phím `<Space>l` (Ví dụ: `<Space>lc` để biên dịch tài liệu, `<Space>lv` để mở xem PDF).

---
## 4. Tùy biến Keymap của riêng bạn

Nếu bạn muốn chỉnh sửa, bạn hãy tìm đến các file cấu hình sau:
- **Phím tắt không dùng Leader:** Mở file `lua/neotex/config/keymaps.lua`
- **Phím tắt có dùng Leader (Menu):** Mở file `lua/neotex/plugins/editor/which-key.lua`

*Tài liệu này được tổng hợp cho cấu hình cá nhân của bạn, bao gồm cả hai tiện ích tuyệt vời nhất vừa được tích hợp là `Flash.nvim` (di chuyển siêu tốc) và `Noice.nvim` (Giao diện UI cao cấp).*
