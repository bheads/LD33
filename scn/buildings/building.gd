
extends Area2D

var eExploder
var sBox
var sAmmo
var sRow
var sScooner

export(int) var health
var maxHealth

export(int) var minLoot
export(int) var maxLoot

export(float) var hMeter

export(float) var fireTime = 8
var fireTime_o

export(float) var rowSpawner = 0
var rowSpawner_o = 0
export(float) var scoonerSpawner = 0
var scoonerSpawner_o = 0
export(Vector2) var spawnOffset = Vector2(0, 0)


func _ready():
	randomize()
	eExploder = load("res://scn/effects/expl1.scn")
	sBox = load("res://scn/floatsum/box1.scn")
	sAmmo = load("res://scn/ammo/cannon.scn")
	sRow = load("res://scn/boats/row_boat.scn")
	sScooner = load("res://scn/boats/scooner.scn")
	
	maxHealth = health
	get_node("HealthBG").set_scale(Vector2(20, 0.4))
	get_node("Health").set_scale(Vector2(20 * (health / maxHealth), 0.4))
	get_node("Health").set_pos(Vector2(0, -hMeter))
	get_node("HealthBG").set_pos(Vector2(0, -hMeter))
	fireTime_o = fireTime
	rowSpawner_o = rowSpawner
	scoonerSpawner_o = scoonerSpawner
	set_fixed_process(true)
	
func _fixed_process(delta):
	var p = get_global_pos()

	fireTime -= delta
	if(fireTime_o > 0 && fireTime <=0):
		fire()
		
	scoonerSpawner -= delta
	if(scoonerSpawner_o > 0 && scoonerSpawner <=0):
		scoonerSpawner = scoonerSpawner_o
		var s = sScooner.instance()
		s.show()
		s.set_global_pos(Vector2(p.x + spawnOffset.x, p.y + spawnOffset.y))
		get_tree().get_root().get_node("World").add_child(s)
	
	rowSpawner -= delta
	if(rowSpawner_o > 0 && rowSpawner <=0):
		rowSpawner = rowSpawner_o
		var s = sRow.instance()
		s.show()
		s.set_global_pos(Vector2(p.x + spawnOffset.x, p.y + spawnOffset.y))
		get_tree().get_root().get_node("World").add_child(s)
		
func fire():
	if(fireTime_o<=0):
		return
		
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

func _body_enter( body ):
	hit(body)
	
func _on_Area2D_body_enter( body ):
	hit(body)

func hit(body):
	if(body.is_in_group("player")):
		print("player hit me!")
		var v = body.get_linear_velocity()
		var dX = abs(v.x)
		var dY = abs(v.y)
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
				
				for i in range(minLoot, rand_range(minLoot, maxLoot)):
					spawnBox()
				
				get_parent().queue_free()
				return

func spawnBox():
	randomize()
	var p = get_global_pos()
	var s = sBox.instance()
	s.show()
	s.set_global_pos(Vector2(p.x, p.y - 50))
	get_tree().get_root().get_node("World").add_child(s)
