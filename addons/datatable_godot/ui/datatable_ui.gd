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
@onready var bg_manageType: Panel = $MarginContainer/bg_manageType
@onready var bg_autoupdate: Panel = $MarginContainer/bg_autoupdate

@onready var version_statut: RichTextLabel = $MarginContainer/bg_main/Panel/VBoxContainer/HBoxContainer/HBoxContainer3/version_status

###############
## Functions ##
###############

func _ready():
	
	## We check if a new update is available or not
	_dt_updater.get_instance().check_update(version_statut)
	_dt_updater.get_instance().update_available.connect(_show_update_window)
	
	## By security we reset the visible state of the main window to true
	toggleMain()
	
	common.popup_alert_ask.connect(_signal_show_alert_popup)

func _disable_all_UI():
	bg_main.visible = false
	bg_newTable.visible = false
	bg_manageType.visible = false

#####################
## Signal Callable ##
#####################

func toggleMain():
	_disable_all_UI()
	bg_main.visible = true
	
	common.toggle_main_response.emit()

func toggleNewTable():
	_disable_all_UI()
	bg_newTable.visible = true
	
	common.toggle_newTable_response.emit()

func toggleManageType():
	_disable_all_UI()
	bg_manageType.visible = true
	
	common.toggle_manageType_response.emit()

func _signal_show_alert_popup(title: String, description: String):
	pop_alert_title.text = title
	pop_alert_description.text = description
	pop_alert_main.show()

func check_for_datatable_change():
	
	_dt_resource.get_instance().res_reload.emit()

func _show_update_window(next_v: String):
	bg_autoupdate.next_version = next_v
	bg_autoupdate.visible = true
