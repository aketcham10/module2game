extends CharacterBody2D

@export var gravity = 750
@export var run_speed = 300
@export var jump_speed = -800
var default_run_speed = run_speed
var life = 3: set = set_life
signal died
signal life_changed
enum {IDLE, RUN, JUMP, HURT, DEAD, DUCK}
var state = IDLE

func set_life(value):
	life = value
	life_changed.emit(life)
	if life <= 0:
		change_state(DEAD)

func get_input():
	var right = Input.is_action_pressed("right")
	var left = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("jump")
	var down = Input.is_action_pressed("duck")
	velocity.x = 0
	if right:
		velocity.x += run_speed
		$Sprite2D.flip_h = false
	if left:
		velocity.x -= run_speed
		$Sprite2D.flip_h = true
	if jump and is_on_floor():
		change_state(JUMP)
		velocity.y = jump_speed
	if down:
		change_state(DUCK)
	if state == IDLE and velocity.x != 0:
		change_state(RUN)
	if state == RUN and velocity.x == 0:
		change_state(IDLE)
	if state in [IDLE, RUN] and !is_on_floor():
		change_state(JUMP)
		
	
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		RUN:
			$AnimationPlayer.play("run")
			run_speed = default_run_speed
		HURT:
			velocity.y = -200
			velocity.x = -300 * sign(velocity.x)
			life -= 1
			await get_tree().create_timer(1.5).timeout
			print('done')
			change_state(IDLE)
		JUMP:
			$AnimationPlayer.play("jump")
			run_speed = default_run_speed
		DUCK:
			$AnimationPlayer.play('duck')
		DEAD:
			died.emit()
			hide()
			
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	if state != DEAD:
		get_input()
		move_and_slide()
	#print(state)
	if state == HURT:
		print('fart')
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("enemies") && state != HURT:
			if position.y < collision.get_collider().position.y - 15:
				collision.get_collider().take_damage()
				velocity.y = -200
			else:
				print('im in')
				change_state(HURT)
	velocity.y += gravity * delta
	if state == JUMP and is_on_floor():
		change_state(IDLE)
	if position.y > 5000 || position.y < -5000:
		change_state(DEAD)
		
