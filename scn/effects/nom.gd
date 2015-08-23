
extends Node2D

var life = 5


func _ready():
	get_node("Particles2D").pre_process(2.9)
	set_fixed_process(true)


func _fixed_process(delta):
	life -= delta
	if(life <= 0):
		queue_free()


