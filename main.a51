        /*
                K?tkezes indit?st megvalos?t? program, ammenyiben a k?t gombot egy 500ms-es idoablakban nyomj?k meg.
                1. gomb         P1.0
                2. gomb         P1.1
                
                Sikeres indul?st jelzi:
                P1.0 ?s P1.1 aktiv marad
                
                Kikapcsol?s:
                Ha b?rmelyik gombot elengedj?k, akkor mindk?t bit '0'-ra v?lt.
                
                Idoz?t?s:
                T0-?s idozito 2-es m?dj?ban, 200us idoalappal 500ms idozito
                ?sszesen sz?ks?ges 2500 overflow, amit 250*10 form?ban ker?l megvalos?t?sra, ezt R5 ?s R6 regiszter 
                fogja sz?molni.
                R5 =>   #64H
                R6 =>   #10H
                
                200us idoalap be?ll?t?s?hoz:
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
        A megszak?t?sok enged?lyez?se glob?lisan ?s a Timer0-n?l
        *
        */
        
        SETB    EA
        SETB    ET0
        
        RET
        
S_INIT_TIMER0_200U:
       /**
        *
        Timer0 be?ll?t?sa:
        - 2-es m?d
        - TH0 ?rt?ke 56D -> 5000Hz/200us idolap
        - R5 ?s R6 regiszter 250x10 ?sszesen 2500 overflowot sz?mol a megszak?t?s elott
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