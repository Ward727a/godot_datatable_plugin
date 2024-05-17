@tool
extends Control

## import common
@onready var common:Node = %signals

## Popup components - Alert
@onready var pop_alert_main: Popup = $alert
@onready var pop_alert_title: Label = $alert/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/alert_title
@onready var pop_alert_description: RichTextLabel = $alert/Panel/MarginContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/alert_text

## UI Components - Background
@onready var bg_main: VBoxContainer = $MarginContainer/bg_main
@onready var bg_newTable: Panel = $MarginContainer/bg_newTable
@onready var bg_help: Panel = $MarginContainer/bg_help
@onready var bg_manageType: Panel = $MarginContainer/bg_manageType

###############
## Functions ##
###############

func _ready():
	## By security we reset the visible state of the main window to true
	bg_main.visible = true
	
	## Connect each asking signal for the toggle on/off of UI main window
	common.toggle_main_ask.connect(_signal_toggleMain)
	common.toggle_newTable_ask.connect(_signal_toggleNewTable)
	common.toggle_help_ask.connect(_signal_toggleHelp)
	common.toggle_manageType_ask.connect(_signal_toggleManageType)
	common.popup_alert_ask.connect(_signal_show_alert_popup)

#####################
## Signal Callable ##
#####################

func _signal_toggleMain():
	bg_main.visible = true
	bg_newTable.visible = false
	bg_help.visible = false
	bg_manageType.visible = false
	
	common.toggle_main_response.emit()

func _signal_toggleNewTable():
	bg_main.visible = false
	bg_newTable.visible = true
	bg_help.visible = false
	bg_manageType.visible = false
	
	common.toggle_newTable_response.emit()

func _signal_toggleManageType():
	bg_main.visible = false
	bg_newTable.visible = false
	bg_help.visible = false
	bg_manageType.visible = true
	
	common.toggle_manageType_response.emit()

func _signal_toggleHelp():
	bg_main.visible = false
	bg_newTable.visible = false
	bg_help.visible = true
	bg_manageType.visible = false
	
	common.toggle_help_response.emit()

func _signal_show_alert_popup(title: String, description: String):
	pop_alert_title.text = title
	pop_alert_description.text = description
	pop_alert_main.show()
