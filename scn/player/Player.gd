
extends RigidBody2D

var inTheAir = -1
var maxAccel = 100
var waterFriction = 10
var eSplash

func _ready():
	set_process(true)
	eSplash = load("res://scn/effects/splash.scn")
	

func _process(delta):
	# simple floating
	if(inTheAir != 0 && get_global_pos().y > 0):
		set_gravity_scale(0)
		set_friction(10)
		inTheAir = 0
		var v = get_linear_velocity()
		set_linear_velocity(Vector2(v.x, v.y / 2)) # hitting the water slows you down
		# Create spash effect
		if(abs(v.y) >= 50):
			print("Splash!")
			var s = eSplash.instance()
			s.show()
			s.set_global_pos(Vector2(get_global_pos().x, 10))
			get_parent().add_child(s)
		print("swimming mode")
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		set_gravity_scale(10)
		set_friction(1)
		inTheAir = 1
		print("flying mode")

	
	# rotate to face the mouse
	var p = self.get_global_pos()
	var g = get_global_mouse_pos()
	var dY = p.y - g.y
	var dX = g.x - p.x
	set_rot(deg2rad(atan2(dY, dX) * 180 / PI))

	

	# acceleration
	var v = get_linear_velocity()
	if(inTheAir == 0 && Input.get_mouse_button_mask() & 1):
		set_linear_velocity(Vector2(v.x + clamp(dX * delta, -maxAccel, maxAccel), v.y + clamp(-dY * delta, -maxAccel, maxAccel)))
	elif(inTheAir == 0): # water friction
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
	
	#print(get_linear_velocity())


