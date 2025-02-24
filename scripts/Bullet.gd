extends Area2D

var speed: float = 500.0
var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var piercing: bool = false
var bounce_count: int = 0
var homing: bool = false
var homing_strength: float = 5.0
var target: Node2D = null
var split_shot: bool = false
var split_count: int = 2
var has_split: bool = false
var is_laser: bool = false
var laser_width: float = 2.0

func _ready():
	$Sprite2D.queue_redraw()
	if is_laser:
		$Sprite2D.scale = Vector2(2.0, laser_width * 0.25)
		$Sprite2D.modulate = Color(0.5, 1, 1, 1)

func _process(delta):
	if homing and target and is_instance_valid(target):
		var target_dir = global_position.direction_to(target.global_position)
		direction = direction.lerp(target_dir, homing_strength * delta)
	
	global_position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
			if split_shot and !has_split:
				has_split = true
				for i in range(split_count):
					var split = duplicate()
					split.has_split = true
					split.global_position = global_position
					split.direction = direction.rotated(PI * 2 * (float(i) / split_count))
					get_tree().root.add_child(split)
			
		if !piercing:
			queue_free()
	elif bounce_count > 0:
		bounce_count -= 1
		direction = direction.bounce(body.get_collision_normal())
	else:
		queue_free()

func _on_life_timer_timeout():
	queue_free()

func _draw():
	if is_laser:
		draw_line(Vector2.ZERO, Vector2.RIGHT * 16, Color(0.5, 1, 1, 1), laser_width)
	else:
		draw_circle(Vector2.ZERO, 4, Color(1, 0.8, 0.2))