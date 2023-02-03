; listing no 2 st mag no 32 - avec le code init
; article scrolling 2e partie
; j'ai ajoute pour le code source la partie
; appel de la fonction scroll.
; j'ai fait un fix voir dans le source
PHYSBASE EQU 2 ;No de la fonction Xbios Phybase
              ;pour recuperer l'adresse de
              ;l'ecran
CCONIN EQU 1  ;No de la fonction Gemdos Cconin
              ;pour attendre un caractere au
              ;clavier
LG_ECRAN EQU 160 ;Largeur de l'ecran en octets
H_ECRAN EQU 200 ;Hauteur de l'écran en points

	section TEXT

;********************************************
; Programme d'appel de la routine de scroll.
; Appelle 200 fois la routine de scroll
; vertical pour décaler tout l'écran.

principal:
	move.w	#PHYSBASE,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,a3 ;a3 contient l'adresse
                      ;du debut de l'ecran
		      ;a3 pointe vers le
                      ;debut de la 1ere ligne

	move.w	#H_ECRAN,d2 ;Hauteur de l'ecran
                            ;dans d2 pour
                            ;pour decaler tout
                            ;l'ecran

bcl_scroll:
	bsr.s	scroll ;Decale l'ecran vers le
                       ;haut d'un point
	dbra d2,bcl_scroll ;Idem pour decaler
                           ;l'ecran 200 fois

;Attend un appui sur une touche

	move.w #CCONIN,-(sp)
	trap #1
	addq.l #2,sp


;Fin du programme

	clr.w -(sp)
	trap #1

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

	end
