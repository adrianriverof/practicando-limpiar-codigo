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
var conexiones_buscadas = []

var game_has_started = false
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



func numero_aleatorio_entre_uno_y(numero_maximo_inclusivo):
	randomize()       
	return ((randi() % numero_maximo_inclusivo + 1))


func _ready():
	set_process(true)


#------------------------------------------------------------------------
#------------ Zona de menús e interfaces (borraré estos comentarios y usaré clases)
# - (muy largo, probablemente haya que agrupar más)
#------------------------------------------------------------------------


func _on_pause_button_button_down():
	toggle_game_pause()
	
func _on_Button_start_mouse_entered():
	$card_menu_animation_start.play("start")

func _on_Button_start_mouse_exited():
	$card_menu_animation_start.play_backwards("start")

func _on_Button_close_mouse_entered():
	$card_menu_animation_exit.play("exit")

func _on_Button_close_mouse_exited():
	$card_menu_animation_exit.play_backwards("exit")


func _input(event):   
	if Input.is_action_just_pressed("esc") and game_has_started:
		toggle_game_pause()

func toggle_game_pause():
	if menu_pause.is_visible_in_tree():
		pause_game()
	else:
		continue_playing()

func close_menu_and_start():
	
	iniciar_temporizador_estrella_fugaz()
	$camera_animation.play("1")
	$menu_animation.play("menu_fade_out")
	
	game_has_started = true
	paused_game = false
	

func pause_game():

	menu_pause.set_visible(false)
	paused_game = false
	iniciar_temporizador_estrella_fugaz()
	
	set_pause_button_enabled_and_visible()


func continue_playing():

	menu_pause.set_visible(true)
	paused_game = true
	$fugaz_timer.stop()

	set_pause_button_disabled_and_invisible()	


func set_pause_button_enabled_and_visible():
	$animated_camera/node/pause_button.disabled = false
	$animated_camera/node/pause_button.visible = true

func set_pause_button_disabled_and_invisible():
	$animated_camera/node/pause_button.disabled = true
	$animated_camera/node/pause_button.visible = false


func _on_Button_start_button_down():

	game_has_started = true
	close_menu_and_start()
	
	$animated_camera/node/pause_button.disabled = false
	$animated_camera/node/pause_button.visible = true
	
	GlobalSound.start_sound()


func _on_Button_close_button_down():
	cerrar_juego()


func _on_Button_exit_button_down():
	reiniciar_escena()


func _on_Button_continue_button_down():
	toggle_game_pause()
	


func _on_view_button_button_down():
	
	GlobalSound.view_sound()
	
	if !view_mode:
		$view_animation.play("on")
		
	else:
		$view_animation.play_backwards("on")
	
	view_mode = !view_mode




#------------------------------------------------------------------------
#------------ Zona de brillos
#------------------------------------------------------------------------


func lanzar_brillitos_en(posicion):

	var brillos_instance = brillos.instance()
	brillos_instance.position = posicion
	brillos_instance.emitting = true
	
	get_tree().get_root().add_child(brillos_instance)
	

func lanzar_brillitos_en_fugaz(posicion):
	
	var brillos_instance = brillos_tocar_fugaz.instance()
	brillos_instance.position = posicion
	
	get_tree().get_root().add_child(brillos_instance)
	

#------------------------------------------------------------------------
#------------ Zona de lineas
#------------------------------------------------------------------------



func dibujar_linea(punto_fin):
	
	lanzar_brillitos_en(get_global_mouse_position())
	var linea = trazar_linea_desde_hasta_color(punto_inicial_marcado, punto_fin, Color(color_marca))

	lineas_temporales.append(linea)
	conexiones_temporales.append(ordenar_menor_a_mayor(nodo_inicial_temporal,nodo_final_temporal))
	
	comprobar_conexiones()


func ordenar_menor_a_mayor(primero,segundo):

	if primero < segundo: 
		return Vector2(primero,segundo)
	else:
		return Vector2(segundo,primero)
	


func dibujar_lineas_encontradas(conexiones):
	

	var posiciones_a_brillar = []
	recorrer_conexiones_dibujando_lineas(conexiones, posiciones_a_brillar)
	recorrer_posiciones_a_brillar_y_hacer_que_brillen(posiciones_a_brillar)
	

func recorrer_conexiones_dibujando_lineas(conexiones, lista_en_que_guardar):
	for conexion in conexiones:
		
		var primeraPosicion = posiciones_estrellas[int(conexion[0])]
		var segundaPosicion = posiciones_estrellas[int(conexion[1])]
		
		meter_en_lista_si_no_lo_esta_ya(primeraPosicion, lista_en_que_guardar)
		meter_en_lista_si_no_lo_esta_ya(segundaPosicion, lista_en_que_guardar)
		
		var linea = trazar_linea_desde_hasta_color(primeraPosicion,segundaPosicion,color_azul_2)

		lineas_permanentes.append(linea)
		

func recorrer_posiciones_a_brillar_y_hacer_que_brillen(posiciones_a_brillar):
	for posicion in posiciones_a_brillar:
		lanzar_brillitos_en(posicion)


	
func meter_en_lista_si_no_lo_esta_ya(elemento, lista):
	if !lista.has(elemento):
		lista.append(elemento)


func trazar_linea_desde_hasta_color(start,end,color):
	var linea = Line2D.new()
	linea.default_color = Color(color)
	linea.width = line_width 
	linea.points = [start, end]
	add_child(linea)
	return linea


func borrar_lineas_temporales():

	for linea in lineas_temporales:
		linea.queue_free()
	lineas_temporales.clear()
	conexiones_temporales.clear()



#------------------------------------------------------------------------
#------------ Zona de grupos
#------------------------------------------------------------------------




func grupo_encontrado(conexiones_encontradas):
	
	poner_grupo_encontrado_en_la_lista_de_encontrados()
	borrar_lineas_temporales()
	iniciar_temporizador_estrella_fugaz()
	dibujar_lineas_encontradas(conexiones_encontradas)
	comprobar_objetivos()
	reproducir_sonido_grupo_encontrado()
	reproducir_animacion_carta_encontrada()


func poner_grupo_encontrado_en_la_lista_de_encontrados():
	grupos_encontrados.append(grupo_objetivo)

func reproducir_animacion_carta_encontrada():
	$card_down.play(str(grupo_objetivo))

func reproducir_sonido_grupo_encontrado():
	GlobalSound.group_found()


func comprobar_conexiones():	

	grupo_objetivo = obtener_entero_id_de_grupo_de_la_estrella(conexiones_temporales[-1][0])
	conexiones_buscadas = conexiones_buscadas_para_el_grupo(grupo_objetivo)
	
	comprobar_si_habiamos_encontrado_ya(grupo_objetivo)
	
	if len(conexiones_buscadas) != 0 and verificar_lista_temporal_contiene_todos_los_vectores(conexiones_temporales, conexiones_buscadas):
		grupo_encontrado(conexiones_buscadas)
		
func comprobar_si_habiamos_encontrado_ya(grupo_a_comprobar):
	if grupos_encontrados.has(grupo_a_comprobar):
		conexiones_buscadas = []


func conexiones_buscadas_para_el_grupo(grupo_en_cuestion):
	
	var lista_salida = []

	match grupo_en_cuestion:

		11:

			lista_salida = [  
			Vector2(1101, 1102),
			Vector2(1101, 1103),
			Vector2(1102, 1103),
			Vector2(1103, 1104),
			Vector2(1104, 1105),
		]
		12:
			lista_salida = [ 
			Vector2(1201, 1202),
			Vector2(1201, 1204),
			Vector2(1202, 1203),
			Vector2(1203, 1204),
			Vector2(1204, 1205),
			Vector2(1205, 1206),
			
		]
		13:
			lista_salida = [  
			Vector2(1301, 1302),
			Vector2(1302, 1303),
			Vector2(1303, 1304),
			Vector2(1302, 1304),
			Vector2(1304, 1305),
			
		]
		14:
			lista_salida = [ 
			Vector2(140, 140),
			Vector2(1302, 1303),
			Vector2(1303, 1304),
			Vector2(1302, 1304),
			Vector2(1304, 1305),
			
		]
		
		#--------- 
		21:
			lista_salida = [ 
				Vector2(2101,2102),
				Vector2(2102,2103),
				Vector2(2101,2103)
			]
		
		#---------
		22:
			lista_salida = [
				Vector2(2201,2202),
				Vector2(2202,2203),
				Vector2(2203,2204)
			]
		
		23:
			lista_salida = [
				Vector2(2301,2302),
				Vector2(2301,2303),
				Vector2(2302,2303),
				Vector2(2303,2304)
			]
		#---------
		
		31:
			lista_salida = [
				Vector2(3101,3102),
				Vector2(3102,3103),
				Vector2(3103,3104),
				Vector2(3103,3105)
			]
			
		32:
			lista_salida = [
				Vector2(3201,3202),
				Vector2(3202,3203),
				Vector2(3203,3204),
				Vector2(3203,3205)
			]
			
		33:
			lista_salida = [
				Vector2(3301,3302),
				Vector2(3302,3303),
				Vector2(3303,3304),
				Vector2(3301,3304),
				Vector2(3302,3305),
				Vector2(3305,3306)
			]
		
		#---------
		
		41:
			lista_salida = [
				Vector2(4101,4102),
				Vector2(4102,4103),
				Vector2(4103,4104),
				Vector2(4104,4105),
				Vector2(4103,4106),
				Vector2(4104,4106),
				Vector2(4106,4107)
			]
			
		42:
			lista_salida = [
				Vector2(4201,4202),
				Vector2(4202,4203),
				Vector2(4203,4204),
				Vector2(4203,4205)
			]
		
		43:
			lista_salida = [
				Vector2(4301,4302),
				Vector2(4302,4303),
				Vector2(4303,4304),
				Vector2(4303,4305),
				Vector2(4304,4305)
			]
		
		44:
			lista_salida = [
				Vector2(4401,4402),
				Vector2(4402,4403),
				Vector2(4402,4404),
				Vector2(4404,4405),
				Vector2(4404,4406),
				Vector2(4405,4406),
				Vector2(4406,4407)
			]
	return lista_salida	


func verificar_lista_temporal_contiene_todos_los_vectores(temporal: Array, objetivo: Array) -> bool:
    for vector_objetivo in objetivo:
        if not temporal.contains(vector_objetivo):
            return false
        conexiones_a_permanente.append(vector_objetivo)
    return true




#------------------------------------------------------------------------
#------------ Zona de control de nivel/progreso
#------------------------------------------------------------------------




func comprobar_objetivos():
	match len(grupos_encontrados): 
		1:
			$camera_animation.play("2")
		3:
			$camera_animation.play("3")
		6:
			$camera_animation.play("4")
		10:
			$camera_animation.play("5")


func reiniciar_escena():
	$fugaz_timer.stop()
	get_tree().reload_current_scene()

func cerrar_juego():
	get_tree().quit()


func _on_camera_animation_animation_finished(anim_name):
	if anim_name == "5":
		reiniciar_escena()


#------------------------------------------------------------------------
#------------ Zona de estrellas fugaces
#------------------------------------------------------------------------



func generar_estrella_fugaz():

	iniciar_temporizador_estrella_fugaz()
	GlobalSound.fugaz_appear()
		
	var fugaz = preload("res://estrella_fugaz.tscn")
	var camera_position = get_node("animated_camera/fugaces_posiciones")
	var fugaz_especifica = numero_aleatorio_entre_uno_y(camera_position.get_child_count())

	var fugaz_instance = fugaz.instance()
	fugaz_instance.position = camera_position.get_node(str(fugaz_especifica)).global_position
	fugaz_instance.rotation_degrees = camera_position.get_node(str(fugaz_especifica)).rotation_degrees
	
	get_tree().get_root().add_child(fugaz_instance)

func tocar_fugaz():
	
	for numero_estrella in posiciones_estrellas:

		var grupo_de_la_estrella = obtener_entero_id_de_grupo_de_la_estrella(numero_estrella)
		
		if grupo_no_encontrado_y_no_generico(grupo_de_la_estrella):
			lanzar_brillitos_en_fugaz(posiciones_estrellas[numero_estrella])
			break
		 

func grupo_no_encontrado_y_no_generico(grupo_en_cuestion):
	return (!grupos_encontrados.has(grupo_en_cuestion) and !grupo_en_cuestion == 10)


func obtener_entero_id_de_grupo_de_la_estrella(string_id_de_la_estrella):
	return int(str(string_id_de_la_estrella).left(2))



func _on_fugaz_timer_timeout():

	generar_estrella_fugaz()
	

func iniciar_temporizador_estrella_fugaz():
	$fugaz_timer.start()
