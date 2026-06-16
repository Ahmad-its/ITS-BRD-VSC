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


zeit_init			DCB		"00:00:00", 0
zeit				DCB		"00:00:00", 0
zeit_alt			DCB		"  :  :  ", 0 

TIME_10MIN			equ		60000000   ; 10 Min
TIME_1MIN			equ		6000000   ; 1 Min
TIME_1s				equ		1000000   ; 1 Min
TIME_01s			equ		100000   ; 1 Min
TIME_001s			equ		10000   ; 1 Min
TIME_0001s			equ		1000   ; 1 Min
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

		mov	r0, #10
		mov		r1, #6
		bl lcdGotoXY
		
		ldr		r0, =zeit_init
		bl lcdPrintS
superloop
        
        BL      check_button                        ; Rückgabe in R0: 1 = gedrückt, 0 = nicht gedrückt

if_zustand
			ldr		r0, =zustand
			ldrb	r5, [r0]
			cmp 	r5, #1
			BEQ		then_Running
			cmp 	r5, #2
			BEQ		then_Hold
			cmp 	r5, #3	
			BEQ		then_Init	
			b		else_zustand
then_Init
			;MOV     R0, R4 
			bl		init
			b		endif_zustand	
then_Running
			;MOV     R0, R4 
			bl		run
			b		endif_zustand
then_Hold
			;MOV     R0, R4 		
			bl		hold
			b		endif_zustand
else_zustand
			bl		init
			b		endif_zustand
endif_zustand

	
		BAL		superloop
		ENDP
;*******************************************************************************
; 1. FUNKTION: check_button
;*******************************************************************************
check_button PROC
        PUSH    {R0, r1, r2, r3, r4, r5, LR}                           ; Sichert R1 und R2 auf dem Stack

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
		B       btn_end
endif_Check1

if_Check2	
		mov 	r4, #64
		and		r4, r3
		cmp 	r4, #0			
		bne		endif_Check2
then_Check2
if_init_on
		ldrb	r5, [r1]
		cmp		r5, #1
		bne		endif_Check2
then_init_on			
		MOV		r2, #2

		strb	r2, [r1]
		B       btn_end
endif_init_on
endif_Check2

if_Check3	
		mov 	r4, #32
		and		r4, r3
		cmp 	r4, #0			
		bne		endif_Check3
then_Check3
		MOV		r2, #3
		strb	r2, [r1]
		B       btn_end
endif_Check3
btn_end
        POP     {R0, r1, r2, r3, r4, r5, LR}                      ; Register wiederherstellen
        BX      LR                              ; Zurück zur Hauptschleife
        ENDP
;*********************************************************
init PROC
		PUSH	{r0, r1, r2,r3, r4, r5, r6, LR}
		
		;LEDs steuern
		LDR     r1, =GPIO_D_CLR
		mov		r2, #3
		strb	r2, [r1]
		
		mov		r0, #10
		mov		r1, #6
		bl		lcdGotoXY
		
		
		ldr 	R1,=TIM2_ERG   			; Restart timer	
		mov		R0,#0x01
		strh	R0,[R1]					; Set UG Bit

		;mov		r5, #0
		;ldr		r0, =zustand
		;strb	r5, [r0]
		;ldr		r0, =zeit_init
		;bl		lcdPrintS

	
for_rs
				ldr		r3, =zeit
				ldr		r4, =zeit_init
				mov		r5, #0
				

until_rs		
				cmp		r5, #8
				BEQ		endfor_rs
do_rs
				ldrb	r6, [r4, r5]
				strb	r6, [r3, r5]

step_rs			
				add		r5, r5, #1
				B		until_rs
endfor_rs

		bl	print_Time

		pop {r0, r1, r2, r3, r4, r5, r6, pc}
		ENDP
		
		
hold PROC
		PUSH	{r0, r1, r2, r3, lr}
		
		
		; LEDs steuern
		LDR     r1, =GPIO_D_SET 
		mov		r2, #3
		strb	r2, [r1]
		
		;Display steuern
		
		bl		print_Time
		
		pop {r0, r1, r2, r3 , pc}
		ENDP
		
run PROC

		PUSH	{r0, r1, r2, lr}
		
		; LEDs steuern
		LDR     r0, =GPIO_D_SET 
		LDR     r1, =GPIO_D_CLR
		mov		r2, #2
		strb	r2, [r1]
		mov		r2, #1
		strb	r2, [r0]
		
		;Display steuern
		;mov		r0, #10
		;mov		r1, #6
		;bl		lcdGotoXY
		
		bl		get_Time
		bl		print_Time
		
		pop {r0, r1, r2, pc}
        ENDP

get_Time PROC

		PUSH	{r0, r1, r2, r3, r4, r5, r6, r7,r8, LR}

	
		ldr 	r0, =zeit

		ldr     R1, =TIMER
		ldr     R1, [R1]    

		ldr		r2, = TIME_10MIN
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #0]
		mul		r2, r2, r3
		sub		r1, r1, r2

		ldr		r2, = TIME_1MIN
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #1]
		mul		r2, r2, r3
		sub		r1, r1, r2

		ldr		r2, = TIME_1s
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #3]
		mul		r2, r2, r3
		sub		r1, r1, r2

		ldr		r2, = TIME_01s
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #4]
		mul		r2, r2, r3
		sub		r1, r1, r2

		ldr		r2, = TIME_001s
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #6]
		mul		r2, r2, r3
		sub		r1, r1, r2

		ldr		r2, = TIME_0001s
		udiv	r3, r1, r2
		add 	r4, r3, #48
		strb	r4, [r0, #7]
		mul		r2, r2, r3
		sub		r1, r1, r2

		

		pop {r0, r1, r2, r3, r4, r5, r6,r7,r8,pc}
        ENDP
;****************************	
print_Time PROC
		PUSH {r0, r2, r3, r4, r5, r6, r7, r8, LR}
for_print
			mov r5, #0
until_print
			cmp	r5, #8
			BEQ	enddo_print
	
do_print

if_gleich	ldr r8, = zeit
			ldr r6, = zeit_alt
			ldrb r2, [r8, r5]
			ldrb r4, [r6, r5]
			cmp r2, r4
			BEQ done
then_gleich
			strb r2, [r6, r5]
			add		r7, r5, #10
			mov		r0, r7
			mov		r1, #6
			bl		lcdGotoXY

			ldrb r0, [r8, r5]
			bl	lcdPrintC	

done

step_print
			add r5, r5, #1
			B	until_print
enddo_print
		pop {r0, r2, r3, r4, r5, r6, r7, r8, pc}
		ENDP
		ALIGN
		END