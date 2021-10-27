        /*
                Kétkezes inditást megvalosító program, ammenyiben a két gombot egy 500ms-es idoablakban nyomják meg.
                1. gomb         P1.0
                2. gomb         P1.1
                
                Sikeres indulást jelzi:
                P1.0 és P1.1 aktiv marad
                
                Kikapcsolás:
                Ha bármelyik gombot elengedjük, akkor mindkét bit '0'-ra vált.
                
                Idozítés:
                T0-ás idozito 2-es módjában, 200us idoalappal 500ms idozito
                Összesen szükséges 2500 overflow, amit 250*10 formában kerül megvalosításra, ezt R5 és R6 regiszter 
                fogja számolni.
                R5 =>   #64H
                R6 =>   #10H
                
                200us idoalap beállításához:
                TH0 =>  #38H
                
        */
        
        CSEG    AT      0000H
        LJMP    0030H
        
        CSEG    AT      000BH
        LJMP    ISR_TIMER0_OVERFLOW
        
        
        CSEG    AT      0030H
        
        
        
        
        /*--- INIT ---*/
        LCALL   S_ENABLE_INTERUP
        LCALL   S_INIT_TIMER0_200U
        
        MOV     P1,#00H
        
        
CHECK_BUTTON:

        MOV     A,P1
        ANL     A,#03H
        
        CJNE    A,#03H,NOT_BOTH_PUSHED
        
        CLR     TR0
        MOV     TL0,#00H
        
        LJMP    CHECK_BUTTON
        
NOT_BOTH_PUSHED:
        
        JNZ     FIRST_PUSHED
        
        
        LJMP    CHECK_BUTTON
        
        
FIRST_PUSHED:     
        SETB    TR0
        
        
        LJMP    CHECK_BUTTON
        
        
        
END_OF_PROGRAM:
        LJMP    END_OF_PROGRAM
       
       
       
       
ISR_TIMER0_OVERFLOW:
        DJNZ    R5,ISR_TIMER0_OVERFLOW_END
        MOV     R5,#64H
        DJNZ    R6,ISR_TIMER0_OVERFLOW_END
        MOV     R6,#10H
        
        LCALL   AUTOOFF

ISR_TIMER0_OVERFLOW_END:        
        RETI
       
S_ENABLE_INTERUP:
        /*
        *
        A megszakítások engedélyezése globálisan és a Timer0-nál
        *
        */
        
        SETB    EA
        SETB    ET0
        
        RET
        
S_INIT_TIMER0_200U:
       /**
        *
        Timer0 beállítása:
        - 2-es mód
        - TH0 értéke 56D -> 5000Hz/200us idolap
        - R5 és R6 regiszter 250x10 összesen 2500 overflowot számol a megszakítás elott
        *
        **/ 
               
        ANL     TMOD, #0FH
        ORL     TMOD, #00000010B
        
        MOV     TH0,#38H
        
        MOV     R5,#64H
        MOV     R6,#10H
        

        RET
        
AUTOOFF:
        CLR     TR0
        MOV     P1,#00H
        
        RET
        
        
        END