;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf  
;* Version            : V1.0
;* Date               : 16.05.2022
;* Modified by        : Thomas Lehmann, 2024-07-12
;* Description        : This is the frame for the last assignment.
;                     : Einfaches Lauflicht.
;
;*******************************************************************************
    EXTERN initITSboard
    EXTERN lcdPrintS            ;Display ausgabe
    EXTERN GUI_init
    EXTERN TP_Init
    EXTERN delay
; Lauflicht.2        
; Define address of selected GPIO and Timer registers
PERIPH_BASE         equ 0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE     equ (PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE          equ (AHB1PERIPH_BASE + 0x0C00)
GPIOE_BASE          equ (AHB1PERIPH_BASE + 0x1000)
GPIOF_BASE          equ (AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)

GPIO_F_PIN          equ (GPIOF_BASE + 0x10)

GPIO_D_PIN          equ (GPIOD_BASE + 0x10)
GPIO_D_SET          equ (GPIOD_BASE + 0x18)
GPIO_D_CLR          equ (GPIOD_BASE + 0x1A) 
    
GPIO_E_PIN          equ (GPIOE_BASE + 0x10)
GPIO_E_SET          equ (GPIOE_BASE + 0x18)
GPIO_E_CLR          equ (GPIOE_BASE + 0x1A)     



;********************************************
; Data section, aligned on 4-byte boundery
;********************************************   
    AREA MyData, DATA, align = 2
TestPattern DCW     0x8000, 0x7000, 0x5000, 0xab00, 0xcccc

;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3

;--------------------------------------------
; main subroutine
;--------------------------------------------

        
; Unterprogramm Lauftlicht
;
; Einfaches Lauflicht, das ein Bitmuster zyklisch ueber die 
; LEDs D23 bis D8 schiebt. Das LED Muster wird nach rechts 
; geschoben. Die Frequenz betraegt 2 Hz.
;
; IN R0  Die unteren 16 Bits von R0 speichern das Muster, mit
;        dem die LEDs initialisiert werden.
; IN R1  Anzahl Schritte, die das Lauflicht laufen soll.
;--------------------------------------------       
;

DelayTime   EQU     500

;*******************************************
Lauflicht   PROC
;*******************************************
            PUSH    {R4, R5, R6, LR} 
            
            
            MOV     R4, R0          
            MOV     R5, R1          
for         
until       
            CMP     R5, #0          
            beq     endfor          

do          
            
			
            LDR     R6, =0xFFFF
            AND     R4, R4, R6

            MOV     R0, R4
            BL      set_leds
            
           
            LDR     R0, =DelayTime 
            BL      delay

			
            AND     R6, R4, #1      
            LSR     R4, R4, #1     
            LSL     R6, R6, #15   
            ORR     R4, R4, R6      
            
step          
            
            
            SUB     R5, R5, #1
            B       until
endfor

           
            ;BL      clearAll
            POP     {R4, R5, R6, PC}
            ENDP

;*******************************************
clearAll    PROC
;*******************************************
            PUSH    {R4, R5, LR}  

            LDR     R5, =0xFF         
            LDR     R4, =GPIO_D_CLR
            STRH    R5, [R4]            
            LDR     R4, =GPIO_E_CLR
            STRH    R5, [R4]

            POP     {R4, R5, PC}
            ENDP

;*******************************************
set_leds    PROC
;*******************************************
            PUSH    {r4, r5, r6, LR}  

            BL      clearAll
            ; Schreibe das 16-Bit Muster aus R0 auf Port E und Port D
            LDR     r4, =GPIO_E_SET
			LSR     R5, R0, #8
            STRb    r5, [R4]

            LDR     r4, =GPIO_D_SET 
            STRb    r0, [R4]

            POP     {R4, r5, r6, PC}
            ENDP

;--------------------------------------------
; main subroutine
;--------------------------------------------
    EXPORT main [CODE]
        
main    PROC
        BL initITSboard
        LDR     R7, =TestPattern
        MOV     R8, #0                  ; Laufindex Testpattern
forever 
        CMP     R8, #5
        MOVGE   R8, #0
        
        ; Test Lauflicht
        LDRH    R0, [R7,R8,LSL #1]
        MOV     R1, #20
        BL      Lauflicht

		LDR     R0, =DelayTime
        BL      delay

        ADD     R8, #1
		BAL     forever
        ENDP 
        ALIGN
        END
