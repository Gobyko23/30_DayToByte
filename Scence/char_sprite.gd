extends CharacterBody3D


const SPEED = 6.0
const JUMP_VELOCITY = 4.5
@onready var InteractArea = $InteractArea
@onready var InteractText = $Text_Screen
var nearby_objects: Array[Node3D] = []
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
	
	
	
	if Input.is_action_just_pressed("interact_bind"):
		_interact_closest_object()


func _interact_closest_object():
	if nearby_objects.is_empty():
		return
		
	var closest = null
	var closest_dist = INF
	var player_pos = global_transform.origin
	
	for obj in nearby_objects:
		var d = player_pos.distance_to(obj.global_transform.origin)
		if d < closest_dist:
			closest_dist = d
			closest = obj

	if closest:
		print("Interacting with: ", closest.name)
		closest.queue_free()
		nearby_objects.erase(closest)

		# ถ้าไม่มีอะไรในระยะแล้ว → ซ่อนข้อความ
		if nearby_objects.is_empty():
			InteractText.visible = false

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
		if nearby_objects.is_empty():
			InteractText.visible = false
		
