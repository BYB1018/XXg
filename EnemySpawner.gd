extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.0
@export var min_spawn_distance: float = 300.0
@export var max_spawn_distance: float = 400.0

var next_spawn_time: float = 0.0
var player: Node2D

func _ready():
    player = get_tree().get_first_node_in_group("player")

func _process(_delta):
    var current_time = Time.get_ticks_msec() / 1000.0
    if current_time >= next_spawn_time:
        spawn_enemy()
        next_spawn_time = current_time + spawn_interval

func spawn_enemy():
    if player == null:
        return
        
    # 在玩家周围随机位置生成敌人
    var angle = randf() * 2 * PI
    var distance = randf_range(min_spawn_distance, max_spawn_distance)
    var spawn_position = player.global_position + Vector2(
        cos(angle) * distance,
        sin(angle) * distance
    )
    
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
    enemy.global_position = spawn_position 