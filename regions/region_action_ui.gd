extends PanelContainer
class_name RegionActionUI

@export var btn: Button

var action_type: Types.REGION_ACTION_TYPE = Types.REGION_ACTION_TYPE.NONE

func _ready():
	btn.pressed.connect(_on_action_btn_pressed)

func _on_action_btn_pressed():
	UIState.current_region_action = action_type
