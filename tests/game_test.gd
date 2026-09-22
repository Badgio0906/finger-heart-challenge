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
	check(seen.size() == 7 and game.textures.size() == 7, "Seven poses loaded and drawn")
	check(game.clear_texture != null and game.failure_texture != null, "Ending illustrations loaded")
	for hand in range(1, 7):
		game.reset_game()
		game.current_hand = hand
		game.stop_hand()
		check(game.game_state == game.GameState.FAILED and game.score == 0, "Every wrong pose ends run")
		check(game.end_title.text == "Failure" and game.end_art.texture == game.failure_texture, "Failure presentation")
		check(game.end_message.text == "指ハートマスターへの道は遠い", "Failure message")
		check(game.hand_timer.is_stopped() and game.result_timer.is_stopped(), "Failure timers stopped")
		game._resume()
		game.stop_hand()
		game._next_hand()
		check(game.game_state == game.GameState.FAILED and game.current_hand == hand, "Failure cannot auto resume")
	game.reset_game()
	for success in range(1, 26):
		game.hand_timer.stop()
		game.current_hand = game.HandType.HEART
		game.stop_hand()
		check(game.score == success, "Success counted once")
		game.stop_hand()
		check(game.score == success, "Rapid input ignored")
		if success < 25:
			check(game.game_state == game.GameState.JUDGING, "Success pauses for result")
			game.result_timer.stop()
			game._resume()
			check(game.stage == success / 5, "Advance only at five-success boundary")
			check(is_equal_approx(game.hand_timer.wait_time, game.STAGE_INTERVALS[success / 5]), "Stage interval applied")
	check(game.game_state == game.GameState.CLEARED and game.stage == 4, "25 successes clear five stages")
	check(game.end_title.text == "Clear" and game.end_art.texture == game.clear_texture, "Clear presentation")
	check(game.end_message.text == "これであなたも指ハートマスター", "Clear message")
	check(game.end_screen.visible and not game.game_content.visible, "Result screen replaces gameplay")
	check(game.hand_timer.is_stopped() and game.result_timer.is_stopped(), "Clear timers stopped")
	game._resume()
	game.stop_hand()
	await create_timer(0.9).timeout
	check(game.game_state == game.GameState.CLEARED and game.score == 25, "Clear persists")
	game.reset_game()
	check(game.stage == 0 and game.score == 0 and is_equal_approx(game.hand_timer.wait_time, 0.65), "Retry resets speed and progress")
	check(not game.end_screen.visible and game.game_content.visible, "Retry restores game")
	for key in [KEY_ENTER, KEY_SPACE]:
		game.reset_game()
		game.current_hand = game.HandType.HEART
		var event := InputEventKey.new()
		event.physical_keycode = key
		event.pressed = true
		game._unhandled_input(event)
		check(game.game_state == game.GameState.JUDGING, "Keyboard input")
		game.reset_game()
		event.echo = true
		game._unhandled_input(event)
		check(game.game_state == game.GameState.RUNNING, "Key repeat ignored")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	game.current_hand = game.HandType.HEART
	game._unhandled_input(click)
	check(game.game_state == game.GameState.JUDGING, "Mouse input")
	game.reset_game()
	game.current_hand = game.HandType.HEART
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(100, 400)
	game._unhandled_input(touch)
	check(game.game_state == game.GameState.JUDGING, "Touch input")
	touch.position = game.reset_button.get_global_rect().get_center()
	game._input(touch)
	check(game.score == 0 and game.game_state == game.GameState.RUNNING, "Touch RESET does not judge")
	check(game.result_timer.is_stopped(), "Reset cancels pending result")
	check(game.character.scale == Vector2.ONE and game.character.rotation == 0.0, "Reset clears animation")
	game.hand_timer.stop()
	game.current_hand = game.HandType.HEART
	game.stop_hand()
	await create_timer(0.9).timeout
	check(game.game_state == game.GameState.RUNNING and not game.hand_timer.is_stopped(), "Real result timer resumes")
	print("GAME TEST: %d checks, %d failures" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
