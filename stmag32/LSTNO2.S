; listing no 2 st mag no 32 - avec le code init
; article scrolling 2e partie
; j'ai fait un fix voir dans le source

;********************************************
;Routine de scroll. Decale d'un pixel l'ecran
;vers le bas.
;En entree : A3 contient l'adresse de debut
;d'ecran
;Registres modifies: A0, A1, D0, D1

scroll:
        ;ca crash avec ce qu'il y a dans
        ;l'article. J'ai soustrait par 1
        ;le bug semble corrige
	;lea LG_ECRAN*(H_ECRAN-2)(a3),a0
	lea LG_ECRAN*(H_ECRAN-1)(a3),a0

	lea LG_ECRAN(a0),a1

	move.w #H_ECRAN-1,d0 ;d0 compte les
                             ;lignes a decaler
                             ;Decale une ligne

ligne_suivante:

	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	lea	-80(a0),a0
	lea	-80(a1),a1
	
	dbra d0,ligne_suivante ;Passe a la
                               ;ligne suivante
	rts

