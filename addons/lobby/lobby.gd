class_name _Lobby extends Node
## This is the 'lobby' code meant to be accessed as an autoload.
## It handles the networking setup, game hosting and joining, and player info.

# In game signals
## Emitted when a player connects, or for each other player when you connect, with their ID and player info.
signal player_connected(peer_id: int, client_info: Dictionary)
## Emitted when a player disconnects, with their ID.
signal player_disconnected(peer_id: int)
## Emitted when the server disconnects.
signal server_disconnected

# Setup signals
## Emitted when the network setup is completed, with an error code.
signal network_setup_completed(error: int)
## Emitted when we finish (or fail) connecting to a server, with a bool for success.
signal connected_to_server(error: bool)

## Emitted when a new icon is selected via open_icon_select().
signal icon_selected(icon: ImageTexture)


# The client_info of all connected players in the game, by their peer ID.
var players := {}

# The player info of the local player.
# Modifying this to add variables during gameplay is fine, but only variables defined in the
# default client info in project settings will be saved and loaded.
# Default variables should never be removed.
@onready var client_info = _default_client_info


# details to use when connecting or hosting.
# Should be changed by a lobby scene of some kind.
# Defaults are in the project settings.
var port: int = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["port"])

var address: String = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["address"])

var max_connections: int = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["max_players"])

# Max values for player icons.
var icon_dim: int = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["icon_dim"])

# Whether to use UPNP to forward the port.
var use_upnp: bool = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["upnp"])

# Path to save the user's data to.
var _data_path: String = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["data_path"]):
	get: return ("user://%s" % _data_path) if _data_path else "" # Only return the full path if a relative one is set.

# Whether to save the user's data in a file, and to load on startup.
var _save_data: bool = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["data"]):
	get: return _save_data if _data_path else false # Only sets if a path is set.

# Path to save the user's data to.
var _default_client_info: Dictionary = ProjectSettings.get_setting(_proj_sett["root"] + _proj_sett["user_data"])


# Names for the project settings.
const _proj_sett: Dictionary = {
	"root" = "psprite_games/lobby/",
	"address" = "default_address",
	"port" = "default_port",
	"max_players" = "max_player_connections",
	"icon_dim" = "icon_dimensions",
	"upnp" = "use_upnp",
	"data_path" = "data_path",
	"data" = "save_data",
	"user_data" = "default_client_data"
}


# Instance of UPNP for easy porting, and somewhere to store a thread to set it up on.
var _upnp = UPNP.new()
var _upnp_thread: Thread
var _upnp_used: bool = false


# When the server decides to start the game from a UI scene.
@rpc("authority", "call_local", "reliable")
func load_game(game_scene_path: String) -> void:
	get_tree().change_scene_to_file(game_scene_path)


## Call to configure and host a game.
func create_game() -> void:
	if use_upnp:
		_upnp_thread = Thread.new()
		_upnp_thread.start(network_config.bind(true))
	else:
		_network_setup_completed(0)


## Sets up UPNP for port forwarding, and then starts the game. Should be called on a thread.\n
## network_setup_completed will be emitted with an error code if something goes wrong, or 0 if it succeeds.
func network_config(start: bool) -> void:
	_upnp_used = true
	var error_discover = _upnp.discover()
	if error_discover:
		printerr("Ran into error while discovering UPNP: " + str(error_discover))
		call_thread_safe("_network_setup_completed", error_discover)
		return

	if !_upnp.get_gateway() or !_upnp.get_gateway().is_valid_gateway():
		printerr("Unknown error while setting up UPNP.")
		call_thread_safe("_network_setup_completed", 28)
		return

	var error_addport = _upnp.add_port_mapping(port, port, "Godot Pong", "UDP")
	if error_addport:
		printerr("Ran into error while adding port mapping: " + str(error_addport))
		call_thread_safe("_network_setup_completed", error_addport)
		return

	call_thread_safe("_network_setup_completed", 0)


## Connects a client to the server, and sends their player info to each other client.
func join_game() -> int:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		printerr("Error while joining game: " + str(error))
		return error
	multiplayer.multiplayer_peer = peer
	return 0


## Disconnects from the server.
func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = null


## Saves the given data as the user's UserData, falling back to the current client_info if none is given.
func save_user_data(data: Dictionary = {}) -> void:
	if !_save_data:
		print("Tried to save data, but saving is disabled")
		return
	if !data:
		data = client_info

	var config = ConfigFile.new()
	for key in _default_client_info:
		config.set_value("UserData", key, data[key])
	config.save(_data_path)


## Loads the UserData found on the system if any, and sets it as the current client_info.
func load_user_data() -> void:
	if !_save_data:
		print("Tried to load data, but saving is disabled")
		return

	var config = ConfigFile.new()
	var err = config.load(_data_path)
	if err:
		if err == ERR_FILE_NOT_FOUND:
			print("No userdata file found")
			return
		printerr("Error when loading user data: %s" % err)
		return
	if !config.has_section("UserData"):
		return

	var keys = config.get_section_keys("UserData")
	for key in keys:
		if client_info.keys().has(key):
			client_info[key] = config.get_value("UserData", key)


## Opens a file dialog to select a new icon, and sets it as the current in client_info.
func open_icon_select() -> void:
	var dialog := FileDialog.new()
	dialog.size = Vector2i(480, 520)
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.png, *.jpg, *.jpeg", "Images")

	dialog.file_selected.connect(set_icon_path)

	add_child(dialog)
	dialog.show()


## Sets the image at the given path as the current icon.
func set_icon_path(file: String, peer: int = 0):
	var image := Image.load_from_file(file)
	set_icon_image(image, peer)


## Resizes the given image, makes a texture from it, and sets it as the current icon.
func set_icon_image(image: Image, peer: int = 0):
	var size := image.get_size()
	var longer: float = size.x if size.x > size.y else size.y
	var factor: float = icon_dim / longer
	size *= factor
	image.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var image_texture = ImageTexture.create_from_image(image)

	if !peer:
		client_info["icon"] = image_texture
	else:
		players[peer]["icon"] = image_texture
	icon_selected.emit(image_texture)


func _ready() -> void:
	# Connects all the multiplayer signals to this code.
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	# Attempts to load player data from a file.
	if _save_data:
		load_user_data()

	# Generates a random icon if none is set.
	if client_info.keys().has("icon") and not client_info["icon"] is Texture2D:
		var image = ImageGen.poke_out()
		image.resize(icon_dim, icon_dim, Image.INTERPOLATE_NEAREST)
		set_icon_image(image)


## Make sure we clean up when the game is closed.
func _exit_tree() -> void:
	if _upnp_thread:
		_upnp_thread.wait_to_finish()
	if _upnp_used:
		_upnp.deleteport_mapping(port, "UDP")


## Starts the actual server hosting, intended to be called by a thread after UPNP is set up.\n
## Used by the network_config function.
func _network_setup_completed(network_error: int) -> void:
	if _upnp_thread:
		_upnp_thread.wait_to_finish()

	if network_error:
		network_setup_completed.emit(network_error)
		return

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_connections)
	if error:
		network_setup_completed.emit(error)
		return

	multiplayer.multiplayer_peer = peer

	network_setup_completed.emit(0)

	_register_player(client_info)
	connected_to_server.emit(true)


## Registers the given player info to the ID of the player who sent it and emits the relevant signal.
@rpc("any_peer", "reliable", "call_local")
func _register_player(new_player_info: Dictionary) -> void:
	var new_player_id = multiplayer.get_remote_sender_id()
	if !new_player_id:
		new_player_id = multiplayer.get_unique_id()

	players[new_player_id] = new_player_info

	if new_player_info.has("icon") and new_player_info["icon"] is Dictionary: # If there's an icon and it's not an icon, rebuild it into an actual texture.
		var data: Dictionary = new_player_info["icon"]
		var new_image = Image.create_from_data(data["w"], data["h"], false, data["f"], data["d"])
		set_icon_image(new_image, new_player_id)

	print("Client %s: Registering new player: %s - %s" % [multiplayer.get_unique_id(), new_player_id, players[new_player_id]])
	player_connected.emit(new_player_id, players[new_player_id])


## When a player connects, send them our data. This way, when someone connects, they get every other player's data.\n
## When *someone else* connects, we send them our data. This ensures any newly connected client has all the player data.
func _on_player_connected(id) -> void:
	print("Client %s: Player connected: %s" % [multiplayer.get_unique_id(), id])
	var info = client_info.duplicate(true)

	if info.has("icon"): # Turn the icon into a dict containing the icon's data, so it can be remade.
		var image = info["icon"].get_image()
		var icon_data: Dictionary = {
			"w" = image.get_width(),
			"h" = image.get_height(),
			"f" = image.get_format(),
			"d" = image.get_data()
		}
		info["icon"] = icon_data

	_register_player.rpc_id(id, info)


## Emits the relevant signal when a player disconnects and removes their data.
func _on_player_disconnected(id) -> void:
	print("Client %s: Player disconnected: %s" % [multiplayer.get_unique_id(), id])
	player_disconnected.emit(id)
	client_info.erase(id)


## Adds ourselves to our own player list when we join.
func _on_connected_ok() -> void:
	print("Client %s: Connected to server!" % multiplayer.get_unique_id())
	_register_player(client_info)
	connected_to_server.emit(true)


## Handles failing to connect to the server.
func _on_connected_fail() -> void:
	print("Client %s: Failed to connect!" % multiplayer.get_unique_id())
	multiplayer.multiplayer_peer = null
	connected_to_server.emit(false)


## Handles the server disconnecting.
func _on_server_disconnected() -> void:
	print("Client %s: Server disconnected!" % multiplayer.get_unique_id())
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
