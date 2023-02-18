; listing drapoints
; article scrolling st mag 59
; Thomas Conte

SCREENS = $90000 ; Screen(s) address

SCRSIZ = 32000 ; Screen(s) length

NBPX = 33

NBPY = 22

PSAVEBUF = SCREENS * 2 + SCRSIZ

PDELCODE = PSAVEBUF + NBPX * NBPY * 4 * 2

PSINTAB = PDELCODE + NBPX * NBPY * 8 + 2

; -------------------------

	SECTION TEXT

* Super

	pea	0
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	lea	SaveAll(pc),a6
	move.l	d0,(a6)+

* Nouvelle palette

	lea	OldPal(pc),a0
	lea	NewPal(pc),a1
	lea	$FFFF8240.w,a2
	movem.l	(a2),d0-d7
	movem.l	d0-d7,(a0)
	movem.l	(a1),d0-d7
	movem.l	d0-d7,(a2)

	move	#$2700,sr

* Sauve les regitres du MFP

	move.b	$FFFF8260.w,(a6)+ ; Résolution
	move.b	$FFFF8201.w,(a6)+ ; Adresse...
	move.b	$FFFF8203.w,(a6)+ ; ...ecran
	move.b	$FFFFFA07.w,(a6)+ ; IERA
	move.b	$FFFFFA09.w,(a6)+ ; IERB
	move.b	$FFFFFA13.w,(a6)+ ; IMRA
	move.b	$FFFFFA15.w,(a6)+ ; IMRB
	move.b	$FFFFFA17.w,(a6)+ ; Vector Register
	move.b	$FFFFFA19.w,(a6)+ ; TACR
	move.b	$FFFFFA1B.w,(a6)+ ; TBCR
	move.l	$70.w,(a6)+       ; VBI Vecteur
	move.l	$120.w,(a6)+      ; TB Vecteur
	move.l	$134.w,(a6)+      ; TA Vecteur
	
* On coupe les IT du MFP

	moveq	#0,d0
	move.b	d0,$FFFFFA07.w    ; IERA
	move.b	d0,$FFFFFA09.w    ; IERB
	move.b	d0,$FFFFFA13.w    ; IMRA
	move.b	d0,$FFFFFA15.w    ; IMRB
	bclr.b	#3,$FFFFFA17.w    ; Bit AEI dans le VR

* Adresse ecran et resolution

	stop	#$2300
	stop	#$2300
	move.b	NewSAdr+1(pc),$FFFF8201.w
	move.b	NewSAdr+2(pc),$FFFF8203.w
	move.b	#$00,$FFFF8260.w
	move.b	#$02,$FFFF820A.w  ; a retirer sur TT !

	move	#$2700,sr

; -------------------------

Main
	jsr	ClearScreens
	jsr	InitPoints

* Nouveaux vecteurs

	lea	InstallVBL(pc),a0
	move.l	a0,$70.w
	lea	IT_Null(pc),a0
	move.l	a0,$120.w
	lea	IT_Null(pc),a0
	move.l	a0,$134.w

	move.b	#$01,$FFFFFA07.w ; Timer B on
	move.b	#$01,$FFFFFA13.w ; Unmask TB

* On valide les interruptions

	move	#$2300,sr

* On attend la barre d'espace

.Wait0
	cmpi.b	#$39,$FFFFFC02.w
	bne.s	.Wait0
.Wait1
	cmpi.b	#$39+$80,$FFFFFC02.w
	bne.s	.Wait1

; -------------------------

Exit
	move	#$2700,sr
	move.l	#IT_Null,$70.w

	moveq	#0,d0
	move.b	d0,$FFFFFA07.w ; IERA
	move.b	d0,$FFFFFA09.w ; IERB
	move.b	d0,$FFFFFA13.w ; IMRA
	move.b	d0,$FFFFFA15.w ; IMRB
	
	lea	SaveAll+4(pc),a6
	stop	#$2300
	stop	#$2300
	move.b	(a6)+,$FFFF8260.w
	move.b	(a6)+,$FFFF8201.w
	move.b	(a6)+,$FFFF8203.w

* On remet tout le monde comme avant

	move	#$2700,sr
	lea	SaveAll+7(pc),a6
	move.b	(a6)+,$FFFFFA07.w
	move.b	(a6)+,$FFFFFA09.w
	move.b	(a6)+,$FFFFFA13.w
	move.b	(a6)+,$FFFFFA15.w
	move.b	(a6)+,$FFFFFA17.w
	move.b	(a6)+,$FFFFFA19.w
	move.b	(a6)+,$FFFFFA1B.w
	move.l	(a6)+,d7
	move.l	(a6)+,$120.w
	move.l	(a6)+,$134.w

* Ancien vecteur VBL

	move.l	d7,$70.w

* Ancienne palette

	lea	OldPal(pc),a0
	lea	$FFFF8240,a2
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a2)

* Vide le buffer clavier

.KFlush
	btst.b	#0,$FFFFFC00.w
	beq.s	.KFOK
	move.b	$FFFFFC02.w,d0
	bra.s	.KFlush

.KFOK
	move	#$2300,sr

* Utilisateur

	lea	SaveAll(pc),a6
	move.l	(a6),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

* PTerm
	clr.w	-(sp)
	trap	#1


; -------------------------

SaveAll	DCB.B	30,0

OldPal	DCB.W	16,0
NewPal	DC.W	$000,$777,$654,$765,$432,$777,$654,$765
	DC.W	$321,$777,$654,$765,$432,$777,$654,$765

NewSAdr	DC.L	SCREENS

InstallVBL
	move.l	#VGTVBL,$70.w
	rte

IT_Null
	rte

; -------------------------
; Effacage des ecrans

ClearScreens
	lea	SCREENS,a0
	moveq	#0,d0
	move.w	#((2*SCRSIZ)/4)-1,d7
.CS
	move.l	d0,(a0)+
	dbf	d7,.CS
	rts

; -------------------------
; Recodage d'un texte
; Adr. texte dans A0, adr. table dans A1

EncodeText
	movea.l	a1,a2

.GetChar
	move.b	(a0)+,d0

	cmpi.b	#$FF,d0 ; End of text
	beq.s	.End

	movea.l	a2,a1
.Scan
	move.b	(a1)+,d1
	cmpi.b	#$FF,d1
	beq.s	.NotFound
	move.b	(a1)+,d2
	cmp.b	d0,d1
	bne.s	.Scan
	move.b	d2,-1(a0)
	bra.s	.GetChar

.NotFound
	move.b	#0,-1(a0)
	bra.s	.GetChar

.End
	rts

; -------------------------
; Initialisation des variables et routines

InitPoints

* Recodage du texte

	lea	LText,a0 ; text for flagpoints
	lea	TextTab0,a1
	bsr	EncodeText

* Plonk

	move.w	#50*50,VCount

* Initialisation des buffers d'effacement

	lea	PSAVEBUF,a0
	move.w	#(NBPX*NBPY)-1,d7
.I0
	move.l	#SCREENS,(a0)+
	dbf	d7,.I0
	move.w	#(NBPX*NBPY)-1,d7
.I1
	move.l	#SCREENS+SCRSIZ,(a0)+
	dbf	d7,.I1

* Generation du code d'effacage

	lea	PDELCODE,a0
* On genere: move.l (a5)+,a0 et move.l d0,(a0)
	move.l	#$205D3080,d0
* puis on genere: move.l d0,2*160+2(a0)
	move.l	#$31400142,d1
	move.w	#(NBPX*NBPY)-1,d7
.Gen0
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	dbf	d7,.Gen0
	move.w	#$4E75,(a0)+

* On se bidouille une nouvelle table de sinus

	lea	PSINTAB,a1
	move.w	#4-1,d7
.NewSin
	lea	SinTab,a0
	move.w	#512-1,d6
.Calc
	move.w	(a0)+,d0
	asr.w	#7,d0
	move.w	d0,(a1)+
	dbf	d6,.Calc
	dbf	d7,.NewSin
	
* Fin des initialisations

	rts

; -------------------------
; VBL Principale

VGTVBL
	sf	$FFFF8240.w

* Swap des ecrans

	lea	CScreen,a0
	movem.l	(a0),d0-d1
	exg	d0,d1
	movem.l	d0-d1,(a0)
	move.b	1(a0),$FFFF8201.w
	move.b	2(a0),$FFFF8203.w

* Timer B pour les deux barres

	move.b	#$00,$FFFFFA1B.w
	move.l	#PTB0,$120.w
	move.b	#$01,$FFFFFA21.w
	move.b	#$08,$FFFFFA1B.w

* Compteur de VBLs

	addq.w	#1,VSync

* On saute a la demo

	jsr	PointsVBL

* Fin de la VBL

	st	$FFFF8240.w
	rte

; -------------------------
; Timers B pour les barres

PTB0
	move.w	#$776,$FFFF8240.w
	move.l	#PTB00,$120.w
	rte

PTB00
	move.w	#$000,$FFFF8240.w
	move.b	#$00,$FFFFFA1B.w
	move.b	#197,$FFFFFA21.w
	move.l	#PTB1,$120.w
	move.b	#$08,$FFFFFA1B.w
	rte

PTB1
	move.w	#$776,$FFFF8240.w
	move.b	#$00,$FFFFFA1B.w
	move.b	#$01,$FFFFFA21.w
	move.l	#PTB2,$120.w
	move.b	#$08,$FFFFFA1B.w
	rte

PTB2
	move.w	#$000,$FFFF8240.w
	rte

; -------------------------

PointsVBL

* Effacer les points precedents

	lea	PSAVEBUF,a5
	cmpi.l	#SCREENS,CScreen
	beq	*+8
	lea	PSAVEBUF+NBPX*NBPY*4,a5

	moveq	#0,d0
	jsr	PDELCODE

* Et maintenant, affichons les nouveaux

	lea	PSINTAB,a6
	lea	Mulu160,a4
	lea	PointsTab,a2
	movea.l	CScreen,a1

	move.w	#4+28,d2
	move.w	#8+8,a3
	move.w	#511*2,d5

	lea	PSAVEBUF,a5
	cmpi.l	#SCREENS,CScreen
	beq	*+8
	lea	PSAVEBUF+NBPX*NBPY*4,a5

	move.w	XAng,SavXAng
	move.w	YAng,d6
	move.w	XAng,d3

	move.w	#NBPY-1,d7
.PLines
	move.w	d3,d4

	REPT NBPX

	movea.l	a1,a0
	
	move.w	0(a6,d4.w),d0
	addi.w	#16*2,d4

	add.w	d2,d0
	addq.w	#8,d2

	move.w	0(a6,d6.w),d1
	addi.w	#32*2,d6

	add.w	a3,d1
	add.w	d1,d1
	adda.w	0(a4,d1.w),a0

	move.w	d0,d1
	andi.w	#$FFF0,d1
	lsr.w	#1,d1
	adda.w	d1,a0

	move.l	a0,(a5)+

	add.w	d0,d0
	move.w	0(a2,d0.w),d1
	or.w	d1,(a0)
	or.w	d1,2*160+2(a0)

	ENDR

.Phi0XAng
	addi.w	#24*2,d3
	and.w	d5,d3

.Phi0YAng
	addi.w	#24*2,d6
	and.w	d5,d6

	move.w	#4+28,d2
	addq.w	#8,a3

	dbf	d7,.PLines

.Phi1YAng
	addi.w	#12*2,YAng
	andi.w	#511*2,YAng

	move.w	SavXAng,XAng
.Phi1XAng
	addi.w	#16*2,XAng
	andi.w	#511*2,XAng

* Doit-on changer de courbe?

	subi.w	#1,CtPPars
	bne.s	.NoChangeCurve
	bsr	PChangeCurve
.NoChangeCurve

* La partie d'affichage de texte

	cmpi.w	#$00FF,LTextWait
	beq	.EndPoints

	tst.w	LTextWait
	beq.s	.DrawLText

	subi.w	#1,LTextWait
	bra	.EndPoints

.DrawLText
	movea.l	CScreen,a0
	movea.l	CScreen+4,a3
	lea	190*160+4(a0),a0
	lea	190*160+4(a3),a3

	move.w	CtLText,d0
	move.w	d0,d1
	andi.w	#$FFFE,d0
	andi.w	#$0001,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d0

	adda.w	d0,a0
	adda.w	d0,a3

	movea.l	PtLText,a1
	moveq	#0,d0
	move.b	(a1),d0

	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	Font88,a1
	adda.w	d0,a1

N	SET	0
	REPT	8
	move.b	(a1),N(a0)
	move.b	(a1),N(a3)
	move.b	(a1),N+2-160(a0)
	move.b	(a1),N+2-160(a3)
N	SET	N+160
	ENDR

	addi.w	#1,CtLText
	addi.l	#1,PtLText
	cmpi.w	#40,CtLText
	blt.s	.EndPoints

	movea.l	PtLText,a0
	tst.b	(a0)
	bpl.s	.OkText
	st	LTextWait
	bra.s	.EndPoints

.OkText
	move.w	#50*3,LTextWait
	clr.w	CtLText

.EndPoints
	rts

; -------------------------

	DC.L	.Phi0XAng,.Phi0YAng,.Phi1YAng,.Phi1XAng
	DC.L	.PLines+2

PointsPars
	DC.W	16*2,16*2,6*2,2*2,11*2,10*2
	DC.W	32*2,16*2,16*2,16*2,10*2,14*2
	DC.W	32*2,48*2,48*2,12*2,8*2,12*2
	DC.W	16*2,32*2,24*2,24*2,12*2,16*2
	DC.W	12*2,36*2,18*2,12*2,12*2,12*2
	DC.W	16*2,16*2,16*2,0*2,12*2,16*2
EndPointsPars

; -------------------------

PChangeCurve
	movea.l	PointsPars-4,a0

	movea.l	PtPPars,a1
	move.w	(a1)+,d0
	move.w	(a1)+,d1

N	SET	0
	REPT	32
	move.w	d0,N+6+2(a0)
	move.w	d1,N+18+2(a0)
N	SET	N+$36
	ENDR

	lea	PointsPars-20,a0

	REPT	4
	move.l	(a0)+,a2
	move.w	(a1)+,2(a2)
	ENDR

	move.w	#6*50,CtPPars

	cmpa.l	#EndPointsPars,a1
	blt.s	.OKPt
	movea.l	#PointsPars,a1

.OKPt
	move.l	a1,PtPPars

	rts

; -------------------------

	SECTION DATA

* Variables generales

CScreen	DC.L	SCREENS
	DC.L	SCREENS+SCRSIZ

Font88
	DCB.B	8,0
	DC.W	$7CFE
	DC.W	$EEEE,$FEFE,$EEEE,$FCFE,$EEFC
	DC.W	$FEEE,$FEFC,$7CFE,$EEE0,$E0EE
	DC.W	$FE7C,$FCFE,$EEEE,$EEEE,$FEFC
	DC.W	$7EFE,$E0F8,$F8E0,$FE7E,$7EFE
	DC.W	$E0F8,$F8E0,$E0E0,$7CFE,$EEE0
	DC.W	$E0EE,$FE7E,$EEEE,$EEFE,$FEEE
	DC.W	$EEEE,$FEFE,$3838,$3838,$FEFE
	DC.W	$0E0E,$0E0E,$EEEE,$FE7C,$EEEE
	DC.W	$EEFC,$FCEE,$EEEE,$E0E0,$E0E0
	DC.W	$E0E0,$FE7E,$C6EE,$FEFE,$EEEE
	DC.W	$EEEE,$CEEE,$FEFE,$FEFE,$EEE6
	DC.W	$7CFE,$EEEE,$EEEE,$FE7C,$FCFE
	DC.W	$EEFE,$FCE0,$E0E0,$7CFE,$EEEE
	DC.W	$EEEE,$FE7E,$FCFE,$EEFE,$FCEE
	DC.W	$EEEE,$7EFE,$E0FC,$7E0E,$FEFC
	DC.W	$FEFE,$3838,$3838,$3838,$EEEE
	DC.W	$EEEE,$EEEE,$FE7C,$EEEE,$EEEE
	DC.W	$EEEE,$7C38,$EEEE,$EEEE,$FEFE
	DC.W	$EEC6,$EEEE,$EE7C,$7CFE,$EEEE
	DC.W	$EEEE,$EE7C,$3838,$3838,$FEFE
	DC.W	$0E1C,$3870,$FEFE,$E0E0,$E0E0
	DC.W	$E000,$E0E0,$0000,$0000,$00E0
	DC.W	$E0E0,$0000,$0000,$0060,$60E0
	DC.W	$1C3C,$7C1C,$1C1C,$1C1C,$7CFE
	DC.W	$EE0E,$7CF8,$FEFE,$7CFE,$CE1C
	DC.W	$1CCE,$FE7C,$E0E0,$E0E0,$F8FE
	DC.W	$FE18,$FEFE,$F0FE,$0EEE,$FE7C
	DC.W	$7CFE,$EEE0,$FEEE,$FE7C,$FEFE
	DC.W	$EE0E,$0E0E,$0E0E,$7CFE,$EE7C
	DC.W	$7CEE,$FE7C,$7CFE,$EEFE,$0EEE
	DC.W	$FE7C,$387C,$EEEE,$EEEE,$7C38
	DC.W	$7CFE,$D6FE,$BAC6,$FE7C

* Table de recodage du texte

TextTab0:
	DC.B	' ',0

N	SET	1
M	SET	1
	REPT 26
	DC.B	64+M,N
N	SET	N+1
M	SET	M+1
	ENDR

	DC.B	'!',N
	DC.B	'.',N+1
	DC.B	',',N+2

	DC.B	'1',N+3
	DC.B	'2',N+4
	DC.B	'3',N+5
	DC.B	'4',N+6
	DC.B	'5',N+7
	DC.B	'6',N+8
	DC.B	'7',N+9
	DC.B	'8',N+10
	DC.B	'9',N+11
	DC.B	'0',N+12
	DC.B	'*',N+13
	DC.B	$FF

	EVEN

* La table de sinus

SinTab	INCBIN	SIN1024.VGT

* Table de multiplication
* par 160

Mulu160
N	SET	0
	REPT	200
	DC.W	N
N	SET	N+160
	ENDR

VSync	DC.W	0

* Variables des points

VCount	DC.W	50*40

XAng	DC.W	0
SavXAng	DC.W	0
YAng	DC.W	0

PointsTab
	REPT	20
	DC.W	$8000,$4000,$2000,$1000
	DC.W	$0800,$0400,$0200,$0100
	DC.W	$0080,$0040,$0020,$0010
	DC.W	$0008,$0004,$0002,$0001
	ENDR

PtPPars	DC.L	PointsPars
CtPPars	DC.W	1

* Variables du texte

PtLText	DC.L	LText
CtLText	DC.W	0
LTextWait	DC.W	0

LText
	DC.B	' ST MAG PRESENTIERT LOS SEHR MAGNIFICOS '
	DC.B	'DEMO MIT DER POINTS ALL OVER DAS SCREEN '
	DC.B	' MA QUE VOUS SEHEN 1452 PIXELOS KIBOUJ! '
	DC.B	' DU MOECHSTCHEN WAIT UNA MOMENTI UM POUR'
	DC.B	'ZU ALL DER EFFECTS VOIR, UND AT LOS FINE'
	DC.B	'   UNA SPEKTAKULAR DOCUMENTI SURPRISE   '
	DC.B	'        IN BED WITH CREGIRECHE!         '
	DC.B	'                                        '
	DC.B	$FF

END

