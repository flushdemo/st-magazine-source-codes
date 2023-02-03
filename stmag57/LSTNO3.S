; listing no 3 st mag no 57
; article flexi-scroll
; code Marlon / STCNX
; 

REZ EQU 0 ; 0 couleur sinon monochrome

	section TEXT

	movea.l	4(sp),a6
	lea	database(pc),a0
	adda.l	#mystack-database,a0
	movea.l	a0,sp
	move.l	$0c(a6),d0
	add.l	$14(a6),d0
	add.l	$1c(a6),d0
	add.l	#$0100,d0
	move.l	d0,-(sp)
	move.l	a6,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bne.s	Problem
	pea	Demo(pc)
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
Problem:
	clr.w -(sp)
	trap #1

Demo:
	movem.l	d0-a6,-(sp)
	bsr	SaveInterrupts
	bsr	DemoScroll
	cmp	#$b9,$fffffc02.w
	bne.s	MainLoop
	bsr	EndDemo
	bsr	ResetInterrupts
	movem.l	(sp)+,d0-a6
	rts

SaveInterrupts:
	move	#$2700,sr
	move.b	#$12,$fffffc02.w
	dc.w	$a00a
	movem.l	d0-a6,-(sp)
	lea	Vectors(pc),a6
	move.l	$70.w,Vbl(a6)
	move.l	$0134.w,Timera(a6)
	move.l	$0120.w,Timerb(a6)
	move.l	$0114.w,Timerc(a6)
	move.l	$0110.w,Timerd(a6)
	lea	VideoRegisters(a6),a1
	movea.w	#$8200,a0
	movep.w	(a0),d0
	move.w	d0,(a1)+
	move.w	$60(a0),(a1)+
	movem.l	$40(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.l	$fffffa06.w
	bclr	#3,$fffffa17.<
	movem.l	(sp)+,d0-a6
	move	#$2300,sr
	rts

ResetInterrupts:
	move	#$2700,sr
	movem.l	d0-a6,-(sp)
	lea	Vectors(pc),a6
	lea	vblfake(pc),a0
	move.l	a0,$70.w
	stop #$2300
	stop #$2300
	lea	VideoRegisters(a6),a1
	movea.w	#$8200,a0
	move.w	(a1)+,d0
	movep.w	d0,1(a0)
	move.w	(a1)+,$60(a0)
	movem.l	(a1),d0-d7
	movem.l	d0-d7,$40(a0)
	move.l	Vbl(a6),$70.w
	move.l	Timera(a6),$0134.w
	move.l	Timerb(a6),$0120.w
	move.l	Timerc(a6),$0114.w
	move.l	Timerd(a6),$0110.w
;Restore Mfp Regs ($FFFA03 - $FFFA25)
	lea	$fffffa00.w,a1
	move.l	#$04001e64,d0
	movep.l	d0,$03(a1)
	movep.w	d0,$13(a1)
	clr.b	$19(a1)
	clr.b	$1b(a1)
	clr.b	$1d(a1)
	move.l	#$fff0c002,d0
	movep.l	d0,$1f(a1)
	move.b	#$51,$1d(a1)
	move.b	#$48,$17(a1)
	movem.l	(sp)+,d0-a6
	dc.w	$a009
	move	#$2300,sr
	bsr	FlushKeyboard
	move.b	#$08,$fffffc02.w
	rts
vblfake:
	rte
FlushKeyboard:
	movem.l	d0-a6,-(sp)
	move.b	#$13,$fffffc02.w
FlushKey:
	moveq	#$a1,d0
	and.b	$fffffc00.w,d0
	beq.s	Flush
	tst.b	$fffffc02.w
	bra.s	FlushKey
Flush:
	move.w	#$22,-(sp)
	trap	#14
	addq.l	#2,sp
	suba.l	a0,a0
	clr.b	109(a0,d0.l)
	move.b	#$11,$fffffc02.w
	movem.l	(sp)+,d0-a6
	rts
Vectors:
Vbl:	dc.l	0
Timera:	dc.l	0
Timerb:	dc.l	0
Timerc:	dc.l	0
Timerd:	dc.l	0
VideoRegisters:	ds.l	9

InitDemo:
	movem.l	d0-a6,-(sp)
	move.l	$ffff8200.w,d7
	lsl.w	#8,d7
	lea	screenadd(pc),a0
	and.l	#$ffff00,d7
	move.l	d7,(a0)+
	lea	database(pc),a1
	adda.l	#screen2-database,a1
	move.l	a1,d7
	and.l	#ffff00,d7
	move.l	d7,(a0)+
	bsr	Cls
	lea	database(pc),a0
	adda.l	#demoscrolltxt-database,a0
	movea.l	a0,a1
	lea	12+fontsdisplayed(a1),a1
	move.l	a1,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	bsr	CircleCalcul
	bsr	GenereFonts
	pea	Frame(pc)
	move.l	(sp)+,$70.w
	stop	#$2300
	stop	#$2300
	bsr	Cls
	movem.l	(sp)+,d0-a6
	rts
Cls:
	movea.w	#8240,a0
	moveq	#7,d0
ClearPal:
	clr.l	(a0)+
	dbra	d0,ClearPal
	movem.l	screenadd(pc),a0-a1
	move.w	#7999,d0
ClearScreens:
	clr.l	(a0)+
	clr.l	(a1)+
	dbra	d0,ClearScreens
	rts
fontsdiplayed	EQU 23
DemoScroll:
	movem.l	d0-a6,-(sp)
;efface le scrolling
	movea.l	screensadd(pc),a0
	lea	database(pc),a1
	adda.l	#wavebuffer-database,a1
	lea	database(pc),a2
	adda.l	#demoscrolltxt-database,a2
	move.l	4(a2),d0
	movea.l	(a2),a2
	sub.l	#(hauteur*4)*2,d0
	bge.s clrok
	move.l	#(hauteur*4)*30,d0
	subq.l	#1,a2
clrok:
	adda.l	d0,a1
	lea	database(pc),a3
	adda.l	#fontsclrgenerated-database,a3
	moveq	#0,d1
	moveq	#fonttsdisplayed-1,d2
clrfont:
	moveq	#0,d0
	move.b	-(a2),d0
	sub.b	#' ',d0
	add.w	d0,d0
	move.w	0(a3,d0.w),d0
	jsr	0(a3,d0.w)
	lea	(hauteur*4)*32(a1),a1
	dbra	d2,clrfont
;imprime le scrolling
	movea.l	screensadd(pc),a0
	lea	database(pc),a1
	adda.l	#wavebuffer-database,a1
	lea	database(pc),a2
	adda.l	#demoscrolltxt-database,a2
	movea.l	(a2),a3
	move.l	4(2),d0
	add.l	#(hauteur*4)*2,d0
	cmp.l	#(hauteur*4)*32,d0
	blt.s	nonewletter
	moveq	#0,d0
	addq.l	#1,a3
	tst.b	(a3)
	bne.s	nonewscroll
	lea	12+fontsdiplayed(a2),a3
nonewscroll:
	move.l	a3,(a2)
nonewletter:
	move.l	d0,4(a2)
	lea	database(pc),a1
	adda.l	#wavebuffer-database,a1
	lea	database(pc),a2
	adda.l	#demoscrolltxt-database,a2
	movea.l	(a2),a2
	adda.l	d0,a1
	lea	database(pc),a3
	adda.l	#fontsgenerated-database,a3
	movea.l	a1,a4
	moveq	#fontsdiplayed-1,d2
printfont:
	moveq	#0,d0
	move.b	-(a2),d0
	sub.b	#' ',d0
	add.w	d0,d0
	move	0(a3,d0.w),d0
	jsr	0(a3,d0.w)
	lea	(hauteur*4)*32(a4),a4
	movea.l	a4,a1
	dbra	d2,printfont
	movem.l	(sp)+,d0-a6
	rts
;routine qui precalcule la courbe
;decrite par le scrolling
TablePlot:
	dc.w	1,2,4,8,16,32,64,128
	dc.w	256,512,1024,2048,4096,8192,16384,32768
CircleCalcul:
	movem.l	d0,a6,-(sp)
	lea	database(pc),a0
	adda.l	#democosinus-database,a0
	lea	database(pc),a1
	adda.l	#demosinus-database,a1
	lea	database(pc),a2
	adda.l	#wavebuffer-database,a2
	move.w	#719,d7
calcul0:
	moveq	#0,d0
	move.w	(a0)+,d0
	moveq	#0,d1
	move.w	(a1)+,d1
	moveq	#hauteur-1,d6
calcul1:
	move.l	d0,d2
	IFEQ	REZ
	move.l	#85,d5
	ELSE
	move.l	#185,d5
	ENDC
	add.w	d6,d5
	muls	d5,d2
	lsl.l	#2,d2
	clr.w	d2
	swap	d2
	move.l	d2,d3
	ext.l	d3
	lsr.l	#4,d3
	IFEQ	REZ
	lsl.l	#3,d3
	ELSE
	lsl.l	#1,d3
	ENDC
	and.w	#$0f,d2
	neg.b	d2
	add.b	#15,d2
	add.w	d2,d2
	move.w	TablePlot(pc,d2.w),d2
	swap	d2
	move.w	d3,d2
	move.l	d1,d3
	IFEQ	REZ
	move.l	#85,d5
	ELSE
	move.l	#185,d5
	ENDC
	add.w	d6,d5
	muls	d5,d3
	lsl.l	#2,d3
	clr.w	d3
	swap	d3
	ext.l	d3
	IFEQ	REZ
	muls	#160,d3
	add.w	#80+99*160,d3
	ELSE
	muls	#80,d3
	add.w	#40+199*80,d3
	ENDC
	add.w	d2,d3
	move.w	d3,(a2)+
	swap	d2
	move.w	d2,(a2)+
	dbra	d6,calcul1
	dbra	d7,calcul0
;cree un effet de disparition
;et d'effacement des caracteres
	move.w	#25*12-1,d0
fill1:
	clr.w	(a2)+
	dbra	d0,fill1
	lea	database(pc),a0
	adda.l	#wavebuffer-database,a0
	move.w	#26*2,d0
rnd0:
	clr.w	2(a0)
	addq.l	#8,a0
	clr.w	2(a0)
	addq.l	#4,a0
	clr.w	2(a0)
	addq.l	#8,a0
	dbra	d0,rnd0
	lea	database(pc),a0
	adda.l	#wavebuffer-database+33520,a0
	move.w	#26*2,d0
rnd1:
	clr.w	2(a0)
	addq.l	#8,a0
	clr.w	2(a0)
	addq.l	#4,a0
	clr.w	2(a0)
	addq.l	#8,a0
	dbra	d0,rnd1
	movem.l	(sp)+,d0-a6
	rts
;Genere le code de fonts 1 plan (-90 degre)
;de 16 de large et de x de hauteur
;ici, on sait que les 4 premieres
;colonnes des fonts sont vides
nbrfonts	EQU	59
hauteur	EQU	12
largeur	EQU	13
GenereFonts:
	movem.l	d0-a6,-(sp)
	lea	database(pc),a0
	adda.l	#fontsgraphix-database,a0
	lea	database(pc),a1
	adda.l	#fontsgenerated-database,a1
	lea	nbrfonts*2(a1),a2
	moveq	#nbrfonts-1,d0
gen1font:
	lea	database(pc),a3
	adda.l	#fontsgenerated-database,a3
	move.l	a3,d4
	neg.l	d4
	add.l	a2,d4
	move.w	d4,(a1)+
;codefont-fontsgenerated
	moveq	#0,d4
	moveq	#largeur-1,d1
gen1ligne:
	move.w	(a0)+,d3
	moveq	#hauteur-1,d2
gen1column:
	roxr.w	#1,d3
	bcc.s	nopixel
	tst.w	d4
	beq.s	addok
	cmp	#4,d4
	bne.s	add8
	move.w	#$5889,(a2)+
;addq.l	#4,a1
	bra.s	addok
add8:
	cmp	#8,d4
	bne.s	addw
	move.w	#$5089,(a2)+
;addq.l	#8,a1
	bra.s	addok
addw:
	cmp.w	#8,d4
	bmi.s	addw
	move.w	#$43e9,(a2)+
;lea xxxx(a1),a1
	move.w	d4,(a2)+
;xxxx
addok:
	moveq	#0,d4
	move.l	#$30193219,(a2)+
;move.w (a1)+,d0/move.w (a1)+,d1
	move.l	#$83700000,(a2)+
;or.w	d1,(a0,d0.w)
	bra.s	gen1columnend
nopixel:
	addq.l	#4,d4
gen1columnend:
	dbra	d2,gen1column
	dbra	d1,gen1line
	move.w	#$4e75,(a2)+
;rts
	dbra	d0,gen1font
	lea	database(pc),a0
	adda.l	#fontsgraphix-database,a0
	lea	database(pc),a1
	adda.l	#fontsclrgenerated-database,a1
	lea	nbrfonts*2(a1),a2
	moveq	#nbrfonts-1,d0
gen1fontclr:
	lea	database(pc),a3
	adda.l	#fontsclrgenerated-database,a3
	move.l	a3,d4
	neg.l	d4
	add.l	a2,d4
	move.w	d4,(a1)+
;codefontclr-fontsclrgenerated
	moveq	#0,d4
	moveq	#largeur-1,d1
gen1lineclr:
	move.w	(a0)+,d3
	moveq	#hauteur-1,d2
gen1columnclr:
	roxr.w	#1,d3
	bcc.s	nopixelclr
; A FINIR

