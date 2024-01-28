extends Area2D

const SPEED = 1000

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	print(0)
	
func _physics_process(delta: float) -> void:
	position += delta * Vector2.RIGHT.rotated(rotation) * SPEED
