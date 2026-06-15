# 🌱 Grow A Garden Script

Script Roblox untuk game Grow A Garden dengan fitur lengkap.

## 📋 Daftar Fitur

| No | Fitur | Icon | Deskripsi |
|----|-------|------|-----------|
| 1 | Pet Finder | 🐾 | Cari & kumpulkan pet otomatis |
| 2 | Weather Predict | 🌤 | Prediksi cuaca & multiplier |
| 3 | Seed Sniper | 🌱 | Auto beli seed saat event |
| 4 | Tame Sniper | 🐾 | Auto hop server & tame pet |
| 5 | Raccoon Finder | 🦝 | Cari pet Raccoon spesial |
| 6 | Coin Farmer | 💰 | Farm coin & token otomatis |
| 7 | Unicorn Finder | 🦄 | Cari & hatch pet Unicorn |

---

## ⚙️ Kebutuhan

- **Roblox Executor** (salah satu):
  - Synapse X (berbayar, paling stabil)
  - Fluxus (gratis)
  - Delta (mobile/PC)
  - Arceus X (mobile)
  - KRNL (gratis)

- **Game**: Grow A Garden (Roblox)

---

## 🚀 Cara Install & Jalankan

### Metode 1: GitHub (Recommended)

1. **Upload ke GitHub**
   ```
   - Buat repository baru di GitHub
   - Upload semua file dari folder /root/GAG-farm-v1/
   - Pastikan struktur folder tetap sama
   ```

2. **Dapatkan Raw URL**
   ```
   - Klik file main.lua
   - Klik tombol "Raw"
   - Copy URL dari browser
   - Contoh: https://raw.githubusercontent.com/AUR4NK/GAG-farm-v1/main/main.lua
   ```

3. **URL sudah disesuaikan** (tidak perlu diubah lagi)
   ```lua
   -- URL sudah benar:
   local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AUR4NK/GAG-farm-v1/main/libs/ui_library.lua"))()
   ```

4. **Jalankan di Executor**
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/AUR4NK/GAG-farm-v1/main/main.lua"))()
   ```

### Metode 2: Langsung Paste

1. Buka Roblox, masuk ke game **Grow A Garden**
2. Buka executor (Synapse, Fluxus, dll)
3. Copy isi `main.lua` seluruhnya
4. Paste ke executor
5. Klik **Execute**

---

## 🎮 Cara Penggunaan

### Toggle Menu
```
Tekan [RightShift] untuk buka/tutup menu
```

### Tab 1: Pet Finder 🐾
```
Fungsi: Cari & kumpulkan semua pet di sekitar

Toggle:
  - Auto Scan Pets    : Scan pet otomatis terus-menerus
  - Auto Collect      : Kumpulkan pet yang ditemukan
  - Notify on Find    : Notifikasi saat pet ditemukan

Slider:
  - Scan Radius       : Jarak scan pet (50-500 stud)

Button:
  - Scan Once         : Scan sekali saja
  - Collect All Now   : Kumpulkan semua pet sekarang

Tips:
  - Aktifkan "Auto Scan" + "Auto Collect" untuk AFK farm
  - Radius 200-300 sudah cukup untuk area kecil
```

### Tab 2: Weather Predict 🌤
```
Fungsi: Monitor & prediksi cuaca berikutnya

Toggle:
  - Auto Monitor      : Monitor cuaca terus-menerus
  - Notify Changes    : Notifikasi saat cuaca berubah

Info yang ditampilkan:
  - Current Weather   : Cuaca saat ini
  - Multiplier        : Bonus multiplier (x1.0 - x2.5)
  - Time Remaining    : Sisa waktu cuaca
  - Predicted Next    : Prediksi cuaca berikutnya
  - Confidence        : Tingkat kepercayaan prediksi

Tips:
  - Weather dengan multiplier tinggi (Stormy x2.0, Rainbow x2.5) lebih menguntungkan
  - Gunakan prediksi untuk plan farming saat multiplier tinggi
```

### Tab 3: Seed Sniper 🌱
```
Fungsi: Auto beli seed saat muncul di shop

Toggle:
  - Auto Snipe        : Auto beli seed terus-menerus
  - Auto Buy          : Otomatis beli saat seed tersedia
  - Rare Only         : Hanya beli seed rare

Slider:
  - Max Buy Per Seed  : Maksimal beli per seed (1-50)
  - Buy Delay         : Delay antar pembelian (100-2000ms)

Button:
  - Check Shop Now    : Cek shop sekarang
  - Snipe All Now     : Beli semua seed yang tersedia

Tips:
  - Aktifkan "Rare Only" untuk hemat coin
  - Set delay 300-500ms untuk menghindari detection
```

### Tab 4: Tame Sniper 🐾
```
Fungsi: Auto hop server & tame pet

Toggle:
  - Auto Snipe Tame   : Auto tame pet
  - Auto Server Hop   : Ganti server otomatis
  - Auto Tame         : Otomatis tame pet

Slider:
  - Scan Radius       : Jarak scan (50-500 stud)
  - Max Tame/Server   : Maks tame per server (1-20)
  - Hop Delay         : Delay sebelum hop (1-10 detik)

Dropdown:
  - Server Hop Mode   : 
    - random : Server acak
    - low    : Server sepi (lebih bagus)

Button:
  - Scan & Tame Now   : Scan & tame sekarang
  - Hop Server Now    : Ganti server sekarang

Tips:
  - Gunakan mode "low" untuk server sepi (lebih banyak pet)
  - Set Max Tame/Server = 3-5 untuk efisien
```

### Tab 5: Raccoon Finder 🦝
```
Fungsi: Cari pet Raccoon spesial

Toggle:
  - Auto Find Raccoon : Scan Raccoon terus-menerus
  - Auto Collect      : Kumpulkan otomatis
  - Auto Teleport     : Teleport ke Raccoon
  - Sound Notification: Bunyi saat ditemukan

Slider:
  - Scan Radius       : Jarak scan (100-1000 stud)
  - Scan Interval     : Interval scan (500-5000ms)

Button:
  - Scan Now          : Scan sekarang
  - Scan & Collect All: Scan & kumpulkan semua
  - Save Current Position : Simpan posisi spawn
  - Check All Known Spawns : Cek semua spawn tersimpan

Cara pakai:
  1. Saat menemukan Raccoon, klik "Save Current Position"
  2. Script akan otomatis cek posisi tersebut setiap scan
  3. Raccoon yang ditemukan di-highlight merah + label kedip

Tips:
  - Radius 500+ untuk menjangkau area luas
  - Simpan beberapa spawn point untuk efisiensi
```

### Tab 6: Coin Farmer 💰
```
Fungsi: Farm coin & token otomatis

Toggle:
  - Auto Farm         : Farm otomatis
  - Auto Sell         : Jual otomatis setiap X detik
  - Auto Rebirth      : Rebirth otomatis

Dropdown:
  - Farm Mode         :
    - all    : Semua (coin + token)
    - coins  : Hanya coin
    - tokens : Hanya token/drops
  - Priority          :
    - nearest  : Terdekat duluan
    - highest  : Coin duluan (lebih bernilai)
    - farthest : Terjauh duluan

Slider:
  - Collect Radius    : Jarak collect (50-1000 stud)
  - Teleport Speed    : Kecepatan teleport (50-1000ms)
  - Sell Interval     : Interval auto sell (10-120 detik)
  - Max Collect/Loop  : Maks collect per loop (10-100)

Button:
  - Sell All Now      : Jual semua sekarang
  - Farm Once (Quick) : Farm sekali saja

Status:
  - Total Collected   : Total item dikumpulkan
  - Coins             : Jumlah coin
  - Tokens            : Jumlah token
  - Coins/Min         : Kecepatan farming
  - Session Time      : Waktu session
  - Next Sell In      : Waktu sell berikutnya

Tips:
  - Set Teleport Speed 200-300ms untuk farming cepat
  - Set Sell Interval 30-60 detik untuk optimal
  - Mode "highest" untuk prioritaskan coin
```

### Tab 7: Unicorn Finder 🦄
```
Fungsi: Cari & hatch pet Unicorn

Toggle:
  - Auto Find Unicorn : Scan Unicorn terus-menerus
  - Auto Collect      : Kumpulkan Unicorn
  - Auto Teleport     : Teleport ke target
  - Auto Hatch Eggs   : Otomatis hatch egg legendary/mythical
  - Sound Notification: Bunyi saat ditemukan
  - Visual Notification: Notifikasi visual

Slider:
  - Scan Radius       : Jarak scan (100-1500 stud)
  - Scan Interval     : Interval scan (500-5000ms)
  - Max Retries       : Maks retry collect (1-10)

Button:
  - Scan for Unicorn Now : Scan sekarang
  - Scan & Collect All   : Scan & kumpulkan semua
  - Save Current Position: Simpan posisi spawn
  - Check All Known Spawns: Cek spawn tersimpan

Cara kerja:
  1. Script scan Unicorn PET langsung
  2. Script juga scan EGG legendary/mythical
  3. Egg otomatis di-hatch
  4. Setelah hatch, scan lagi untuk cek hasil
  5. Jika hasilnya Unicorn, otomatis dikumpulkan

Tips:
  - Radius 600+ sangat disarankan (Unicorn sangat langka)
  - Simpan spawn point saat menemukan Unicorn/Egg
  - "Auto Hatch Eggs" harus ON untuk proses egg
```

### Tab 8: Settings ⚙
```
Fungsi: Pengaturan umum

Toggle:
  - Anti-AFK          : Mencegah kick saat AFK
  - Debug Mode        : Tampilkan log debug

Info:
  - Version           : Versi script
  - Modules           : Jumlah module loaded
  - Toggle Key        : Tombol toggle menu

Button:
  - Destroy GUI       : Tutup & hapus menu
```

---

## 🔧 Konfigurasi Lanjutan

### Edit Config di Script

Buka file `configs/settings.lua` untuk mengubah default:

```lua
Settings.General = {
    AutoReconnect = true,   -- Auto reconnect saat disconnect
    AntiAFK = true,         -- Anti AFK
    NotificationSound = true, -- Suara notifikasi
    DebugMode = false,      -- Mode debug
}
```

### Tambah Spawn Point Manual

Di `modules/raccoon_finder.lua` atau `unicorn_finder.lua`:

```lua
-- Tambah koordinat spawn yang sudah diketahui
RaccoonFinder.KnownSpawns = {
    Vector3.new(100, 50, 200),   -- Spawn 1
    Vector3.new(-50, 30, 150),   -- Spawn 2
    Vector3.new(0, 25, -100),    -- Spawn 3
}
```

---

## ❓ FAQ

**Q: Script tidak jalan?**
A: Pastikan:
   - Pakai executor yang support (Synapse, Fluxus, dll)
   - Sudah masuk ke game Grow A Garden
   - URL GitHub sudah benar (jika pakai metode GitHub)

**Q: Menu tidak muncul?**
A: Tekan `RightShift` untuk toggle menu

**Q: Auto Collect tidak jalan?**
A: Beberapa game punya anti-cheat. Coba:
   - Kurangi kecepatan teleport (set lebih tinggi ms)
   - Jangan terlalu banyak collect sekaligus

**Q: Raccoon/Unicorn tidak ditemukan?**
A: Pet ini sangat langka. Tips:
   - Scan radius 500+
   - Cek beberapa server (pakai Tame Sniper hop)
   - Simpan spawn point saat menemukan

**Q: Auto Sell tidak jalan?**
A: Script mencari sell remote/part otomatis. Jika tidak jalan:
   - Cek apakah game punya sell NPC/area
   - Coba manual "Sell All Now"

---

## 📁 Struktur File

```
GAG-farm-v1/
├── main.lua                    # Script utama + UI
├── libs/
│   └── ui_library.lua          # UI Library
├── modules/
│   ├── pet_finder.lua          # Pet Finder
│   ├── weather_predict.lua     # Weather Predict
│   ├── seed_sniper.lua         # Seed Sniper
│   ├── pet_tame_sniper.lua     # Tame Sniper
│   ├── raccoon_finder.lua      # Raccoon Finder
│   ├── coin_farmer.lua         # Coin Farmer
│   └── unicorn_finder.lua      # Unicorn Finder
├── configs/
│   └── settings.lua            # Konfigurasi
├── utils/
│   └── helpers.lua             # Utility functions
└── README.md                   # Dokumentasi (file ini)
```

---

## ⚠️ Disclaimer

- Script ini untuk educational purposes
- Gunakan dengan bijak dan bertanggung jawab
- Developer game bisa update kapan saja yang bisa membuat script tidak work
- Gunakan resiko sendiri

---

## 📝 Changelog

### v1.3.0 (Latest)
- Added Unicorn Finder 🦄
- Auto hatch eggs
- Post-hatch scan

### v1.2.0
- Added Coin Farmer 💰
- Auto sell & rebirth
- Farm mode & priority

### v1.1.0
- Added Raccoon Finder 🦝
- Known spawn points
- Highlight effect

### v1.0.0
- Initial release
- Pet Finder, Weather, Seed Sniper, Tame Sniper
- Custom UI Library