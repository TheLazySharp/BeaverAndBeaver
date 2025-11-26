@tool
extends Control

const SPRITE_SIZE = Vector2(32,32)

@export var background_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: float = 64
@export var line_width: float = 5

@export var items : Array[WheelItems]
var slice_amount:= 6

var selection:=0
#var deadzone:= 0.2 
#var joy_rotation_speed:= 5.0
#var joy_target_angle: float

func _ready() -> void:
	pass
	
func _draw():
	var offset = SPRITE_SIZE * - 0.5
	draw_circle(Vector2.ZERO,outer_radius,background_color)
	draw_arc(Vector2.ZERO,inner_radius,0,TAU,50,line_color,line_width,true)
	
	for i in (items.size() - 1):
		var rads = TAU * i / (items.size() - 1)
		var point = Vector2.from_angle(rads)
		#print(i, " / ", rad_to_deg(rads))
		draw_line(point * inner_radius, point * outer_radius, line_color, line_width, true)
	
	#draw_texture_rect_region(items[0].atlas, Rect2(offset, SPRITE_SIZE), items[0].region)

	for i in range(1,items.size()):
		@warning_ignore("integer_division")
		var step = TAU / (items.size() - 1)
		var start_rads = step * (i - 1)
		var end_rads = start_rads + step
		var mid_rads = (start_rads + end_rads) * 0.5 * - 1
		var radius_mid = (inner_radius + outer_radius) * 0.5
		
		if selection == i :
			print(i," / ",selection," / ",rad_to_deg(start_rads) , " / ", rad_to_deg(end_rads))
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for j in (points_per_arc + 1):
				var angle = start_rads + j * (step) / points_per_arc
				points_inner.append(inner_radius * Vector2.from_angle(TAU - angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU - angle))
			
			points_outer.reverse()
			draw_polygon(points_inner + points_outer,PackedColorArray([highlight_color]))
		
		var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
		var item = items[i]
		draw_texture_rect_region(item.atlas, Rect2(draw_pos, SPRITE_SIZE), item.region)
	
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		#mouse_process()
	
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("open_obstacle_wheel"):
			self.show()
		joystick_process()
		queue_redraw()
		
		if Input.is_action_just_released("open_obstacle_wheel"):
			self.hide()
			

func joystick_process() -> void :
	if self.visible:
		var joystick := Input.get_vector("wheel_left","wheel_right","wheel_up","wheel_down")
		var dir := joystick.normalized()
		var angle = -fmod(dir.angle(), TAU)
		if angle <0:
			angle +=TAU
		selection = ceil((angle/TAU) * (items.size() - 1))
		print(selection)

func mouse_process() -> void:
	if self.visible:
		var mouse_pos = get_local_mouse_position()
		var mouse_radius = mouse_pos.length()
		
		if mouse_radius < inner_radius:
			selection = 0
		else:
			var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
			selection = round(ceil((mouse_rads / TAU) * (items.size() - 1)))
			print(selection)
