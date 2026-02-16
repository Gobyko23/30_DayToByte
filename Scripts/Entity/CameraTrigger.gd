extends Area3D

# กำหนด Offset กล้องที่ต้องการเมื่อเดินเข้าเขตนี้ (เช่น มุมสูง หรือ มุมข้าง)
@export var view_offset: Vector3 = Vector3(0, 10, -10) 

func _ready():
    # เชื่อมต่อสัญญาณเมื่อมีวัตถุเข้ามาและออกไป
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body):
    if body.is_in_group("Player"):
        var camera = get_tree().get_first_node_in_group("WorldCamera")
        if camera and camera.has_method("set_custom_view"):
            camera.set_custom_view(view_offset)
            print("🎥 Camera switched to custom view")

func _on_body_exited(body):
    if body.is_in_group("Player"):
        var camera = get_tree().get_first_node_in_group("WorldCamera")
        if camera and camera.has_method("reset_view"):
            camera.reset_view()
            print("🔄 Camera returned to normal")