# Claude Design Prompt — SeaReady Mobile App

> **Cara pakai:** Copy seluruh isi file ini ke Claude di awal sesi desain. Untuk menambah screen/feature baru, cukup tambahkan section baru di bagian **7. Screen Specs** — bagian lain tidak perlu diubah.

---

## 1. Product Context

**Product name:** SeaReady
**Tagline:** "Certificate wallet & training platform untuk pelaut Indonesia"
**Target users:**
- Pelaut Indonesia (umur 25-55, mayoritas pria, mobile-first)
- Sekunder: admin lembaga diklat (desktop-first)

**User mental model:**
Pelaut Anda **tidak power user aplikasi**. Mereka terbiasa dengan WhatsApp, Facebook, dan formulir pemerintah yang lambat. Desain harus:
- Familiar (bukan trendy)
- Besar (button, text, tap target)
- Forgiving (konfirmasi sebelum aksi penting)
- Efficient (5 tap maksimum untuk aksi apapun)

---

## 2. Brand Identity

### 2.1 Positioning
Profesional, dapat dipercaya, solid — bukan startup flashy. Ini aplikasi yang berisi sertifikat karir mereka; vibe-nya harus seperti bank atau institusi, bukan seperti game atau e-commerce.

### 2.2 Visual personality
- **Calm authority** — nautical (laut), bukan playful
- **Structured, not decorative** — clean layouts over visual flourishes
- **Warm data** — pakai warna gradasi untuk status (hijau = aman, kuning = warning, merah = urgent) tapi subtle, bukan loud

### 2.3 Color palette (Ocean Gradient)

| Token | Hex | Usage |
|---|---|---|
| `primary-dark` | `#21295C` | Navigation bar, headers, emphasis |
| `primary` | `#065A82` | Primary buttons, interactive elements |
| `teal` | `#1C7293` | Secondary actions, accents |
| `light-mint` | `#B8E0E8` | Soft backgrounds, subtle highlights |
| `white` | `#FFFFFF` | Primary background |
| `card-bg` | `#F5F8FA` | Card surfaces, section bg |
| `text-primary` | `#1A1A2E` | Body text, headings |
| `text-muted` | `#5A6380` | Secondary text, captions |
| `border` | `#D5DCE6` | Dividers, input borders |
| `success` | `#0F6E56` (bg `#D1FAE5`, text `#065F46`) | Valid certificates, completed quests |
| `warning` | `#854F0B` (bg `#FEF3C7`, text `#92400E`) | Expiring soon, pending verification |
| `danger` | `#A32D2D` (bg `#FEE2E2`, text `#991B1B`) | Expired, errors, destructive actions |
| `info` | `#185FA5` (bg `#DBEAFE`, text `#1E40AF`) | Tips, helper text, announcements |

**Aturan warna:**
- Maksimum 3 warna per screen (di luar neutrals)
- Warna status (success/warning/danger) jangan dipakai untuk hal non-status
- Text pada colored background pakai darker variant dari ramp yang sama

### 2.4 Typography

| Level | Font | Size | Weight | Line-height |
|---|---|---|---|---|
| Display | Cambria | 28-36px | Bold | 1.2 |
| H1 (screen title) | Cambria | 22px | Bold | 1.3 |
| H2 (section) | Cambria | 17px | Bold | 1.4 |
| Body | Calibri | 14px | Regular | 1.5 |
| Caption | Calibri | 12px | Regular | 1.4 |
| Overline (labels) | Calibri | 11px | Bold uppercase, letter-spacing 1.5px | 1.2 |

**Fallback untuk Android/iOS native:** Cambria → serif, Calibri → system sans

**No:** Italic untuk emphasis (pakai weight/color), underline (kecuali link), mixed casing (TiTlE cAsE)

### 2.5 Iconography
- Style: Outlined, 1.5px stroke, rounded corners
- Size: 20px default, 16px inline, 24px action button, 32px feature illustration
- Source: Phosphor Icons (free) — ban Font Awesome untuk avoid generic look
- Jangan pakai emoji di UI formal (kecuali di reward section untuk playfulness)

---

## 3. Layout System

### 3.1 Spacing scale
`4 · 8 · 16 · 24 · 32 · 48 · 64` (px) — pakai hanya angka ini, jangan custom

### 3.2 Radius
- `4px` untuk small elements (badges, tags)
- `8px` untuk buttons, inputs, cards kecil (default)
- `12px` untuk cards besar (course card, cert card)
- `16px` untuk sheets, modals
- `50%` untuk avatar, chip buttons

### 3.3 Shadow
**Minimal use.** Pakai border 0.5px `#D5DCE6` untuk separation, bukan shadow.
Exception: floating action button, bottom sheet handle.

### 3.4 Breakpoints (Flutter responsive)
- Mobile: default (360-420px wide)
- Tablet: 600px+ (aktifkan 2-column layout)
- Desktop: 1024px+ (admin panel only, max width 1280px)

---

## 4. Component Library

Component ini **wajib konsisten** di semua screen. Jangan buat variant baru tanpa alasan kuat.

### 4.1 Buttons

| Variant | Use case | Style |
|---|---|---|
| Primary | Main CTA per screen | BG `primary`, text white, 44px tall |
| Secondary | Alt action | BG transparent, border `primary`, text `primary` |
| Ghost | Tertiary / cancel | No border, text `text-muted` |
| Danger | Destructive | BG `danger`, text white |
| Icon-only | Dense UI | 40×40px, transparent, icon 20px |

**Disabled state:** Opacity 0.4, no cursor hover effect
**Loading state:** Inline spinner 16px di kiri label, label ganti jadi "Memuat..."

### 4.2 Form fields

**Text input baseline:**
- Height: 48px (besar, pelaut sering pakai tangan kotor/pakai sarung tangan)
- Label di atas (bukan placeholder-as-label)
- Padding: 12px horizontal
- Border: 0.5px `border` default, 1.5px `primary` focused, 1.5px `danger` error

**States:**
- Empty: placeholder muted
- Filled + valid: subtle green checkmark di kanan
- Error: red border + error message di bawah dengan icon ⚠

**Specific types:**
- Password: toggle show/hide default
- Date: native picker, format `DD / MM / YYYY`
- Phone: prefix `+62`, validator Indonesian format
- NIK: 16-digit numeric, mask sebagai `1234 **** **** ****` after filled

### 4.3 Cards

**Course card (list view):**
```
┌─────────────────────────────────┐
│ [Thumbnail 48×48]               │
│ Course name (H2)                │
│ Partner name · duration         │
│ ─────────────────────────────── │
│ Rp X,XXX,XXX        Mulai DD MMM│
└─────────────────────────────────┘
```

**Certificate card (wallet):**
```
┌─────────────────────────────────┐
│ Icon  Certificate name  [Badge] │
│       Berlaku s/d MMM YYYY      │
└─────────────────────────────────┘
```
Border-left 3px colored sesuai status (hijau/kuning/merah)

**Quest card:**
Icon circle 22px (status color) + task label + points reward `+XX`

### 4.4 Navigation

**Bottom nav (mobile):**
5 tabs max — Beranda, Kursus, Wallet, Quest, Profil
Active state: icon filled + label in `primary`, inactive: outlined + muted

**App bar:**
Title center (H2), back button left, action icon right (max 1)
Height 56px, BG white, border-bottom 0.5px

**Tab bar (within screen):**
Underline style (bukan pill), underline 2px `primary`, inactive label muted

### 4.5 Feedback

**Toast:** Top-positioned, auto-dismiss 3s, icon + text + optional action
**Snackbar:** Bottom, untuk undo actions
**Dialog:** Modal untuk confirm destructive action — title, body, 2 buttons (cancel ghost + confirm primary/danger)
**Bottom sheet:** Untuk detail quick view, filter, pick options — handle bar di atas (4px × 48px rounded)

### 4.6 Empty / error / loading states

**Wajib ada 3 state ini di setiap list/detail screen:**

- Loading: skeleton shimmer (bukan spinner tengah layar)
- Error: illustration + pesan manusiawi + retry button
- Empty: illustration + subtle prompt + primary action

Pesan error hindari "Terjadi kesalahan" — pakai bahasa spesifik seperti "Koneksi internet bermasalah" + "Coba lagi".

### 4.7 Badges & status

**Size:** 22px tall, 8px horizontal padding, font 11px bold
**Variants:** success (hijau), warning (kuning), danger (merah), info (biru), neutral (abu-abu)
**Content:** 1-2 kata maksimum ("Valid", "3 bln lagi", "Expired")

---

## 5. Interaction Patterns

### 5.1 Micro-animations
- Durasi standard: 200ms (ease-out untuk masuk, ease-in untuk keluar)
- Gunakan untuk: page transition, button tap feedback, badge appear, checkbox toggle
- Jangan pakai untuk: icon entrance, text changes, progress bar fill (terlalu banyak motion distract)

### 5.2 Haptic feedback (mobile)
- Light: button tap, checkbox
- Medium: success action (payment done, quest complete)
- Heavy: error, destructive confirm

### 5.3 Gestures
- Pull-to-refresh: di list screens
- Swipe-to-delete: jangan — pelaut kurang terbiasa, pakai long-press menu
- Long-press: context menu untuk certificate (share/delete/edit)

### 5.4 Progressive disclosure
- Informasi paling penting di fold atas
- Advanced settings di "Lihat lainnya" expander
- Form multi-step pakai wizard (step indicator), bukan long scroll

---

## 6. Accessibility (Non-negotiable)

- **Contrast:** min WCAG AA (4.5:1 untuk body, 3:1 untuk large text)
- **Tap target:** min 44×44px (Apple HIG) — konsisten untuk semua platform
- **Dynamic type:** support iOS/Android font size setting — test up to 150%
- **Screen reader:** semua image butuh `semantic label`, button punya tooltip text
- **Keyboard nav:** untuk web & desktop, Tab order logical
- **No text dalam image:** semua label berupa actual text, bukan raster

Pelaut mid-age: testing dengan font size +20% sebagai default saat review.

---

## 7. Screen Specs

> **Ini section yang akan berkembang.** Setiap tambah screen baru, append section di sini.

### 7.1 Login
- Logo center top, tagline di bawah
- Email input, password input, "Lupa password?" link kanan bawah password
- Primary button "Masuk" full-width
- Divider "atau"
- Secondary button "Masuk dengan Google"
- Footer link "Belum punya akun? Daftar"
- **Focus:** Simple, 1 task

### 7.2 Register — Step 1: Akun
- Step indicator 1/3
- Email, password, confirm password, phone (all required)
- Primary "Lanjut" (disabled sampai valid)
- Back link ke Login

### 7.3 Register — Step 2: Data diri (Buku Pelaut)
- Step indicator 2/3
- Fields: Nama lengkap, Tgl lahir (date picker), No KTP (NIK, 16-digit + mask), Alamat (textarea 3 baris), No Seafarer (optional dengan helper text "Isi jika sudah punya")
- Privacy callout di bawah: "🔒 NIK dienkripsi, tidak ditampilkan penuh di aplikasi"
- Primary "Lanjut → Upload dokumen"

### 7.4 Register — Step 3: Dokumen
- Step indicator 3/3
- Upload area untuk: foto KTP (tap to capture/pick), selfie verifikasi (guided camera dengan frame oval)
- Preview thumbnail setelah upload
- Primary "Selesai"
- Setelah submit → success screen "Menunggu verifikasi (1-2 hari kerja)"

### 7.5 Home (Beranda)
- Greeting card: "Halo, [Nama]" + cert yang butuh attention count
- **Urgent card** (jika ada cert urgent/expired): border merah, tampilkan cert name, tanggal kedaluwarsa, CTA "Renewal sekarang"
- **Quick actions** 2×2: Kursus, Wallet, Quest, Profil (icon + label)
- **Upcoming classes** horizontal scroll: enrolled courses mendatang
- **Recommendation**: 2-3 courses suggested by expiry engine

### 7.6 Catalog (Kursus)
- App bar: "Kursus tersedia" + filter icon
- Search bar sticky di atas
- Filter chips horizontal scroll: Semua, Renewal, Rating, SAT, dll
- List course cards (4.3)
- Infinite scroll dengan skeleton loading

### 7.7 Course Detail
- Hero image (aspect 16:9)
- Course name H1, partner name dengan small logo
- Stats row: Durasi, Standar (STCW), Kategori — 3 metric cards
- Deskripsi expandable (3 baris + "Lihat lebih lanjut")
- "Pilih jadwal" section: list batches dengan tanggal, kuota, kelas pagi/sore
- Bottom fixed bar: Harga (left) + "Daftar & bayar" primary button (right)

### 7.8 Certificate Wallet
- App bar: "Sertifikat saya"
- Stats card: jumlah aktif, jumlah expiring soon
- Filter chips: Semua, Valid, Expiring soon, Expired
- List certificate cards (4.3) — border-left colored per status
- FAB "+" untuk tambah manual

### 7.9 Quest Overview
- App bar: course name
- Hero card: Points balance (⭐ XX poin) + streak indicator
- Progress bar + "X dari 8 quest selesai"
- List quests:
  - Done (checkmark hijau)
  - Current (dot kuning)
  - Locked (lingkaran abu-abu)
  - Reward (bintang amber) for final
- Each item shows points `+XX` di kanan

### 7.10 Quest Detail
- App bar: quest name + status badge
- Hero callout (jika ada bonus): "Bonus +15 poin jika selesai sebelum [waktu]"
- Countdown timer "⏳ XX menit tersisa" (jika current)
- Info rows (side-bar colored):
  - Lokasi (primary color)
  - Rute (teal)
  - Kontak PJ (teal)
  - Batas waktu (danger)
  - Mulai dari (muted)
- Primary button "Tandai selesai" (disabled sampai verifikasi dari partner)

### 7.11 Points Dashboard
- Hero card dark brown (`#854F0B`): Big star icon left, big number right, subtitle "poin terkumpul"
- Streak indicator success card: "🔥 N quest berturut-turut cepat!"
- Section "Perolehan terbaru" — list earning rows (label + date + points)
- Section "Riwayat penukaran" — list redemptions

### 7.12 Reward Catalog
- App bar: "Tukarkan poin" + balance di kanan
- List reward items:
  - Available (can redeem): white bg, green border, primary "Tukar" button
  - Phase 2/3 (locked): gray bg, badge "Fase 2"/"Fase 3" bukan "Belum cukup poin"
- Each item: thumbnail 55×55, name, subtitle, points cost, action

### 7.13 Redeem Confirm Modal
- Bottom sheet
- Title "Tukar [reward name]?"
- Detail rows: Harga, Sisa poin setelah tukar
- Disclaimer voucher expiry
- Button row: Cancel (ghost) + Confirm (primary)

### 7.14 Profile
- Hero: avatar + name + title "Pelaut · [Verified/Pending]"
- Stats row 2 metrics: Sertifikat aktif, Kursus selesai
- Menu list items:
  - Edit profil
  - Buku pelaut (view/edit data diri)
  - Pengaturan notifikasi
  - Bantuan
  - Keluar (danger)

### 7.15 Venue Map (MVP 2D)
- Hero card: destination info (gedung + ruangan)
- 2D map SVG: gedung-gedung as rectangles, pin di destinasi, marker pintu masuk
- Tap gedung → detail sheet (nama, lantai, fasilitas)
- Primary "Mulai navigasi" (link ke Google Maps dengan koordinat) + note "Tampilan 3D segera hadir"

---

## 8. How to Add a New Screen

Ketika butuh screen baru:

1. **Tambah section 7.X di prompt ini** dengan: purpose, layout, components used, interaction patterns, edge cases
2. Identifikasi **reusable components** yang sudah ada di Section 4 — gunakan ulang, jangan buat baru
3. Kalau perlu component baru, **tambahkan ke Section 4** juga
4. Specify **empty/error/loading states** untuk screen ini
5. Confirm **accessibility requirements** terpenuhi (contrast, tap target, screen reader)
6. Output yang diharapkan dari Claude:
   - Ascii wireframe / mockup description
   - Atau Flutter widget code sesuai `claude_code_prompt.md` conventions
   - Atau HTML/SVG mockup untuk stakeholder review

---

## 9. Current Task

**[ISI SESI INI: jelaskan tugas desain yang Anda butuhkan]**

Contoh:
- "Desain screen 7.7 Course Detail dalam bentuk HTML mockup untuk diskusi dengan PMTC"
- "Buatkan variasi warna dark mode untuk design system ini"
- "Review screen 7.9 Quest Overview — ada yang bisa diperbaiki dari UX?"
- "Buatkan illustrasi empty state untuk Certificate Wallet (screen 7.8)"

**Penting:**
- Jangan invent color/size di luar token di Section 2-3
- Jangan buat komponen baru kalau existing bisa dipakai
- Setiap decision yang di luar scope prompt, tanya dulu sebelum eksekusi

---

**End of prompt.**
