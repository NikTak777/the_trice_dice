extends CanvasLayer

@onready var log_output: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var input_field: LineEdit = $PanelContainer/VBoxContainer/LineEdit

var commands = {}
var is_console_open: bool = false

var history: Array[String] = []
var history_index: int = -1

func _ready():
	log_output.custom_minimum_size = Vector2(600, 400)
	input_field.custom_minimum_size = Vector2(600, 30)
	$PanelContainer.position += Vector2(20, 110)
	
	toggle() # Скрывает консоль при старте
	
	# input_field.connect("text_submitted", Callable(self, "_on_command_entered"))

	_load_commands()
	
	input_field.gui_input.connect(_on_input_gui_input)
	
func _on_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		
		# Логика стрелок (история)
		if event.keycode == KEY_UP:
			_navigate_history(-1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			_navigate_history(1)
			get_viewport().set_input_as_handled()
			
		# НОВАЯ ЛОГИКА ДЛЯ ENTER
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			# 1. Сначала выполняем команду
			_on_command_entered(input_field.text)
			
			# 2. Говорим движку, что мы сами обработали эту кнопку.
			# Благодаря этому Godot НЕ будет выполнять стандартное действие "снять фокус".
			get_viewport().set_input_as_handled()
			
			# 3. На всякий случай обновляем фокус (хотя он и не должен был пропасть)
			input_field.grab_focus()

func _navigate_history(direction: int):
	if history.is_empty():
		return
		
	history_index = clampi(history_index + direction, 0, history.size())
	
	if history_index < history.size():
		input_field.text = history[history_index]
		# Устанавливаем каретку в конец текста
		input_field.caret_column = input_field.text.length()
	else:
		input_field.text = "" # Если спустились ниже самой последней команды

func toggle():
	visible = !visible
	Global.is_console_open = visible
	if visible:
		input_field.grab_focus()
	else:
		get_viewport().set_input_as_handled()

func register_command(name: String, cmd_object):
	commands[name] = cmd_object

func _load_commands() -> void:
	var CommandList = preload("res://scr/Utils/Console/command_list.gd")

	for full_path in CommandList.COMMANDS:
		var script = load(full_path)
		if script == null:
			push_warning("Не удалось загрузить команду: %s" % full_path)
			continue

		var cmd_script = script.new()
		if not cmd_script.has_method("get_name") or not cmd_script.has_method("execute"):
			push_warning("Файл %s не является корректной командой" % full_path)
			continue

		var cmd_name = cmd_script.get_name()
		register_command(cmd_name, cmd_script)
		print_to_console("[OK] Команда '%s' загружена" % cmd_name)

func _on_command_entered(command: String):
	var stripped_command = command.strip_edges()
	if stripped_command == "":
		return
		
	input_field.text = ""
	
	# Добавляем в историю (только если команда не дублирует предыдущую)
	if history.is_empty() or history.back() != stripped_command:
		history.append(stripped_command)
		
	# Сбрасываем индекс истории для следующего раза
	history_index = history.size()

	var parts: Array = Array(command.strip_edges().split(" "))
	var cmd = parts[0]
	var args: Array = parts.slice(1, parts.size()).filter(func(a): return str(a).strip_edges() != "")

	if commands.has(cmd):
		var cmd_script = commands[cmd]
		# Проверка аргументов
		if cmd_script.has_method("get_arg_count"):
			var expected_args = cmd_script.get_arg_count()
			if args.size() < expected_args:
				print_to_console("Ошибка: команда '%s' требует %d аргумент(ов), введено %d" % [cmd, expected_args, args.size()])
				return

		cmd_script.execute(args, self)
	else:
		print_to_console("Неизвестная команда: " + cmd)

func print_to_console(text: String):
	log_output.append_text(text + "\n")
