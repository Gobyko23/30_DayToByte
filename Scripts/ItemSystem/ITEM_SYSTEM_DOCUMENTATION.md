# ระบบไอเทมคอมพิวเตอร์ - เอกสารการใช้งาน

## 📋 ข้อมูลไอเทมใหม่

### 1. CPU (Processor)
- **Intel i5 (12th Gen)** - เบา
  - Cores: 10 (P+E)
  - Clock: 3.3 GHz
  - TDP: 65W
  - ราคา: 200

- **Intel i7 (13th Gen)** - กลาง
  - Cores: 16 (P+E)
  - Clock: 3.4 GHz
  - TDP: 125W
  - ราคา: 400

- **Intel i9 (13th Gen)** - แรง
  - Cores: 24 (P+E)
  - Clock: 3.0 GHz
  - TDP: 253W
  - ราคา: 700

### 2. GPU (Graphics Card)
- **RTX 3060** - เบา
  - Memory: 12GB GDDR6
  - CUDA: 3584
  - Bandwidth: 360 GB/s
  - ราคา: 300

- **RTX 3080** - กลาง
  - Memory: 10GB GDDR6X
  - CUDA: 8704
  - Bandwidth: 760 GB/s
  - ราคา: 700

- **RTX 4090** - แรง
  - Memory: 24GB GDDR6X
  - CUDA: 16384
  - Bandwidth: 1036 GB/s
  - ราคา: 1600

### 3. MainBoard
- **B550** - เบา
  - Socket: AM5
  - USB 3.2: 6 Ports
  - Max RAM: 192GB
  - ราคา: 200

- **X570** - กลาง
  - Socket: AM5
  - USB 3.2: 8 Ports
  - Max RAM: 192GB
  - ราคา: 350

- **TRX50** - แรง (Threadripper)
  - Socket: TRX50
  - USB 3.2: 10 Ports
  - Max RAM: 1.2TB
  - ราคา: 800

### 4. Case
- **NZXT H510 Flow** - เบา
  - Size: Mid Tower
  - Max GPU: 384mm
  - Cooling: 360mm
  - ราคา: 80

- **Lian Li O11XL** - กลาง
  - Size: Large Tower
  - Max GPU: 443mm
  - Cooling: 360mm x2
  - ราคา: 200

- **Corsair Crystal 1200D** - แรง
  - Size: Super Tower
  - Max GPU: 475mm
  - Cooling: 420mm x3
  - ราคา: 400

### 5. RAM (Memory)
- **8GB** - เบา
  - Speed: 3600MHz
  - Latency: CAS 18
  - ราคา: 50

- **16GB** - กลาง
  - Speed: 5200MHz
  - Latency: CAS 20
  - ราคา: 120

- **32GB** - แรง
  - Speed: 6000MHz
  - Latency: CAS 30
  - ราคา: 300

### 6. Fan (ระบายอากาศ)
- **Arctic P12 PWM** - เบา
  - Size: 120mm
  - Airflow: 56 CFM
  - ราคา: 15

- **Noctua NF-F12 PWM** - กลาง
  - Size: 120mm
  - Airflow: 122 CFM
  - ราคา: 30

- **Corsair LL120 RGB** - แรง
  - Size: 120mm
  - Airflow: 130 CFM
  - ราคา: 50

---

## 🔧 วิธีใช้งาน

### ดึงข้อมูลสเปค
```gdscript
# ดึงข้อมูลทั้งหมดของไอเทม
var specs = HardwareSpecs.get_specs("CPU_Intel_i5")

# ดึงชื่อแสดง
var name = ItemHelper.get_item_display_name("CPU_Intel_i5")
# ผลลัพธ์: "Intel Core i5 (12th Gen)"

# ดึงคำอธิบาย
var desc = ItemHelper.get_item_description("GPU_RTX_4090")

# ดึงราคา
var price = ItemHelper.get_item_price("RAM_16GB")

# ดึงหมวดหมู่
var category = ItemHelper.get_item_category("MainBoard_X570")
```

### การนับไอเทม
```gdscript
# นับไอเทมตามหมวดหมู่
var cpu_count = ItemHelper.count_items_by_category("CPU")
var gpu_count = ItemHelper.count_items_by_category("GPU")
```

### สร้าง Tooltip
```gdscript
# สร้างข้อความ tooltip พร้อม BBCode
var tooltip = ItemHelper.create_tooltip("CPU_Intel_i7")
```

### ดึงรายชื่อหมวดหมู่
```gdscript
var categories = ItemHelper.get_all_categories()
# ผลลัพธ์: ["CPU", "GPU", "MainBoard", "Case", "RAM", "Fan"]
```

---

## 🎮 ตัวอย่างการใช้งาน

### เพิ่มไอเทมในเกม
```gdscript
# วิธีที่ 1: ใช้ random_obj()
var random_item = InventorySystem.random_obj()
InventorySystem.update_item(random_item, 1)

# วิธีที่ 2: เพิ่มไอเทมเฉพาะ
InventorySystem.update_item("CPU_Intel_i7", 1)
InventorySystem.update_item("GPU_RTX_3080", 1)
```

### แสดงข้อมูลใน UI
```gdscript
# ในฟังก์ชัน _ready()
ItemHelper.create_tooltip("RAM_32GB")

# ผลลัพธ์:
# Intel Core i5 (12th Gen)
# CPU
# ━━━━━━━━━━━━
# • Core Count: 10 Cores (P+E)
# • Base Clock: 3.3 GHz
# • TDP: 65W
# ━━━━━━━━━━━━
# ฿200
# โปรเซสเซอร์ Intel รุ่นกลาง เหมาะสำหรับงานทั่วไปและเกมเม็ดขนาดกลาง
```

---

## 📊 สัญญาณ (Signals)

```gdscript
# เมื่อ Inventory มีการเปลี่ยนแปลง
InventorySystem.inventory_changed.connect(func():
    print("Inventory updated!")
)
```

---

## 📝 หมายเหตุ

- **ความหายาก (Rarity)**:
  - `common`: ไอเทมเบา (ความน่าจะเป็นมากที่สุด)
  - `rare`: ไอเทมปกติ
  - `legendary`: ไอเทมแรง (ความน่าจะเป็นน้อยสุด)

- **Performance Tier**:
  - 1: ระดับเบา
  - 2: ระดับกลาง
  - 3: ระดับแรง

- **สีไอเทม**:
  - CPU: น้ำเงิน (#4a90e2)
  - GPU: เขียว (#2ecc71)
  - MainBoard: ส้ม (#e67e22)
  - Case: เทา (#95a5a6)
  - RAM: ชมพู (#e91e63)
  - Fan: แดง (#e74c3c)
