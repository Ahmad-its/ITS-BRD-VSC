				AREA MyData, DATA, align = 2


siebFeld		fill  1001    ; 1001 Bytes im speicher reservieren
primzahlenListe	fill  2000


				AREA |.text|, CODE, READONLY, ALIGN = 3
				EXPORT siebFeld
				

				EXPORT main
				EXTERN initITSboard

main            PROC
                bl    initITSboard                 ; HW Initialisieren


  				ldr r0, =siebFeld
  				mov r1, #1
  				mov r2, #0


for_Init
				mov r3,#0

until_Init
				cmp r3,#1000
				bgt enddo_Init

do_Init
				strb r1, [r0, r3]

step_Init
				add r3, r3, #1
				b until_Init

enddo_Init

  	 			strb r2, [r0]
  	 			strb r2, [r0, #1]



for_Sieb
				mov r3,#2

until_Sieb

				mul r4, r3, r3
				cmp r4,#1000
				bgt enddo_Sieb

do_Sieb
				ldrb r5, [r0,r3]

if_Primzahl
				cmp r5, #1
				beq then_Primzahl
				b endif_Primzahl

then_Primzahl

for_streichIndex
				mov r6, r4

until_streichIndex
				cmp r6,#1000
				bgt enddo_streichIndex

do_streichIndex
				strb r2, [r0, r6]

step_streichIndex
				add r6, r6, r3
				b until_streichIndex

enddo_streichIndex

endif_Primzahl
				


step_Sieb
				add r3, r3, #1
				b until_Sieb

enddo_Sieb


				ldr r7, =primzahlenListe
  				mov r8, #0
for_Copy
				mov r3, #2

until_Copy
				cmp r3,#1000
				bgt enddo_Copy

do_Copy

if_Zahl
				ldrb r5, [r0, r3]
				cmp r5, #1
				beq then_Zahl
				b endif_Zahl

then_Zahl
				str r3, [r7, r8]
				add r8, r8, #4

endif_Zahl

step_Copy
				add r3, r3, #1
				b until_Copy

enddo_Copy			
forever         b   forever  
                ENDP
                END