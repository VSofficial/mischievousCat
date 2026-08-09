#extends CanvasLayer
#
#@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
#@onready var health_label: Label = $MarginContainer/VBoxContainer/Health
#
#func _ready():
	#update_health(50)  # Start at 50%
#
#func update_health(value: float):
	#health_bar.value = value
	#
	## Update label to show percentage
	#health_label.text = "Food: " + str(int(value)) + "%"
	#
	## Change color based on health level
	#if value > 66:
		#health_bar.modulate = Color(0.2, 1.0, 0.2)  # Green
	#elif value > 33:
		#health_bar.modulate = Color(1.0, 1.0, 0.2)  # Yellow
	#else:
		#health_bar.modulate = Color(1.0, 0.2, 0.2)  # Red

extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/Health

func _ready():
	update_health(50)

func update_health(value: float):
	if health_label:
		health_label.text = "Food: " + str(int(value)) + "%"
		
		# Color based on health
		if value > 66:
			health_label.add_theme_color_override("font_color", Color.GREEN)
		elif value > 33:
			health_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			health_label.add_theme_color_override("font_color", Color.RED)
