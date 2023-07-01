# Manual Técnico Proyecto 2 Pixelcraft
#
| Carnet            | Nombre      | Auxiliar | Sección|
|-------------------|-------------|------------|--------|
|202101149| Mariano Roberto Rac Noguera | Mynor Ruíz|ACYE N|
#
## Introducción

Este manual técnico es una guía para los desarrolladores y técnicos encargados del mantenimiento de la aplicación o bien interesados en el código y desarrollo de la app. Proporciona información detallada sobre la arquitectura, el diseño y las tecnologías utilizadas en el desarrollo de Exregan
## Requerimientos de Software
- Arquitectura: x86 de 16 bits.Esto significa que el procesador debe ser compatible con la arquitectura x86 de 16 bits. La mayoría de los procesadores modernos son compatibles con esta arquitectura, pero se debe tener cuenta que algunos procesadores más nuevos solo admiten la arquitectura x86 de 32 o 64 bits
- Sistema operativo: MS-DOS o algún otro sistema operativo compatible con x86 de 16 bits.Asm6 es un ensamblador diseñado para sistemas operativos de 16 bits, como MS-DOS. Si se desea ejecutar programas asm6, se necesitará un sistema operativo compatible con esta arquitectura. 
- Herramienta de ensamblaje: asm6.El programa asm6 es un ensamblador específico para el lenguaje de ensamblaje de 6502 utilizado en algunos sistemas de 8 bits  o 16 bits. Aunque asm6 está diseñado para el ensamblaje de código de 8 bits, aún es posible utilizarlo para ensamblar código x86 de 16 bits. 
- Memoria suficiente: La computadora debe tener suficiente memoria para cargar el programa ASM y los datos necesarios. El programa utiliza gráficos en modo de video, es posible que se requiera una mayor cantidad de memoria para almacenar los datos de pantalla y los recursos gráficos.
- Tarjeta gráfica compatible: Es necesario tener una tarjeta gráfica compatible con la resolución y el modo de color requeridos por el programa. La tarjeta gráfica debe admitir la capacidad de escribir directamente en la memoria de vídeo (como en el modo VGA) o proporcionar interfaces de programación específicas para el acceso a los gráficos.
- 


# Arquitectura
Este código está escrito en ensamblador x86 y sigue una estructura básica de un programa en ensamblador para el procesador Intel 8086.
- Incluye un archivo de macros que contiene funciones útiles para simplificar la escritura del código ensamblador..
- Es un juego interactivo que muestra un menú al usuario y le permite interactuar con las distintas opciones como cargar un nivel personalizado o bien jugar directamente los niveles que se disponen.

## Tecnologías utilizadas

Exregan utiliza las siguientes tecnologías:

* ASM- para el desarrollo del programa
* DOSBOX - como entorno virtual

## Introducción
# Estructura del Código

- UI: La interfaz gráfica consiste en una aplicación directamente en la que el usuario puede interactuar por medio del teclado,




## Funcionamiento Interno de la Aplicación
Menu Principal
```
entrada_menu_principal:
		mov AH, 00
		int 16
		cmp AH, 48
		je restar_opcion_menu_principal
		cmp AH, 50
		je sumar_opcion_menu_principal
		cmp AH, 3b  ;; le doy F1
		je fin_menu_principal
		jmp entrada_menu_principal
restar_opcion_menu_principal:
		mov AL, [opcion]
		dec AL
		cmp AL, 0ff
		je volver_a_cero
		mov [opcion], AL
		jmp mover_flecha_menu_principal
sumar_opcion_menu_principal:
		mov AL, [opcion]
		mov AH, [maximo]
		inc AL
		cmp AL, AH
		je volver_a_maximo
		mov [opcion], AL
		jmp mover_flecha_menu_principal
volver_a_cero:
		mov AL, 0
		mov [opcion], AL
		jmp mover_flecha_menu_principal
volver_a_maximo:
		mov AL, [maximo]
		dec AL
		mov [opcion], AL
		jmp mover_flecha_menu_principal
mover_flecha_menu_principal:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		mov AX, 50
		mov BX, 28
		mov CL, [opcion]
ciclo_ubicar_flecha_menu_principal:
		cmp CL, 0
		je pintar_flecha_menu_principal
		dec CL
		add BX, 10
		jmp ciclo_ubicar_flecha_menu_principal
pintar_flecha_menu_principal:
		mov [xFlecha], AX
		mov [yFlecha], BX
		call pintar_flecha
		jmp entrada_menu_principal
		;;
fin_menu_principal:
		ret

;; pintar_flecha - pinta una flecha
pintar_flecha:
		mov AX, [xFlecha]
		mov BX, [yFlecha]
		mov SI, offset dim_sprite_flcha
		mov DI, offset data_sprite_flcha
		call pintar_sprite
		ret
```
entrada_menu_principal:: Etiqueta que marca el inicio de la sección de entrada del menú principal. Aquí comienza la captura de la entrada del usuario.
mov AH, 00: Mueve el valor 00 al registro AH. Este valor indica la función del teclado a utilizar.
int 16: Invoca la interrupción 16h, que permite leer una tecla presionada del teclado. El resultado se guarda en el registro AH.
cmp AH, 48: Compara el valor en AH con 48, que es el código ASCII para el número 0. Esto verifica si el usuario ha presionado la tecla "0".
je restar_opcion_menu_principal: Salta a la etiqueta restar_opcion_menu_principal si la comparación anterior fue verdadera (es decir, si se presionó la tecla "0").
cmp AH, 50: Compara el valor en AH con 50, que es el código ASCII para el número 2. Esto verifica si el usuario ha presionado la tecla "2".
je sumar_opcion_menu_principal: Salta a la etiqueta sumar_opcion_menu_principal si la comparación anterior fue verdadera (es decir, si se presionó la tecla "2").
cmp AH, 3b: Compara el valor en AH con 3b, que es el código ASCII para la tecla F1. Esto verifica si el usuario ha presionado la tecla F1.
je fin_menu_principal: Salta a la etiqueta fin_menu_principal si la comparación anterior fue verdadera (es decir, si se presionó la tecla F1).
jmp entrada_menu_principal: Salta de nuevo a la etiqueta entrada_menu_principal para capturar otra entrada del usuario si ninguna de las condiciones anteriores se cumplió.
restar_opcion_menu_principal:: Etiqueta que marca el inicio de la sección para restar la opción del menú principal.
mov AL, [opcion]: Mueve el valor almacenado en la dirección de memoria [opcion] al registro AL. Este valor representa la opción actual del menú.
dec AL: Decrementa en 1 el valor en AL. Resta 1 a la opción del menú.
cmp AL, 0ff: Compara el valor en AL con 0ff, que es -1 en complemento a dos. Esto verifica si el resultado de restar 1 a la opción del menú es igual a -1, lo que significa que se alcanzó el valor mínimo.
je volver_a_cero: Salta a la etiqueta volver_a_cero si la comparación anterior fue verdadera (es decir, si la opción del menú se redujo a -1).
mov [opcion], AL: Guarda el nuevo valor de la opción del menú en la dirección de memoria [opcion].
jmp mover_flecha_menu_principal: Salta a la etiqueta mover_flecha_menu_principal para actualizar la posición de la flecha en el menú principal.
sumar_opcion_menu_principal:: Etiqueta que marca el inicio de la sección para sumar la opción del menú principal.
mov AL, [opcion]: Mueve el valor almacenado en la dirección de memoria [opcion] al registro AL.
mov AH, [maximo]: Mueve el valor almacenado en la dirección de memoria [maximo] al registro AH. Este valor representa el valor máximo permitido para la opción del menú.
inc AL: Incrementa en 1 el valor en AL. Suma 1 a la opción del menú.
cmp AL, AH: Compara el valor en AL con el valor en AH. Esto verifica si el resultado de sumar 1 a la opción del menú es igual al valor máximo.
je volver_a_maximo: Salta a la etiqueta volver_a_maximo si la comparación anterior fue verdadera (es decir, si la opción del menú alcanzó el valor máximo).
mov [opcion], AL: Guarda el nuevo valor de la opción del menú en la dirección de memoria [opcion].
jmp mover_flecha_menu_principal: Salta a la etiqueta mover_flecha_menu_principal para actualizar la posición de la flecha en el menú principal.
volver_a_cero:: Etiqueta que marca el inicio de la sección para volver a cero la opción del menú.
mov AL, 0: Mueve el valor 0 al registro AL, estableciendo la opción del menú en cero.
mov [opion], AL: Guarda el valor cero en la dirección de memoria [opcion].
jmp mover_flecha_menu_principal: Salta a la etiqueta mover_flecha_menu_principal para actualizar la posición de la flecha en el menú principal.
volver_a_maximo:: Etiqueta que marca el inicio de la sección para volver al valor máximo la opción del menú.
mov AL, [maximo]: Mueve el valor almacenado en la dirección de memoria [maximo] al registro AL.
dec AL: Decrementa en 1 el valor en AL. Resta 1 al valor máximo para la opción del menú.
mov [opcion], AL: Guarda el nuevo valor máximo en la dirección de memoria [opcion].
jmp mover_flecha_menu_principal: Salta a la etiqueta mover_flecha_menu_principal para actualizar la posición de la flecha en el menú principal.
mover_flecha_menu_principal:: Etiqueta que marca el inicio de la sección para mover la flecha en el menú principal.
mov AX, [xFlecha]: Mueve el valor almacenado en la dirección de memoria [xFlecha] al registro AX. Este valor representa la coordenada X de la posición actual de la flecha.
mov BX, [yFlecha]: Mueve el valor almacenado en la dirección de memoria [yFlecha] al registro BX. Este valor representa la coordenada Y de la posición actual de la flecha.
mov SI, offset dim_sprite_vacio: Mueve la dirección de memoria del tamaño del sprite vacío a SI. Esto se utilizará para pintar el sprite vacío.
mov DI, offset data_sprite_vacio: Mueve la dirección de memoria de los datos del sprite vacío a DI.
```
pintar_pixel:
		push AX
		push BX
		push CX
		push DX
		push DI
		push SI
		push DS
		mov DX, 0a000
		mov DS, DX
		;; (
		;; 	posicionarse en X
		mov SI, AX
		mov AX, 140
		mul BX
		add AX, SI
		mov DI, AX
		;;
		mov [DI], CL  ;; pintar
		;; )
		pop DS
		pop SI
		pop DI
		pop DX
		pop CX
		pop BX
		pop AX
		ret

;; pintar_sprite - pinta un sprite
;; Entrada:
;;    - DI: offset del sprite
;;    - SI: offset de las dimensiones
;;    - AX: x sprite 320x200
;;    - BX: y sprite 320x200
pintar_sprite:
		push DI
		push SI
		push AX
		push BX
		push CX
		inc SI
		mov DH, [SI]  ;; vertical
		dec SI        ;; dirección de tam horizontal
		;;
inicio_pintar_fila:
		cmp DH, 00
		je fin_pintar_sprite
		push AX
		mov DL, [SI]
pintar_fila:
		cmp DL, 00
		je pintar_siguiente_fila
		mov CL, [DI]
		call pintar_pixel
		inc AX
		inc DI
		dec DL
		jmp pintar_fila
pintar_siguiente_fila:
		pop AX
		inc BX
		dec DH
		jmp inicio_pintar_fila
fin_pintar_sprite:
		pop CX
		pop BX
		pop AX
		pop SI
		pop DI
		ret

;; delay - subrutina de retardo
delay:
		push SI
		push DI
		mov SI, 0200
cicloA:
		mov DI, 0130
		dec SI
		cmp SI, 0000
		je fin_delay
cicloB:
		dec DI
		cmp DI, 0000
		je cicloA
		jmp cicloB
fin_delay:
		pop DI
		pop SI
		ret
		

;; clear_pantalla - limpia la pantalla
;; ..
;; ..
clear_pantalla:
		mov CX, 19  ;; 25
		mov BX, 00
clear_v:
		push CX
		mov CX, 28  ;; 40
		mov AX, 00
clear_h:
		mov SI, offset dim_sprite_vacio
		mov DI, offset data_sprite_vacio
		call pintar_sprite
		add AX, 08
		loop clear_h
		add BX, 08
		pop CX
		loop clear_v
		ret
| Interrupción | Descripción                                                |
|--------------|------------------------------------------------------------|
| `int 10h`    | Interrupción de video - control de pantalla y funciones BIOS |
| `int 16h`    | Interrupción de teclado - leer teclado (espera input)       |
| `int 15h`    | Espera una cantidad específica de microsegundos            |
| `int 21h`    | Llamada al sistema DOS para realizar varias funciones      |
