# godot-yarn-importer
A Yarn Importer for Godot 3+

![Screenshot](https://i.imgur.com/WRtQUJl.png)

# Yarn

Based on:
- Yarn: https://github.com/InfiniteAmmoInc/Yarn

![Screenshot](https://i.imgur.com/OJ95pvr.png)

# GDScript

The focus of this is to provide a GDScript library that reads ".yarn.txt" files from Yarn, then imports it into a data structure useful for Godot developers.  Convienience functions and an example are included but the GUI portion of the import is up to *you*, the developer.  Whether you want basic 2D, animated 2D, 3D controls, or whatever, you are responsible for the look and feel and you must choose the components used to create the GUI. A basic vanilla dialog+choice GUI is provided only as an example.

There are some non-standard Yarn features such as in-text variables, running GDScript code from a node, a settings node, export to GDScript, and preliminary support for logical statements.

# Todo

- Support for Yarn Shortcut Options
- Improved Parsing of Code, Logic, Conditionals, and Math Operations

#  Wishlist / Ideas

- Ability to jump to another Yarn file
- Explicit Support for Multiple Characters
- Improve Demo with Advanced Dialog Widgets
- Improve GDScript Export Feature
