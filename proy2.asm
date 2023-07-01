include macros.asm
.MODEL SMALL
.RADIX 16
.STACK
.DATA
	 
    inicio_juego  db "Iniciar Juego",0
    cargar_nivel  db "Cargar nivel",0
    config      db "Configuracion",0
    puntaje_alto   db "Puntajes altos",0
    salir       db "Salir",0
    datos       db "Mariano Roberto Rac Noguera/202101149",0
    short_datos db "Mariano Rac/202101149",0
    vacio       db " ",0
    ganaste      db "GANASTE!",0
    continuar    db "CONTINUAR",0
	; archivos de nivel
    lvl1_name   db "NIV.00",0
    lvl2_name   db "NIV.01",0
    lvl3_name   db "NIV.10",0
	prompt_lv   db "Ingrese el nombre de archivo:",0
	zeropad     db "0",0
    pad2        db "00",0
    pad3        db "000",0
    dospuntos       db ":",0
	;;
    player_pos    EQU 08h
    load_pos    EQU 0Ah
    cnf_pos    EQU 0Ch
    hs_pos    EQU 0Eh
    exit_pos    EQU 10h

    ln_bot EQU 18h

    ps_cont    EQU 0Ah
    ps_le    EQU 0Eh

    ; teclas del menú
    F_1         EQU 3Bh
    arriba      EQU 48h
    abajo    EQU 50h

    F_2         EQU 3Ch

    ;
    cambio_arriba  EQU 01h
    cambio_der  EQU 02h 
    cambio_lef  EQU 03h
    cambio_rig  EQU 04h
    desp  db 0
   
  
    flecha       db 10h,0

    ;controles por defecto: flechas (arriba,izquierda,derecha,abajo)
    key_up      db 48h
    key_down    db 50h
    key_right   db 4Dh
    key_left    db 4Bh

    
    lv_ing   db 20h dup (0),0
    kb_lv   db 21h,20h,22h dup (0),0
    
    handle_lv  dw 0000
    g_counter   dw 0000
    g_counter2  dw 0000
    g_buffer    db 20h dup(0),0
    g_buffer2   db 20h dup(0),0
    ;
    caja_xpos    db 1Eh  dup (0FFh),0FFh
    caja_ypos    db 1Eh  dup (0FFh),0FFh
    obj_xpos    db 1Eh  dup (0FFh),0FFh
    obj_ypos    db 1Eh  dup (0FFh),0FFh
    ;
    pared_xpos    db 0FFh dup (0FFh),0FFh
    pared_ypos    db 0FFh dup (0FFh),0FFh
    suelo_xpos    db 0FFh dup (0FFh),0FFh
    suelo_ypos    db 0FFh dup (0FFh),0FFh

    ;num de objetos existentes
    caja_cant       db 0,0
    obj_cant       db 0,0
    pared_cant       db 0,0
    piso_cant       db 0,0
    
    ; jug
    jug_xpos    db 0
    jug_ypos    db 0
    ply_over    db 0,0 

    ;Temps
    tmp_x       db 0,0
    tmp_y       db 0,0
    tmp_xp      db 0
    tmp_yp      db 0

    tmp_xb      db 0
    tmp_yb      db 0
    
    tmp_char    db 0a dup (0),0

    lv_actual    db 0 
    mapa_actual    dw 0000
    
    timer       db 0
    secs        db 0
    mins        db 0
    hrs         db 0
    secs2b      dw 0000
    mins2b      dw 0000
    hrs2b       dw 0000

.CODE
.STARTUP

Start:
    mov AX, @DATA
    mov DS,AX
    mov ES,AX

    mov AH,00h
    call InitVideo
    ;jmp Intro
    jmp menu_principal

Intro:
    
    mPrint 00h,ln_bot,datos,0f
    mov AH,86h      ; wait CX:DX microsegundos 
    mov CX, 80h
    mov DX, 1E84h   ; 1E8480 -> 2 millones us (2 segundos)
    int 15h 

    call InitVideo  ; usandolo como clear screen xd
    jmp menu_principal

menu_principal:
    mPrint 0Ch,player_pos,inicio_juego,0f
    mPrint 0Ch,load_pos,cargar_nivel,0f
    mPrint 0Ch,cnf_pos,config,0f
    mPrint 0Ch,hs_pos,puntaje_alto,0f
    mPrint 0Ch,exit_pos,salir,0d
    mPrint 00h,ln_bot,datos,08          ;imprimir datos en la última linea
    mPrint 0Ah,player_pos,flecha,0a
loop_menu:
    jmp obtener_entrada_menu

; leer los teclazos en el menú
obtener_entrada_menu:
    mov AH,12h ;test Control/Shift (resultado en AX)
    int 16h
    mov BX,AX ; guardar AX

    mov AH,10h ; Leer teclado (espera input) en AX -> AH : Scan Code , AL : ASCII
    int 16h

revisar_menu:
    cmp AH,arriba  ; flecha arriba
    je flecha_arriba_menu
    cmp AH,abajo  ; flecha abajo
    je flecha_abajo_menu
    cmp AH,F_1
    je op_seleccionada_menu
    jmp loop_menu

flecha_arriba_menu:
    get_cursor_pos
    mPrint 0Ah,DH,vacio,0a
    cmp DH,player_pos
    je MoveToPos5
    sub DH,02h
    mPrint 0Ah,DH,flecha,0a
    jmp FinalCheckflechaUp
    MoveToPos5:
        mPrint 0Ah,DH,vacio,0a
        mPrint 0Ah,exit_pos,flecha,0a
        jmp FinalCheckflechaUp
    FinalCheckflechaUp:
        jmp loop_menu

flecha_abajo_menu:
    get_cursor_pos
    mPrint 0Ah,DH,vacio,0a
    cmp DH,exit_pos
    je MoveToPos1
    add DH,02h
    mPrint 0Ah,DH,flecha,0a
    jmp FinalCheckflechaDown
    MoveToPos1:
        mPrint 0Ah,DH,vacio,0a
        mPrint 0Ah,player_pos,flecha,0a
        jmp FinalCheckflechaUp
    FinalCheckflechaDown:
        jmp loop_menu
        
op_seleccionada_menu:
    get_cursor_pos
    cmp DH,player_pos
    je iniciar_game
    cmp DH,load_pos
    je iniciar_lv_ingresado
    cmp DH,exit_pos
    je Final
    jmp loop_menu

iniciar_game:
    mov AH,00h  ; nivel 1
    mov lv_actual,AH
    call parsear_nivel 
    jmp loop_game

iniciar_lv_ingresado:
    call InitVideo
    clear_kb_buffer kb_lv,20h
    mPrint 3h,8h,prompt_lv,0f
    mover_cursor 3h,0Ah
    mov AH,0Ah
    mov DX,offset kb_lv
    int 21h

    lea SI, kb_lv
    add SI,02h
    lea DI, lv_ing

    quitar_carry:
        lodsb
        cmp AL,0d
        je seguir_lv_ingresado
        cmp AL,0a
        je seguir_lv_ingresado
        cmp AL,0h
        je seguir_lv_ingresado
        stosb
        jmp quitar_carry
    seguir_lv_ingresado:
    mov AH,03h  
    call parsear_nivel 
    jmp loop_game

loop_game:
    call GetTime
    mov ah,11h
    int 16h
    jz loop_game 
    mov desp,00h
    call jug_step_on
    mov AH,10h
    int 16h
    cmp AH,F_2
    je menu_pausa
    cmp AH,key_up
    jnz arriba_n
    dec jug_ypos
    mov desp,cambio_arriba
    jmp pos_final 
    arriba_n:
        cmp AH,key_down
        jnz abajo_n
        inc jug_ypos
        mov desp,cambio_der
    abajo_n:
        cmp AH,key_left
        jnz izq_n
        dec jug_xpos
        mov desp,cambio_lef
    izq_n:
        cmp AH,key_right
        jnz pos_final
        inc jug_xpos
        mov desp,cambio_rig
    pos_final:    
        call revisar_choque 
        call actualizar_movs
        call render_jugador

    jmp loop_game

RenderSprite:		
    push ES
    push DS
	mov AX,0A000h
	mov ES,AX
	mov AX,@CODE
	mov DS,AX
	
	push DX	
    mov AX,08h
    mul DH
    mov DI,AX
        
    mov AX,0A00h
    mov BX,00h
    add BL,DL
    mul BX
    add DI,AX

	pop DX
	
	mov CL,08h			
dibujar_y:
	push DI
    mov CH,08h		    
dibujar_x:				
    mov AL,DS:[SI]
    mov ES:[DI],AL
    inc SI
    inc DI
    dec CH
    jnz dibujar_x ;pixel horizontal 
	pop DI
	add DI,0140h			
	inc BL
	dec CL
	jnz dibujar_y
    pop ES
    pop DS
	ret		
parsear_nivel:
    call limpiar_assets 
    cmp AH,00h
    je LvlOne
    cmp AH,01h
    je LvlTwo
    cmp AH,02h
    je LvlThree
    cmp AH,03h
    je LvlArb
 
    LvlOne:    
        mov DX, offset lvl1_name
        jmp cargar_archivo

    LvlTwo:
        mov DX, offset lvl2_name
        jmp cargar_archivo

    LvlThree:
        mov DX, offset lvl3_name
        jmp cargar_archivo

    LvlArb:
        lea DX, lv_ing
        jmp cargar_archivo

    cargar_archivo:
        mov AL, 2
        mov AH, 3Dh
        int 21h
        mov [handle_lv], AX
        mov BX,[handle_lv]
        jc menu_principal ; el archivo a abrir no fue encontrado
        call InitVideo
    leer_entrada:
        limpiar_buffer tmp_char,0a
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h
        jc term_leer  
        cmp AX,0000h      
        je term_leer

        call saltar_espacio
        cmp tmp_char,'c' 
        je Readcaja
        cmp tmp_char,'j' 
        je Readjugador
        cmp tmp_char,'p' 
        je Readpared
        cmp tmp_char,'o' 
        je ReadObjective
        cmp tmp_char,'s' 
        je Readsuelo
        ret
    ;; 
    Readcaja:
        mov AH,42h
        mov AL,01h
        mov DX,0003h 
        mov CX,0000h 
        int 21h

        call leer_xy

        cmp caja_cant,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,caja_xpos
        lea DI, tmp_x
        call agregar_arr

        lea SI,caja_ypos
        lea DI, tmp_y
        call agregar_arr

        inc caja_cant

        pop SI
        pop DI
        jmp leer_entrada
    Readjugador:
        mov AH,42h
        mov AL,01h
        mov DX,0006h 
        mov CX,0000h 
        int 21h

        call leer_xy

        mov AL,[tmp_x] 
        mov AH,[tmp_y] 
        mov [jug_xpos],AL
        mov [jug_ypos],AH
        jmp leer_entrada
    Readpared:
        mov AH,42h
        mov AL,01h
        mov DX,0004h 
        mov CX,0000h 
        int 21h

        call leer_xy

        cmp pared_cant,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,pared_xpos
        lea DI, tmp_x
        call agregar_arr

        lea SI,pared_ypos
        lea DI, tmp_y
        call agregar_arr

        pop SI
        pop DI
        jmp leer_entrada
    ReadObjective:
        mov AH,42h
        mov AL,01h
        mov DX,0007h
        mov CX,0000h 
        int 21h

        call leer_xy

        cmp obj_cant,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,obj_xpos
        lea DI, tmp_x
        call agregar_arr

        lea SI,obj_ypos
        lea DI, tmp_y
        call agregar_arr

        pop SI
        pop DI
        jmp leer_entrada
    Readsuelo:
        mov AH,42h
        mov AL,01h
        mov DX,0004h 
        mov CX,0000h 
        int 21h

        call leer_xy

        cmp piso_cant,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,suelo_xpos
        lea DI, tmp_x
        call agregar_arr

        lea SI,suelo_ypos
        lea DI, tmp_y
        call agregar_arr

        pop SI
        pop DI
        jmp leer_entrada

    ObjError:
        ret

    term_leer:
        call render_archivos
        ret

render_archivos:
    call InitVideo 
    call render_paredes
    call render_suelo
    call render_obj
    call render_cajas
    call render_jugador
    mPrint 00h,ln_bot,short_datos,08
    ret

render_suelo:
    mov g_counter,0000h ; contador  SI 
    render_sueloTile:
    ; suelo_xpos , suelo_ypos

    render_pos suelo_xpos,suelo_ypos,g_counter

    xor AX,AX
    xor SI,SI
    lea SI,suelo
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    inc g_counter
    jmp render_sueloTile
    Finishsuelo:
        mov g_counter,0000h
        ret

render_paredes:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderparedTile:
    ; pared_xpos , pared_ypos

    render_pos pared_xpos,pared_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,pared
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderparedTile
    Finishpareds:
        mov g_counter,0000h
        ret

render_cajas:
    mov g_counter,0000h ; contador para imprimir SI 
    RendercajaTile:
    ; pared_xpos , pared_ypos

    render_pos caja_xpos,caja_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,caja
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RendercajaTile
    Finishcajaes:
        mov g_counter,0000h
        ret

render_obj:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderObjTile:
    ; pared_xpos , pared_ypos

    render_pos obj_xpos,obj_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,objetivo
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderObjTile
    FinishObjs:
        mov g_counter,0000h
        ret

render_jugador:
    lea SI,jugador
    mov DH,[jug_xpos]
    mov DL,[jug_ypos]
    mov tmp_xp,DH
    mov tmp_yp,DL
    call RenderSprite
    ret
 

revisar_choque: 
    call pared_encontrar
    call choque_cajas
    call revisar_gana
    ret

; Verifica si hay una pared, impidiendo el moviento o no dado el caso
pared_encontrar:
    mov g_counter,0000h
    lea SI,pared_xpos
    encontrar_pared_x:
        lodsb
        cmp AL,jug_xpos
        je encontrar_pared_y
        cmp AL,0FFh
        je si_mover_pared
        inc g_counter
        jmp encontrar_pared_x
    encontrar_pared_y:
        push SI
        xor SI,SI
        lea SI,pared_ypos
        add SI,g_counter
        lodsb
        cmp AL,jug_ypos
        je no_mover_pared
        pop SI
        inc g_counter
        jmp encontrar_pared_x
    no_mover_pared:
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov jug_xpos,AH
        mov jug_ypos,AL
    si_mover_pared:
        ret
        
    ret


choque_cajas: 
    ;  caja con un potencial movimiento
    ; jug_xpos , jug_ypos
    encontrar_caja:
    mov g_counter,0000h
    lea SI,caja_xpos
    encontrar_caja_x:
        lodsb
        cmp AL,jug_xpos
        je encontrar_caja_y
        cmp AL,0FFh
        je no_encontro_caja
        inc g_counter
        jmp encontrar_caja_x
    encontrar_caja_y:
        push SI
        xor SI,SI
        lea SI,caja_ypos
        add SI,g_counter
        lodsb
        cmp AL,jug_ypos
        je si_encontro_caja
        pop SI
        inc g_counter
        jmp encontrar_caja_x
    no_encontro_caja:
        ret
    si_encontro_caja:
        pop SI
        lea SI,caja_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL
        lea SI,caja_ypos
        add SI,g_counter
        lodsb

        
        mov tmp_yb,AL
        cmp desp,cambio_arriba
        je CheckMoveUp
        cmp desp,cambio_der
        je CheckMoveDown
        cmp desp,cambio_lef
        je CheckMoveLeft
        cmp desp,cambio_rig
        je CheckMoveRight
        ret
    ; suma o resta 
    CheckMoveUp: ; arriba
        dec tmp_yb
        jmp CheckcajaMoves
    CheckMoveDown: ;  abajo
        inc tmp_yb
        jmp CheckcajaMoves
    CheckMoveLeft: ; izquierda
        dec tmp_xb
        jmp CheckcajaMoves
    CheckMoveRight: ;  derecha
        inc tmp_xb
        jmp CheckcajaMoves
    ; validar movimientos
    CheckcajaMoves:
        call encontrar_cajaNextAt
        cmp AH,01h
        je no_mover_caja
        call pared_encontrarNextAt
        cmp AH,01h
        je no_mover_caja

       
        lea BX,caja_xpos
        add BX,g_counter
        mov AH,tmp_xb
        mov [BX],AH

        
        lea BX,caja_ypos
        add BX,g_counter
        mov AH,tmp_yb
        mov [BX],AH
        
        ;caja en su nueva posición
        mov DH,tmp_xb
        mov DL,tmp_yb
        lea SI,caja
        call RenderSprite

        ret
    no_mover_caja:
        ; resetear la posición del jugador
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov jug_xpos,AH
        mov jug_ypos,AL
        ret


encontrar_cajaNextAt:
    mov g_counter2,0000h
    lea SI,caja_xpos
    encontrar_caja_xAt:
        lodsb
        cmp AL,tmp_xb
        je encontrar_caja_yAt
        cmp AL,0FFh
        je no_encontro_cajaAt
        inc g_counter2
        jmp encontrar_caja_xAt
    encontrar_caja_yAt:
        push SI
        xor SI,SI
        lea SI,caja_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je si_encontro_cajaAt
        pop SI
        inc g_counter2
        jmp encontrar_caja_xAt
    no_encontro_cajaAt:
        mov AH,00h
        ret
    si_encontro_cajaAt:
        pop SI
        mov AH,01h
        ret


pared_encontrarNextAt:
    mov g_counter2,0000h
    lea SI,pared_xpos
    encontrar_pared_xAt:
        lodsb
        cmp AL,tmp_xb
        je encontrar_pared_yAt
        cmp AL,0FFh
        je si_mover_paredAt
        inc g_counter2
        jmp encontrar_pared_xAt
    encontrar_pared_yAt:
        push SI
        xor SI,SI
        lea SI,pared_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je no_mover_paredAt
        pop SI
        inc g_counter2
        jmp encontrar_pared_xAt
    no_mover_paredAt:
        pop SI
        mov AH,01h
        ret
    si_mover_paredAt:
        mov AH,00h
        ret


revisar_gana:
    mov g_counter,0000h
    WinStateLoop:
        lea SI,caja_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL

        cmp tmp_xb,0FFh 
        je jug_gana

        lea SI,caja_ypos
        add SI,g_counter
        lodsb
        mov tmp_yb,AL

        mov g_counter2,0000h
        estado_gana_x:
            lea SI,obj_xpos
            add SI,g_counter2
            lodsb
            cmp tmp_xb,AL
            je estado_gana_y
            cmp AL,0FFh
            je sin_ganar_sigue
            inc g_counter2
            jmp estado_gana_x
        estado_gana_y:
            lea SI,obj_ypos
            add SI,g_counter2
            lodsb
            cmp tmp_yb,AL
            je si_encuentra
            inc g_counter2
            jmp estado_gana_x
        si_encuentra:
            inc g_counter
            jmp WinStateLoop

    sin_ganar_sigue:
        ret

    jug_gana:
        jmp msg_ganaste

msg_ganaste:
    mPrint 10h,0Bh,ganaste,0f      
    cmp lv_actual,02h
    jb GoToNextLevel
    mov lv_actual,00h
    call InitVideo
    jmp menu_principal
    GoToNextLevel:
        inc lv_actual
        mov AH,lv_actual
        call parsear_nivel
        ret

actualizar_movs:
    mov AH,tmp_xp
    cmp AH,jug_xpos
    je comparar_y
    inc mapa_actual 
    jmp reenderizar_movs
    comparar_y:
        mov AL,tmp_yp
        cmp AL,jug_ypos
        je reenderizar_movs
        inc mapa_actual
    reenderizar_movs:
        cmp mapa_actual,0064h
        jb TriplePad
        cmp mapa_actual,03E8h
        jb DoublePad
        cmp mapa_actual,2710h
        jb SinglePad
        ;no pad
        itoa_buffer mapa_actual,g_buffer2
        mPrint 22h,00h,g_buffer2,0f
        ret
        TriplePad:
            mPrint 22h,00h,pad3,0f
            itoa_buffer mapa_actual,g_buffer2
            mPrint 25h,00h,g_buffer2,0f
            ret
        DoublePad:
            mPrint 22h,00h,pad2,0f
            itoa_buffer mapa_actual,g_buffer2
            mPrint 24h,00h,g_buffer2,0f
            mPrint 27h,00h,vacio,0f
            ret
        SinglePad:
            mPrint 22h,00h,zeropad,0f
            itoa_buffer mapa_actual,g_buffer2
            mPrint 23h,00h,g_buffer2,0f
            ret
    ret


jug_step_on:
    mov g_counter,0000h
    lea SI,obj_xpos
    x_step:
        lodsb
        cmp AL,tmp_xp
        je y_step
        cmp AL,0FFh
        je Steppingsuelo
        inc g_counter
        jmp x_step
    y_step:
        push SI
        xor SI,SI
        lea SI,obj_ypos
        add SI,g_counter
        lodsb
        cmp AL,tmp_yp
        je SteppingObj
        pop SI
        inc g_counter
        jmp x_step

    SteppingObj:
        pop SI
        xor AX,AX
        lea SI, objetivo
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
    Steppingsuelo:
        lea SI, suelo
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
        
    ret

menu_pausa:
    call InitVideo
    mPrint 0Ch,ps_cont,continuar,0f
    mPrint 0Ch,ps_le,salir,0d
    mPrint 0Ah,ps_cont,flecha,0a
    jmp pausa_llave

pausa_llave:
    mov AH,12h 
    int 16h
    mov BX,AX 

    mov AH,10h 
    int 16h

revisar_pausa_entrada:
    cmp AH,arriba  ; flecha arriba
    je revisar_flecha_pausa
    cmp AH,abajo  ; flecha abajo
    je revisar_flecha_pausa
    cmp AH,F_1
    je seleccionado_pausa
    jmp pausa_llave

revisar_flecha_pausa:
    get_cursor_pos
    mPrint 0Ah,DH,vacio,0a
    cmp DH,load_pos
    je MoveToLeave
    mPrint 0Ah,ps_le,vacio,0a
    mPrint 0Ah,ps_cont,flecha,0a
    jmp Finalrevisar_flecha_pausa
    MoveToLeave:
        mPrint 0Ah,ps_cont,vacio,0a
        mPrint 0Ah,ps_le,flecha,0a
        jmp Finalrevisar_flecha_pausa
    Finalrevisar_flecha_pausa:
        jmp pausa_llave
 
seleccionado_pausa:
    get_cursor_pos
    cmp DH,ps_cont
    je render_seguir
    cmp DH,ps_le
    je limpiar_salir
    jmp revisar_pausa_entrada
    render_seguir:
        call render_archivos
        jmp loop_game
    limpiar_salir:
        call InitVideo
        jmp menu_principal


saltar_espacio:
    comparar_espacio:
        cmp tmp_char, 0a
        je si_saltar
        cmp tmp_char,' '
        jne Finishsaltar_espacio
    si_saltar:
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h

        jc term_leer  ; carry flag si hay error
        cmp AX,0000h      
        je term_leer

        jmp comparar_espacio
    Finishsaltar_espacio:
        ret


leer_xy:
    limpiar_buffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call saltar_espacio

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    
    buffer_atoi tmp_char,tmp_x


    limpiar_buffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call saltar_espacio
    
    mov AH,42h
    mov AL,01h
    mov DX,0001h
    mov CX,0000h 
    int 21h

    limpiar_buffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h

    call saltar_espacio

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    buffer_atoi tmp_char,tmp_y
    inc tmp_y
    limpiar_buffer tmp_char,0a
    ret


agregar_arr:
    push DI 
    push SI

    mov DI,SI   
    mov AH,00h  ;contador de posiciones
    FindZero:   
        lodsb
        cmp AL,0FFh      ;AL es FF (255)
        je FoundZero
        inc AH          
        jmp FindZero
    FoundZero:
        pop DI
        pop SI
        mov AL,AH   
        mov AH,00h  

        add DI,AX   ; 00NNh
        movsb       
        ret
PrintStr:
    getChar: 
        lodsb       
        cmp AL,0    
        je finishedPrint 
        
        mov AH,0Eh  
        mov BH,00h 
        int 10h

        jmp getChar
    finishedPrint:
        ret

atoi:
    xor BX,BX
    atoi_1:
        lodsb   

        cmp AL,'0'
        jb noascii
        cmp AL,'9'
        ja noascii

        sub AL,30h
        cbw
        push AX
        mov AX,BX
        jc of
        mov CX,0Ah
        mul CX
        jc of
        mov BX,AX
        pop AX
        add BX,AX
        jc of
        jmp atoi_1
    noascii:
        ret 
    of:
        pop AX      
        mov AH,01h
        ret

 
itoa: 
    xor CX,CX  ;CX = 0
    itoa_1:
        cmp AX,0
        je itoa_2            
        xor DX,DX
        push BX
        mov BX,0Ah
        div BX
        pop BX
        push DX
        inc CX
        jmp itoa_1

    itoa_2:
        cmp CX,0
        ja itoa_3
        mov AX,'0'
        mov [BX],AX
        inc BX
        jmp itoa_4

    itoa_3:
        pop AX
        add AX,30h
        mov [BX],AX
        inc BX
        loop itoa_3
    itoa_4:
        mov AX,0
        mov [BX],AX
        ret


InitVideo:
    mov AH, 00h
    mov AL, 13h
    int 10h
    ret


RestoreVideo:
    mov AH,00h
    mov AL,03h
    int 10h
    ret


limpiar_assets:
    clear_game_buffer caja_xpos,1Eh
    clear_game_buffer caja_ypos,1Eh
    clear_game_buffer obj_xpos,1Eh
    clear_game_buffer obj_ypos,1Eh
    clear_game_buffer pared_xpos,0FFh
    clear_game_buffer pared_ypos,0FFh
    clear_game_buffer suelo_xpos,0FFh
    clear_game_buffer suelo_ypos,0FFh
    mov jug_xpos,00h
    mov jug_ypos,00h
    mov obj_cant,00h
    mov caja_cant,00h
    mov pared_cant,00h
    mov piso_cant,00h
    mov secs,00h
    mov mins,00h
    mov hrs,00h
    mov timer,00h
    mov mapa_actual,0000h
    ret

GetTime:
    mov AH,2Ch
    int 21h
    cmp DH,timer
    jne UpdateTimer
    ret
    UpdateTimer:
        mov timer,DH
        inc secs
        cmp secs,3Ch ; comparar con 60
        jge UpdateMinutes
        jmp PrintNewHour
    UpdateMinutes:
        mov secs,00h
        inc mins
        cmp mins,3Ch
        jge UpdateHrs
        jmp PrintNewHour
    UpdateHrs:
        mov mins,00h
        inc hrs     
    PrintNewHour:
        mov AL,secs
        cbw
        mov secs2b,AX
        mov AL,mins
        cbw
        mov mins2b,AX
        mov AL,hrs
        cbw
        mov hrs2b,AX
        mPrint 24h,ln_bot,dospuntos,0f

        itoa_buffer secs2b,g_buffer2
        mPrint 25h,ln_bot,g_buffer2,0f

        mPrint 21h,ln_bot,dospuntos,0f

        itoa_buffer mins2b,g_buffer2
        mPrint 22h,ln_bot,g_buffer2,0f
        

        itoa_buffer hrs2b,g_buffer2
        mPrint 1Fh,ln_bot,g_buffer2,0f
        ret

printTextStr:
    TMgetchar:
        lodsb
        cmp AL,0a
        je nueva_linea 
        cmp AL,0
        je time_finished
        mov AH, 0Eh
        int 10h
        jmp TMgetchar
    
    nueva_linea:              
        mov AL, 0d
        mov AH, 0Eh
        int 10h
        mov AL, 0a
        mov AH, 0Eh
        int 10h
        jmp TMgetchar

    time_finished:
        ret
nule_padding:
    cmp AX,0Ah
    jb addnule_padding
    limpiar_buffer g_buffer,20h
    lea DI,g_buffer 
    ret
addnule_padding: 
    limpiar_buffer g_buffer,20h
    lea DI,g_buffer 
    addto_buffer zeropad,01h,0 
    ret



Final:
;    call RestoreVideo
    .EXIT

;Sprites

pared:    
    db   0c, 0c, 0e, 0e, 0c, 0c, 0e, 0e
    db   0c, 0e, 0e, 0c, 0c, 0e, 0e, 0c
    db   0e, 0e, 0c, 0c, 0e, 0e, 0c, 0c
    db   0e, 0c, 0c, 0e, 0e, 0c, 0c, 0e
    db   0c, 0c, 0e, 0e, 0c, 0c, 0e, 0e
    db   0c, 0e, 0e, 0c, 0c, 0e, 0e, 0c
    db   0e, 0e, 0c, 0c, 0e, 0e, 0c, 0c
    db   0e, 0c, 0c, 0e, 0e, 0c, 0c, 0e

caja:
    db   0f, 0f, 0f, 03, 0f, 0f, 0f, 0f
    db   0f, 0f, 03, 0b, 03, 0f, 0f, 0f
    db   0f, 0f, 03, 0b, 03, 0f, 0f, 0f
    db   0f, 0f, 03, 0b, 03, 0f, 0f, 0f
    db   0f, 0f, 03, 0b, 03, 0f, 0f, 0f
    db   03, 03, 03, 03, 03, 03, 03, 0f
    db   0f, 0f, 03, 0b, 03, 0f, 0f, 0f
    db   0f, 0f, 0f, 03, 0f, 0f, 0f, 0f

suelo:
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f
    db   0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f

objetivo:
                  db  0f,0f,0f,0f,0f,0f,0f,0f
                  db  0f,28,0f,0f,0f,0f,28,0f
                  db  0f,0f,28,0f,0f,28,0f,0f
                  db  0f,0f,0f,28,28,0f,0f,0f
                  db  0f,0f,0f,28,28,0f,0f,0f
                  db  0f,0f,28,0f,0f,28,0f,0f
                  db  0f,28,0f,0f,0f,0f,28,0f
                  db  0f,0f,0f,0f,0f,0f,0f,0f
   


jugador:
    db   0f, 0f, 0f, 06, 06, 04, 0f, 0f
    db   0f, 0f, 0f, 54, 54, 0f, 0f, 0f
    db   0f, 0f, 0b, 0b, 0b, 0b, 0b, 0f
    db   0f, 0f, 54, 0b, 0b, 0b, 54, 0f
    db   0f, 0f, 54, 0b, 0b, 0b, 54, 0f
    db   0f, 0f, 0f, 01, 0f, 01, 0f, 0f
    db   0f, 0f, 0f, 01, 0f, 01, 0f, 0f
    db   0f, 0f, 0f, 10, 0f, 10, 0f, 0f
    

END
