public class Primzahl {

    public static void main(String[] args) 
    
    {
        // INITIALISIERUNG 

        int obergrenze = 1000;
        boolean[] siebFeld = new boolean[obergrenze + 1];
        
        // Alles mit 1 füllen

        int i = 0;
        while (i <= obergrenze) //alle auf 1 setzten
        {
            siebFeld[i] = true;
            i = i + 1;
        }
        
        
        siebFeld[0] = false; // 0 und 1 auf 0 setzten
        siebFeld[1] = false;




        // Sieb------------------------------------------------

        

        // Prüfen bis p * p > 1000 (wenn p = 31)

        for (int p = 2; p * p <= obergrenze; p++) 
        {
            
            // Wenn es eine Primzahl ist
            if (siebFeld[p]) 
            {
                
                // Innere Schleife: Vielfache streichen (Start bei p * p)

                

                for (int streichIndex = p * p; streichIndex <= obergrenze; streichIndex += p) // alle Zahlen die durch p (außer p selbst) teilbar sind werden auf 0 gesetzt
                
                {
                    siebFeld[streichIndex] = false;
                    
                   
                }

            } 
            
            
           
        }

        // ABSPEICHERN ----------------------------------------------------------------------
        
        int[] primzahlenListe = new int[obergrenze / 2]; 
        int zielIndex = 0;
         // Wir starten die Suche bei der 2

        // Das Feld durchsuchen und Primzahlen umkopieren
        for (int j = 2; j <= obergrenze; j++) 
		{ 
            if (siebFeld[j]) 
			{
                primzahlenListe[zielIndex] = j;
				
                zielIndex = zielIndex + 1; // Platz in der neuen Liste eins weiterbewegen
            } 
            
        }
		
		
		

        // --- AUSGABE ZUR KONTROLLE ---
        System.out.println("Gefundene Primzahlen: " + zielIndex);
		
		for (int a = 0; a < obergrenze /2 ; a++ )
		{
        System.out.print( primzahlenListe[a] + ", " );
		}
    }
}
