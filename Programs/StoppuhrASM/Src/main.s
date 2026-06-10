;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf	
;* Version            : V1.0
;* Date               : 11.05.2022
;* Description        : Rahmen zur Loesung von GTP Woche 7-9 (Stoppuhr).
;
;*******************************************************************************

; Define address of selected GPIO and Timer registers
PERIPH_BASE     	equ	0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE 	equ	(PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE			equ	(AHB1PERIPH_BASE + 0x0C00)
GPIOF_BASE			equ	(AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)
	
GPIO_F_PIN        	equ	(GPIOF_BASE + 0x10)

GPIO_D_PIN			equ	(GPIOD_BASE + 0x10)
GPIO_D_SET			equ (GPIOD_BASE + 0x18)
GPIO_D_CLR			equ	(GPIOD_BASE + 0x1A)
	
TIMER				equ (TIM2_BASE + 0x24)   ; CNT : current time stamp (32 bit),  resolution
TIM2_PSC			equ (TIM2_BASE + 0x28)   ; Prescaler  resolution
TIM2_ERG			equ (TIM2_BASE + 0x14)   ; 16 Bit register, Bit 0 : 1 Restart Timer


    EXTERN initITSboard
    EXTERN GUI_init
	EXTERN TP_Init
	EXTERN initTimer
	EXTERN lcdSetFont
	EXTERN lcdGotoXY      		; TFT goto x y function
	EXTERN lcdPrintS			; TFT output function	
    EXTERN lcdPrintC            ; TFT output one character		
	EXTERN Delay				; Delay (ms) function


;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	AREA MyData, DATA, align = 2

DEFAULT_BRIGHTNESS	DCW     800
MY_TEXT				DCB		"Hold down different buttons from S0 to S7 and watch D8 to D15.", 0
zustand				DCB		0

txt_Init            DCB     "Init", 0
txt_Runn   		    DCB     "Runn", 0
txt_Hold			DCB		"Hold", 0


;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]
	
main	PROC

		; Initialisierung der HW
		BL		initITSboard
		ldr   	r1, =DEFAULT_BRIGHTNESS
		ldrh 	r0, [r1]
		bl   	GUI_init
		bl  	initTimer
		ldr 	R1,=TIM2_PSC   			; Set pre scaler such that 1 timer tick represents 10 us
		mov 	R0,#(90*10-1) 
		strh	R0,[R1]
		ldr 	R1,=TIM2_ERG   			; Restart timer	
		mov		R0,#0x01
		strh	R0,[R1]					; Set UG Bit
		MOV 	R0, #24
		bl  	lcdSetFont

		; Ihre Initialisierung

		; Simple test code
		;LDR 	R0,=MY_TEXT
		;BL  	lcdPrintS

		mov		r0, #12
		mov		r1, #6
		bl		lcdGotoXY

		
		ldr		r0, =txt_Init
		bl lcdPrintS
superloop
		
        
        BL      check_button                        ; Rückgabe in R0: 1 = gedrückt, 0 = nicht gedrückt

    
        BL      control_led                         ; Schaltet LED D8 ein oder aus

		BL		update_display

	
		BAL		superloop
		ENDP
;*******************************************************************************
; 1. FUNKTION: check_button
;*******************************************************************************
check_button PROC
        PUSH    {R0, r1, r2, r3, r4, LR}                           ; Sichert R1 und R2 auf dem Stack

		ldr     r0, =GPIO_F_PIN						; Adresse der Taster-Hardware laden
        ldrh    r3, [R0]							; Tasterzustände einlesen
		ldr		r1, =zustand

if_Check1
		mov 	r4, #128
		and		r4, r3
				cmp r4, #0		
		bne		endif_Check1
then_Check1
		MOV		r2, #1
		strb	r2, [r1]
		B       endif_Check3
endif_Check1
;***************************************************
if_Check2	
		mov 	r4, #64
		and		r4, r3
		cmp 	r4, #0			
		bne		endif_Check2
then_Check2
		MOV		r2, #2
		strb	r2, [r1]
		B       endif_Check3
endif_Check2
;***************************************************
if_Check3	
		mov 	r4, #32
		and		r4, r3
		cmp 	r4, #0			
		bne		endif_Check3
then_Check3
		MOV		r2, #3
		strb	r2, [r1]
		B       endif_Check3
endif_Check3

btn_end
        POP     {R0, r1, r2, r3, r4, LR}                            ; Register wiederherstellen
        BX      LR                              ; Zurück zur Hauptschleife
        ENDP

;*******************************************************************************
; 2. FUNKTION control_led
;*******************************************************************************
control_led PROC
        PUSH    {r0, r1, r2, r3, r4, LR}                            ; Sichert R2 und R3 auf dem Stack

		ldr		r1, =zustand
		ldrb	r0, [r1]                            
		LDR     r3, =GPIO_D_SET                     ; Adresse fürs Einschalten laden
		LDR     r4, =GPIO_D_CLR                     ; Adresse fürs Ausschalten laden
        ;LSL     R2, r0                              ; Verschiebe die 1 an die gewünschte LED-Stelle 

if_led       
 		CMP     r0, #1                              ; Soll die LED eingeschaltet werden?
        BEQ     thenled_Running                             ; Wenn R0 == 1, springe zu led_on
		CMP     r0, #2
		BEQ     thenled_Hold
		CMP     r0, #3
		BEQ     thenled_Init
		b 		endif_led
thenled_Init
		MOV     r2, #3
        STRH    r2, [r4]                            ; Schreibt Bitmaske -> LED geht aus
        B       endif_led
thenled_Running
		MOV     r2, #2 
        STRH    r2, [r4]
		MOV     r2, #1 
        STRH    r2, [r3]
		B       endif_led                            ; Schreibt Bitmaske -> LED geht an
thenled_Hold
		MOV     r2, #3
        STRH    r2, [r3]                            ; Schreibt Bitmaske -> LED geht an

endif_led
        POP     {r0, r1, r2, r3, r4, LR}                            ; Register wiederherstellen
        BX      LR                                  ; Zurück zur Hauptschleife
        ENDP
;*******************************************************************************
; 3. FUNKTION update_display
;*******************************************************************************
update_display PROC

		PUSH	{r0, r1, r2, r3, r4, r5, LR}
		ldr		r5, =zustand
		mov		r3, #0
if_Display	
				ldrb	r2, [r5]
				cmp r2, #1
				BEQ	then_Running
				cmp r2, #2
				BEQ	then_Hold
				cmp r2, #3	
				BEQ	then_Init	
				b	endif_Display

then_Init
				mov		r0, #12
				mov		r1, #6
				bl		lcdGotoXY
				ldr		r0, =txt_Init
				bl lcdPrintS
				strb	r3, [r5]
				b	endif_Display
then_Running
				mov		r0, #12
				mov		r1, #6
				bl		lcdGotoXY
				ldr		r0, =txt_Runn
				bl lcdPrintS
				strb	r3, [r5]
				b	endif_Display 
then_Hold		
				mov		r0, #12
				mov		r1, #6
				bl		lcdGotoXY
				ldr		r0, =txt_Hold
				bl lcdPrintS
				strb	r3, [r5]
endif_Display

		POP		{r0, r1, r2, r3, r4, r5, PC}
		;BX      LR                                  ; Zurück zur Hauptschleife
        ENDP

		ALIGN
		END