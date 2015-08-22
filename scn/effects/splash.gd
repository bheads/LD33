
extends Node2D


func _ready():
	print("starting: ", get_global_pos(), "  p: ", get_parent().get_name())
	
	get_child(0).set_emit_timeout(get_child(0).get_lifetime())
	get_child(0).set_emitting(true)
	get_child(0).pre_process(3.9)
	
	get_child(1).set_emit_timeout(get_child(1).get_lifetime())
	get_child(1).set_emitting(true)
	get_child(1).pre_process(3.9)
	
	get_child(2).set_emit_timeout(get_child(2).get_lifetime())
	get_child(2).set_emitting(true)
	get_child(2).pre_process(4)
	
	get_child(3).start()

func _on_Timer_timeout():
	self.queue_free()
	print("removing")
