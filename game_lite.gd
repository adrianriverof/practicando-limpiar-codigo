extends Node2D



onready var menu_pause = get_node("animated_camera/menus/pause")
onready var menu_start = get_node("animated_camera/menus/start")

onready var brillos = preload("res://particulas/brillitos4.tscn")
onready var brillos_tocar_fugaz = preload("res://particulas/brillitos6.tscn")

var selecting = false
var trazando_conexiones = false 
var buscando_puntos = false

var punto_inicial_marcado = Vector2.ZERO

var grupo = 0
var grupo_objetivo = 0

var nodo_inicial_temporal = 1000
var nodo_final_temporal = 1000




var lineas_temporales = []
var lineas_permanentes = []

var posiciones_estrellas = {}

var conexiones_temporales = []
var conexiones_a_permanente = []

var grupos_encontrados = []

var game_started = false
var paused_game = true
var view_mode = false



var color_blanco = "cdd6e7"
var color_azul_1 = "327bb3"
var color_azul_2 = "00487f"
var color_azul_3 = "103d5f"
var color_negro  = "000613"

var color_trazo = color_blanco
var color_marca = color_azul_1

var line_width = 4







func generate_random_number(number):  #1dN    N = number  
	#ESTO TE DEVUELVE UN NÚMERO ALEATORIO ENTRE 1 Y EL NÚMERO QUE LE METAS
	
	
	var randnumber
	
	var maxnum = number
	
	#MAYBE CHANGING THIS DIRECTION SHOULD ONLY CONSIDER THE 4 ADJACENT DIRECTIONS
	randomize()     # We need one of 8 directions
	randnumber = (randi() % maxnum + 1) + 0   # Returns random integer between 1 and number
	
	return randnumber




func _ready():
	set_process(true)
	#get_node("camera_object").speed = 0.5
	#menu_start.visible = true
	#$menu_animation.play("menu_fade_in")
	
	##check_star_positions()
	print(posiciones_estrellas)
	print(posiciones_estrellas[2101])





func _input(event):    # esto es para testear el avance, las transiciones etc. t luego
	#if Input.is_action_just_pressed("ui_accept"):
	#	grupos_encontrados.append(Vector2.ZERO)
	#	comprobar_objetivos()
	
	if Input.is_action_just_pressed("esc") and game_started:   # falta añadir condición de que hayas empezado
		#generar_estrella_fugaz()
		toggle_pause_buttons_visibility()
		#print("intentamos togglear")
				
			#if child is Button:  # esto no sé muy bien que hace pero yo lo dejo aquí por si sirve
			#	var button = child as Button
			#	button.disabled = true


func toggle_pause_buttons_visibility():
	
	
	if menu_pause.is_visible_in_tree():
		menu_pause.set_visible(false)
		#disable_pause_buttons()
		paused_game = false
		print("despausa")
		
		$fugaz_timer.start()
		#$pause_animation.play("fade_out")
		
		$animated_camera/node/pause_button.disabled = false
		$animated_camera/node/pause_button.visible = true
		
	else:
		menu_pause.set_visible(true)
		enable_pause_buttons()
		paused_game = true
		print("pausa")
		$fugaz_timer.stop()
		#$pause_animation.play("fade_in")
		
		$animated_camera/node/pause_button.disabled = true
		$animated_camera/node/pause_button.visible = false

func disable_pause_buttons():
	for child in menu_pause.get_children():
		if child is Button:
			var button = child as Button
			button.disabled = true

func enable_pause_buttons():
	for child in menu_pause.get_children():
		if child is Button:
			var button = child as Button
			button.disabled = false


func close_menu_and_start():
	
	$fugaz_timer.start() # Ojo que igual todavía no lo queremos hasta más adelante
	# en ese caso hay que arreglar la pausa
	# que sea sensible al len
	
	$camera_animation.play("1")
	
	$menu_animation.play("menu_fade_out")
	
	#menu_start.set_visible(false)
	
	game_started = true
	paused_game = false
	
	for child in menu_start.get_children():
		if child is Button:
			var button = child as Button
			button.disabled = true
	
	
func grupo_encontrado(conexiones_encontradas):
	
	grupos_encontrados.append(grupo_objetivo)
	
	$card_down.play(str(grupo_objetivo))
	#GlobalSound.card_down()
	
	hacer_lineas_permanentes_arreglado()
	dibujar_lineas_encontradas(conexiones_encontradas)
	comprobar_objetivos()
	
	GlobalSound.group_found()


func lanzar_brillitos_mouse():
	
	#        esto lo ideal es generarlo en lugar de esto
	#$CPUParticles2D.position = get_global_mouse_position()
	#$CPUParticles2D.emitting = false
	#$CPUParticles2D.emitting = true
	#print("-------------vamos a emitir")
	
	var posicion_deseada = get_global_mouse_position()
	
	
	
	var brillos_instance = brillos.instance()
	brillos_instance.position = posicion_deseada
	brillos_instance.emitting = true
	
	#print("-------------- furula")
	get_tree().get_root().add_child(brillos_instance)
	
func lanzar_brillitos(posicion):
	
	#        esto lo ideal es generarlo en lugar de esto
	#$CPUParticles2D.position = get_global_mouse_position()
	#$CPUParticles2D.emitting = false
	#$CPUParticles2D.emitting = true
	#print("-------------vamos a emitir")
	
	var posicion_deseada = posicion
	
	
	
	var brillos_instance = brillos.instance()
	brillos_instance.position = posicion_deseada
	brillos_instance.emitting = true
	
	print("-------------- furula")
	get_tree().get_root().add_child(brillos_instance)
	

func lanzar_brillitos_fugaz(posicion):
	
	#        esto lo ideal es generarlo en lugar de esto
	#$CPUParticles2D.position = get_global_mouse_position()
	#$CPUParticles2D.emitting = false
	#$CPUParticles2D.emitting = true
	#print("-------------vamos a emitir")
	
	var posicion_deseada = posicion
	
	
	
	var brillos_instance = brillos_tocar_fugaz.instance()
	brillos_instance.position = posicion_deseada
	
	
	print("-------------- furula")
	#add_child(brillos_instance)
	get_tree().get_root().add_child(brillos_instance)
	

	

func dibujar_linea(punto_fin):
	
	
	lanzar_brillitos_mouse()
	
	
	
	var linea = Line2D.new()
	linea.default_color = Color(color_marca)  # Cambia el color de la línea según tus preferencias
	linea.width = line_width  # Cambia el grosor de la línea según tus preferencias
	linea.points = [punto_inicial_marcado, punto_fin]
	add_child(linea)
	lineas_temporales.append(linea)  # Almacena la línea en la lista
	
	
	
	
	

	
	# ahora quiero que me guarde información de los node_number de los puntos conectados
	
	print("conectamos ", nodo_inicial_temporal, " con ", nodo_final_temporal)
	
	if nodo_inicial_temporal < nodo_final_temporal:   # con esto los ordeno siempre menor primero
		conexiones_temporales.append(Vector2(nodo_inicial_temporal, nodo_final_temporal))
	else:
		conexiones_temporales.append(Vector2(nodo_final_temporal, nodo_inicial_temporal))
	
	print(conexiones_temporales)
	comprobar_conexiones()
	
	
func dibujar_lineas_encontradas(conexiones):
	
	# que suene que hemos encontrado cosas
	
	GlobalSound
	
	#conexiones
	
	
	print("++++++ conexiones: ", conexiones)
	
	var posiciones_a_brillar = []
	
	
	for vector in conexiones:
		print(vector)
		var linea = Line2D.new()
		linea.default_color = Color(color_azul_2)  # Cambia el color de la línea según tus preferencias
		linea.width = line_width  # Cambia el grosor de la línea según tus preferencias
		
		var primerElemento = vector[0]
		var segundoElemento = vector[1]
		#print(primerElemento)
		var primeraPosicion = posiciones_estrellas[int(primerElemento)]
		var segundaPosicion = posiciones_estrellas[int(segundoElemento)]
		#print(posicion)
		
		if !posiciones_a_brillar.has(primeraPosicion):
			posiciones_a_brillar.append(primeraPosicion)
		if !posiciones_a_brillar.has(segundaPosicion):
			posiciones_a_brillar.append(segundaPosicion)
		
		linea.points = [primeraPosicion, segundaPosicion]
		add_child(linea)
		lineas_permanentes.append(linea)  # Almacena la línea en la lista
		
	
	for posicion in posiciones_a_brillar:
		lanzar_brillitos(posicion)


func hacer_lineas_permanentes_arreglado():
	
	# OJO aquí va a haber que avisar JERARQUÍA
	#get_node("estrellas/solucion/"+ str(grupo_objetivo)).visible = true
			# aquí hacer visible el sprite con las conexiones y au
		
	$fugaz_timer.start() # básicamente si te está saliendo no saldrá fugaz
	
	borrar_lineas_temporales()
	
	

func hacer_lineas_permanentes():
	
	
	for linea_num in len(conexiones_temporales):
		print(linea_num)
		var linea = lineas_temporales[0]
		lineas_temporales.remove(0)
		lineas_permanentes.append(linea)
		linea.default_color = Color(0,1,0)
		
	#lineas_temporales.clear()
	#conexiones_temporales.clear()
	borrar_lineas_temporales()
	
	print(grupos_encontrados)
	


func borrar_lineas_temporales():
	
	
	
	for linea in lineas_temporales:
		linea.queue_free()
	lineas_temporales.clear()
	conexiones_temporales.clear()


func comprobar_conexiones():
	# Define tu lista de vectores objetivo
	
	
	grupo_objetivo = int(str(conexiones_temporales[-1][0]).left(2))
	print("buscamos grupo: ",  grupo_objetivo )
	
	var conexiones_buscadas = []
	match grupo_objetivo:
		
		#10:
		#	print("grupo generico")
		
		#---------TEST
		11:
			# PUEDO HACER UN SISTEMA AUTOMÁTICO PARA METER ESTOS VECTORES
			conexiones_buscadas = [  # Esta es la lista de conexiones de la constelación
			Vector2(1101, 1102),
			Vector2(1101, 1103),
			Vector2(1102, 1103),
			Vector2(1103, 1104),
			Vector2(1104, 1105),
			# Agrega más vectores objetivo según tus necesidades
		]
		12:
			conexiones_buscadas = [  # Esta es la lista de conexiones de la constelación
			Vector2(1201, 1202),
			Vector2(1201, 1204),
			Vector2(1202, 1203),
			Vector2(1203, 1204),
			Vector2(1204, 1205),
			Vector2(1205, 1206),
			# Agrega más vectores objetivo según tus necesidades
		]
		13:
			conexiones_buscadas = [  # Esta es la lista de conexiones de la constelación
			Vector2(1301, 1302),
			Vector2(1302, 1303),
			Vector2(1303, 1304),
			Vector2(1302, 1304),
			Vector2(1304, 1305),
			# Agrega más vectores objetivo según tus necesidades
		]
		14:
			conexiones_buscadas = [  # Esta es la lista de conexiones de la constelación
			Vector2(140, 140),
			Vector2(1302, 1303),
			Vector2(1303, 1304),
			Vector2(1302, 1304),
			Vector2(1304, 1305),
			# Agrega más vectores objetivo según tus necesidades
		]
		
		#--------- PANTALLA 1 (Tutorial)
		21:
			conexiones_buscadas = [
				Vector2(2101,2102),
				Vector2(2102,2103),
				Vector2(2101,2103)
			]
		
		#---------
		22:
			conexiones_buscadas = [
				Vector2(2201,2202),
				Vector2(2202,2203),
				Vector2(2203,2204)
			]
		
		23:
			conexiones_buscadas = [
				Vector2(2301,2302),
				Vector2(2301,2303),
				Vector2(2302,2303),
				Vector2(2303,2304)
			]
		#---------
		
		31:
			conexiones_buscadas = [
				Vector2(3101,3102),
				Vector2(3102,3103),
				Vector2(3103,3104),
				Vector2(3103,3105)
			]
			
		32:
			conexiones_buscadas = [
				Vector2(3201,3202),
				Vector2(3202,3203),
				Vector2(3203,3204),
				Vector2(3203,3205)
			]
			
		33:
			conexiones_buscadas = [
				Vector2(3301,3302),
				Vector2(3302,3303),
				Vector2(3303,3304),
				Vector2(3301,3304),
				Vector2(3302,3305),
				Vector2(3305,3306)
			]
		
		#---------
		
		41:
			conexiones_buscadas = [
				Vector2(4101,4102),
				Vector2(4102,4103),
				Vector2(4103,4104),
				Vector2(4104,4105),
				Vector2(4103,4106),
				Vector2(4104,4106),
				Vector2(4106,4107)
			]
			
		42:
			conexiones_buscadas = [
				Vector2(4201,4202),
				Vector2(4202,4203),
				Vector2(4203,4204),
				Vector2(4203,4205)
			]
		
		43:
			conexiones_buscadas = [
				Vector2(4301,4302),
				Vector2(4302,4303),
				Vector2(4303,4304),
				Vector2(4303,4305),
				Vector2(4304,4305)
			]
		
		44:
			conexiones_buscadas = [
				Vector2(4401,4402),
				Vector2(4402,4403),
				Vector2(4402,4404),
				Vector2(4404,4405),
				Vector2(4404,4406),
				Vector2(4405,4406),
				Vector2(4406,4407)
			]
		
		
		
		
		
		
		
	if grupos_encontrados.has(grupo_objetivo):
		print("este ya lo habíamos encontrado")
		conexiones_buscadas = []    # para que no nos la vuelva a marcar como completa
	
	if len(conexiones_buscadas) != 0 and comprobarListas_nos_da_igual_sobrar(conexiones_temporales, conexiones_buscadas):
		print("constelación encontrada!!!!!!")
		
		grupo_encontrado(conexiones_buscadas)
		
	else: 
		print("el grupo no está completo")
	#print('conexiones buscadas: ', conexiones_buscadas)
		




func comprobarListas_nos_da_igual_sobrar(temporal: Array, objetivo: Array) -> bool:
	# Verificar que la lista temporal contiene al menos un vector de cada tipo en objetivo
	for vector_objetivo in objetivo:
		var contiene_vector = false
		for vector_temporal in temporal:
			if vector_temporal == vector_objetivo:
				contiene_vector = true
				conexiones_a_permanente.append(vector_objetivo)
				break
		if not contiene_vector:
			return false
	
	
	

	# Verificar que la lista temporal no contiene ningún vector que no esté en objetivo
	# LO HE QUITADO

	# Si llegamos hasta aquí, todas las comprobaciones han pasado
	return true

func comprobarListas(temporal: Array, objetivo: Array) -> bool:
	# Verificar que la lista temporal contiene al menos un vector de cada tipo en objetivo
	for vector_objetivo in objetivo:
		var contiene_vector = false
		for vector_temporal in temporal:
			if vector_temporal == vector_objetivo:
				contiene_vector = true
				break
		if not contiene_vector:
			return false

	# Verificar que la lista temporal no contiene ningún vector que no esté en objetivo
	for vector_temporal in temporal:
		var esta_en_objetivo = false
		for vector_objetivo in objetivo:
			if vector_temporal == vector_objetivo:
				esta_en_objetivo = true
				break
		if not esta_en_objetivo:
			return false

	# Si llegamos hasta aquí, todas las comprobaciones han pasado
	return true

func comprobar_objetivos():
	
	var cantidad_grupos_a_encontrar = 5 # sustituir esto con la cantidad de grupos por encontrar
	
	
	print("está comprobando los objetivos completados")
	print("lleva ", len(grupos_encontrados), " grupos encontrados")
	
	
	
	
	match len(grupos_encontrados): # nos fijamos en la cantidad que hemos completado
		1:
			print("completaste la primera pantalla")
			#get_node("camera_object").move_to(get_node("camera_positions/2").get_global_position())
			$camera_animation.play("2")
			
		3:
			print("completa la segunda pantalla")
			#get_node("camera_object").move_to(get_node("camera_positions/3").get_global_position())
			# modificamos la velocidad de la cámara para adecuarnos si eso
			#get_node("camera_object").speed = 0.25
			$camera_animation.play("3")
		6:
			print("completa la segunda pantalla")
			#get_node("camera_object").move_to(get_node("camera_positions/4").get_global_position())
			$camera_animation.play("4")
		10:
			print("se ha pasado el juego")
			# esto por si quiero volver al principio
			terminar()
			
	#if len(grupos_encontrados) == cantidad_grupos_a_encontrar: 
	#	print("has ganado")
		# Aquí habrá que establecer las distintas fases y tal. 
		# Toda la progresión puede estar ligada a el número de grupos encontrado y que según este 
		# número pasemos de fases
		

func terminar():
	
	
	#get_node("camera_object").move_to(get_node("camera_positions/1").get_global_position())
		# modificamos la velocidad de la cámara para adecuarnos si eso
	#get_node("camera_object").speed = 0.05
	
	$camera_animation.play("5")
	
	# aquí vemos si metemos un temporizador, un fade out y reinicia escena, etc



func reiniciar_escena():
	# Carga la escena actual nuevamente
	#var escena_actual = get_tree().get_current_scene()
	
	$fugaz_timer.stop()
	
	get_tree().reload_current_scene()


func _on_Button_start_button_down():
	game_started = true
	close_menu_and_start()
	
	$animated_camera/node/pause_button.disabled = false
	$animated_camera/node/pause_button.visible = true
	
	GlobalSound.start_sound()


func _on_Button_close_button_down():
	cerrar_juego()

func cerrar_juego():
	# Verifica la plataforma actual
	get_tree().quit()


# BOTONES DE PAUSE

func _on_Button_exit_button_down():
	reiniciar_escena()


func _on_Button_continue_button_down():
	toggle_pause_buttons_visibility()
	

func _on_fugaz_timer_timeout():
	
	print("timeout")
	generar_estrella_fugaz()
	$fugaz_timer.start()
	GlobalSound.fugaz_appear()


func generar_estrella_fugaz():
	
	# en lugar de aleatorizarlo, quiero tener una serie de estrellas predefinidas
	# tira el dado para elegir cual de ellas lanza
	# está automatizado que aparezca en su posición y con el ángulo correcto
	
	print("nos piden generar estrellas")
	
	var fugaz = preload("res://estrella_fugaz.tscn")
	
	var camera_position = get_node("animated_camera/fugaces_posiciones")
	
	print("cantidad de nodos: -----------", camera_position.get_child_count())
	var fugaz_especifica = generate_random_number(camera_position.get_child_count()) # numero de 1 al 10
	
	var fugaz_instance = fugaz.instance()
	fugaz_instance.position = camera_position.get_node(str(fugaz_especifica)).global_position
	fugaz_instance.rotation_degrees = camera_position.get_node(str(fugaz_especifica)).rotation_degrees
	#fugaz_instance.speed = 5
	
	get_tree().get_root().add_child(fugaz_instance)
	









func _on_Button_toggled(button_pressed):
	if button_pressed:
		$view_animation.play("on")
	else:
		$view_animation.play_backwards("on")


func _on_view_button_button_down():
	
	GlobalSound.view_sound()
	
	if !view_mode:
		$view_animation.play("on")
		
	else:
		$view_animation.play_backwards("on")
	
	view_mode = !view_mode



func _on_pause_button_button_down():
	toggle_pause_buttons_visibility()
	
	
	


func tocar_fugaz():
	
	# necesito saber en qué punto estoy
	
	#print(posiciones_estrellas)
	
	for numero_estrella in posiciones_estrellas:
		#print(numero_estrella)
		#print(grupos_encontrados)
		var grupo_de_la_estrella = int(str(numero_estrella).left(2))
		print("grupo ", grupo_de_la_estrella)
		
		if !grupos_encontrados.has(grupo_de_la_estrella) and !grupo_de_la_estrella == 10:
			print("haríamos un destello en ", posiciones_estrellas[numero_estrella])
			lanzar_brillitos_fugaz(posiciones_estrellas[numero_estrella])
			
			break
		 
		






func _on_Button_start_mouse_entered():
	$card_menu_animation_start.play("start")


func _on_Button_start_mouse_exited():
	$card_menu_animation_start.play_backwards("start")

func _on_Button_close_mouse_entered():
	$card_menu_animation_exit.play("exit")


func _on_Button_close_mouse_exited():
	$card_menu_animation_exit.play_backwards("exit")


func _on_camera_animation_animation_finished(anim_name):
	if anim_name == "5":
		reiniciar_escena()
