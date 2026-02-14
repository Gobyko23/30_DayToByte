extends Node

# ข้อมูลสเปคของฮาร์ดแวร์คอมพิวเตอร์ (เบาไปแรง)

const HARDWARE_SPECS = {
    # ============================================
    # CPU (ต้องเช็ค socket ให้ตรงกับ MainBoard)
    # ============================================
    "CPU_Intel_i5": {
        "name": "Intel Core i5 (12th Gen)",
        "category": "CPU",
        "rarity": "common",
        "specs": ["10 Cores (P+E)", "3.3 GHz"],
        "socket": "LGA1700",    # <--- ใส่เพิ่ม
        "wattage_draw": 65,     # <--- ใส่เพิ่มเพื่อคำนวณไฟ
        "performance_tier": 1,
        "price": 200,
        "description": "โปรเซสเซอร์รุ่นกลาง เหมาะสำหรับงานทั่วไป"
    },
    "CPU_Intel_i7": {
        "name": "Intel Core i7 (13th Gen)",
        "category": "CPU",
        "rarity": "rare",
        "specs": ["16 Cores (P+E)", "3.4 GHz"],
        "socket": "LGA1700", 
        "wattage_draw": 125,
        "performance_tier": 2,
        "price": 400,
        "description": "โปรเซสเซอร์แรง เหมาะสำหรับการสตรีมเกม"
    },
    "CPU_Intel_i9": {
        "name": "Intel Core i9 (13th Gen)",
        "category": "CPU",
        "rarity": "legendary",
        "specs": ["24 Cores (P+E)", "3.0 GHz"],
        "socket": "LGA1700",
        "wattage_draw": 253,
        "performance_tier": 3,
        "price": 700,
        "description": "ระดับสูงสุด สำหรับการคำนวณหนัก"
    },

    # ============================================
    # GPU (เน้นเช็ค wattage_draw ว่า PSU จ่ายไหวไหม)
    # ============================================
    "GPU_RTX_3060": {
        "name": "NVIDIA GeForce RTX 3060",
        "category": "GPU",
        "rarity": "common",
        "specs": ["12GB GDDR6", "CUDA: 3584"],
        "wattage_draw": 170,    # <--- ใส่เพิ่ม
        "performance_tier": 1,
        "price": 300,
        "description": "การ์ดจอแรงพอสำหรับเกม 1440p"
    },
    "GPU_RTX_3080": {
        "name": "NVIDIA GeForce RTX 3080",
        "category": "GPU",
        "rarity": "rare",
        "specs": ["10GB GDDR6X", "CUDA: 8704"],
        "wattage_draw": 320,    # <--- ใส่เพิ่ม
        "performance_tier": 2,
        "price": 700,
        "description": "เหมาะสำหรับเกม 4K และการเรนเดอร์"
    },
    "GPU_RTX_4090": {
        "name": "NVIDIA GeForce RTX 4090",
        "category": "GPU",
        "rarity": "legendary",
        "specs": ["24GB GDDR6X", "CUDA: 16384"],
        "wattage_draw": 450,    # <--- ใส่เพิ่ม
        "performance_tier": 3,
        "price": 1600,
        "description": "ระดับสูงสุด สำหรับ 4K Ultra และ AI"
    },

    # ============================================
    # MainBoard (ต้องเช็ค socket ให้ตรงกับ CPU)
    # ============================================
    "MainBoard_B550": {
        "name": "ASUS B550-E (Intel Edition)",
        "category": "MainBoard",
        "rarity": "common",
        "socket": "LGA1700",    # <--- ปรับให้ตรงกับ CPU Intel ด้านบน
		"supported_ram": ["DDR4"],
        "ram_slots": 4,         # <--- เผื่อใช้จำกัดจำนวน RAM
        "performance_tier": 1,
        "price": 200,
        "description": "เมนบอร์ดรุ่นกลาง พื้นฐานดี"
    },
    "MainBoard_X570": {
        "name": "ASUS X570-E (Intel Edition)",
        "category": "MainBoard",
        "rarity": "rare",
        "socket": "LGA1700",
		"supported_ram": ["DDR4", "DDR5"],
        "ram_slots": 4,
        "performance_tier": 2,
        "price": 350,
        "description": "เมนบอร์ดระดับสูง พร้อม PCIe 4.0"
    },
	"MainBoard_TRX50": {
        "name": "ASUS Pro WS TRX50-SAGE",
        "category": "MainBoard",
        "rarity": "legendary",
        "specs": [
            "Socket: TRX50",
            "Quad-Channel Memory",
            "Max Memory: 1.2TB"
        ],
        # --- Technical Data สำหรับใช้เช็คเงื่อนไข ---
        "socket": "TRX50",              # ต้องตรงกับ CPU Threadripper (ถ้าคุณจะเพิ่มในอนาคต)
        "ram_type": ["DDR5"],           # รองรับแรม DDR5
        "ram_slots": 4,                 # จำนวนแถวที่ใส่ได้
        "performance_tier": 3,
        "price": 800,
        "description": "เมนบอร์ด Workstation ระดับสูงสุด รองรับการประมวลผลขั้นสูง"
    },

    # ============================================
    # PowerSupply (ส่วนสำคัญที่ขาดไป!)
    # ============================================
    "PSU_650W": {
        "name": "CoolerMaster 650W Gold",
        "category": "PowerSupply",
        "rarity": "common",
        "wattage_capacity": 650, # <--- ค่าพลังงานที่จ่ายได้
        "performance_tier": 1,
        "price": 80,
        "description": "จ่ายไฟเสถียรสำหรับสเปคเริ่มต้น"
    },
    "PSU_850W": {
        "name": "Corsair RM850x",
        "category": "PowerSupply",
        "rarity": "rare",
        "wattage_capacity": 850,
        "performance_tier": 2,
        "price": 150,
        "description": "จ่ายไฟสูง สำหรับการ์ดจอระดับกลาง-สูง"
    },
    "PSU_1200W": {
        "name": "EVGA SuperNOVA 1200 P2",
        "category": "PowerSupply",
        "rarity": "legendary",
        "wattage_capacity": 1200,
        "performance_tier": 3,
        "price": 300,
        "description": "ที่สุดของการจ่ายไฟ สำหรับ RTX 4090"
    },
	
	# ============================================
	# Case - Computer Case
	# ============================================
	"Case_Standard": {
		"name": "NZXT H510 Flow",
		"category": "Case",
		"rarity": "common",  # เบา
		"specs": [
			"Size: Mid Tower",
			"Max GPU Length: 384mm",
			"Max Cooling: 360mm"
		],
		"performance_tier": 1,
		"price": 80,
		"description": "เคสคอมพิวเตอร์ขนาดกลาง ดีไซน์สะอาด พื้นฐานดี"
	},
	
	"Case_Premium": {
		"name": "Lian Li O11XL",
		"category": "Case",
		"rarity": "rare",  # กลาง
		"specs": [
			"Size: Large Tower",
			"Max GPU Length: 443mm",
			"Max Cooling: 360mm x2"
		],
		"performance_tier": 2,
		"price": 200,
		"description": "เคสคอมพิวเตอร์ระดับสูง ดีไซน์สวย การระายอากาศดี"
	},
	
	"Case_Titan": {
		"name": "Corsair Crystal 1200D",
		"category": "Case",
		"rarity": "legendary",  # แรง
		"specs": [
			"Size: Super Tower",
			"Max GPU Length: 475mm",
			"Max Cooling: 420mm x3"
		],
		"performance_tier": 3,
		"price": 400,
		"description": "เคสคอมพิวเตอร์ยักษ์ ดีไซน์โปรแกรม พื้นที่เยอะมาก"
	},
	
# ============================================
    # RAM - Memory (ต้องเช็ค ram_type ให้ตรงกับ MainBoard)
    # ============================================
    "RAM_8GB": {
        "name": "Corsair Vengeance RGB Pro 8GB",
        "category": "RAM",
        "rarity": "common",
        "specs": ["8GB", "3600MHz"],
        "ram_type": "DDR4",      # <--- เพิ่ม: ประเภทแรม
        "performance_tier": 1,
        "price": 50,
        "description": "หน่วยความจำ 8GB เหมาะสำหรับงานพื้นฐาน"
    },
    
    "RAM_16GB": {
        "name": "Corsair Dominator Platinum 16GB",
        "category": "RAM",
        "rarity": "rare",
        "specs": ["16GB", "5200MHz"],
        "ram_type": "DDR5",      # <--- เพิ่ม: ประเภทแรม (รุ่นใหม่)
        "performance_tier": 2,
        "price": 120,
        "description": "หน่วยความจำ 16GB ความเร็วสูง DDR5"
    },
    
    "RAM_32GB": {
        "name": "G.Skill Trident Z Royal 32GB",
        "category": "RAM",
        "rarity": "legendary",
        "specs": ["32GB", "6000MHz"],
        "ram_type": "DDR5",
        "performance_tier": 3,
        "price": 300,
        "description": "หน่วยความจำ 32GB สำหรับการทำงานหนักและดีไซน์หรูหรา"
    },

	# ============================================
	# Fan - Cooling System
	# ============================================
	"Fan_Standard": {
		"name": "Arctic P12 PWM",
		"category": "Fan",
		"rarity": "common",  # เบา
		"specs": [
			"Type: Case Fan",
			"Size: 120mm",
			"Air Flow: 56 CFM"
		],
		"performance_tier": 1,
		"price": 15,
		"description": "พัดลมระบายอากาศพื้นฐาน เสียงเงียบ เก็บเงินได้"
	},
	
	"Fan_Premium": {
		"name": "Noctua NF-F12 PWM",
		"category": "Fan",
		"rarity": "rare",  # กลาง
		"specs": [
			"Type: High-Performance Fan",
			"Size: 120mm",
			"Air Flow: 122 CFM"
		],
		"performance_tier": 2,
		"price": 30,
		"description": "พัดลมระบายอากาศคุณภาพสูง ระบายลมดี เสียงเงียบ"
	},
	
	"Fan_Gaming": {
		"name": "Corsair LL120 RGB",
		"category": "Fan",
		"rarity": "legendary",  # แรง
		"specs": [
			"Type: RGB Gaming Fan",
			"Size: 120mm",
			"Air Flow: 130 CFM"
		],
		"performance_tier": 3,
		"price": 50,
		"description": "พัดลมเกมมิ่ง RGB หลากหลายสี ระบายลมดีเยี่ยม"
	},
	
	# ============================================
	# PowerSupply - Power Supply Unit
	# ============================================
	"PowerSupply_550W": {
		"name": "Corsair CX550M",
		"category": "PowerSupply",
		"rarity": "common",  # เบา
		"specs": [
			"Wattage: 550W",
			"Efficiency: 80+ Bronze",
			"Protection: Over Current, Over Voltage"
		],
		"performance_tier": 1,
		"price": 60,
		"description": "ยูนิตจ่ายไฟ 550W เหมาะสำหรับระบบพื้นฐาน เสถียร และราคาถูก"
	},
	
	"PowerSupply_850W": {
		"name": "EVGA SuperNOVA 850W",
		"category": "PowerSupply",
		"rarity": "rare",  # กลาง
		"specs": [
			"Wattage: 850W",
			"Efficiency: 80+ Gold",
			"Protection: OCP, OVP, OHP, SCP"
		],
		"performance_tier": 2,
		"price": 140,
		"description": "ยูนิตจ่ายไฟ 850W ประสิทธิภาพสูง เหมาะสำหรับระบบเกมมิ่งแรง"
	},
	
	"PowerSupply_1600W": {
		"name": "Corsair AX1600i",
		"category": "PowerSupply",
		"rarity": "legendary",  # แรง
		"specs": [
			"Wattage: 1600W",
			"Efficiency: 80+ Platinum",
			"Protection: Full Digital Control, Fan Control"
		],
		"performance_tier": 3,
		"price": 350,
		"description": "ยูนิตจ่ายไฟ 1600W ระดับสูงสุด สำหรับระบบ High-End และ Multi-GPU"
	}
}

# ฟังก์ชัน: ดึงข้อมูลสเปคของไอเทม
func get_specs(item_name: String) -> Dictionary:
	if HARDWARE_SPECS.has(item_name):
		return HARDWARE_SPECS[item_name]
	return {}

# ฟังก์ชัน: ดึงสเปคเป็นข้อความ
func get_specs_text(item_name: String) -> String:
	var specs = get_specs(item_name)
	if specs.is_empty():
		return "ไม่มีข้อมูล"
	
	if not specs.has("name") or not specs.has("specs"):
		return "ข้อมูลไม่สมบูรณ์"
	
	var text = specs["name"] + "\n"
	var separator = ""
	for i in range(30):
		separator += "="
	text += separator + "\n"
	
	if specs["specs"] is Array:
		for spec in specs["specs"]:
			text += "• " + str(spec) + "\n"
	
	return text

# ฟังก์ชัน: ดึงทั้งหมด
func get_all_specs() -> Dictionary:
	return HARDWARE_SPECS

func calculate_pc_score(parts: Dictionary) -> int:
	var score = 0
	for part_id in parts.values():
		var spec = HardwareSpecs.get_specs(part_id)
		score += spec.get("performance_tier", 0)
	return score
