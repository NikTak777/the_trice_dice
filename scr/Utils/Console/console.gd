extends CanvasLayer

@onready var log_output: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var input_field: LineEdit = $PanelContainer/VBoxContainer/LineEdit

var commands = {}
var is_console_open: bool = false

func _ready():
	log_output.custom_minimum_size = Vector2(600, 400)
	input_field.custom_minimum_size = Vector2(600, 30)
	$PanelContainer.position += Vector2(20, 110)
	
	toggle() # Скрывает консоль при старте
	
	input_field.connect("text_submitted", Callable(self, "_on_command_entered"))

	_load_commands()

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
	if command.strip_edges() == "":
		return

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

	input_field.text = ""

func print_to_console(text: String):
	log_output.append_text(text + "\n")
