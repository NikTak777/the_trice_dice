extends Node

@export var camera: Camera2D
@export var start_zoom: float = 1.0
@export var target_zoom: float = 5.0
@export var duration: float = 3.0
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT

func _ready():
	if camera:
		var tween = create_tween()
		tween.set_trans(transition_type)
		tween.set_ease(ease_type)
		
		tween.tween_property(camera, "zoom", 
			Vector2(target_zoom, target_zoom), duration
		).from(Vector2(start_zoom, start_zoom))
