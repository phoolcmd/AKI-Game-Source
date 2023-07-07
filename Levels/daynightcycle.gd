extends CanvasModulate
@export var gradient : GradientTexture2D

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY


signal time_tick(day : int, hour: int, minute : int)
var time : float = 0.0
var past_minute : float  = -1.0

func _process(delta: float) -> void:
	time += delta
	var value = (sin(time - PI / 2) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)
	_recalculate_time()
	
func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var  day = int(total_minutes / MINUTES_PER_DAY)

	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day,hour,minute)
