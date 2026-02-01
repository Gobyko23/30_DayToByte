extends Node

# ข้อมูลสเปคของฮาร์ดแวร์คอมพิวเตอร์ (เบาไปแรง)

const HARDWARE_SPECS = {
	# ============================================
	# CPU - Intel Processor
	# ============================================
	"CPU_Intel_i5": {
		"name": "Intel Core i5 (12th Gen)",
		"category": "CPU",
		"rarity": "common",  # เบา
		"specs": [
			"Core Count: 10 Cores (P+E)",
			"Base Clock: 3.3 GHz",
			"TDP: 65W"
		],
		"performance_tier": 1,
		"price": 200,
		"description": "โปรเซสเซอร์ Intel รุ่นกลาง เหมาะสำหรับงานทั่วไปและเกมเม็ดขนาดกลาง"
	},
	
	"CPU_Intel_i7": {
		"name": "Intel Core i7 (13th Gen)",
		"category": "CPU",
		"rarity": "rare",  # กลาง
		"specs": [
			"Core Count: 16 Cores (P+E)",
			"Base Clock: 3.4 GHz",
			"TDP: 125W"
		],
		"performance_tier": 2,
		"price": 400,
		"description": "โปรเซสเซอร์ Intel แรง เหมาะสำหรับการแก้ไขวิดีโอ หรือสตรีมเกม"
	},
	
	"CPU_Intel_i9": {
		"name": "Intel Core i9 (13th Gen)",
		"category": "CPU",
		"rarity": "legendary",  # แรง
		"specs": [
			"Core Count: 24 Cores (P+E)",
			"Base Clock: 3.0 GHz",
			"TDP: 253W"
		],
		"performance_tier": 3,
		"price": 700,
		"description": "โปรเซสเซอร์ Intel ระดับสูงสุด เหมาะสำหรับการคำนวณหนักและการทำงานมัลติเทสก์"
	},
	
	# ============================================
	# GPU - NVIDIA Graphics Card
	# ============================================
	"GPU_RTX_3060": {
		"name": "NVIDIA GeForce RTX 3060",
		"category": "GPU",
		"rarity": "common",  # เบา
		"specs": [
			"Memory: 12GB GDDR6",
			"CUDA Cores: 3584",
			"Memory Bandwidth: 360 GB/s"
		],
		"performance_tier": 1,
		"price": 300,
		"description": "การ์ดจอ NVIDIA แรงพอสำหรับเกม 1440p และงาน 3D กลาง"
	},
	
	"GPU_RTX_3080": {
		"name": "NVIDIA GeForce RTX 3080",
		"category": "GPU",
		"rarity": "rare",  # กลาง
		"specs": [
			"Memory: 10GB GDDR6X",
			"CUDA Cores: 8704",
			"Memory Bandwidth: 760 GB/s"
		],
		"performance_tier": 2,
		"price": 700,
		"description": "การ์ดจอ NVIDIA ระดับสูง เหมาะสำหรับเกม 4K และการเรนเดอร์"
	},
	
	"GPU_RTX_4090": {
		"name": "NVIDIA GeForce RTX 4090",
		"category": "GPU",
		"rarity": "legendary",  # แรง
		"specs": [
			"Memory: 24GB GDDR6X",
			"CUDA Cores: 16384",
			"Memory Bandwidth: 1036 GB/s"
		],
		"performance_tier": 3,
		"price": 1600,
		"description": "การ์ดจอ NVIDIA ระดับสูงสุด สำหรับการเล่นเกม 4K Ultra และการคำนวณ AI"
	},
	
	# ============================================
	# MainBoard - AMD Socket AM5
	# ============================================
	"MainBoard_B550": {
		"name": "ASUS ROG STRIX B550-E",
		"category": "MainBoard",
		"rarity": "common",  # เบา
		"specs": [
			"Socket: AM5",
			"USB 3.2: 6 Ports",
			"Max Memory: 192GB"
		],
		"performance_tier": 1,
		"price": 200,
		"description": "เมนบอร์ด AMD รุ่นกลาง พื้นฐานดี สำหรับใช้งานทั่วไป"
	},
	
	"MainBoard_X570": {
		"name": "ASUS ROG STRIX X570-E",
		"category": "MainBoard",
		"rarity": "rare",  # กลาง
		"specs": [
			"Socket: AM5",
			"USB 3.2: 8 Ports",
			"Max Memory: 192GB"
		],
		"performance_tier": 2,
		"price": 350,
		"description": "เมนบอร์ด AMD ระดับสูง พร้อม PCIe 4.0 สำหรับการใช้งานหนัก"
	},
	
	"MainBoard_TRX50": {
		"name": "ASUS Pro WS TRX50-SAGE",
		"category": "MainBoard",
		"rarity": "legendary",  # แรง
		"specs": [
			"Socket: TRX50",
			"USB 3.2: 10 Ports",
			"Max Memory: 1.2TB"
		],
		"performance_tier": 3,
		"price": 800,
		"description": "เมนบอร์ด AMD Threadripper ระดับสูงสุด สำหรับการคำนวณและวิทยาศาสตร์"
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
	# RAM - Memory
	# ============================================
	"RAM_8GB": {
		"name": "Corsair Vengeance RGB Pro 8GB",
		"category": "RAM",
		"rarity": "common",  # เบา
		"specs": [
			"Capacity: 8GB",
			"Speed: 3600MHz",
			"Latency: CAS 18"
		],
		"performance_tier": 1,
		"price": 50,
		"description": "หน่วยความจำ 8GB เหมาะสำหรับงานพื้นฐาน"
	},
	
	"RAM_16GB": {
		"name": "Corsair Dominator Platinum 16GB",
		"category": "RAM",
		"rarity": "rare",  # กลาง
		"specs": [
			"Capacity: 16GB",
			"Speed: 5200MHz",
			"Latency: CAS 20"
		],
		"performance_tier": 2,
		"price": 120,
		"description": "หน่วยความจำ 16GB เหมาะสำหรับหลายงาน"
	},
	
	"RAM_32GB": {
		"name": "G.Skill Trident Z Royal 32GB",
		"category": "RAM",
		"rarity": "legendary",  # แรง
		"specs": [
			"Capacity: 32GB",
			"Speed: 6000MHz",
			"Latency: CAS 30"
		],
		"performance_tier": 3,
		"price": 300,
		"description": "หน่วยความจำ 32GB สำหรับการทำงานหนักและโปรแกรมมิ่ง"
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
