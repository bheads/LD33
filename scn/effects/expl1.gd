
extends Node2D


var life = 0

func _ready():
	#print("starting: ", get_global_pos(), "  p: ", get_parent().get_name())
	get_child(0).set_emitting(true)
	#get_child(0).set_emit_timeout(get_child(0).get_lifetime())
	get_child(0).pre_process(1.95)
	set_process(true)


func _process(delta):
	life += delta
	if(life >= 1.0):
		print("removing")
		self.queue_free()
