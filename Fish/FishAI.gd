extends CharacterBody3D

@export var seek_area : Vector3 = Vector3(100,5,100)
@export var scare_speed : float = 15.0
@export var straight_speed : float = 10.0
@export var avoid_speed : float = 5.0

var speed : float = 5.0
var dead : bool = false
var direction : Vector3 = Vector3.FORWARD
var scare_cooldown : int = 0
var goal_location : Vector3 = Vector3(0,0,0)
var goal_direction : Vector3 = Vector3(0,0,0)


func damaged():
	dead = true

func object_avoidance():
	var avoidance_offset : Vector3 = Vector3(0,0,0)
	if $RayBundle/Forward/Down.is_colliding():
		speed = avoid_speed
		avoidance_offset.y = lerpf(avoidance_offset.y, 1.5, .01)
	elif $RayBundle/Mid/Down.is_colliding():
		speed = avoid_speed *1.25
		avoidance_offset.y = lerpf(avoidance_offset.y, .5, .01)
	elif $RayBundle/Forward/Up.is_colliding():
		speed = avoid_speed
		avoidance_offset.y = lerpf(avoidance_offset.y, -1.5, .01)
	elif $RayBundle/Mid/Up.is_colliding():
		speed = avoid_speed *1.25
		avoidance_offset.y = lerpf(avoidance_offset.y, -.5, .01)
	
	if $RayBundle/Forward/Left.is_colliding():
		speed = avoid_speed
		avoidance_offset.x = lerpf(avoidance_offset.x, -1.5, .01)
	elif $RayBundle/Mid/Up.is_colliding():
		speed = avoid_speed *1.25
		avoidance_offset.x = lerpf(avoidance_offset.x, -.5, .01)
	elif $RayBundle/Forward/Right.is_colliding():
		speed = avoid_speed
		avoidance_offset.x = lerpf(avoidance_offset.x, 1.5, .01)
	elif $RayBundle/Mid/Right.is_colliding():
		speed = avoid_speed *1.25
		avoidance_offset.x = lerpf(avoidance_offset.x, .5, .01)
	return avoidance_offset

func get_goal_location():
	if snapped(goal_location-global_position, Vector3(3,3,3)).is_zero_approx():
		return Vector3(randf_range(global_position.x-seek_area.x, global_position.x+seek_area.x), randf_range(global_position.y-seek_area.y, global_position.y+seek_area.y), randf_range(global_position.z-seek_area.z, global_position.z+seek_area.z))
		
	return goal_location

func _physics_process(delta):
	##logic
	
	if scare_cooldown > 0:
		scare_cooldown - 1
		print(scare_cooldown)
	
	if dead:
		velocity = lerp(velocity, Vector3.DOWN, .01)
		move_and_slide()
	
	else:
		if $RayBundle/DetectArea.has_overlapping_bodies():
			scare_cooldown = 200
			var seen_bodies : Array = $RayBundle/DetectArea.get_overlapping_bodies()
			var detect_body = seen_bodies.pop_back()
			if detect_body.name == "Low_Poly_Player":
				direction = global_position - detect_body.global_position
				goal_location=global_position
		
		##if scared
		if scare_cooldown > 0:
			scare_cooldown = scare_cooldown - 1
			speed = scare_speed
			object_avoidance()
		
		else:
			goal_location = get_goal_location()
			goal_direction = goal_location-global_position
			
			$Location_Ray.global_position = goal_location
			if $Location_Ray.is_colliding():
				goal_location = global_position
				goal_location = get_goal_location()
				print("changed")
			
			
			
			direction = lerp(direction, goal_direction.normalized(), .009) + object_avoidance()
			speed = lerpf(speed, straight_speed, .01)
		
		look_at(-direction + global_position,Vector3.UP)
		velocity = direction.normalized() * speed
		move_and_slide()
