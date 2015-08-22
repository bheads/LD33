
extends RigidBody2D

var inTheAir = -1
var grav = 5
var eSplash
var eExploder

func _ready():
	set_process(true)
	set_mass(10 + randf() * 190)
	eSplash = load("res://scn/effects/splash.scn")
	eExploder = load("res://scn/effects/expl1.scn")
	# find a way to scale the splash
	# todo: set the image to one of several random box type floatsum
	
	
func _process(delta):
	var p = get_global_pos()
	var v = get_linear_velocity()
	
	# splash
	if(inTheAir != 0 && p.y > 0):
		inTheAir = 0
		if(abs(v.y) >= 50):
			var s = eSplash.instance()
			s.show()
			s.set_global_pos(Vector2(p.x, 10))
			get_tree().get_root().get_node("World").add_child(s)
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		inTheAir = 1

	if(p.y > 0.001):
		# in the water
		set_gravity_scale(-grav)
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
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		var v = state.get_contact_collider_velocity_at_pos(i)
		var v2 = v - get_linear_velocity()
		var f = (abs(v2.x) + abs(v2.y)) * get_mass()
		if(f > 50000):
			var s = eExploder.instance()
			s.show()
			s.set_global_pos(get_global_pos())
			get_tree().get_root().get_node("World").add_child(s)
			self.queue_free()
			return
