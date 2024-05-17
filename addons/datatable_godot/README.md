## Datatable Plugin for Godot
### What is it?
This is a plugin that allow you to create a datatable like Unreal Engine has, in Godot.
- You create a "structure"
- Then you create a table that will use that structure
- You populate this table with your data
- Finally you use the singleton provided to use these data

I created this plugin because I come from UE, and I really like the datatable system of UE, but I didn't found this in godot.

### I don't have X type!
Yes, for now the type that you can use in your structure is limited, you can use:
- String
- Int
- Float
- Color
- Vec2
- Vec3
- Vec4

Other type will come with futur update, but please say what you want as type, it could really help me know what is needed!

### I want to create a array of item in my structure, how can I do that?
You can't for now, I will work on it because I found it really usefull, but for now you need to wait.

### Where are saved my table / structure?
Your "data" (table and/or structure) are saved in a file located at the root folder of your project, the file is named "datatable.res" and it's a PackedDataContainer.

### Can I move the "datatable.res" file?
For now, no, if you move it, the datatable plugin will create a new one, and you can lose your data, and finally the singleton will not know where to find the file.

### Can I use this plugin in C# ?
I don't really know if it's working in C# because I don't use Godot C# system (I have it installed on my computer and it's this editor that I use, but I don't use C#). All I can say is that I created the system in GDScript, and if someone want to create the C# system for the plugin, I would be really happy to help him if needed!😃

### How to use the data that I created in my script?
For this, you need to check inside the file "singleton.gd", you can search in the doc inside your editor and search for "get_table", it should return you to the documentation of the singleton.

## FYI
This is my first plugin for Godot, so I probably made some error here and there, do not hesitate to say it! :)
