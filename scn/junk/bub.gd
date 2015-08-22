extends Sprite

export(float) var life = 10
export(float) var bscale = 2
export(float) var decay = 0.3


func _ready():
	set_fixed_process(true)
	set_scale(Vector2(bscale, bscale))
	
func _fixed_process(delta):
	var v = get_global_pos()
	life -= delta
	
	if(life <= 0 || v.y <= 0.5 || bscale < 0.2):
		self.queue_free()
		return
	bscale -= decay * delta
	set_scale(Vector2(bscale, bscale))

	v.x -= 10 * delta
	v.y -= 60 * delta
	if(v.y < 0):
		v.y = 0

	set_global_pos(v)


