extends CharacterBody2D

@export var move_speed: float = 300.0
@export var max_health: float = 100.0

var current_health: float

func _ready():
	current_health = max_health

func _physics_process(_delta):
	# 获取输入
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("ui_left", "ui_right")
	input_direction.y = Input.get_axis("ui_up", "ui_down")
	input_direction = input_direction.normalized()
	
	# 设置速度和移动
	velocity = input_direction * move_speed
	move_and_slide()

func take_damage(damage: float):
	current_health -= damage
	if current_health <= 0:
		die()

func die():
	# TODO: 实现游戏结束逻辑
	queue_free() 
