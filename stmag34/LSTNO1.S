; listing no 1 st mag no 34
; article scrolling 4e partie
; 
; 
;
;**********************************************
;  Programme de scroll horizontal
;**********************************************
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
;Routine de scroll horizontal transparent
;a gauche 8 pixels
;a0, d0 modifies

scroll:
	move.l	adr_ecran,a0 ;adresse ecran
                             ;dans a0
	move.w	#H_ECRAN-1,d0 ;Nombre de
                              ;lignes

ligsui:
	move.b	1(a0),(a0) ;1er plan, et
	move.b	8(a0),1(a0) ;et un seul plan
	move.b	9(a0),8(a0) ;traite
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)

	lea LG_LIGNE(a0),a0 ;a0 pointe vers la
                            ;ligne suivante
	
	dbra d0,ligsui ;decale ligne suivante

	rts

	end
