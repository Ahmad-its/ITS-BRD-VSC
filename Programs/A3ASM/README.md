;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2
Base
VariableA          DCW 0x1234
VariableB          DCW 0x4711

VariableC          DCD  0

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45

MeinWortFeld       DCD 0x12345678 , 0x9dca5986
                   DCD -872415232 , 1308622848
                   DCD 0x27000000
                   DCD 0x45000000

MeinTextFeld       DCB "ABab0123",0

                   EXPORT VariableA
                   EXPORT VariableB
                   EXPORT VariableC
                   EXPORT MeinHalbwortFeld
                   EXPORT MeinWortFeld
                   EXPORT MeinTextFeld

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; Laden von Konstanten in Register
                mov   r0,#0x12                      ; schreibt den Wert 0x12 in R0
                mov   r1,#-128                      ; schreibt den Wert -128 in R1
                ldr   r2,=0x12345678                ; lädt eine Konstante in r2                                                                     

; Zugriff auf Variable
                ldr   r0,=VariableA                 ; Lädt Adresse in r0
                ldrh  r1,[r0]                       ; lädt 2 Bytes aus dem Speicher von der Adresse in r0 nach r1
                ldr   r2,[r0]                       ; lädt 4 Bytes von der Adresse nach r2
                str   r2,[r0,#VariableC-VariableA]  ; Speichert den Wert von r2 an die Adresse r0 + (VariableC-VariableA) offset (4)

; Zugriff auf Felder (Speicherzellen)
                ldr   r0,=MeinHalbwortFeld          ; lädt Adresse in r0
                ldrh  r1,[r0]                       ; lädt 2 Bytes von der Adresse in r0 nach r1
                ldrh  r2,[r0,#2]                    ; lädt 2 Byets von einer Adresee (r0 + 2) nach r2
                mov   r3,#10                        ; Speichert den Wert 10 in r3
                ldrh  r4,[r0,r3]                    ; lädt 2 Bytes aus dem Speicher von der Adresse (r0 + r3) nach r4

                ldrh  r5,[r0,#2]!                   ; lädt 2 Bytes aus dem Speicher von der Adresse (r0 + 2) nach r5 und die Adresse an R0 um 2 erhöhen.
                ldrh  r6,[r0,#2]!                   ; lädt 2 Bytes aus dem Speicher von der Adresse (r0 + 2) nach r6 und die Adresse an R0 um 2 erhöhen.
                strh  r6,[r0,#2]!                   ; speichert den Wert von r6 auf der Adresse von (r0 + 2)  und die Adresse an R0 um 2 erhöhen.

; Addition und Subtraktion von unsigned / signed Integer-Werten
                ldr  r0,=MeinWortFeld               ; lädt Adresse in r0
                 ldr  r1,[r0]                        ; lädt den Wert (4 Bytes) aus dem Speicher an der Adresse in R0 nach R1
                ldr  r2,[r0,#4]                     ; lädt den Wert aus dem Speicher an der Adresse in R0 + 4 nach r2
                adds r3,r1,r2                       ; addiert r1 und r2 und speichert das Ergibniss in r3

                ldr  r4,[r0,#8]                     ;lädt die Adresse an R0 und erhöht diese um acht nach r4
                ldr  r5,[r0,#12]                    ; erhöht die Adresse an r0 um 12 und lädt sie in r5
                subs r6,r4,r5                       ; Subtrahiert r5 von r4 und speichert das Rrgbniss in r6

                ldr  r7,[r0,#16]                    ; erhöht die Adresse an R0 um 16 und lädt sie in r7
                ldr  r8,[r0,#20]                    ; erhöht die Adresse an R0 um 20 und lädt sie in r8
                subs r9,r7,r8                       ; Subtrahiert r8 von r7 und speichert das Rrgbniss in r9

forever         b   forever                         ; Anw-26
                ENDP
                END