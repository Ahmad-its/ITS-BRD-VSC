1: INITIALISIERUNG DES SPEICHERS (siebFeld)
@ -----------------------------------------------------------------------------
@ - siebFeld Array initialisieren
@ - alle standardmaessig auf 1 setzen.
@ - Index 0 und Index 1 auf 0 setzen, da sie keine Primzahlen


2: SIEB DES ERATOSTHENES (Sieben)
@ -----------------------------------------------------------------------------
@ - Prüfen bis p * p > 1000 (wenn p = 31)
@ - Start bei p * p
@ - alle Vielfache (bis 1000) werden auf 0 gesetzt



3: ABSPEICHERN DER PRIMZAHLEN (primzahlenListe)
@ -----------------------------------------------------------------------------
@ - Ergebnisliste erstellen. 
@ - Variable deklarieren, der sich die aktuelle Position in der neuen Liste merkt
@ - Die Variable (zielIndex) verwaltet die Schreibposition in der neuen Ergebnisliste.
@ - Eine Schleife scannt das "siebFeld" von Index 2 bis 1000.
@ - WENN siebFeld[j] == 1 ist, kopiere die Zahl j in die "primzahlenListe".
@ - Erhoehe danach den zielIndex, um Platz fuer die naechste Primzahl zu machen.