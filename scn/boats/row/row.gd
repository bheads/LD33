
extends RigidBody2D


var inTheAir = -1
var grav = 2
var eSplash
var eExploder
var sBox

export(float) var health = 30
var maxHealth

func _ready():
	eSplash = load("res://scn/effects/splash.scn")
	eExploder = load("res://scn/effects/expl1.scn")
	sBox = load("res://scn/floatsum/box1.scn")
	set_process(true)
	set_mass(1000)
	maxHealth = health
	get_node("Health").set_scale(Vector2(20 * (health / maxHealth), 0.4))

func _process(delta):
	var p = get_global_pos()
	var v = get_linear_velocity()
	
	# splash
	if(inTheAir != 0 && p.y > 0):
		inTheAir = 0
		if(abs(v.y) >= 100):
			var s = eSplash.instance()
			s.show()
			s.set_global_pos(Vector2(p.x, 10))
			get_tree().get_root().get_node("World").add_child(s)
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		inTheAir = 1


	if(p.y > 0.01):
		# in the water
		set_gravity_scale(-grav * 2)
		# slow down
		var nv = Vector2()
		var xFrict = max(abs(v.x / 3), 40)
		var yFrict = max(abs(v.y / 5), 40)
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
		if(-5 < v.y && v.y <= 5):
			nv.y = 0
		set_linear_velocity(nv) 
		
		# self righting
		var r = get_rot()
		var av = get_angular_velocity()
		
		if(-0.01 < av && av < 0.01):
			set_angular_velocity(0)
			if(r > 0):
				set_rot(max(r - 0.3 * delta, 0))
			elif(r < 0):
				set_rot(min(r + 0.3 * delta, 0))
		elif(av < 0):
			set_angular_velocity(min(av + 0.3 * delta, 0))
		elif(av > 0):
			set_angular_velocity(max(av - 0.3 * delta, 0))
			
		
	else:
		set_gravity_scale(grav)
		
func _integrate_forces(state):
	var lv = get_linear_velocity()
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		var v = state.get_contact_collider_velocity_at_pos(i)
		var dX = abs(lv.x - v.x)
		var dY = abs(lv.y - v.y)
		var f = (dX + dY) / 500
		print(f)
		if(f > 0.5):
			health -= f
			get_node("Health").set_scale(Vector2(20 * (health / maxHealth), 0.4))
			if(health <=0):
				var s = eExploder.instance()
				s.show()
				s.set_global_pos(get_global_pos())
				get_tree().get_root().get_node("World").add_child(s)
				
				for i in range(0, 1 + randi() % 4):
					spawnBox()
				
				self.queue_free()
				return
				
func spawnBox():
	var p = get_global_pos()

	var s = sBox.instance()
	s.show()
	s.set_global_pos(Vector2(p.x, p.y))
	get_tree().get_root().get_node("World").add_child(s)
