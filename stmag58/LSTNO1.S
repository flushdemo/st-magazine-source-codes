* Little PLAYFIELD pour STE *
*   developpe sous devpac   *
*         par CST           *
; article scrolling st mag 58
; 

rscreen = $3b000 ; Adresse de
                 ; l'ecran
x_step  = 4 ; Pas de
            ; deplacement en
            ; en x

y_step  = 4 ; Pas de
            ; deplacement en
            ; y
Start:
	pea	0.w
	move.w	#$20,-(sp)
	trap	#1 ; Mode
                   ; Superviseur
	addq.l	#6,sp
	move.l	d0,oldsp
	lea stack,a7 ; Installe
                     ; la
                     ; nouvelle
                     ; pile
	bsr	save_ints ; Sauve
			  ; les
                          ; interruptions
	bsr	install_ints ; Installe
                             ; les
                             ; interruptions
	move.b	$ffff8260.w,old_res ; Sauve
	                            ; la
			            ; resolution
	clr.b	$ffff8260.w ; Basse
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal ; Sauve la
                              ; palette
	jsr	vsync ; Synchronisation
	lea	$ffff8240.w,a0 ; puis
	moveq	#15,d0
.dark:
	clr.w	(a0)+
	dbra	d0,.dark ; Palette noire
	dc.w	$a00a ; Supprime la souris
	move.b	#$12,$fffffc02.w ; Plus de
                                 ; donnes souris
	bsr	cls_screen
	bsr	load_picture
	move.w	#080,ind_x ; Initialisation
	move.w	#150,ind_y ; position
	bsr	set_screen ; Charge le
                           ; mega-ecran
	movem.l	zone1+2,d0-d7 ; Installe la
	movem.l	d0-d7,$ffff8240.w ; palette

key:                ; Point d'attente
	move.b	$fffffc02.w,d0 ; Clavier
	cmp.b	#$39,d0        ; si Espace
	beq.s	way_out        ; Sortie
	cmp.b	#$3b,d0        ; Si F1
	beq.s	left           ; Gauche
	cmp.b	#$3c,d0        ; Si F2
	beq.s	right          ; Droite
	cmp.b	#$3d,d0        ; Si F3
	beq.s	up             ; Haut
	cmp.b	#$3e,d0        ; Si F4
	beq.s	down           ; Bas
	bra.s	key
way_out:
	jsr	vsync
	bsr	restore_ints
	move.b	#$08,$fffffc02.w
	clr.w	$ffff820e.w
	clr.w	$ffff8264.w
	move.b	old_res,$ffff8260.w
	dc.w	$a009
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	-(sp)
	trap	#1

left:
	subq.w	#x_step,ind_x
	bpl	ok1
	clr.w	ind_x
	bra	ok1
right:
	addq.w	#x_step,ind_x
	cmp.w	#319,ind_x
	ble	ok1
	move.w	#319,ind_x
	bra	ok1
up:
	subq.w	#y_step,ind_y
	bpl	ok1
	clr.w	ind_y
	bra	ok1
down:
	addq.w	#y_step,ind_y
	cmp.w	#199,ind_y
	ble	ok1
	move.w	#199,ind_y
	bra	ok1
ok1:
	bsr	set_screen
	bra	key
newvbl:
	clr.b	$fffffa1b.w
	addq.l	#1,$466.w
	rte
newikbd:
	move.w	$2300,sr
newikbd1:
	jmp	$00000000.l
	rte
newtb:
	clr.b	$fffffa1b.w
	bclr	#$00,$fffffa0f.w
	rte
vsync:
	move.l	d0,-(sp)
	move.l	$466.w,d0
.wait:
	cmp.l	$466.w,d0
	beq.s	.wait
	move.l	d0,(sp)+
	rts

save_ints:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	$fffffa07.w,mfp1
	move.b	$fffffa09.w,mfp2
	move.l	$70.w,oldvbl
	move.l	$118.w,oldikbd
	move.l	$120.w,oldtb
	move.w	(sp)+,sr
	rts
restore_ints:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	mfp1,$fffffa07.w
	move.b	mfp2,$fffffa09.w
	move.l	oldvbl,$70.w
	move.l	oldikbd,$118.w
	move.b	oldtb,$120.w
	move.w	(sp)+,sr
	rts
install_ints:
	move.w	sr,-(sp)
	move.w	#$2700,sr
	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	move.l  #newvbl,$70.w
        move.l  #newikbd,$118.w
	move.l	oldikbd,newikbd1+4
        move.l  #newtb,$120.w
        move.w  (sp)+,sr
	rts

cls_screen:
	lea	rscreen,a0
	move.w	#40*300-1,d0
.loop1:
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.loop1
	rts
load_picture:
	move.l	#picture1,namer
	bsr	load_file
	lea	zone1+34,a0
	lea	rscreen,a2
	lea	320*100(a2),a2
	move.w	#200-1,d1

;.ld_0:
;	moveq	#20-1,d0
;
;.ld_1:
;	move.l	(a0)+,(a2)+
;	move.l	(a0)+,(a2)+
;	dbra	d0,.ld_1
;	lea	160(a2),a2
;	dbra	d1,.ld_0
;	move.l	#picture2,namer
;	bsr	load_file
;	lea	zone1+34,a0
;	lea	rscreen,a2
;	lea	320*100(a2),a2

.ld_0:
	moveq	#20-1,d0

.ld_1:
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbra	d0,.ld_1
	lea	160(a2),a2
	dbra	d1,.ld_0
	move.l	#picture2,namer
	bsr	load_file
	lea	zone1+34,a0
	lea	rscreen,a2
	lea	320*100(a2),a2
	move.w	#200-1,d1

.ld_2:
	moveq	#20-1,d0
	lea	160(a2),a2

.ld_3:
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbra	d0,.ld_3
	dbra	d1,.ld_2
	rts

set_screen: ;Positionne l'ecran
	move.w	ind_x,d0
	move.w	d0,d1
	lsr	#1,d0
	and.l	#$fff8,d0
	and.W	#$f,d1
	move.w	ind_y,d2
	mulu	#320,d2 ; 1 ligne = 320
	add.l	d0,d2
	add.l	#rscreen,d2
	move.l	d2,stamp
	lea	stamp,a0
	tst.w	d1 ; Si HSCROLL<>0
	bne.s	out ; alors ...
	jsr	vsync ; Attend une VBL
	move.b	1(a0),$ffff8205.w ; On force le
	move.b	2(a0),$ffff8207.w ; compteur
	move.b	3(a0),$ffff8209.w ; video
	move.b	#80,$ffff820f.w ; Ligne
                                ; totale de 320
	move.b	d1,$ffff8265.w
	move.b	1(a0),$ffff8201.w ; base ecran
	move.b	2(a0),$ffff8203.w
	move.b	3(a0),$ffff820d.w
	rts

out:
	jsr	vsync
	move.b	1(a0),$ffff8205.w	
	move.b	2(a0),$ffff8207.w
	move.b	3(a0),$ffff8209.w
	move.b	#80-4,$ffff820f.w
;Comme d1<>0, on retranche 4 a LINEWID
	move.b	d1,$ffff8265.w
	move.b	1(a0),$ffff8201.w
	move.b	2(a0),$ffff8203.w
	move.b	3(a0),$ffff820d.w
	rts
load_file:
	clr.w	-(sp) ; On ouvre le
	move.l	namer,-(sp) ; fichier
	move.w	#$3d,-(sp)
	trap	#1
	add.w	#8,sp
	tst.l	d0 ; Si d0 < 0
	bmi	out1 ; on s'en va
	; le numero logique du fichier
	move.w	#2,-(sp) ; On cherche
	move.w	nlog1,-(sp) ; la taille 
                            ; du
	clr.l	-(sp)       ; fichier
	move.w	#$42,-(sp)
	trap	#1
	add.w	#10,sp
	move.l	d0,length ; On le stocke
	move.w	nlog1,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.w	#4,sp
	clr.w	-(sp)
	move.l	namer,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	add.w	#8,sp
	tst.l	d0
	bmi	out1
	move.l	#zone1,-(sp) ; On charge le
	move.l	length,-(sp) ; fichier a
	move.w	nlog1,-(sp)  ; partir de
	move.w	#$3f,-(sp)   ; la zone
	trap	#1           ; image
	add.w	#12,sp
	move.w	nlog1,-(sp) ; On referme le
	move.w	#$3e,-(sp)  ; fichier
	trap	#1
	addq.w	#4,sp
out1:
	rts

	section DATA
	; noms des fichiers a charger
picture1:
	dc.b	'ct1.pi1',0
picture2:
	dc.b	'ct2.pi1',0

	section BSS
	ds.l	256
stack:
oldsp:
	ds.l	1
old_pal:
	ds.w	16
oldvbl
	ds.l	1
oldikbd:
	ds.l	1
oldtb:
	ds.l	1
mfp1:
	ds.b	1
mfp2:
	ds.b	1
ind_x:
	ds.w	1
ind_y:
	ds.w	1
stamp:
	ds.l	1
old_res:
	ds.w	1
indway:
	ds.w	1
namer:
	ds.l	1
nlog1:
	ds.w	1
length:
	ds.l	1
zone:
	ds.l	1
zone1:
	ds.b	32*1024 ; Taille pour PI1
                        ; ou NEO
	end
