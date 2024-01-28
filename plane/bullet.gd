extends Area2D

func _ready():
	print('_ready()')
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print(0)
