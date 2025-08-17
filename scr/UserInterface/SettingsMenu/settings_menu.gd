extends Control

# Кнопка включения/выключения полноэкранного режима
@onready var fullscreen_check: Button = $VBoxContainer/FullScreenSelector/FullScreenCheckBox
@onready var fullscreen_label: Label = $VBoxContainer/FullScreenSelector/FullScreenLabel

# Кнопки переключения сложности
@onready var left_arrow: Button = $VBoxContainer/DifficultySelector/LeftArrow
@onready var right_arrow: Button = $VBoxContainer/DifficultySelector/RightArrow
@onready var difficulty_mode: Label = $VBoxContainer/DifficultySelector/DifficultyMode
@onready var difficulty_label: Label = $VBoxContainer/DifficultySelector/DifficultyLabel

# Слайдер громкости и его подпись
@onready var volume_label: Label = $VBoxContainer/VolumeSelector/VolumeLabel
@onready var volume_slider: HSlider = $VBoxContainer/VolumeSelector/VolumeSlider

# Кнопка, возвращающая в меню
@onready var back_button: Button = $VBoxContainer/BackButtonContainer/BackButton

func _ready():
	
	# Подключение сигналов кнопок
	back_button.pressed.connect(_on_back_button_pressed)
	left_arrow.pressed.connect(_on_left_pressed)
	right_arrow.pressed.connect(_on_right_pressed)
	
	# Настройка кнопок смены сложности
	left_arrow.custom_minimum_size = Vector2(77, 75)  # Ширина 77 = 80 - 3(Отступ между элементами)
	right_arrow.custom_minimum_size = Vector2(77, 75)
	left_arrow.text = "◀"
	right_arrow.text = "▶"

	# Настройка лейбла сложности
	difficulty_mode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_mode.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	difficulty_mode.custom_minimum_size = Vector2(150, 75)
	difficulty_label.custom_minimum_size = Vector2(137, 75)
	
	# Настройка кнопки "Назад"
	back_button.custom_minimum_size = Vector2(450, 75)

	update_label()

	# Настройка слайдера и подписи громкости
	volume_slider.custom_minimum_size = Vector2(300, 30)
	volume_label.add_theme_color_override("font_color", Color(1, 1, 1))
	volume_label.custom_minimum_size = Vector2(125, 30)
	
	# Настройка кнопки полноэкранного режима
	fullscreen_check.toggle_mode = true
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	fullscreen_check.toggled.connect(_on_fullscreen_check_toggled)
	fullscreen_check.custom_minimum_size = Vector2(197, 75)
	fullscreen_label.custom_minimum_size = Vector2(250, 75)
	fullscreen_check.text = "On" if SettingsManager.fullscreen else "Off"
	
	
	# Обновляем текст сложности при запуске
	update_label()
	
# Логика смены сложности
func _on_left_pressed(): # Уменьшение уровня сложности
	SettingsManager.decrease_difficulty() 
	update_label()

func _on_right_pressed(): # Увеличение уровня сложности
	SettingsManager.increase_difficulty()
	update_label()

# Обновление отображаемого уровня сложности
func update_label():
	difficulty_mode.text = SettingsManager.get_current_difficulty().capitalize()
	
# Логика переключения полноэкранного режима
func _on_fullscreen_check_toggled(button_pressed: bool):
	SettingsManager.fullscreen = button_pressed
	SettingsManager.apply_settings()
	
	if button_pressed:
		fullscreen_check.text = "On"
	else:
		fullscreen_check.text = "Off"

# Закрытие меню
func _on_back_button_pressed():
	queue_free()
