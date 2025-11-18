extends Area2D

@onready var canvas_modulate: CanvasModulate = $"../CanvasModulate"
@onready var point_light_2d: PointLight2D = $"../Player/PointLight2D2"

const COLOR_LIGHT = Color(1, 1, 1)         # ffffff
const COLOR_DARK  = Color(0.16, 0.16, 0.16) # 292929

func _ready() -> void:
	canvas_modulate.color = COLOR_LIGHT
	point_light_2d.visible = false


func fade_to_dark():
	var t = create_tween()
	t.tween_property(canvas_modulate, "color", COLOR_DARK, 0.6)


func fade_to_light(on_finished: Callable):
	var t = create_tween()
	t.tween_property(canvas_modulate, "color", COLOR_LIGHT, 0.6)
	t.finished.connect(on_finished)  # เรียกหลัง fade เสร็จ


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		point_light_2d.visible = true
		fade_to_dark()


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		fade_to_light(func(): point_light_2d.visible = false)
