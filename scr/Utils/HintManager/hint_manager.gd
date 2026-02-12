extends Node
class_name HintManager

# Словарь подсказок: ключ - английское сокращение, значение - полный текст
var hints: Dictionary = {
	"shoot": "Чтобы стрелять, зажмите ЛКМ",
	"pickup_weapon": "Подойди и нажми E, чтобы подобрать оружие",
	"switch_weapon": "Смена оружие колёсиком мыши или Q",
	# Добавьте сюда другие подсказки по мере необходимости
}

# Ссылка на компонент HintLabel для отображения подсказок
var hint_label: Node = null

func _ready():
	pass

# Метод для установки ссылки на hint_label
func set_hint_label(label: Node) -> void:
	hint_label = label

# Метод для активации подсказки по ключу
# hint_key - английское сокращение подсказки из словаря hints
# duration - длительность отображения подсказки (по умолчанию 5.0 секунд)
func show_hint(hint_key: String, duration: float = 5.0) -> void:
	if not hint_label:
		push_error("HintManager: hint_label не установлен! Используйте set_hint_label() для установки ссылки.")
		return
	
	if not hints.has(hint_key):
		push_error("HintManager: Подсказка с ключом '" + hint_key + "' не найдена в словаре hints!")
		return
	
	var hint_text = hints[hint_key]
	hint_label.show_hint(hint_text, duration)

# Метод для добавления новой подсказки в словарь
func add_hint(key: String, text: String) -> void:
	hints[key] = text

# Метод для удаления подсказки из словаря
func remove_hint(key: String) -> void:
	if hints.has(key):
		hints.erase(key)

