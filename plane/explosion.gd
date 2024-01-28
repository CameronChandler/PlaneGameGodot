extends Node2D

func _ready():
	$AnimatedSprite2D.play('explosion')
	$AnimatedSprite2D.animation_finished.connect(queue_free)
