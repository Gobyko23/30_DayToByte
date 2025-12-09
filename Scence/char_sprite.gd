extends CharacterBody3D


const SPEED :float= 6.0
const JUMP_VELOCITY :float= 4.5
@onready var InteractArea = $InteractArea
@onready var InteractText = $Interact_Screen/Interact_Text
@onready var HoldBar = $Interact_Screen/HoldBar
@onready var Interact_Anim :AnimationPlayer= $TheBox/Interact_Anim
@onready var ViewSprite = $ViewSprite
@onready var TextView3D = $ViewSprite/SubViewport/ViewPortControl/TextView3D
@onready var ViewPort3DAnim = $ViewSprite/ViewSpriteAnim
@onready var MenuItem :ItemList = $Interact_Screen/ItemList
var nearby_objects: Array[Node3D] = []
var highlighted = null


# เวลาที่ต้องการให้ผู้เล่นกดค้าง (วินาที)
const HOLD_TIME :float= 1.9
var hold_timer :float= 0.0
var is_holding :bool= false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	_update_closest_object()
	
# -------------------------
	# ระบบเปิด-ปิด menu
	# -------------------------
	var menu_check = false
	if Input.is_action_just_pressed("inventory_menu"):
		menu_check = true
		if menu_check:
			MenuItem.visible = true

			
		
	
# -------------------------
	# ระบบกดค้างเพื่อ Interact
	# -------------------------
	if Input.is_action_pressed("interact_bind") and not nearby_objects.is_empty():
		is_holding = true
		# 🟢 เรียก animation ของ object ตอนเริ่มกดค้าง
		if highlighted and hold_timer == 0:
			if highlighted.has_method("interacting"):
				highlighted.interacting()
		hold_timer += delta
		HoldBar.value = (hold_timer / HOLD_TIME) * 100.0
		
		if hold_timer >= HOLD_TIME:
			# สำเร็จ → หยุดอนิเมชันค้าง
			if highlighted and highlighted.has_method("interacting_cancle"):
				highlighted.interacting_cancle()
			hold_timer = 0
			HoldBar.value = 0
			is_holding = false
			_interact_closest_object()
	
	else:
		# ปล่อยปุ่ม
		if is_holding:
			if highlighted and highlighted.has_method("interacting_cancle"):
				highlighted.interacting_cancle()
			is_holding = false
			HoldBar.value = 0
			hold_timer = 0


func _update_closest_object():
	if nearby_objects.is_empty():
		if highlighted:
			_set_highlight(highlighted, false)
			highlighted = null
		InteractText.visible = false
		return

	var closest = null
	var closest_dist = INF
	var player_pos = global_transform.origin
	
	for obj in nearby_objects:
		var d = player_pos.distance_to(obj.global_transform.origin)
		if d < closest_dist:
			closest_dist = d
			closest = obj

	# ถ้าเจอ object ตัวใหม่ → ปิด highlight ของตัวเก่า
	if highlighted and highlighted != closest:
		_set_highlight(highlighted, false)

	highlighted = closest
	_set_highlight(highlighted, true)
	InteractText.visible = true


func _interact_closest_object():
	var Result_interact = null
	if not highlighted:
		return

	print("Interact with: ", highlighted.name)
	Result_interact = highlighted.interactable() #method แยก
	ViewPort3DAnim.play("3dViewPortAnim")
	TextView3D.text = "You Got:  " + str(Result_interact)
	print(InventorySystem.Inventory)
	nearby_objects.erase(highlighted)

	highlighted = null
	InteractText.visible = false
	


func _set_highlight(obj, enable: bool):
	if obj.has_node("HighlightMesh"):
		obj.get_node("HighlightMesh").visible = enable

func _on_interact_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("interactable"):
		body.interact_event_in()
		InteractText.visible = true
		print("Player: Interacted: ", body.name)
		nearby_objects.append(body)


func _on_interact_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("interactable"):
		nearby_objects.erase(body)
		body.interact_event_out()
		print("Player: Not Interacted: ", body.name)
		if highlighted == body:
			_set_highlight(body, false)
			highlighted = null
		if nearby_objects.is_empty():
			InteractText.visible = false
		
