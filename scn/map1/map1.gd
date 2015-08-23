
extends Node2D


func _ready():
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	pass
	
func _draw():
	# draw sky
	draw_rect(Rect2(-100000, -200000, 200000, 200000), Color(0.527,0.807,0.98))
	
	
	#draw water layers

	
	

