extends AnimationPlayer

var queue: Array = []

func play_queued(name: String, custom_speed: float = 1.0, custom_blend: float = -1, backward: bool = false):
	if is_playing():
		queue.push_back({"name": name, "custom_speed": custom_speed, "custom_blend": custom_blend, "backward": backward})
	else:
		play(name, custom_speed, custom_blend, backward)

func _process(delta):
	if not is_playing() and queue.size() > 0:
		var args = queue.front()
		play(args.name, args.custom_speed, args.custom_blend, args.backward)
		queue.pop_front()
