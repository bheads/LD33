
extends Node2D

var life = 3


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	life -= delta
	if(life <= 0):
		queue_free()


