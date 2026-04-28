;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke    
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to demonstrate data transfer
;                     : and manipulation.
;                     : 
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board

    EXPORT main         ; we need this for the linker - In this context it set the entry point,too

ConstByteA  EQU 0xaffe
    
;* We need some data to work on
    AREA DATA, DATA, align=2    
VariableA   DCW 0xbeef      ;VariableA initialisieren
VariableB   DCW 0x1234      ;VariableB initialisieren
VariableC	DCW 0x00        ;VariableC initialisieren

;* We need minimal memory setup of InRootSection placed in Code Section 
    AREA  |.text|, CODE, READONLY, ALIGN = 3    
    ALIGN   
main
    BL initITSboard             ; needed by the board to setup
;* swap memory - Is there another, at least optimized approach?
    ldr     R0,=VariableA       ; Die Adresse von VariableA in R0 laden
    ldrb    R2,[R0]             ; Das erste Byte von R0 in R2 laden
    ldrb    R3,[R0,#1]          ; Das zweite Byte von R0 in R3 laden
    lsl     R2, #8              ; 8 bit nach links verschieben
    orr     R2, R3              ; R2 und R3 zusammen Kombinieren
    strh    R2,[R0]             ; R2 in R0 speichen
    
;* const in var
    mov     R5,#ConstByteA           ; Den wert von ConstByteA in R5 speichern
    ldr     R0,=VariableC            ; Die Adresse von VariableC in R0 laden
    strh    R5,[R0]                  ; R5 in R0 speichern
    ldrb    R2,[R0]                  ; Das erste Byte von R0 in R2 laden
    ldrb    R3,[R0,#1]               ; Das zweite Byte von R0 in R3 laden
    lsl     R2, #8                   ; 8 bit nach links verschieben
    orr     R2,R3                    ; R2 und R3 zusammen Kombinieren
    strh    R2,[R0]                  ; R2 in R0 speichen

    
;* Change value from x1234 to x4321
    ldr     R1,=VariableB   ; Anw09 ; Die Adresse von VariableB in R1 laden
    mov     R6, #0x3412             ; 0x3412 in R6 speichern
    strh    R6,[R1]         ; Anw0D ; R6 in R1 speichen
    b .                     ; Anw0E
    
    ALIGN
    END