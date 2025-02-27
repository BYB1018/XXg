extends CharacterBody2D

@export var move_speed: float = 150.0
@export var max_health: float = 50.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var experience_value: float = 10.0

var current_health: float
var player: Node2D
var last_attack_time: float = 0.0

func _ready():
    current_health = max_health
    player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
    if player == null:
        return
        
    # 移动向玩家
    var direction = global_position.direction_to(player.global_position)
    velocity = direction * move_speed
    move_and_slide()

func _on_hitbox_body_entered(body):
    if body.is_in_group("player"):
        var current_time = Time.get_ticks_msec() / 1000.0
        if current_time >= last_attack_time + attack_cooldown:
            last_attack_time = current_time
            body.take_damage(damage)

func take_damage(damage: float):
    current_health -= damage
    if current_health <= 0:
        die()

func die():
    # TODO: 生成经验值
    queue_free() 