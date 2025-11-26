extends Node2D
@export var bgm_player: AudioStreamPlayer

var current_biom : String

func _ready() -> void:
	current_biom = AudioGlobal.current_biom
	
	
func _process(delta: float) -> void:
	print(current_biom)
	if current_biom != AudioGlobal.current_biom:
		current_biom = AudioGlobal.current_biom
		
		update_music_for_scene()
		
func update_music_for_scene():
	var current_biom_music = str(current_biom)
	bgm_player["parameters/switch_to_clip"] = current_biom
