
extends RigidBody2D

var inTheAir = -1
var grav = 2
var eSplash
var eExploder
export(float) var inv = 3

func _ready():
	randomize()
	var divSprite = get_node("Sprite").get_texture().get_height()/16
	get_node("Sprite").set_region_rect(Rect2(0,16*(randi()%divSprite),16,16))
	set_fixed_process(true)
	set_mass(100 + randf() * 190)
	eSplash = load("res://scn/effects/splash.scn")
	eExploder = load("res://scn/effects/expl1.scn")
	add_to_group("food")
	add_to_group("big food")
	# find a way to scale the splash
	
	
func _fixed_process(delta):
	var p = get_global_pos()
	var v = get_linear_velocity()
	
	# count down till this box can be destryed
	if(inv > 0):
		inv -= delta
	
	# splash
	if(inTheAir != 0 && p.y > 0):
		inTheAir = 0
		if(abs(v.y) >= 100):
			var s = eSplash.instance()
			s.show()
			s.set_global_pos(Vector2(p.x, 10))
			s.set_scale(Vector2(0.5, 0.5))
			get_tree().get_root().get_node("World").add_child(s)
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		inTheAir = 1

	if(p.y > 0.001):
		# in the water
		set_gravity_scale(-grav * 2)
		# slow down
		var nv = Vector2()
		var xFrict = max(abs(v.x / 3), 10)
		var yFrict = max(abs(v.y / 2), 10)
		if(1 < v.x):
			nv.x = v.x - (xFrict * delta)
		if(v.x < -1):
			nv.x = v.x + (xFrict * delta)
		if(-1 <= v.x && v.x <= 1):
			nv.x = 0
		
		if(1 < v.y):
			nv.y = v.y - (yFrict * delta)
		if(v.y < -1):
			nv.y = v.y + (yFrict * delta)
		if(-1 < v.y && v.y <= 1):
			nv.y = 0
		set_linear_velocity(nv) 
	else:
		set_gravity_scale(grav)


func _integrate_forces(state):
	# skip till timer ticks down	
	if(inv >= 0):
		return

	var lv = get_linear_velocity()
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		var v = state.get_contact_collider_velocity_at_pos(i)
		var dX = abs(lv.x - v.x)
		var dY = abs(lv.y - v.y)
		var f = (dX + dY) / 500

		if(f > 1.5):
			var s = eExploder.instance()
			s.show()
			s.set_global_pos(get_global_pos())
			get_tree().get_root().get_node("World").add_child(s)
			self.queue_free()
			return
