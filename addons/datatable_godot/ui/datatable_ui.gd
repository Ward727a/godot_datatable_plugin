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

@onready var http_request: HTTPRequest = $HTTPRequest

@onready var version_statut: RichTextLabel = $MarginContainer/bg_main/Panel/VBoxContainer/HBoxContainer/HBoxContainer3/version_status

const UPDATE_URL: String = "https://api.github.com/repos/Ward727a/godot_datatable_plugin/releases"

var checking_update: bool = false

const check_update_text: String = "[img]res://addons/datatable_godot/icons/Reload.png[/img] Checking for update... "
const up_to_date_text: String = "[img]res://addons/datatable_godot/icons/StatusSuccess.png[/img] [color=lightgreen]Version up-to-date! "
const update_available_text: String = "[img]res://addons/datatable_godot/icons/StatusError.png[/img] [color=#ff768b]An update is available! "
const cant_check_text: String = "[img]res://addons/datatable_godot/icons/StatusWarning.png[/img] [color=ffde66]Couldn't check for update! "

const check_update_tip: String = "The plugin is check for an update..."
const up_to_date_tip: String = "You good to go, you got the last version available!"
const update_available_tip: String = "A new update is available, please update it!"
const cant_check_tip: String = "The plugin couldn't check if an update was available due to an unknown error. Check it manually please!"

const LOCAL_CONFIG_PATH: String = "res://addons/datatable_godot/plugin.cfg"


###############
## Functions ##
###############

func _ready():
	
	## We check if a new update is available or not
	_dt_updater.get_instance().check_update()
	
	## By security we reset the visible state of the main window to true
	_signal_toggleMain()
	
	## Connect each asking signal for the toggle on/off of UI main window
	common.toggle_main_ask.connect(_signal_toggleMain)
	common.toggle_newTable_ask.connect(_signal_toggleNewTable)
	common.toggle_manageType_ask.connect(_signal_toggleManageType)
	common.popup_alert_ask.connect(_signal_show_alert_popup)

func _disable_all_UI():
	bg_main.visible = false
	bg_newTable.visible = false
	bg_manageType.visible = false

#####################
## Signal Callable ##
#####################

func _signal_toggleMain():
	_disable_all_UI()
	bg_main.visible = true
	
	common.toggle_main_response.emit()

func _signal_toggleNewTable():
	_disable_all_UI()
	bg_newTable.visible = true
	
	common.toggle_newTable_response.emit()

func _signal_toggleManageType():
	_disable_all_UI()
	bg_manageType.visible = true
	
	common.toggle_manageType_response.emit()

func _signal_show_alert_popup(title: String, description: String):
	pop_alert_title.text = title
	pop_alert_description.text = description
	pop_alert_main.show()

func check_for_datatable_change():
	
	_dt_resource.get_instance().res_reload.emit()

func _show_update_window():
	bg_autoupdate.visible = true
