extends Control

# Кнопка включения/выключения полноэкранного режима
@onready var fullscreen_check: Button = $VBoxContainer/FullScreenSelector/FullScreenCheckBox

# Кнопки переключения сложности
@onready var left_arrow: Button = $VBoxContainer/DifficultySelector/LeftArrow
@onready var right_arrow: Button = $VBoxContainer/DifficultySelector/RightArrow
@onready var difficulty_label: Label = $VBoxContainer/DifficultySelector/DifficultyLabel

# Слайдер громкости и его подпись
@onready var volume_label: Label = $VBoxContainer/VolumeSelector/VolumeLabel
@onready var volume_slider: HSlider = $VBoxContainer/VolumeSelector/VolumeSlider

# Кнопка, возвращающая в меню
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready():
	
	# Подключение сигналов кнопок
	back_button.pressed.connect(_on_back_button_pressed)
	left_arrow.pressed.connect(_on_left_pressed)
	right_arrow.pressed.connect(_on_right_pressed)
	
	# Настройка кнопок смены сложности
	left_arrow.custom_minimum_size = Vector2(147, 75)  # Ширина 147 = 150 - 3(Отступ между элементами)
	right_arrow.custom_minimum_size = Vector2(147, 75)
	left_arrow.text = "◀"
	right_arrow.text = "▶"

	# Настройка лейбла сложности
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	difficulty_label.custom_minimum_size = Vector2(150, 75)
	
	# Настройка кнопки "Назад"
	back_button.custom_minimum_size = Vector2(450, 75)

	update_label()

	# Настройка слайдера и подписи громкости
	volume_slider.custom_minimum_size = Vector2(275, 30)
	volume_label.add_theme_color_override("font_color", Color(1, 1, 1))
	volume_label.custom_minimum_size = Vector2(150, 30)
	
	# Настройка кнопки полноэкранного режима
	fullscreen_check.toggle_mode = true
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	fullscreen_check.toggled.connect(_on_fullscreen_check_toggled)
	fullscreen_check.custom_minimum_size = Vector2(450, 75)
	
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
	difficulty_label.text = SettingsManager.get_current_difficulty().capitalize()
	
# Логика переключения полноэкранного режима
func _on_fullscreen_check_toggled(button_pressed: bool):
	SettingsManager.fullscreen = button_pressed
	SettingsManager.apply_settings()

# Закрытие меню
func _on_back_button_pressed():
	queue_free()
