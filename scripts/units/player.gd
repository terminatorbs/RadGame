extends CharacterBody3D


@onready var player_cam = $camera_rotation/camera_arm/player_camera
@onready var synchronizer = $mpsynchronizer
@export var player := 1 :
		set(id):
			player = id
#			$player_input.set_multiplayer_authority(id)

var playermodel_reference = null

#const speed = 10.0
const jump_velocity = 4.5

# targeting vars - NEEDS REWORK FOR MULTIPLAYER
var space_state
var unit_selectedtarget = null
var unit_mouseover_target = null
var interactables_in_range = []
var current_interact_target = null

# other
var esc_level = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#@onready var input = $player_input

#func _enter_tree() -> void:
#	# We need to set the authority before entering the tree, because by then,
#	# we already have started sending data.
#	if str(name).is_valid_int():
#		var id := str(name).to_int()
#		# Before ready, the variable `multiplayer_synchronizer` is not set yet
#		$mpsynchronizer.set_multiplayer_authority(id)

func _ready():
	print("player ready function")
	# REWORK ALL
	# TODO: read save file
#	if multiplayer.is_server():
#		ready_server()
#	if not synchronizer.is_multiplayer_authority():
#		return
#	ready_authority()
#	if multiplayer.is_server():
#		set_model("res://scenes/units/knight_scene.tscn",multiplayer.get_unique_id())
#	else:
#		rpc_id(1,"set_model","res://scenes/units/knight_scene.tscn",multiplayer.get_unique_id())
	# load spell scenes
	# load_spell_scenes()
	# a bit of hackyhack
	# load persistent ui features
#	Autoload.player_ui_main_reference.load_persistent()
#	Autoload.player_ui_main_reference.get_node("ui_persistent").playerframe_initialize()
#	Autoload.player_ui_main_reference.get_node("ui_persistent").actionbars_initialize()
	# load spell scenes
#	load_spell_scenes()
#	# a bit of hackyhackfraudyfraud to test spells, assignment will implemented later
#	$spells/spell_10.actionbar.append(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_1"))
#	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_1").\
#						assign_actionbar($spells.get_node("spell_10"))
#	$spells/spell_12.actionbar.append(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_2"))
#	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_2").\
#						assign_actionbar($spells.get_node("spell_12"))
#	$spells/spell_11.actionbar.append(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_3"))
#	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_3").\
#						assign_actionbar($spells.get_node("spell_11"))
#	$spells/spell_13.actionbar.append(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_4"))
#	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_4").\
#						assign_actionbar($spells.get_node("spell_13"))
#	$spells/spell_14.actionbar.append(Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_5"))
#	Autoload.player_ui_main_reference.get_node("ui_persistent").get_node("actionbars").get_node("actionbar1").get_node("actionbar1_5").\
#						assign_actionbar($spells.get_node("spell_14"))

#func ready_server():
#	# ready function for the server
#	initialize_base_unit("player","0")

func ready_authority():
	# ready function for the multiplayer authority
	Autoload.player_reference = self
	player_cam.set_current(true)

func _input(event):
	if not synchronizer.is_multiplayer_authority():
		return
	if event.is_action_pressed("escape") and esc_level == 0:
		Autoload.player_ui_main_reference.esc_menu()
	if event.is_action_pressed("interact"):
		if current_interact_target != null:
			current_interact_target.interaction_start(self.name)

func _unhandled_input(event):
	#targeting
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("re-implement targeting ray in player script")
#		# targeting ray
#		var result = targetray(event.position)
#		targeting(result)

func _process(_delta):
	# resource regen
#	if stats_curr["resource_regen"] != 0:
#		stats_curr["resource_current"] = max(min(stats_curr["resource_current"]+stats_curr["resource_regen"]*delta,stats_curr["resource_max"]),0)
	# interaction target sorting
	if interactables_in_range.size() > 0:
		var distance = 10000.
		var distance_new = 0.
		var old_interactable = null
		if is_instance_valid(current_interact_target):
			old_interactable = current_interact_target
		for interactable_nearby in interactables_in_range:
			distance_new = self.global_position.distance_to(interactable_nearby.global_position)
			if distance_new < distance:
				distance = distance_new
				current_interact_target = interactable_nearby
		if not old_interactable == current_interact_target:
			if is_instance_valid(old_interactable):
				old_interactable.hide_interact_popup()
		current_interact_target.show_interact_popup()

func _physics_process(delta):
	# dumb test hotfix
	self.position = Vector3.ZERO
	print(self.position)
	# targeting ray
	space_state = get_world_3d().direct_space_state
	if not synchronizer.is_multiplayer_authority(): 
		return
#	handle_movement(delta)

#func handle_movement(delta):
#	# jumping
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Jump")
#		velocity.y = jump_velocity
#	if not is_on_floor():
#		velocity.y -= gravity * delta
#	# movement
#	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
#	# unrotated direction vector
#	var direction_ur = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	# rotate direction vector using camera angle
#	var direction = Vector3(cos(-$camera_rotation.rotation.y)*direction_ur.x - sin(-$camera_rotation.rotation.y)*direction_ur.z, 0, \
#							sin(-$camera_rotation.rotation.y)*direction_ur.x + cos(-$camera_rotation.rotation.y)*direction_ur.z)
#	if direction:
#		velocity.x = direction.x * stats.stats_current.speed
#		velocity.z = direction.z * stats.stats_current.speed
#	else:
#		velocity.x = move_toward(velocity.x, 0, stats.stats_current.speed)
#		velocity.z = move_toward(velocity.z, 0, stats.stats_current.speed)
#	# turn character to match movement direction
#	if direction != Vector3.ZERO:
#		$pivot.look_at(position + direction, Vector3.UP)
#	if velocity == Vector3.ZERO:
#		is_moving = false
#		# animation
#		if Autoload.playermodel_reference != null:
#			Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Idle")
#	else:
#		is_moving = true
#		# animation
#		if Autoload.playermodel_reference != null:
#				Autoload.playermodel_reference.get_node("AnimationPlayer").play("KayKit Animated Character|Run")
#	move_and_slide()
	###################
	### NEW
#	# falling
#	if not is_on_floor():
#		velocity.y -= gravity * delta
#	# jumping
#	if input.jumping and is_on_floor():
#		velocity.y = jump_velocity
#	input.jumping = false
#	# movement
#	var direction = (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized()
#	move_and_slide()
#	if direction:
#		velocity.x = direction.x * stats.stats_current.speed
#		velocity.z = direction.z * stats.stats_current.speed
#	else:
#		velocity.x = move_toward(velocity.x, 0, stats.stats_current.speed)
#		velocity.z = move_toward(velocity.z, 0, stats.stats_current.speed)

## set player model
#@rpc("any_peer")
#func set_model(model_name,peer_id):
#	var playernode = $/root/main/players.find_child(str(peer_id),true,false)
#	if playernode.get_child(0).get_child_count() > 0:
#		for node in playernode.get_child(0).get_children():
#			node.queue_free()
#	var model = load(model_name).instantiate()
#	playernode.get_child(0).add_child(model,true)
	
###################################################################################################
# target ray
func targetray(eventposition):
	var origin = player_cam
	var from = origin.project_ray_origin(eventposition)
	var to = from + origin.project_ray_normal(eventposition) * 1000
	var query = PhysicsRayQueryParameters3D.create(from,to)
	var result = space_state.intersect_ray(query)
	return result
	
#func targeting(result) -> void:
#	# unset target and return if no collider is hit (like when clicking the sky)
#	if not result.has("collider"):
#		unit_selectedtarget = null
#		Autoload.player_ui_main_reference.targetframe_remove()
#		return
#	# set target if player, npc or hostile is hit by ray
#	if result.collider.is_in_group("playergroup") or result.collider.is_in_group("npcgroup_targetable") or\
#	result.collider.is_in_group("hostilegroup_targetable"):
#		unit_selectedtarget = result.collider
#		Autoload.player_ui_main_reference.targetframe_initialize()
#	# unset target if no valid target is hit by ray
#	else:
#		unit_selectedtarget = null
#		Autoload.player_ui_main_reference.targetframe_remove()
###################################################################################################
# set up spells, auras, absorbs
#func sort_absorbs():
#	pass
###################################################################################################
# get spell target
#func get_spell_target(spell):
#	var spell_target = null
#	var ray_result = null
#	# set target to either mouseovered unit frame or ray collider
#	if unit_mouseover_target != null:
#		spell_target = unit_mouseover_target
#	else:
#		ray_result = targetray(get_viewport().get_mouse_position())
#		# check if target ray result has a collider, and check if collider is a valid result
#		if ray_result.has("collider") and (ray_result.collider.is_in_group("playergroup") or \
#			ray_result.collider.is_in_group("npcgroup_targetable") or\
#			ray_result.collider.is_in_group("hostilegroup_targetable")):
#				spell_target = ray_result.collider
#	# check legality of mouseover target
#	if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#		# illegal mouseover target, set target to selected target
#		spell_target = unit_selectedtarget
#		# check legality of selected target
#		if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#			# illegal selected target as well, cannot use spell, so return
#			return "no_legal_target"
#	# return legal target
#	return spell_target
#
## check target and send combat event from action bar
#func send_combat_event(spell) -> void:
#	var spell_target = null
#	var ray_result = null
#	# set target to either mouseovered unit frame or ray collider
#	if unit_mouseover_target != null:
#		spell_target = unit_mouseover_target
#	else:
#		ray_result = targetray(get_viewport().get_mouse_position())
#		# check if target ray result has a collider, and check if collider is a valid result
#		if ray_result.has("collider") and (ray_result.collider.is_in_group("playergroup") or \
#			ray_result.collider.is_in_group("npcgroup_targetable") or\
#			ray_result.collider.is_in_group("hostilegroup_targetable")):
#				spell_target = ray_result.collider
#	# check legality of mouseover target
#	if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#		# illegal mouseover target, set target to selected target
#		spell_target = unit_selectedtarget
#		# check legality of selected target
#		if spell_target == null or not spell_target.is_in_group(spell["targetgroup"]):
#			# illegal selected target as well, cannot use spell, so return
#			return
#	# legal target found, either from mouseover or selected, so send combat event
#	Combat.combat_event(spell,self,spell_target)
