class_name Interactable extends Area3D

signal on_interact()

@export var action_text: String

@export var game_event: GameEvent

enum GameEvent {
    NONE,
    SLEEP,
    EXIT
}

func interact():
    on_interact.emit()