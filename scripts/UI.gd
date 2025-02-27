extends CanvasLayer

@onready var health_label = $MarginContainer/VBoxContainer/HealthLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var exp_label = $MarginContainer/VBoxContainer/ExpLabel
@onready var upgrades_label = $MarginContainer/VBoxContainer/UpgradesLabel

var player: Node

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player:
		update_labels()

func update_labels():
	health_label.text = "Health: %d/%d" % [player.current_health, player.max_health]
	level_label.text = "Level: %d" % player.level
	exp_label.text = "EXP: %d/%d" % [player.current_exp, player.exp_to_next_level]
	upgrades_label.text = "Upgrades: %s" % get_upgrades_text()

func get_upgrades_text() -> String:
	var upgrades = player.obtained_upgrades
	if upgrades.size() == 0:
		return "None"
	return ", ".join(upgrades) 
