; listing no 1 st mag no 33
; article scrolling 3e partie
; 
; 
;
PHYSBASE EQU 2 ;No de la fonction Xbios Phybase
              ;pour recuperer l'adresse de
              ;l'ecran
CCONIN EQU 1  ;No de la fonction Gemdos Cconin
              ;pour attendre un caractere au
              ;clavier

H_ECRAN EQU 8*15 ;Hauteur de l'ecran a decaler

CADRE_GAUCHE	EQU 8 ;Epaisseur cadre gauche
                      ;en octets

CADRE_HAUT	EQU 8*2 ;Hauteur du cadre haut
                        ;en pixels

LG_LIGNE	EQU 160 ;Largeur totale de
                        ;l'ecran en octets

	section DATA

adr_ecran	dc.l	0 ;Adresse de l'ecran
                          ;ou commence le
                          ;scroll

;********************************************
; Programme principal
;
;

	section TEXT

	move.w	#PHYSBASE,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,a0 ;Adresse ecran dans a0

;Calcule l'adresse du coin superieur gauche du
;cadre dans lequel se fait le scroll

	lea LG_LIGNE*CADRE_HAUT+CADRE_GAUCHE(a0),a0
	move.l	a0,adr_ecran

;Boucle d'appel de la routine de decalage horizontal

	move.w	#100,d1 ;Routine appelee 100 fois

boucle:
	bsr.s	scroll
	dbra d2,boucle

;Attend un appui sur une touche

	move.w #CCONIN,-(sp)
	trap #1
	addq.l #2,sp


;Fin du programme

	clr.w -(sp)
	trap #1

;******************************************
;Routine de scroll horizontal a gauche
;1 pixel
;a0, d0 modifies

scroll:
	move.l	adr_ecran,a0 ;adresse ecran
                             ;dans a0
	move.w	#H_ECRAN-1,d0 ;Nombre de
                              ;lignes

ligsui:
	roxl.w	136(a0) ;Decale le 1er plan
	roxl.w	128(a0)
	roxl.w	120(a0)
	roxl.w	112(a0)
	roxl.w	104(a0)
	roxl.w	96(a0)
	roxl.w	88(a0)
	roxl.w	80(a0)
	roxl.w	72(a0)
	roxl.w	64(a0)
	roxl.w	56(a0)
	roxl.w	48(a0)
	roxl.w	40(a0)
	roxl.w	32(a0)
	roxl.w	24(a0)
	roxl.w	16(a0)
	roxl.w	8(a0)
	roxl.w	(a0)

	roxl.w	138(a0) ;Decale le 2eme plan
	roxl.w	130(a0)
	roxl.w	122(a0)
	roxl.w	114(a0)
	roxl.w	106(a0)
	roxl.w	98(a0)
	roxl.w	90(a0)
	roxl.w	82(a0)
	roxl.w	74(a0)
	roxl.w	66(a0)
	roxl.w	58(a0)
	roxl.w	50(a0)
	roxl.w	42(a0)
	roxl.w	34(a0)
	roxl.w	26(a0)
	roxl.w	18(a0)
	roxl.w	10(a0)
	roxl.w	2(a0)

	roxl.w	140(a0) ;Decale le 3eme plan
	roxl.w	132(a0)
	roxl.w	124(a0)
	roxl.w	116(a0)
	roxl.w	108(a0)
	roxl.w	100(a0)
	roxl.w	92(a0)
	roxl.w	84(a0)
	roxl.w	76(a0)
	roxl.w	68(a0)
	roxl.w	60(a0)
	roxl.w	52(a0)
	roxl.w	44(a0)
	roxl.w	36(a0)
	roxl.w	28(a0)
	roxl.w	20(a0)
	roxl.w	12(a0)
	roxl.w	4(a0)

	roxl.w	142(a0) ;Decale le 3eme plan
	roxl.w	134(a0)
	roxl.w	126(a0)
	roxl.w	118(a0)
	roxl.w	110(a0)
	roxl.w	102(a0)
	roxl.w	94(a0)
	roxl.w	86(a0)
	roxl.w	78(a0)
	roxl.w	70(a0)
	roxl.w	62(a0)
	roxl.w	54(a0)
	roxl.w	46(a0)
	roxl.w	38(a0)
	roxl.w	30(a0)
	roxl.w	22(a0)
	roxl.w	14(a0)
	roxl.w	6(a0)

	lea LG_LIGNE(a0),a0 ;a0 pointe vers la
                            ;ligne suivante
	
	dbra d0,ligsui ;decale ligne suivante

	rts

	end
