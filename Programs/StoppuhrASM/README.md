Init    00:00:00
S7      RUNNING
S6      HOLD
S5      Init (D9 und D8 aus machen)

D8      Zeitmessung aktiv (RUNNING oder HOLD ) und D9 ausmachen
D9      HOLD (D8 und D9 sind an)


;*******************************************************************
main	PROC                                       ; Beginn des Hauptprogramms

		; Initialisierung der HW
		BL		initITSboard                       ; Ruft die externe Initialisierung für das ITS-Board auf
		ldr   	r1, =DEFAULT_BRIGHTNESS            ; Lädt die Speicheradresse der Display-Helligkeit nach R1
		ldrh 	r0, [r1]                           ; Lädt den Helligkeitswert (800) als 16-Bit-Zahl nach R0
		bl   	GUI_init                           ; Ruft die Display-Initialisierung mit dem Wert aus R0 auf
		bl  	initTimer                          ; Ruft die Basis-Initialisierung für die Timer-Hardware auf
		ldr 	R1,=TIM2_PSC   			           ; Lädt die Speicheradresse des Timer-Prescaler-Registers nach R1
		mov 	R0,#(90*10-1)                      ; Lädt den Vorteiler-Wert 899 für eine 10us-Auflösung nach R0
		strh	R0,[R1]                            ; Schreibt den Vorteiler-Wert in das Prescaler-Register
		ldr 	R1,=TIM2_ERG   			           ; Lädt die Speicheradresse des Event-Generation-Registers nach R1
		mov		R0,#0x01                           ; Lädt den Wert 1 (UG-Bit setzen) nach R0
		strh	R0,[R1]					           ; Schreibt den Wert, um den Timer mit neuem Prescaler neu zu starten
		MOV 	R0, #24                            ; Lädt die gewünschte Schriftgröße 24 nach R0
		bl  	lcdSetFont                         ; Ruft die Funktion zur Änderung der Display-Schriftgröße auf

		; Ihre Initialisierung

		; Simple test code
		;LDR 	R0,=MY_TEXT
		;BL  	lcdPrintS

		mov		r0, #12                            ; Lädt Spalten-Koordinate 12 für den Cursor nach R0
		mov		r1, #6                             ; Lädt Zeilen-Koordinate 6 für den Cursor nach R1
		bl		lcdGotoXY                          ; Ruft die Funktion zur Cursor-Positionierung auf

		
		ldr		r0, =txt_Init                      ; Lädt die Speicheradresse des Strings "Init" nach R0
		bl lcdPrintS                               ; Gibt den Text "Init" an Position (12, 6) auf dem Display aus
superloop                                          ; Label für den Start der Hauptschleife (Endlosschleife)
		
        
        BL      check_button                        ; Ruft Taster-Abfrage auf (aktualisiert Zustand im RAM)

    
        BL      control_led                         ; Ruft LED-Steuerung auf (schaltet D8/D9 je nach Zustand)

		BL		update_display                     ; Ruft Display-Aktualisierung auf (zeigt aktuellen Modus-Text)

	
		BAL		superloop                          ; Springt bedingungslos zurück zum Schleifenanfang
		ENDP                                       ; Ende des Hauptprogramms
;*******************************************************************************
; 1. FUNKTION: check_button
;*******************************************************************************
check_button PROC                                  ; Beginn der Funktion zum Prüfen der Hardware-Taster
        PUSH    {R0, r1, r2, r3, r4, LR}           ; Sichert genutzte Register und Rücksprungadresse auf dem Stack

		ldr     r0, =GPIO_F_PIN						; Lädt Hardware-Adresse des Taster-Eingangsregisters nach R0
        ldrh    r3, [R0]							; Liest aktuellen Zustand aller Taster (16-Bit) nach R3 ein
		ldr		r1, =zustand                        ; Lädt Speicheradresse der RAM-Variable 'zustand' nach R1

if_Check1                                          ; --- Block: Überprüfung von Taster S7 (Bit 7) ---
		mov 	r4, #128                           ; Lädt Bitmaske für Bit 7 (Binär: 1000 0000) nach R4
		and		r4, r3                             ; R4 = R3 AND R4 (Isoliert Zustand von Taster S7 in R4)
				cmp r4, #0		                   ; Vergleicht Ergebnis mit 0 (0 = S7 gedrückt, da Low-Aktiv)
		bne		endif_Check1                       ; Wenn nicht 0 (S7 nicht gedrückt), springe zu Check 2
then_Check1                                        ; Pfad wenn S7 gedrückt wurde:
		MOV		r2, #1                             ; Lädt Zustandswert 1 (Running) nach R2
		strb	r2, [r1]                           ; Schreibt den Wert 1 in die RAM-Variable 'zustand'
		B       endif_Check3                       ; HINWEIS: Logikfehler im Code, springt mitten in S5-Pfad
endif_Check1
;***************************************************
if_Check2	                                       ; --- Block: Überprüfung von Taster S6 (Bit 6) ---
		mov 	r4, #64                            ; Lädt Bitmaske für Bit 6 (Binär: 0100 0000) nach R4
		and		r4, r3                             ; R4 = R3 AND R4 (Isoliert Zustand von Taster S6 in R4)
		cmp 	r4, #0			                   ; Vergleicht Ergebnis mit 0 (0 = S6 gedrückt)
		bne		endif_Check2                       ; Wenn nicht 0 (S6 nicht gedrückt), springe zu Check 3
then_Check2                                        ; Pfad wenn S6 gedrückt wurde:
		MOV		r2, #2                             ; Lädt Zustandswert 2 (Hold) nach R2
		strb	r2, [r1]                           ; Schreibt den Wert 2 in die RAM-Variable 'zustand'
		B       endif_Check3                       ; HINWEIS: Logikfehler im Code, springt mitten in S5-Pfad
endif_Check2
;***************************************************
if_Check3	                                       ; --- Block: Überprüfung von Taster S5 (Bit 5) ---
		mov 	r4, #32                            ; Lädt Bitmaske für Bit 5 (Binär: 0010 0000) nach R4
		and		r4, r3                             ; R4 = R3 AND R4 (Isoliert Zustand von Taster S5 in R4)
		cmp 	r4, #0			                   ; Vergleicht Ergebnis mit 0 (0 = S5 gedrückt)
		bne		endif_Check3                       ; Wenn nicht 0 (S5 nicht gedrückt), springe ans Ende
then_Check3                                        ; Pfad wenn S5 gedrückt wurde:
		MOV		r2, #3                             ; Lädt Zustandswert 3 (Init) nach R2
		strb	r2, [r1]                           ; Schreibt den Wert 3 in die RAM-Variable 'zustand'
		B       endif_Check3                       ; Springt zum direkt darunter liegenden Label
endif_Check3

btn_end                                            ; Label für das Funktionsende (wird im Code unvollständig genutzt)
        POP     {R0, r1, r2, r3, r4, LR}           ; Stellt alle gesicherten Registerwerte vom Stack wieder her
        BX      LR                                 ; Kehrt zur Hauptschleife zurück (nutzt die Adresse aus LR)
        ENDP                                       ; Ende der Funktion 'check_button'

;*******************************************************************************
; 2. FUNKTION control_led
;*******************************************************************************
control_led PROC                                   ; Beginn der Funktion zur Ansteuerung der LEDs
        PUSH    {r0, r1, r2, r3, r4, LR}           ; Sichert genutzte Register und Rücksprungadresse auf dem Stack

		ldr		r1, =zustand                        ; Lädt Speicheradresse der RAM-Variable 'zustand' nach R1
		ldrb	r0, [r1]                           ; Liest aktuellen Zustandswert (1, 2 oder 3) aus dem RAM nach R0
		LDR     r3, =GPIO_D_SET                    ; Lädt Hardware-Adresse zum Einschalten von LEDs nach R3
		LDR     r4, =GPIO_D_CLR                    ; Lädt Hardware-Adresse zum Ausschalten von LEDs nach R4
        ;LSL     R2, r0                              

if_led                                             ; --- Verzweigungs-Struktur basierend auf dem Zustand ---
 		CMP     r0, #1                             ; Prüft, ob Zustand == 1 (Running)
        BEQ     thenled_Running                    ; Wenn ja, springe zum Running-LED-Block
		CMP     r0, #2                             ; Prüft, ob Zustand == 2 (Hold)
		BEQ     thenled_Hold                       ; Wenn ja, springe zum Hold-LED-Block
		CMP     r0, #3                             ; Prüft, ob Zustand == 3 (Init)
		BEQ     thenled_Init                       ; Wenn ja, springe zum Init-LED-Block
		b 		endif_led                          ; Wenn kein Zustand passt, überspringe Schaltung
thenled_Init                                       ; --- Zustand INIT (3): Beide LEDs ausschalten ---
		MOV     r2, #3                             ; Lädt Bitmaske für LED D8 und D9 (Wert 3 = Binär 0011) nach R2
        STRH    r2, [r4]                           ; Schreibt Wert in CLR-Register -> Schaltet D8 und D9 aus
        B       endif_led                          ; Springt zum Ende der LED-Steuerung
thenled_Running                                    ; --- Zustand RUNNING (1): D8 ein, D9 aus ---
		MOV     r2, #2                             ; Lädt Bitmaske für LED D9 (Wert 2 = Binär 0010) nach R2
        STRH    r2, [r4]                           ; Schreibt Wert in CLR-Register -> Schaltet LED D9 aus
		MOV     r2, #1                             ; Lädt Bitmaske für LED D8 (Wert 1 = Binär 0001) nach R2
        STRH    r2, [r3]                           ; Schreibt Wert in SET-Register -> Schaltet LED D8 ein
		B       endif_led                          ; Springt zum Ende der LED-Steuerung
thenled_Hold                                       ; --- Zustand HOLD (2): Beide LEDs einschalten ---
		MOV     r2, #3                             ; Lädt Bitmaske für LED D8 und D9 (Wert 3 = Binär 0011) nach R2
        STRH    r2, [r3]                           ; Schreibt Wert in SET-Register -> Schaltet D8 und D9 ein

endif_led
        POP     {r0, r1, r2, r3, r4, LR}           ; Stellt die gesicherten Register wieder her
        BX      LR                                 ; Kehrt zur Hauptschleife zurück
        ENDP                                       ; Ende der Funktion 'control_led'
;*******************************************************************************
; 3. FUNKTION update_display
;*******************************************************************************
update_display PROC                                ; Beginn der Funktion zur Display-Aktualisierung
		PUSH	{r0, r1, r2, r3, r4, r5, LR}       ; Sichert Register und Rücksprungadresse auf dem Stack
		ldr		r5, =zustand                       ; Lädt Speicheradresse der RAM-Variable 'zustand' nach R5
		mov		r3, #0
if_Display	
				ldrb	r2, [r5]                   ; Aktuellen Zustand aus dem RAM lesen
				cmp r2, #1                         ; Ist Zustand == 1 (Running)?
				BEQ	then_Running                   ; Wenn ja, springe zu Running
				cmp r2, #2                         ; Ist Zustand == 2 (Hold)?
				BEQ	then_Hold                      ; Wenn ja, springe zu Hold
				cmp r2, #3	                       ; Ist Zustand == 3 (Init)?
				BEQ	then_Init                      ; Wenn ja, springe zu Init
				b	endif_Display                  ; Wenn Zustand 0 oder ungültig, nichts tun

then_Init
				mov		r0, #12                    ; X-Koordinate laden
				mov		r1, #6                     ; Y-Koordinate laden
				bl		lcdGotoXY                  ; Cursor setzen
				ldr		r0, =txt_Init              ; Adresse für "Init" laden
				bl lcdPrintS                       ; Text auf Display ausgeben
				; KORREKTUR: Die Zeile 'strb r3, [r5]' wurde gelöscht, damit der Zustand im RAM bleibt!
				b	endif_Display                  ; Zum Ausgang springen
then_Running
				mov		r0, #12                    ; X-Koordinate laden
				mov		r1, #6                     ; Y-Koordinate laden
				bl		lcdGotoXY                  ; Cursor setzen
				ldr		r0, =txt_Runn              ; Adresse für "Runn" laden
				bl lcdPrintS                       ; Text auf Display ausgeben
				; KORREKTUR: Die Zeile 'strb r3, [r5]' wurde gelöscht, damit der Zustand im RAM bleibt!
				b	endif_Display                  ; Zum Ausgang springen
then_Hold		
				mov		r0, #12                    ; X-Koordinate laden
				mov		r1, #6                     ; Y-Koordinate laden
				bl		lcdGotoXY                  ; Cursor setzen
				ldr		r0, =txt_Hold              ; Adresse für "Hold" laden
				bl lcdPrintS                       ; Text auf Display ausgeben
				; KORREKTUR: Die Zeile 'strb r3, [r5]' wurde gelöscht, damit der Zustand im RAM bleibt!
endif_Display

		POP		{r0, r1, r2, r3, r4, r5, PC}       ; Register vom Stack holen und Funktion sauber beenden
		;BX      LR                                ; (Durch POP PC bereits erledigt)
        ENDP

		ALIGN
		END
