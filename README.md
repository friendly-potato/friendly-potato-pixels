# Friendly Potato Pixels
A pixel art tool plugin for Godot 3.4.2. Also available as a standalone tool.

## Installation

### Addon
1. Grab [FriendlyPotatoPixels_alpha_addon.zip](https://github.com/friendly-potato/friendly-potato-pixels/releases) from releases
2. Unzip the file
3. Place the folder in the addons directory
4. Enable the plugin in Godot

### Standalone
1. Grab the appropriate release from [releases](https://github.com/friendly-potato/friendly-potato-pixels/releases)
2. Unzip the file
3. Run the executable

## Usage

### Addon
Clicking on any png image in your filesystem dock will load it into the plugin. You can then start editing the image and save it all inside the Godot editor!

Creation of new images is also possible by clicking the "New" button in the bottom "Pixels" bar.

All editor controls are integrated, so undo/redo is integrated with the editor along with resource saving.

### Standalone
The plugin is also available as a standalone executable with the same controls.

## Planned enhancements
* [ ] DDA algorithm for filling in broken lines
* [ ] Better menu options
* [ ] Fill tool
* [ ] Line tool
* [ ] Actually implement pencil and smart brush tool

## Known bugs
* [ ] Drawing too quickly can cause the line draw to skip (related to DDA algorithm)
