# Grid Battle

A tactical grid-based battle game built with Godot 4.6.

## Description

Grid Battle is a turn-based strategy game where players command units on a grid-based battlefield. Take turns moving units and attacking enemies to achieve victory.

## Features

- Turn-based tactical combat
- Grid-based movement system
- Multiple unit types
- AI opponent
- Health and damage system
- Victory/defeat conditions

## Controls

- **Mouse Click**: Select units and interact with UI
- **End Turn Button**: Complete your turn
- **ESC**: Pause/Unpause game

## How to Play

1. Player 1 (Blue) starts first
2. Click units to select them
3. Move units within their movement range
4. Attack enemies within attack range
5. End your turn
6. Defeat all enemy units to win

## Project Structure

```
Grid_Battle/
├── project.godot          # Main project configuration
├── scenes/               # Scene files (.tscn)
│   ├── main.tscn        # Main game scene
│   └── unit.tscn        # Unit scene
├── scripts/              # GDScript files (.gd)
│   ├── game_controller.gd
│   ├── grid_manager.gd
│   ├── unit.gd
│   ├── player.gd
│   ├── turn_manager.gd
│   └── ui_manager.gd
├── assets/               # Art, audio, and other assets
└── AGENTS.md             # Development guidelines
```

## Running the Game

```bash
# From the project directory
godot --path . --main-pack project.godot

# Or run specific scene
godot --path . scenes/main.tscn
```

## Development

This project follows the guidelines outlined in `AGENTS.md` for code style, testing, and development practices.