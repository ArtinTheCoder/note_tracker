extends TextureRect

func _ready() -> void:
	self.pivot_offset = Vector2(350,160)

func _process(delta: float) -> void:
	self.rotation += 0.08
