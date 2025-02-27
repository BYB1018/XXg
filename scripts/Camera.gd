extends Camera2D

@export var smooth_speed: float = 0.125

func _process(_delta):
	if get_parent() == null:
		return
		
	# 摄像机平滑跟随父节点（通常是玩家）
	var target_position = get_parent().global_position
	global_position = global_position.lerp(target_position, smooth_speed)
