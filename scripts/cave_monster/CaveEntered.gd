extends Area2D

@onready var canvas_modulate: CanvasModulate = $"../CanvasModulate"
@onready var point_light_2d: PointLight2D = $"../Player/PointLight2D2"

# ค่าเริ่มต้นก่อนจะเดินเข้า
var isCanvasDark := false
var isLightOn := false

func _ready() -> void:
	canvas_modulate.visible = isCanvasDark
	point_light_2d.visible = isLightOn

func _on_body_entered(body: Node2D) -> void:
	# ตรวจว่าเป็นผู้เล่น (ถ้าต้องการ)
	if body.name == "Player":
		isCanvasDark = true
		isLightOn = true
		
		canvas_modulate.visible = true
		point_light_2d.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		isCanvasDark = false
		isLightOn = false

		canvas_modulate.visible = false
		point_light_2d.visible = false
