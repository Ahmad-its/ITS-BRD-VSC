public class Primzahl {

    public static void main(String[] args) 
    
    {
        // INITIALISIERUNG 

        int obergrenze = 1000;
        byte[] siebFeld = new byte[obergrenze + 1];
        
        // Alles mit 1 füllen

        int i = 0;
        while (i <= obergrenze) 
        {
            siebFeld[i] = 1;
            i = i + 1;
        }
        
        // 0 und 1 auf 0 setzten
        siebFeld[0] = 0;
        siebFeld[1] = 0;




        // Sieb------------------------------------------------

       

        // Prüfen bis p * p > 1000 (wenn p = 31)

        for ( int p = 2 ; p * p <= obergrenze; p++) 
        {
            
            // Wenn es eine Primzahl ist
            if (siebFeld[p] == 1) 
            {
                
                // Innere Schleife: Vielfache streichen (Start bei p * p)

                

                for (int streichIndex = p * p; streichIndex <= obergrenze; streichIndex + p) // alle Zahlen die durch p (außer p selbst) teilbar sind werden auf 0 gesetzt
                
                {
                    siebFeld[streichIndex] = 0;
                    
                  
                }

            } 
            
            
            
        }

        // ABSPEICHERN ----------------------------------------------------------------------
        
        short[] primzahlenListe = new short[obergrenze]; 
        int zielIndex = 0;
        int j = 2; // Wir starten die Suche bei der 2

        // Das Feld durchsuchen und Primzahlen umkopieren
        while (j <= obergrenze) 
		{
            if (siebFeld[j] == 1) 
			{
                primzahlenListe[zielIndex] = (short) j;
				
                zielIndex = zielIndex + 1; // Platz in der neuen Liste eins weiterbewegen
            } 
            
            j = j + 1; // Nächsten Index prüfen
        }
		
		
		

        // --- AUSGABE ZUR KONTROLLE ---
        System.out.println("Gefundene Primzahlen: " + zielIndex);
		for (int i = 0; i <= obergrenze; i++ )
		{
        System.out.println("Die ersten drei sind: " + primzahlenListe[i] + ", " ;}
    }
}
