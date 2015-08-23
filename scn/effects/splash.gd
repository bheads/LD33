
extends Node2D

var life = 8

func _ready():
	#print("starting: ", get_global_pos(), "  p: ", get_parent().get_name())
	
	get_child(0).set_emit_timeout(get_child(0).get_lifetime())
	get_child(0).set_emitting(true)
	get_child(0).pre_process(3.9)
	
	get_child(1).set_emit_timeout(get_child(1).get_lifetime())
	get_child(1).set_emitting(true)
	get_child(1).pre_process(3.9)
	
	get_child(2).set_emit_timeout(get_child(2).get_lifetime())
	get_child(2).set_emitting(true)
	get_child(2).pre_process(4)
	
	var v = get_node("SamplePlayer2D").play("splash", false)
	get_node("SamplePlayer2D").voice_set_volume_scale_db(v, 0.1)
	set_fixed_process(true)

func _fixed_process(delta):
	life -= delta
	if(life <= 0):
		self.queue_free()
		print("removing")
