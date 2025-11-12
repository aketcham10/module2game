extends Node2D


func _on_player_life_changed(value) -> void:
	$CanvasLayer/HUD.update_life(value)


func _on_player_died() -> void:
	$CanvasLayer/GameOver/Label.visible = true
