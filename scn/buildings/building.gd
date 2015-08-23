
extends Area2D

var eExploder
var sBox

export(int) var health = 30
var maxHealth

export(int) var minLoot = 0
export(int) var maxLoot = 5

export(float) var hMeter = 100


func _ready():
	randomize()
	eExploder = load("res://scn/effects/expl1.scn")
	sBox = load("res://scn/floatsum/box1.scn")
	maxHealth = health
	get_node("HealthBG").set_scale(Vector2(20, 0.4))
	get_node("Health").set_scale(Vector2(20 * (health / maxHealth), 0.4))
	get_node("Health").set_pos(Vector2(0, -hMeter))
	get_node("HealthBG").set_pos(Vector2(0, -hMeter))

func _on_Area2D_body_enter( body ):
	if(body.is_in_group("player")):
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
				
				for i in range(minLoot, 1 + randi() % (maxLoot)):
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
