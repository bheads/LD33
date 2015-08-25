
extends Node2D


export(int, "RowBoat", "Scooner") var boat_type

var eSplash
var eExploder
var sBox
var sAmmo


var inTheAir = -1
var grav = 2
var mass
var health
var maxHealth
export(float) var speed = 50
export(float) var maxspeed = 1000
export(int, "Left","Right") var direction
export(float) var timeToFlip = 8
var timeToFlip_o

export(float) var fireTime = 8
var fireTime_o

export(Vector2) var hitLoot = Vector2(0, 1)
export(Vector2) var hitSpawn = Vector2(0, -20)


func _ready():
	randomize()
	add_to_group("boat")
	eSplash = load("res://scn/effects/splash.scn")
	eExploder = load("res://scn/effects/expl1.scn")
	sBox = load("res://scn/floatsum/box1.scn")
	sAmmo = load("res://scn/ammo/cannon.scn")

	timeToFlip_o = timeToFlip
	fireTime_o = fireTime
	
	set_fixed_process(true)
	print(get_shape_count())
		# create the boat object to display and use
	var height = 0
	if(boat_type==0):
		health = 12
		mass = 600
		height= 30
	else:
		health = 30
		height = 140
		mass = 3000

	set_mass(mass)
	maxHealth = health
	get_node("HealthBG").set_scale(Vector2(20, 0.4))
	get_node("Health").set_scale(Vector2(20 * (health / maxHealth), 0.4))
	get_node("Health").set_pos(Vector2(0, -height))
	get_node("HealthBG").set_pos(Vector2(0, -height))
	
func _fixed_process(delta):
	timeToFlip -= delta
	var p = get_global_pos()
	var v = get_linear_velocity()

	if(direction==0):
		get_child(0).set_flip_h(true)
		speed = -abs(speed)
	else:
		get_child(0).set_flip_h(false)
		speed = abs(speed)
	
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

	
	if(p.y >= 0.00):
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
		
		if(p.y < 18):
			nv.x = clamp(nv.x + (speed * delta), -maxspeed, maxspeed)
			
		if(timeToFlip <= 0):
			timeToFlip = timeToFlip_o
			direction = (direction + 1) % 2
		
		set_linear_velocity(nv) 
	else:
		set_gravity_scale(grav)
	
	fireTime -= delta
	if(fireTime <=0):
		fire()
		
func fire():
	fireTime = fireTime_o
	var p = get_global_pos()
	var s = sAmmo.instance()
	s.show()
	s.set_global_pos(Vector2(p.x, p.y))
	s.set_linear_velocity(Vector2(rand_range(200, 1000), rand_range(-45, -100)))
	get_tree().get_root().get_node("World").add_child(s)
	
	
	var s2 = sAmmo.instance()
	s2.show()
	s2.set_global_pos(Vector2(p.x, p.y))
	s2.set_linear_velocity(Vector2(-rand_range(200, 1000), rand_range(-45, -100)))
	get_tree().get_root().get_node("World").add_child(s2)


func _integrate_forces(state):
	var lv = get_linear_velocity()
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		if(obj.is_in_group("ammo")):
			continue
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
				
				for i in range(0, rand_range(0, 5)):
					spawnBox()
				
				self.queue_free()
				return
			elif(f > 1):
				for i in range(hitLoot.x, rand_range(hitLoot.x, hitLoot.y)):
					spawnBox()
				
func spawnBox():
	randomize()
	var p = get_global_pos()
	var s = sBox.instance()
	s.show()
	s.get_child(0).set_linear_velocity(Vector2(rand_range(-4, 4), rand_range(-5, -50)))
	s.set_global_pos(Vector2(hitSpawn.x + p.x, p.y + hitSpawn.y))
	get_tree().get_root().get_node("World").add_child(s)