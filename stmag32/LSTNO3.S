; listing no 3 st mag no 32
; article scrolling 2e partie
; 
; 
;
PHYSBASE EQU 2 ;No de la fonction Xbios Phybase
              ;pour recuperer l'adresse de
              ;l'ecran
CCONIN EQU 1  ;No de la fonction Gemdos Cconin
              ;pour attendre un caractere au
              ;clavier
LG_ECRAN EQU 160 ;Largeur de l'ecran en octets

H_ECRAN EQU 200 ;Hauteur de l'ecran en points

VITESSE	EQU 3

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

	asr.w	#VITESSE,d2 ;Pour decaler tout
			    ;l'ecran Hauteur
                            ; divisée par le
                            ; "pas" du scroll

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

;******************************************
;Routine de scroll. Decale de X pixels vers
;vers le haut.
;En entree : A3 contient l'adresse de debut
;d'ecran
;Registres modifies: A0, A1, D0, D1

scroll:
	move.l a3,a0 ;a0 contient l'adresse
                     ;de debut de l'ecran.
                     ;a0 pointe vers le
                     ;debut de la 1ere
                     ;partie.
	
	move.l	a3,a1
	move.l	#LG_ECRAN,d0
	move.l	#VITESSE,d1
	asl.l	d1,d0
	adda.l	d0,a1 ;a1 pointe vers la
                      ;Xeme ligne de
                      ;l'ecran

	move.w #H_ECRAN-1,d0 ;d0 compte les
                             ;lignes a
                             ;decaler

	moveq.l	#1,d3
	asl.l	d1,d3 ;moins le "pas" du
                      ;scroll -> dans d0
	sub.l	d3,d0 ;Decale une ligne
                             ;lignes a decaler
                             ;Decale une ligne

ligne_suivante:

	move.l	(a0)+,(a1)+ ;20 fois move.l
	move.l	(a0)+,(a1)+ ;-> 80 octets
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	lea	80(a0),a0 ;Passe a la ligne
	lea	80(a1),a1
	
	dbra d0,ligne_suivante ;Recommence pour
                               ;la ligne suivante
	rts

	end
