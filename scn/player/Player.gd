
extends RigidBody2D

var inTheAir = -1
var maxAccel = 100
var waterFriction = 10
var scale = 0.4
var eSplash
var eNom

var jBubble
var mOpen = false
var isRest = true
var fRight = true
var extents
var extentsMouth
var ezPos

func _ready():
	randomize()
	set_fixed_process(true)
	set_process_input(true)
	eSplash = load("res://scn/effects/splash.scn")
	eNom = load("res://scn/effects/nom.scn")
	jBubble = load("res://scn/junk/bub.scn")
	add_to_group("player")
	extents = get_shape(0).get_extents()
	extentsMouth = get_node("eat_zone").get_shape(0).get_extents()
	ezPos = get_node("eat_zone").get_pos()
	print("M: ", extentsMouth)
	updateSize()
	
func _input(ev):
	if(ev.type == InputEvent.KEY && ev.scancode == KEY_G):
		scale = clamp(scale + 0.05, 0.4, 2)
		updateSize()
	if(ev.type == InputEvent.KEY && ev.scancode == KEY_S):
		scale = clamp(scale - 0.05, 0.4, 2)
		updateSize()

func updateSize():
	get_node("open").set_scale(Vector2(scale, scale))
	get_node("closed").set_scale(Vector2(scale, scale))
	get_node("Camera2D").set_zoom(Vector2(clamp(scale * 2, 1.5, 4), clamp(scale * 2, 1.5, 4)))
	set_mass(scale * 1000)
	get_shape(0).set_extents(Vector2(extents.x * scale, extents.y * scale))
	var ez = get_node("eat_zone")
	ez.get_shape(0).set_extents(Vector2(extentsMouth.x * scale, extentsMouth.y * scale))
	ez.set_pos(Vector2(ezPos.x * scale, ezPos.y))
	
	
#func _draw():
	

func _fixed_process(delta):
	#update()
	# simple floating
	if(inTheAir != 0 && get_global_pos().y > 0):
		set_gravity_scale(0)
		set_friction(10)
		inTheAir = 0
		var v = get_linear_velocity()
		set_linear_velocity(Vector2(v.x, v.y / 2)) # hitting the water slows you down
		# Create spash effect
		if(abs(v.y) >= 50):
			#print("Splash!")
			var s = eSplash.instance()
			s.show()
			s.set_global_pos(Vector2(get_global_pos().x, 10))
			s.set_scale(Vector2(scale + 1, scale + 1))
			get_parent().add_child(s)
		#print("swimming mode")
	elif(inTheAir != 1 && get_global_pos().y <= 0):
		set_gravity_scale(10)
		set_friction(1)
		inTheAir = 1
		#print("flying mode")

	
	# rotate to face the mouse
	var p = self.get_global_pos()
	var g = get_global_mouse_pos()
	var dY = p.y - g.y
	var dX = g.x - p.x
	var angle = atan2(dY, dX) * 180 / PI
	while(angle > 360):
		angle -= 360;
	while(angle < 0):
		angle += 360
	set_rot(deg2rad(angle))
	
	if(90 < angle && angle < 270):
		if(fRight):
			fRight = false
			get_node("open").set_flip_v(true)
			get_node("closed").set_flip_v(true)
	else:
		if(!fRight):
			fRight = true
			get_node("open").set_flip_v(false)
			get_node("closed").set_flip_v(false)


	# mouth animation
	if(Input.get_mouse_button_mask() & 2):
		if(!mOpen):
			mOpen = true
			get_node("open").show()
			get_node("closed").hide()
	else:
		if(mOpen):
			mOpen = false
			get_node("open").hide()
			get_node("closed").show()



	# acceleration
	var v = get_linear_velocity()
	if(inTheAir == 0 && Input.get_mouse_button_mask() & 1):
		set_linear_velocity(Vector2(v.x + clamp(dX * delta, -maxAccel, maxAccel), v.y + clamp(-dY * delta, -maxAccel, maxAccel)))
	elif(inTheAir == 0): # water friction
		var nv = Vector2()
		var xFrict = max(abs(v.x * 0.95), 10)
		var yFrict = max(abs(v.y * 0.95), 10)
		if(1 < v.x):
			nv.x = v.x - (xFrict * delta)
		if(v.x < -1):
			nv.x = v.x + (xFrict * delta)
		if(-4 <= v.x && v.x <= 4):
			nv.x = 0
		
		if(1 < v.y):
			nv.y = v.y - (yFrict * delta)
		if(v.y < -1):
			nv.y = v.y + (yFrict * delta)
		if(-4 < v.y && v.y <= 4):
			nv.y = 0
		set_linear_velocity(nv) 
	
	if(inTheAir == 0):
		if(randf() * 1000 > 960):
			#print("Bubble time")
			var p = get_global_pos()
			var b = jBubble.instance()
			b.show()
			b.set_global_pos(p)
			b.bscale = scale
			b.decay = 0.2 * scale
			get_parent().add_child(b)

func _on_eat_zone_body_enter( body ):
	print(body)
	
	if(body.is_in_group("food") && Input.get_mouse_button_mask() & 2):
		var worth = 1.6 / 200
		if(body.is_in_group("big food")):
			worth *= 4
		# get points for eating
		scale = clamp(scale + worth, 0.4, 2)
		updateSize()
		# eating effect
		var s = eNom.instance()
		s.show()
		s.set_global_pos(get_global_pos())
		get_parent().add_child(s)
		body.queue_free()


func _integrate_forces(state):
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		if(obj.is_in_group("ammo")):
			var worth = 1.6 / 200
			scale = clamp(scale - worth, 0.4, 2)
			updateSize()



func debug():
	draw_rect(Rect2(-extents.x * scale, -extents.y * scale, 2 * (extents.x * scale), 2 * (extents.y * scale)), Color(1, 0, 0, 0.5))
	var p = get_node("eat_zone").get_pos()
	draw_rect(Rect2(p.x + -extentsMouth.x * scale, p.y + -extentsMouth.y * scale, 2 * (extentsMouth.x * scale), 2 * (extentsMouth.y * scale)), Color(0, 1, 0, 0.5))

#func _draw():
	#debug()
	
