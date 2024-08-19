class_name DebugWindow extends CanvasLayer

@export var table_container: Control

var data: Dictionary = {}
var grids: Dictionary = {}
var grid_labels: Dictionary = {}
func create_table(title: String, info: Dictionary) -> Callable:
	if not info or info.is_empty(): return Callable()

	data[title] = info
	var con: PanelContainer = PanelContainer.new()
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	con.add_child(grid)
	grids[title] = grid

	var labels: Dictionary = {}
	grid_labels[title] = labels

	for key: String in info.keys():
		var key_label: Label = Label.new()
		var value_label: Label = Label.new()

		grid.add_child(key_label)
		grid.add_child(value_label)
		labels[key] = {"key": key_label, "value": value_label}
		

	var update_table: Callable = \
		func() -> void:
			for key: String in info.keys():
				labels[key]["key"].text = key
				labels[key]["value"].text = str(info[key])


	update_table.call()
	
	table_container.add_child(con)

	print(get_children())

	return update_table
