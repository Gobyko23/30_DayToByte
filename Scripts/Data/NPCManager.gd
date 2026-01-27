extends Node


# ระบบจัดการสถานะ NPC ทั้งหมด
var npc_states: Dictionary = {}  # npc_name -> { "visited": bool, "greeted": bool, "interaction_count": int, "last_quest_given": String, "pending_action": int, "current_quest_id": String }

signal npc_interacted(npc_name: String)
signal npc_state_changed(npc_name: String)

# Enum สำหรับเก็บ pending action (ต้องตรงกับ NPCQuestSystem.NEXT_ACTION)
enum NEXT_ACTION {
	NONE = 0,
	START_QUEST = 1,
	COMPLETE_QUEST = 2
}

func _ready() -> void:
	add_to_group("Autoload")


# ฟังก์ชัน: บันทึกการทำ interact กับ NPC
func on_npc_interacted(npc_name: String) -> void:
	if not npc_states.has(npc_name):
		npc_states[npc_name] = {
			"visited": false,
			"greeted": false,
			"interaction_count": 0,
			"last_quest_given": "",
			"pending_action": NEXT_ACTION.NONE,
			"current_quest_id": ""
		}
	
	var state = npc_states[npc_name]
	state["visited"] = true
	state["interaction_count"] += 1
	
	npc_interacted.emit(npc_name)
	npc_state_changed.emit(npc_name)
	print("👤 NPC Interacted: ", npc_name, " (Count: ", state["interaction_count"], ")")


# ฟังก์ชัน: บันทึกว่า NPC ให้เควสแล้ว
func record_quest_given(npc_name: String, quest_id: String) -> void:
	if not npc_states.has(npc_name):
		npc_states[npc_name] = {
			"visited": false,
			"greeted": false,
			"interaction_count": 0,
			"last_quest_given": "",
			"pending_action": NEXT_ACTION.NONE,
			"current_quest_id": ""
		}
	
	npc_states[npc_name]["last_quest_given"] = quest_id
	npc_state_changed.emit(npc_name)
	print("📋 Quest recorded for NPC: ", npc_name, " -> ", quest_id)


# ฟังก์ชัน: บันทึก pending action state ของ NPC
func set_npc_action_state(npc_name: String, action: int, quest_id: String = "") -> void:
	if not npc_states.has(npc_name):
		npc_states[npc_name] = {
			"visited": false,
			"greeted": false,
			"interaction_count": 0,
			"last_quest_given": "",
			"pending_action": NEXT_ACTION.NONE,
			"current_quest_id": ""
		}
	
	npc_states[npc_name]["pending_action"] = action
	npc_states[npc_name]["current_quest_id"] = quest_id
	npc_state_changed.emit(npc_name)
	print("🔄 NPC action state updated: ", npc_name, " -> action: ", action, ", quest: ", quest_id)


# ฟังก์ชัน: ดึง pending action state ของ NPC
func get_npc_action_state(npc_name: String) -> Dictionary:
	if npc_states.has(npc_name):
		return {
			"action": npc_states[npc_name]["pending_action"],
			"quest_id": npc_states[npc_name]["current_quest_id"]
		}
	return {"action": NEXT_ACTION.NONE, "quest_id": ""}


# ฟังก์ชัน: ดึงสถานะ NPC
func get_npc_state(npc_name: String) -> Dictionary:
	if npc_states.has(npc_name):
		return npc_states[npc_name].duplicate()
	return {}


# ฟังก์ชัน: ส่งออกข้อมูล NPC ทั้งหมด
func export_npc_data() -> Dictionary:
	return {
		"npc_states": npc_states.duplicate(true)
	}


# ฟังก์ชัน: โหลดข้อมูล NPC จากไฟล์บันทึก
func load_npc_data(data: Dictionary) -> void:
	if data.has("npc_states") and data["npc_states"] is Dictionary:
		npc_states = data["npc_states"].duplicate(true)
		print("📥 NPC data loaded: ", npc_states.size(), " NPCs")
	else:
		print("⚠️ No NPC data found in save file")


# ฟังก์ชัน: รีเซ็ตสถานะ NPC ทั้งหมด
func reset_all_npc_states() -> void:
	npc_states.clear()
	print("🔄 All NPC states reset")
