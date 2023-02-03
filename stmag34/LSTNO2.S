; listing no 2 st mag no 34
; article scrolling 4e partie
; 
; 
;
;==========================================
;Extrait du magazine :
;Vous avez ci-dessous le listing numero 1
;complet. En ce qui concerne le listing
;numero 2, vous reprenez le "Programme
;de scroll horizontal" et le "Programme
;principal" du premier listing en ajoutant
;la "Routine de scroll horizontal a gauche
;16 pixels" a la place de la routine du
;1er listing, et vous avez le listing
;numero 2 complet.
;==========================================
;******************************************
;Routine de scroll horizontal a gauche
;16 pixels
;a0, d0 modifies

scroll:
	move.l	adr_ecran,a0 ;adresse ecran
                             ;dans a0
	move.w	#H_ECRAN-1,d0 ;Nombre de
                              ;lignes

ligsui:
	movem.l	8(a0),d2-d7/a1-a4 ;Lit 10 mots
                                  ;longs
	movem.l d2-d7/a1-a4,(a0) ;Ecrit les 10
                                 ;mots, decales
                                 ;de 8 octets
	movem.l 48(a0),d2-d7/a1-a6 ;Lit 12 mots
                                   ;longs
	movem.l d2-d7/a1-a6,40(a0) ;Ecrit les
                                   ;12 mots
                                   ;longs
	movem.l 96(a0),d2-d7/a1-a6 ;Lit 12 mots
                                   ;longs
	movem.l d2-d7/a1-a6,92(a0) ;Ecrit 12
                                   ;mots longs


	lea LG_LIGNE(a0),a0 ;a0 pointe vers la
                            ;ligne suivante
	
	dbra d0,ligsui ;decale ligne suivante

	rts

	end
