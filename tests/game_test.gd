extends SceneTree

var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(description)

func run() -> void:
	var game = load("res://scenes/Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.game_state == game.GameState.RUNNING, "Starts immediately")
	check(not game.hand_timer.is_stopped(), "Timer starts")
	game.hand_timer.stop()
	var seen := {}
	var last_heart := -1
	for index in range(10000):
		var previous: int = game.current_hand
		game._next_hand()
		check(game.current_hand != previous, "No repeated poses")
		seen[game.current_hand] = true
		if game.current_hand == game.HandType.HEART:
			if last_heart >= 0:
				check(index - last_heart >= 3 and index - last_heart <= 7, "Heart interval 3..7")
			last_heart = index
	check(seen.size() == 7, "All seven poses appear")
	check(game.textures.size() == 7, "All seven assets loaded")
	for hand in range(7):
		game.game_state = game.GameState.RUNNING
		game.current_hand = hand
		game._refresh_hand()
		var before: int = game.score
		game.stop_hand()
		check(game.score == before + (1 if hand == 0 else 0), "Only heart earns a point")
		check(game.game_state == game.GameState.JUDGING, "Judging state")
		check(game.hand_timer.is_stopped(), "Pose frozen")
		var frozen: int = game.current_hand
		game._next_hand()
		check(game.current_hand == frozen, "Cannot switch in judging")
		for repeat in range(10):
			game.stop_hand()
		check(game.score == before + (1 if hand == 0 else 0), "Rapid input ignored")
		game.result_timer.stop()
		game._resume()
		check(game.game_state == game.GameState.RUNNING, "Resumes")
		game.hand_timer.stop()
	for key in [KEY_ENTER, KEY_SPACE]:
		game.game_state = game.GameState.RUNNING
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.pressed = true
		game._unhandled_input(event)
		check(game.game_state == game.GameState.JUDGING, "Keyboard input")
		game.result_timer.stop()
		game._resume()
		var echo := InputEventKey.new()
		echo.physical_keycode = key
		echo.pressed = true
		echo.echo = true
		game._unhandled_input(echo)
		check(game.game_state == game.GameState.RUNNING, "Key repeat ignored")
		game.hand_timer.stop()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game._unhandled_input(click)
	check(game.game_state == game.GameState.JUDGING, "Mouse input")
	game.reset_game()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100, 400)
	game._unhandled_input(touch)
	check(game.game_state == game.GameState.JUDGING, "Touch input")
	game.score = 99
	touch.position = game.reset_button.get_global_rect().get_center()
	game._input(touch)
	check(game.score == 0 and game.game_state == game.GameState.RUNNING, "Touch RESET does not judge")
	check(game.result_timer.is_stopped(), "Reset cancels pending result")
	check(game.character.scale == Vector2.ONE and game.character.rotation == 0.0, "Reset clears animation")
	game.hand_timer.stop()
	game.current_hand = game.HandType.HEART
	game.stop_hand()
	await create_timer(0.9).timeout
	check(game.game_state == game.GameState.RUNNING, "Actual result timer resumes")
	check(not game.hand_timer.is_stopped(), "Actual hand timer resumes")
	print("GAME TEST: %d checks, %d failures" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
