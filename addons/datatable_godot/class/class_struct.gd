extends Object
## This class is for the DataTable Plugin pre-generated structure class code.
## [br]I discourage you to delete it, but do as you want!
##
## @experimental
class_name Structure

func _get_dict(_structure: Dictionary):

    var _data: Dictionary = {}

    for i in get_property_list():
        if(i['name'].begins_with("_")):

            var _name: String = i['name'].substr(1, i['name'].length() - 1)
            var _var_name: String
            
            if _structure['params'].has(_name):
                if i['type'] == TYPE_OBJECT:
                    if get(i['name']) == null:
                        _data[_name] = "res://"
                    else:
                        if get(i['name']).get_class() == "Resource":
                                _data[_name] = get(i['name']).get_path()

                    continue
                _data[_name] = get(i['name'])
    return _data