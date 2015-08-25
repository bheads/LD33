
extends RigidBody2D

export(float) var life = 20

var eSplash
var eExploder
var inTheAir = -1

func _ready():
	add_to_group("ammo")
	set_fixed_process(true)
	eSplash = load("res://scn/effects/splash.scn")
	eExploder = load("res://scn/effects/expl1.scn")
	set_angular_velocity(1 + randf() * PI)

func _fixed_process(delta):
	var p = get_global_pos()
	var v = get_linear_velocity()
	life -= delta
	
	# kill self
	if(life <= 0):
		queue_free()
		return
		
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

	if(p.y <= 0):
		set_gravity_scale(0.4)
	else:
		set_gravity_scale(1.4)


func _integrate_forces(state):
	var lv = get_linear_velocity()
	for i in range(0, state.get_contact_count()):
		var obj = state.get_contact_collider_object(i)
		
		if(obj.is_in_group("boat")):
			continue
		
		var v = state.get_contact_collider_velocity_at_pos(i)
		var dX = abs(lv.x - v.x)
		var dY = abs(lv.y - v.y)
		var f = (dX + dY) / 500
		if(f > 0.3):
			var s = eExploder.instance()
			s.show()
			s.set_global_pos(get_global_pos())
			get_tree().get_root().get_node("World").add_child(s)
			self.queue_free()
			return

