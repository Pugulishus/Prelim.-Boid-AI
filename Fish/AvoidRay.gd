extends RayCast3D

signal collision(index, detection)
# Called when the node enters the scene tree for the first time.
func _ready():
	collision.connect(Callable(get_node("../.."), "ray_collision"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		collision.emit(int(String(name)), true)
