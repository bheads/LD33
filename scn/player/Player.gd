
extends RigidBody2D

var inTheAir = -1

func _ready():
	set_process(true)
	

func _process(delta):
	# simple floating
	if(inTheAir != 0 && get_global_pos().y > 0):
		set_gravity_scale(0.1)
		set_friction(4)
		inTheAir = 0
		print("swimming mode")
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		set_gravity_scale(3)
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
	if(inTheAir == 0 && Input.get_mouse_button_mask() & 1):
		var v = get_linear_velocity()
		set_linear_velocity(Vector2(v.x + dX * delta, v.y +  -dY * delta))


