; listing no 3 st mag no 57
; article flexi-scroll
; code Marlon / STCNX
;

REZ             EQU 0           ; 0 couleur sinon monochrome

                TEXT
                PART 'System i/o'
                movea.l 4(SP),A6
                lea     database(PC),A0
                adda.l  #mystack-database,A0
                movea.l A0,SP
                move.l  $0C(A6),D0
                add.l   $14(A6),D0
                add.l   $1C(A6),D0
                add.l   #$0100,D0
                move.l  D0,-(SP)
                move.l  A6,-(SP)
                clr.w   -(SP)
                move.w  #$4A,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bne.s   Problem
                pea     Demo(PC)
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,SP
Problem:
                clr.w   -(SP)
                trap    #1
                ENDPART
Demo:
                movem.l D0-A6,-(SP)
                bsr     SaveInterrupts
                bsr     InitDemo
MainLoop:
                bsr     WaitFrame
                bsr     DemoScroll
                cmpi.w  #$B9,$FFFFFC02.w
                bne.s   MainLoop
                bsr     EndDemo
                bsr     ResetInterrupts
                movem.l (SP)+,D0-A6
                rts
                PART 'HardwarePart'
SaveInterrupts:
                move    #$2700,SR
                move.b  #$12,$FFFFFC02.w
                DC.W $A00A
                movem.l D0-A6,-(SP)
                lea     Vectors(PC),A6
                BASE A6,Vectors
                move.l  $70.w,Vbl(A6)
                move.l  $0134.w,Timera(A6)
                move.l  $0120.w,Timerb(A6)
                move.l  $0114.w,Timerc(A6)
                move.l  $0110.w,Timerd(A6)
                lea     VideoRegisters(A6),A1
                movea.w #$8200,A0
                movep.w 1(A0),D0
                move.w  D0,(A1)+
                move.w  $60(A0),(A1)+
                movem.l $40(A0),D0-D7
                movem.l D0-D7,(A1)
                clr.l   $FFFFFA06.w
                bclr    #3,$FFFFFA17.w
                movem.l (SP)+,D0-A6
                move    #$2300,SR
                rts

ResetInterrupts:
                move    #$2700,SR
                movem.l D0-A6,-(SP)
                lea     Vectors(PC),A6
                BASE A6,Vectors
                lea     vblfake(PC),A0
                move.l  A0,$70.w
                stop    #$2300
                stop    #$2300
                lea     VideoRegisters(A6),A1
                movea.w #$8200,A0
                move.w  (A1)+,D0
                movep.w D0,1(A0)
                move.w  (A1)+,$60(A0)
                movem.l (A1),D0-D7
                movem.l D0-D7,$40(A0)
                move.l  Vbl(A6),$70.w
                move.l  Timera(A6),$0134.w
                move.l  Timerb(A6),$0120.w
                move.l  Timerc(A6),$0114.w
                move.l  Timerd(A6),$0110.w
;Restore Mfp Regs ($FFFA03 - $FFFA25)
                lea     $FFFFFA00.w,A1
                move.l  #$04001E64,D0
                movep.l D0,$03(A1)
                movep.w D0,$13(A1)
                clr.b   $19(A1)
                clr.b   $1B(A1)
                clr.b   $1D(A1)
                move.l  #$FFF0C002,D0
                movep.l D0,$1F(A1)
                move.b  #$51,$1D(A1)
                move.b  #$48,$17(A1)
                movem.l (SP)+,D0-A6
                DC.W $A009
                move    #$2300,SR
                bsr     FlushKeyboard
                move.b  #$08,$FFFFFC02.w
                rts

vblfake:
                rte

FlushKeyboard:
                movem.l D0-A6,-(SP)
                move.b  #$13,$FFFFFC02.w
FlushKey:
                moveq   #$A1,D0
                and.b   $FFFFFC00.w,D0
                beq.s   Flush
                tst.b   $FFFFFC02.w
                bra.s   FlushKey
Flush:
                move.w  #$22,-(SP)
                trap    #14
                addq.l  #2,SP
                suba.l  A0,A0
                clr.b   109(A0,D0.l)
                move.b  #$11,$FFFFFC02.w
                movem.l (SP)+,D0-A6
                rts

Vectors:
Vbl:            DC.L 0
Timera:         DC.L 0
Timerb:         DC.L 0
Timerc:         DC.L 0
Timerd:         DC.L 0
VideoRegisters: DS.L 9
                ENDPART
                PART 'DemoPart'
InitDemo:
                movem.l D0-A6,-(SP)
                move.l  $FFFF8200.w,D7
                lsl.w   #8,D7
                lea     screensadd(PC),A0
                and.l   #$FFFF00,D7
                move.l  D7,(A0)+
                lea     database(PC),A1
                adda.l  #screen2-database,A1
                move.l  A1,D7
                and.l   #$FFFF00,D7
                move.l  D7,(A0)+
                bsr     Cls
                lea     database(PC),A0
                adda.l  #demoscrolltxt-database,A0
                movea.l A0,A1
                lea     12+fontsdisplayed(A1),A1
                move.l  A1,(A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                bsr     CircleCalcul
                bsr     GenereFonts
                pea     Frame(PC)
                move.l  (SP)+,$70.w
                stop    #$2300
                stop    #$2300
                move.l  #$0777,$FFFF8240.w
                movem.l (SP)+,D0-A6
                rts

EndDemo:
                movem.l D0-A6,-(SP)
                pea     vblfake(PC)
                move.l  (SP)+,70.w
                stop    #$2300
                stop    #$2300
                bsr     Cls
                movem.l (SP)+,D0-A6
                rts

Cls:
                movea.w #8240,A0
                moveq   #7,D0
ClearPal:
                clr.l   (A0)+
                dbra    D0,ClearPal
                movem.l screensadd(PC),A0-A1
                move.w  #7999,D0
ClearScreens:
                clr.l   (A0)+
                clr.l   (A1)+
                dbra    D0,ClearScreens
                rts

fontsdisplayed  SET 23

DemoScroll:
                movem.l D0-A6,-(SP)
;efface le scrolling
                movea.l screensadd(PC),A0
                lea     database(PC),A1
                adda.l  #wavebuffer-database,A1
                lea     database(PC),A2
                adda.l  #demoscrolltxt-database,A2
                move.l  4(A2),D0
                movea.l (A2),A2
                sub.l   #(hauteur*4)*2,D0
                bge.s   clrok
                move.l  #(hauteur*4)*30,D0
                subq.l  #1,A2
clrok:
                adda.l  D0,A1
                lea     database(PC),A3
                adda.l  #fontsclrgenerated-database,A3
                moveq   #0,D1
                moveq   #fontsdisplayed-1,D2
clrfont:
                moveq   #0,D0
                move.b  -(A2),D0
                sub.b   #' ',D0
                add.w   D0,D0
                move.w  0(A3,D0.w),D0
                jsr     0(A3,D0.w)
                lea     (hauteur*4)*32(A1),A1
                dbra    D2,clrfont
;imprime le scrolling
                movea.l screensadd(PC),A0
                lea     database(PC),A1
                adda.l  #wavebuffer-database,A1
                lea     database(PC),A2
                adda.l  #demoscrolltxt-database,A2
                movea.l (A2),A3
                move.l  4(A2),D0
                add.l   #(hauteur*4)*2,D0
                cmp.l   #(hauteur*4)*32,D0
                blt.s   nonewletter
                moveq   #0,D0
                addq.l  #1,A3
                tst.b   (A3)
                bne.s   nonewscroll
                lea     12+fontsdisplayed(A2),A3
nonewscroll:
                move.l  A3,(A2)
nonewletter:
                move.l  D0,4(A2)
                lea     database(PC),A1
                adda.l  #wavebuffer-database,A1
                lea     database(PC),A2
                adda.l  #demoscrolltxt-database,A2
                movea.l (A2),A2

                adda.l  D0,A1
                lea     database(PC),A3
                adda.l  #fontsgenerated-database,A3
                movea.l A1,A4
                moveq   #fontsdisplayed-1,D2
printfont:
                moveq   #0,D0
                move.b  -(A2),D0
                sub.b   #' ',D0
                add.w   D0,D0
                move.w  0(A3,D0.w),D0
                jsr     0(A3,D0.w)
                lea     (hauteur*4)*32(A4),A4
                movea.l A4,A1
                dbra    D2,printfont
                movem.l (SP)+,D0-A6
                rts

;routine qui precalcule la courbe
;decrite par le scrolling
TablePlot:
                DC.W 1,2,4,8,16,32,64,128
                DC.W 256,512,1024,2048,4096,8192,16384,32768
CircleCalcul:
                movem.l D0-A6,-(SP)
                lea     database(PC),A0
                adda.l  #democosinus-database,A0
                lea     database(PC),A1
                adda.l  #demosinus-database,A1
                lea     database(PC),A2
                adda.l  #wavebuffer-database,A2
                move.w  #719,D7
calcul0:
                moveq   #0,D0
                move.w  (A0)+,D0
                moveq   #0,D1
                move.w  (A1)+,D1
                moveq   #hauteur-1,D6
calcul1:
                move.l  D0,D2
                IFEQ REZ
                move.l  #85,D5
                ELSE
                move.l  #185,D5
                ENDC
                add.w   D6,D5
                muls    D5,D2
                lsl.l   #2,D2
                clr.w   D2
                swap    D2
                move.l  D2,D3
                ext.l   D3
                lsr.l   #4,D3
                IFEQ REZ
                lsl.l   #3,D3
                ELSE
                lsl.l   #1,D3
                ENDC
                and.w   #$0F,D2
                neg.b   D2
                add.b   #15,D2
                add.w   D2,D2
                move.w  TablePlot(PC,D2.w),D2
                swap    D2
                move.w  D3,D2
                move.l  D1,D3
                IFEQ REZ
                move.l  #85,D5
                ELSE
                move.l  #185,D5
                ENDC
                add.w   D6,D5
                muls    D5,D3
                lsl.l   #2,D3
                clr.w   D3
                swap    D3
                ext.l   D3
                IFEQ REZ
                muls    #160,D3
                add.w   #80+99*160,D3
                ELSE
                muls    #80,D3
                add.w   #40+199*80,D3
                ENDC
                add.w   D2,D3
                move.w  D3,(A2)+
                swap    D2
                move.w  D2,(A2)+
                dbra    D6,calcul1
                dbra    D7,calcul0
;cree un effet de disparition
;et d'effacement des caracteres
                move.w  #25*12-1,D0
fill1:
                clr.w   (A2)+
                dbra    D0,fill1
                lea     database(PC),A0
                adda.l  #wavebuffer-database,A0
                move.w  #26*2,D0
rnd0:
                clr.w   2(A0)
                addq.l  #8,A0
                clr.w   2(A0)
                addq.l  #4,A0
                clr.w   2(A0)
                addq.l  #8,A0
                dbra    D0,rnd0
                lea     database(PC),A0
                adda.l  #wavebuffer-database+33520,A0
                move.w  #26*2,D0
rnd1:
                clr.w   2(A0)
                addq.l  #8,A0
                clr.w   2(A0)
                addq.l  #4,A0
                clr.w   2(A0)
                addq.l  #8,A0
                dbra    D0,rnd1
                movem.l (SP)+,D0-A6
                rts

;Genere le code de fonts 1 plan (-90 degre)
;de 16 de large et de x de hauteur
;ici, on sait que les 4 premieres
;colonnes des fonts sont vides
nbrfonts        SET 59
hauteur         SET 12
largeur         SET 13

GenereFonts:
                movem.l D0-A6,-(SP)
                lea     database(PC),A0
                adda.l  #fontsgraphix-database,A0
                lea     database(PC),A1
                adda.l  #fontsgenerated-database,A1
                lea     nbrfonts*2(A1),A2
                moveq   #nbrfonts-1,D0
gen1font:
                lea     database(PC),A3
                adda.l  #fontsgenerated-database,A3
                move.l  A3,D4
                neg.l   D4
                add.l   A2,D4
                move.w  D4,(A1)+
;codefont-fontsgenerated
                moveq   #0,D4
                moveq   #largeur-1,D1
gen1line:
                move.w  (A0)+,D3
                moveq   #hauteur-1,D2
gen1column:
                roxr.w  #1,D3
                bcc.s   nopixel
                tst.w   D4
                beq.s   addok
                cmp.w   #4,D4
                bne.s   add8
                move.w  #$5889,(A2)+
;addq.l #4,a1
                bra.s   addok
add8:
                cmp.w   #8,D4
                bne.s   addw
                move.w  #$5089,(A2)+
;addq.l #8,a1
                bra.s   addok
addw:
                cmp.w   #8,D4
                bmi.s   addw
                move.w  #$43E9,(A2)+
;lea xxxx(a1),a1
                move.w  D4,(A2)+
;xxxx
addok:
                moveq   #0,D4
                move.l  #$30193219,(A2)+
;move.w (a1)+,d0/move.w (a1)+,d1
                move.l  #$83700000,(A2)+
;or.w   d1,(a0,d0.w)
                bra.s   gen1columnend
nopixel:
                addq.l  #4,D4
gen1columnend:
                dbra    D2,gen1column
                dbra    D1,gen1line
                move.w  #$4E75,(A2)+
;rts
                dbra    D0,gen1font
                lea     database(PC),A0
                adda.l  #fontsgraphix-database,A0
                lea     database(PC),A1
                adda.l  #fontsclrgenerated-database,A1
                lea     nbrfonts*2(A1),A2
                moveq   #nbrfonts-1,D0
gen1fontclr:
                lea     database(PC),A3
                adda.l  #fontsclrgenerated-database,A3
                move.l  A3,D4
                neg.l   D4
                add.l   A2,D4
                move.w  D4,(A1)+
;codefontclr-fontsclrgenerated
                moveq   #0,D4
                moveq   #largeur-1,D1
gen1lineclr:
                move.w  (A0)+,D3
                moveq   #hauteur-1,D2
gen1columnclr:
                roxr.w  #1,D3
                bcc.s   nopixelclr
                move.w  #$3029,(A2)+
;move.w xxxx(a1),d0
                move.w  D4,(A2)+
;xxxx
                move.l  #$31810000,(A2)+
;move.w d1,(a0,d0.w)
nopixelclr:
                addq.w  #4,D4
                dbra    D2,gen1columnclr
                dbra    D1,gen1lineclr
                move.w  #$4E75,(A2)+
;rts
                dbra    D0,gen1fontclr
                movem.l (SP)+,D0-A6
                rts

;routine de synchronisation vbl
WaitFrame:
                movem.l D0-D1/A0,-(SP)
                lea     screensadd(PC),A0
                movem.l (A0),D0-D1
                exg     D0,D1
                movem.l D0-D1,(A0)
                lsr.w   #8,D1
                move.l  D1,$FFFF8200.w
                lea     Switch(PC),A0
                sf      (A0)
Wait:
                tst.b   (A0)
                beq.s   Wait
                movem.l (SP)+,D0-D1/A0
                rts

;routine vbl dont le seul but est
;de mettre a l'etat vrai un octet
;Frame
                pea     (A0)
                lea     Switch(PC),A0
                st      (A0)
                movea.l (SP)+,A0
                rte
                ENDPART

                DATA
Switch:
                DC.W 0
screensadd:
                DC.L 0,0
database:
democosinus:
                IBYTES 'COSINUS.CNX'
demosinus:
                IBYTES 'SINUS.CNX'
demoscrolltxt:
                DC.L 0,0,0
                DCB.B fontsdisplayed,' '
                DC.B 'ET VOICI UN SUPER EFFET DE SCROLL'
                DC.B 'POUR $ ST MAGAZINE $ '
                DCB.B fontsdisplayed,' '
                DC.W 0
fontsgraphix:
                PART 'Fonts'
;cette police de caracteres a ete dessinee
;par Arjarn/The Vegetables que je tiens a
;remercier
                DS.W 13
                DC.W $00,$00,$00,$00,$00,$0DFF,$0DFF,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$0F,$00,$0F,$00,$00,$00,$00,$00
                DS.W 13
                DC.W 0,$0C00
                DS.W 26
                DC.W $00,$00,$00,$00,$00,$00,$0F,$00,$00,$00,$00,$00,$00
                DC.W $0801,$0801,$0402,$030C,$F0,$00,$00,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$00,$00,$00,0,$F0,$030C,$0402,$0801,$0801
                DS.W 26
                DC.W $00,$00,$00,$00,$0600,$0800,$00,$00,$00,$00,$00,$00,$00
                DC.W $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
                DC.W $00,$00,$00,$00,$0600,$0600,$00,$00,$00,$00,$00,$00,$00
                DS.W 13
                DC.W $030C,$F0
                DC.W $00,$00,$00,$00,$0800,$0800,$0FFF,$0802,$0804,$00,$00,$00,$00
                DC.W $0C0C,$00
                DC.W $0402,$00
                DC.W $80,$80,$80,$80,$0FE0,$81,$82,$84,$88,$90,$A0,$C0,$80
                DC.W $0821,$083F
                DC.W $0422,$03FC
                DC.W $13,$15,$19,$11,$31,$51,$01,$0F01,$01,$01,$01,$01,$07

                DC.W $0440,$0380
                DC.W $0813,$040C
                DC.W $00,$00,$00,$00,$00,$060C,$060C,$00,$00,$00,$00,$00,$00
                DC.W $00,$00,$00,$00,$06C0,$08C0,$00,$00,$00,$00,$00,$00,$00
                DS.W 39
                DC.W $0C,$12,$21,$21,$41,$0D81,$01,$01,$01,$02,$0C,$00,$00
                DS.W 13
                DC.W $0800,$0FFF,$0882,$84,$88,$90,$A0,$C0,$80,$0100,$0A00,$0C00,$0800
                DC.W $0FFF,$0801
                DC.W $030C,$F0
                DC.W $0FFF,$0801
                DC.W $0FFF,$0801
                DC.W $03,$01,$01,$01,$71,$21,$21,$21,$21,$21,$0821,$0FFF,$0801
                DC.W $030C,$F0
                DC.W $0801,$0FFF,$0821,$20,$20,$20,$20,$20,$20,$20,$0821,$0FFF,$0801
                DC.W $00,$00,$00,$00,$0801,$0801,$0FFF,$0801,$0801,$00,$00,$00,$00
                DC.W $00,$80
                DC.W $0800,$0800,$0C01,$0202,$0104,$88,$50,$20,$40,$0881,$0FFF,$0801,$00
                DC.W $0FFF,$0801
                DC.W $0801,$0FFF,$8001,$02,$04,$08,$10,$08,$04,$02,$0801,$0FFF,$0801
                DC.W $0FFF,$0401,$0200,$0100,$80,$40,$20,$10,$08,$04,$0802,$0FFF,$0801
                DC.W $F0,$030C,$0402,$0402,$0801,$0801,$0801,$0801,$0801,$0402,$0402,$030C,$F0
                DC.W $00,$00,$1C,$22,$41,$41,$41,$41,$41,$41,$0841,$0FFF,$0801
                DC.W $08F0,$070C,$0602,$0502,$0801,$0801,$0801,$0801,$0801,$0402,$0402,$030C,$F0
                DC.W $0800,$0800,$0C1C,$0222,$0141,$C1,$41,$41,$41,$41,$0841,$0FFF,$0801
                DC.W $0812,$0C0C
                DC.W $03,$01,$01,$01,$01,$0801,$0FFF,$0801,$01,$01,$01,$01,$03
                DC.W $03FF,$01
                DC.W $01,$03,$0D,$30,$C0,$0300,$0C00,$0300,$C0,$30,$0D,$03,$01
                DC.W $0FFF,$0801
                DC.W $0801,$0803,$0C04,$0208,$0110,$A0,$40,$A0,$0110,$0208,$0C04,$0803,$0801
                DC.W $01,$03,$04,$08,$10,$0820,$0FC0,$0820,$10,$08,$04,$03,$01
                DC.W $0C00,$0801,$0803,$0805,$0809,$0811,$0821,$0841,$0881,$0901,$0A01,$0C01,$0803
                ENDPART

                BSS
fontsgenerated:
                DS.W nbrfonts
                DS.L 3600
fontsclrgenerated:
                DS.W nbrfonts
                DS.L 2900
wavebuffer:
                DS.L (720+80)*hauteur
screen2:
                DS.L 8064
                DS.L 128
mystack:
                END
