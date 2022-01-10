tool
class_name ResRef  extends Reference
####
# https://gist.github.com/cgbeutler/6901ee99b57390b5ab7bc0761f496c1c
# Settable in the editor. Hit reset to get a new obj. Tries to never be null.
# Cannot be changed once in-game if `p_set_once` is true.
####

#### EXAMPLE USAGE ####
#var __backer := ResRef.new(MyResource)
#export var my_res :Resource  setget set_my_res, get_my_res
#func set_my_res( value :MyResource ) -> void:  __backer.resource = value
#func get_my_res() -> MyResource:  return __backer.resource as MyResource


var __script :Script
var __set_once := false

var __resource :Resource = null
# warning-ignore:unused_class_variable
var resource :Resource  setget set_resource, get_resource
func set_resource( value :Resource ):
	# set it
	if Engine.editor_hint:
		__resource = value  if value != null else  __script.new()
		if __resource.has_method("get_json_serializer") or __resource.has_method("_load_from_json"):
			push_warning("Are you trying to set this to a JResource? Those are meant to only be used with/through FileResRef.")
	else:
		if __resource == value:  return
		assert( not __set_once or (__set_once and __resource == null), "Resource can only been set once in-game" )
		__resource = value
func get_resource() -> Resource:
	if __resource == null and Engine.editor_hint:  set_resource(__script.new())
	return __resource

func _init( p_script :Script, p_set_once := false ):
	__script = p_script
	__set_once = p_set_once
