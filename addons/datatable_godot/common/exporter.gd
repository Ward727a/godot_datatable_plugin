extends _dt_common
class_name _dt_exporter
## Class that manage the exportation of the CSV, JSON, and resources inside the datatable

# ########################### #
# ###### CSV Functions ###### #
# ########################### #
static func _csv_convert_header(structure: Dictionary) -> Dictionary:

    var header: String = ""
    var headers: Array = []

    for param in structure['params']:
        header += param + ","
        headers.append(param)
    
    # remove last comma
    header = header.left(-1)

    return {"arr":headers, "str":header} # return both array and string

static func _csv_convert_lines(header: Array, data: Dictionary) -> String:
    
    var lines: String = ""

    for line in data['rows']:
        
        for key in header:

            if !data['rows'][line]['columns'].has(key):
                lines += ","
                continue
            
            var value = data['rows'][line]['columns'][key]['value']

            value = str(value).replace('"', '""')

            if value.contains(","):
                value = "\"" + value + "\""
            
            value += ","

            lines += value

        # remove last comma
        lines = lines.left(-1)

        lines += "\n"
    
    return lines

static func _csv_export(data: Dictionary, structure: Dictionary) -> String:
    
    var csv: String = ""
    
    var header = _csv_convert_header(structure)

    csv += header['str']
    csv += "\n"
    csv += _csv_convert_lines(header['arr'], data)
    
    return csv


# ################################ #
# ###### Resource Functions ###### #
# ################################ #

