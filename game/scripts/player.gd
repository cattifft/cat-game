extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ACTION
}

@export_category("stats")
@export var speed: int = 400
@onready var player: Sprite2D = $Sprite2D

var state: State = State.IDLE
var move_direction: Vector2 = Vector2.ZERO

# when scene tree loaded
@onready var animation_tree: AnimationTree = $AnimationTree
# I allow travel from one state to another! travel(node/state)
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

func _ready() -> void:
	animation_tree.set_active(true)

# called once per physics tick, with delta being elapsed time b/w ticks
func _physics_process(delta: float) -> void:
	movement_loop()
	
func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	# flip
	if state == State.IDLE or state == State.RUN:
		if move_direction.x < -0.01:
			player.flip_h = true
		elif move_direction.x > 0.01:
			player.flip_h = false
	
	# animation tree functionality
	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()

func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ACTION:
			animation_playback.travel("action")
