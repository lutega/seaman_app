# SeaReady — Panduan Pemakaian Prompt

Repository ini berisi 2 master prompt untuk membangun aplikasi SeaReady:

| File | Untuk | Kapan dipakai |
|---|---|---|
| `claude_code_prompt.md` | Implementasi kode (Flutter + Supabase) | Sesi coding dengan Claude Code |
| `claude_design_prompt.md` | Desain UI/UX (visual, komponen, screen) | Sesi desain dengan Claude |

---

## Cara Pakai Dasar

### Untuk sesi coding

1. Buka Claude Code di terminal (`claude`)
2. Copy seluruh isi `claude_code_prompt.md`
3. Paste sebagai pesan pertama
4. Edit bagian **"10. Current Task"** sesuai kebutuhan sesi itu
5. Kirim ke Claude

Contoh:
```
[paste full prompt]

## 10. Current Task

Setup project dari awal:
- Init Flutter project "seaready"
- Buat folder structure sesuai Section 3.1
- Setup core/theme dengan tokens dari claude_design_prompt.md Section 2-3
- Install dependencies yang diperlukan
- Setup Supabase client
- Buat shared widget SrButton
```

### Untuk sesi desain

1. Buka Claude (web/app)
2. Copy seluruh isi `claude_design_prompt.md`
3. Paste sebagai pesan pertama
4. Edit bagian **"9. Current Task"** sesuai kebutuhan
5. Kirim ke Claude

Contoh:
```
[paste full prompt]

## 9. Current Task

Desain screen baru untuk fitur "Rekomendasi kursus berdasarkan expired sertifikat".
Outputkan dalam HTML mockup yang bisa saya tunjukkan ke tim PMTC.
Screen harus:
- Menampilkan list 3-5 kursus rekomendasi
- Setiap kursus menunjukkan alasan direkomendasikan
- Ada CTA "Daftar sekarang" per kursus
```

---

## Cara Menambah Fitur Baru

Prinsip kunci: **append, jangan edit**. Section 1-6 (Code) / 1-6 (Design) adalah fondasi yang tidak boleh diubah sembarangan.

### Contoh: Menambah fitur "Vessel Management"

**Step 1 — Update Code Prompt**
Tambahkan section baru di `claude_code_prompt.md` Section 8:

```markdown
### 8.X Vessel Management

**Screens:** VesselListScreen, VesselDetailScreen, VesselAddScreen
**State:** `vesselControllerProvider` (StateNotifier)
**API:** Supabase table `vessels` dengan RLS
**Flow:**
1. User di role "Ship Owner" bisa akses menu Vessel
2. Tambah vessel baru dengan form: nama, IMO, jenis, dll
3. Link crew ke vessel
...
```

**Step 2 — Update Design Prompt**
Tambahkan section baru di `claude_design_prompt.md` Section 7:

```markdown
### 7.X Vessel List
- App bar: "Kapal saya" + FAB "+"
- List card per vessel: nama, IMO, jenis, jumlah crew
...

### 7.X+1 Vessel Detail
...
```

**Step 3 — Commit ke git**
Versi prompt di git supaya tim bisa reference versi yang sama.

---

## Why Dual Prompt?

Memisahkan **code** dan **design** prompts ada alasannya:

1. **Separation of concerns** — coding session tidak perlu konteks warna hex; design session tidak perlu konteks Riverpod pattern
2. **Different LLMs best suited** — design prompt cocok untuk Claude di web (visual output), code prompt cocok untuk Claude Code (terminal, file edit)
3. **Iteration speed** — update design tidak break code, dan sebaliknya
4. **Team scale** — saat nanti hire developer/designer, mereka hanya perlu baca prompt relevant dengan role mereka

---

## Tips Memaksimalkan Claude

### Untuk Claude Code

**Efisiensi token:** Prompt panjang (~1500 lines). Sesi pertama akan makan token banyak, tapi setelah Claude Code punya context, sesi berikutnya cukup instruksi singkat.

**Verification loop:** Minta Claude untuk:
1. Konfirmasi pemahaman sebelum coding
2. Tampilkan rencana folder/file yang akan dibuat
3. Tanyakan decision yang ambigu

**Safe mode:** Untuk task critical (misal migration DB), minta Claude generate SQL/code dulu untuk review manual sebelum eksekusi.

### Untuk Claude Design

**Visual output:** Request HTML atau SVG mockup untuk feedback cepat dari stakeholder (contoh: PMTC meeting). Minta "output dalam artifact yang bisa saya screenshot".

**Design review:** Paste design prompt + minta Claude review screen existing Anda. Claude akan identifikasi inconsistency dengan design system.

**Edge cases:** Tanya Claude untuk "sebutkan semua edge case UI dari screen ini" — sangat membantu untuk MVP yang lengkap.

---

## Common Pitfalls

❌ **Edit section di atas "Feature Specs"** — ini fondasi, jangan diubah tanpa diskusi. Kalau warna primary berubah, itu decision besar yang affect semua screen.

❌ **Paste sebagian prompt** — Claude butuh full context. Kalau prompt terlalu panjang, pertimbangkan pakai Claude Projects yang bisa simpan prompt sebagai system instructions.

❌ **Skip "Current Task"** — tanpa task yang jelas, output Claude generic dan tidak actionable.

❌ **Tidak version control** — prompt berkembang terus. Tanpa git, Anda akan kehilangan track kenapa suatu decision dibuat.

❌ **Tidak review output sebelum push** — Claude bisa generate ratusan line code/design dalam menit. Review sebelum commit.

---

## Roadmap Prompt Evolution

Prompt ini hidup bersama produk. Evolution plan:

**Minggu 1-2:** Prompt seperti sekarang, fokus MVP
**Bulan 1-3:** Tambah section untuk feedback pattern dari user research
**Bulan 4-6:** Split jadi multiple files jika makin panjang (per major feature)
**Bulan 6+:** Extract ke internal wiki + onboarding doc untuk new team member

---

## Bantuan

Kalau prompt ini tidak cover situasi Anda:
1. Minta Claude untuk identifikasi apa yang missing
2. Tambahkan sebagai section baru
3. Commit perubahan ke git

Prompt terbaik adalah yang **used regularly** dan **updated often**.
