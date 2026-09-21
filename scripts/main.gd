extends Control

enum GameState { RUNNING, JUDGING }
enum HandType { HEART, FOX, PEACE, OK, THUMBS_UP, OPEN, POINT }

const HAND_CHANGE_INTERVAL := 0.65
const RESULT_DURATION := 0.8
const HAND_FILES := ["heart", "fox", "peace", "ok", "thumbs_up", "open", "point"]
const HAND_NAMES := ["指ハート", "キツネ", "ピース", "OKサイン", "サムズアップ", "手のひら", "人差し指"]
const INK := Color("543b4b")
const ACCENT := Color("e85d80")
const MUTED := Color("927783")

var game_state := GameState.RUNNING
var current_hand := HandType.HEART
var previous_hand := -1
var score := 0
var switches_until_heart := 0
var rng := RandomNumberGenerator.new()
var textures: Array[Texture2D] = []
var hand_timer: Timer
var result_timer: Timer
var score_label: Label
var result_label: Label
var hand_label: Label
var hint_label: Label
var hand_sprite: TextureRect
var character: Control
var reset_button: Button
var body_layout: BoxContainer
var art_frame: AspectRatioContainer
var info_panel: PanelContainer
var motion: Tween
var browser_qa := false

func _ready() -> void:
	rng.randomize()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if OS.has_feature("web"):
		browser_qa = bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('qa') === '1'"))
	for file in HAND_FILES:
		var hand_texture := AtlasTexture.new()
		hand_texture.atlas = load("res://assets/art_v2/%s.png" % file)
		# Use the original fixed sleeve; crop generated cuffs from every hand layer.
		hand_texture.region = Rect2(0, 0, 1254, 900)
		textures.append(hand_texture)
	_build_ui()
	hand_timer = Timer.new()
	hand_timer.name = "HandTimer"
	hand_timer.wait_time = HAND_CHANGE_INTERVAL
	hand_timer.timeout.connect(_next_hand)
	add_child(hand_timer)
	result_timer = Timer.new()
	result_timer.name = "ResultTimer"
	result_timer.one_shot = true
	result_timer.wait_time = RESULT_DURATION
	result_timer.timeout.connect(_resume)
	add_child(result_timer)
	resized.connect(_layout)
	_layout()
	_next_hand()
	hand_timer.start()

func _label(text_value: String, font_size: int, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _style(color: Color, radius: int = 28) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style

func _texture(path: String) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = load(path)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect

func _build_ui() -> void:
	var game_theme := Theme.new()
	game_theme.default_font = preload("res://assets/fonts/NotoSansJP-Regular.otf")
	game_theme.default_font_size = 20
	theme = game_theme
	var background := ColorRect.new()
	background.color = Color("fff5f1")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	margin.add_child(stack)
	var top := HBoxContainer.new()
	stack.add_child(top)
	var eyebrow := _label("♥  FINGER HEART CHALLENGE", 15, ACCENT)
	eyebrow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top.add_child(eyebrow)
	reset_button = Button.new()
	reset_button.text = "RESET"
	reset_button.custom_minimum_size = Vector2(92, 48)
	reset_button.focus_mode = Control.FOCUS_NONE
	reset_button.add_theme_font_size_override("font_size", 16)
	reset_button.add_theme_color_override("font_color", MUTED)
	reset_button.add_theme_stylebox_override("normal", _style(Color("f4e5e3"), 24))
	reset_button.add_theme_stylebox_override("hover", _style(Color("f8d8df"), 24))
	reset_button.add_theme_stylebox_override("pressed", _style(Color("efcad4"), 24))
	reset_button.pressed.connect(reset_game)
	top.add_child(reset_button)
	stack.add_child(_label("畑島さんの\n指ハートチャレンジ", 30))
	stack.add_child(_label("ぴったり止めて、ハートを届けよう。", 18, MUTED))
	body_layout = BoxContainer.new()
	body_layout.add_theme_constant_override("separation", 24)
	body_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(body_layout)
	art_frame = AspectRatioContainer.new()
	art_frame.ratio = 1.0
	art_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_layout.add_child(art_frame)
	character = Control.new()
	character.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_frame.add_child(character)
	var woman := _texture("res://assets/art_v2/body.png")
	woman.name = "WomanBody"
	woman.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character.add_child(woman)
	hand_sprite = _texture("res://assets/art_v2/heart.png")
	hand_sprite.name = "HandSprite"
	# Match the wrist to the fixed sleeve opening in the 1254px body illustration.
	hand_sprite.anchor_left = 0.633
	hand_sprite.anchor_top = 0.280
	hand_sprite.anchor_right = 1.033
	hand_sprite.anchor_bottom = 0.280 + 0.4 * 900.0 / 1254.0
	character.add_child(hand_sprite)
	# The original cuff front covers the wrist edge for a seamless join.
	var cuff := _texture("res://assets/art_v2/body.png")
	var cuff_texture := AtlasTexture.new()
	cuff_texture.atlas = woman.texture
	cuff_texture.region = Rect2(975, 705, 185, 140)
	cuff.texture = cuff_texture
	cuff.anchor_left = 975.0 / 1254.0
	cuff.anchor_top = 705.0 / 1254.0
	cuff.anchor_right = 1160.0 / 1254.0
	cuff.anchor_bottom = 845.0 / 1254.0
	character.add_child(cuff)
	info_panel = PanelContainer.new()
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info_panel.add_theme_stylebox_override("panel", _style(Color("ffffff")))
	body_layout.add_child(info_panel)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 7)
	info_panel.add_child(info)
	score_label = _label("SCORE: 0", 34, ACCENT)
	info.add_child(score_label)
	var line := HSeparator.new()
	line.modulate = Color("ecdce1")
	info.add_child(line)
	result_label = _label("指ハートをねらって！", 24)
	info.add_child(result_label)
	hand_label = _label("", 18, MUTED)
	info.add_child(hand_label)
	hint_label = _label("この形でストップできたら +1", 17, MUTED)
	info.add_child(hint_label)
	hint_label.hide()
	var target_row := HBoxContainer.new()
	target_row.alignment = BoxContainer.ALIGNMENT_CENTER
	info.add_child(target_row)
	var target := _texture("res://assets/art_v2/heart.png")
	var target_crop := AtlasTexture.new()
	target_crop.atlas = load("res://assets/art_v2/heart.png")
	target_crop.region = Rect2(390, 160, 470, 740)
	target.texture = target_crop
	target.custom_minimum_size = Vector2(60, 60)
	target_row.add_child(target)
	var target_text := _label("親指と人差し指で\n小さなハート ♥", 17, ACCENT)
	target_row.add_child(target_text)
	var callout := PanelContainer.new()
	callout.add_theme_stylebox_override("panel", _style(ACCENT, 26))
	stack.add_child(callout)
	callout.add_child(_label("画面のどこでもタップでストップ！", 21, Color.WHITE))
	stack.add_child(_label("PC は ENTER / SPACE / クリックでも OK", 16, MUTED))
	stack.add_child(_label("失敗しても大丈夫。何度でもチャレンジ！", 15, MUTED))
	_ignore_layout_input(margin)

func _ignore_layout_input(node: Node) -> void:
	if node is Control and not node is Button:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_layout_input(child)

func _layout() -> void:
	if not is_instance_valid(body_layout):
		return
	var portrait := size.x < size.y * 1.15
	body_layout.vertical = portrait
	info_panel.size_flags_stretch_ratio = 0.8 if not portrait else 1.0
	info_panel.custom_minimum_size.x = 390.0 if not portrait else 0.0

func _next_hand() -> void:
	if game_state != GameState.RUNNING:
		return
	previous_hand = current_hand
	if switches_until_heart <= 0 and current_hand != HandType.HEART:
		current_hand = HandType.HEART
		switches_until_heart = rng.randi_range(2, 6)
	else:
		var candidates: Array[int] = []
		for hand in range(1, HAND_FILES.size()):
			if hand != current_hand:
				candidates.append(hand)
		current_hand = candidates[rng.randi_range(0, candidates.size() - 1)]
		switches_until_heart -= 1
	_refresh_hand()

func _refresh_hand() -> void:
	hand_sprite.texture = textures[current_hand]
	# Palm-facing poses must have the thumb on the viewer's right (her left hand).
	hand_sprite.flip_h = current_hand in [HandType.FOX, HandType.POINT]
	# Mirroring an off-center source wrist needs a matching horizontal correction.
	hand_sprite.anchor_left = 0.655 if hand_sprite.flip_h else 0.633
	hand_sprite.anchor_right = hand_sprite.anchor_left + 0.4
	hand_label.text = HAND_NAMES[current_hand]
	_publish_state()

# Read-only observations for browser tests; normal play has no JS polling or logging.
func _publish_state() -> void:
	if not browser_qa:
		return
	var button_rect := reset_button.get_global_rect()
	var state := {"state": game_state, "hand": current_hand, "score": score,
		"result": result_label.text, "width": size.x, "height": size.y,
		"reset": [button_rect.position.x, button_rect.position.y, button_rect.size.x, button_rect.size.y]}
	JavaScriptBridge.eval("window.__fingerHeart = " + JSON.stringify(state))

func _input(event: InputEvent) -> void:
	# Touch is handled before the Button consumes it; mouse uses Button.pressed.
	if event is InputEventScreenTouch and event.pressed:
		if reset_button.get_global_rect().has_point(event.position):
			reset_game()
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	var stop := event.is_action_pressed("stop_hand") and not event.is_echo()
	if event is InputEventMouseButton:
		stop = event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if event is InputEventScreenTouch:
		if event.pressed and reset_button.get_global_rect().has_point(event.position):
			reset_game()
			get_viewport().set_input_as_handled()
			return
		stop = event.pressed
	if stop:
		stop_hand()
		get_viewport().set_input_as_handled()

func stop_hand() -> void:
	if game_state != GameState.RUNNING:
		return
	game_state = GameState.JUDGING
	hand_timer.stop()
	var success := current_hand == HandType.HEART
	if success:
		score += 1
		result_label.text = "指ハート！ +1"
		result_label.add_theme_color_override("font_color", ACCENT)
		hint_label.text = "♥  やったね！  ♥"
	else:
		result_label.text = "ざんねん！"
		result_label.add_theme_color_override("font_color", INK)
		hint_label.text = "もう一度、ハートをねらおう"
	score_label.text = "SCORE: %d" % score
	if motion:
		motion.kill()
	character.pivot_offset = character.size * 0.5
	motion = create_tween()
	if success:
		motion.tween_property(character, "scale", Vector2(1.045, 1.045), 0.14).set_trans(Tween.TRANS_SINE)
		motion.tween_property(character, "scale", Vector2.ONE, 0.22)
	else:
		motion.tween_property(character, "rotation", -0.025, 0.08)
		motion.tween_property(character, "rotation", 0.025, 0.12)
		motion.tween_property(character, "rotation", 0.0, 0.12)
	result_timer.start()
	_publish_state()

func _resume() -> void:
	game_state = GameState.RUNNING
	result_label.text = "指ハートをねらって！"
	result_label.add_theme_color_override("font_color", INK)
	hint_label.text = "この形でストップできたら +1"
	_next_hand()
	hand_timer.start()

func reset_game() -> void:
	score = 0
	score_label.text = "SCORE: 0"
	result_timer.stop()
	if motion:
		motion.kill()
	character.scale = Vector2.ONE
	character.rotation = 0.0
	_resume()
