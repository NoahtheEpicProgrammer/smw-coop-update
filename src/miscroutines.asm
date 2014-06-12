CharOffsets:				;Starting tiles for players pre-dma
db $00,$30,$60

NameOffsets:				;Where each player starts in the next table
db $00,$05,$0A
CharNames:					;BLOOM, SCOOT, BELLE
db $0B,$15,$18,$18,$16
db $1C,$0C,$18,$18,$1D
db $0B,$0E,$15,$15,$0E

PlusMax:					;Maximum horizontal motion speeds in various conditions
db $14,$24,$30
MinusMax:
db $EC,$DC,$D0

GetCharacterLong:
JSR GetCharacter
RTL

GetCharacter:
CLC
ADC $010A
CMP #$03
BCC +
SEC
SBC #$03
+
RTS

TickPhysics:
JSR UpdatePosX
JSR UpdatePosY
JSR UpdateSpdY
RTS

UpdatePosX:
TXA
CLC
ADC #$0C
TAX
JSR UpdatePosY
LDX $0F65
RTS

UpdatePosY:				;pretty much copy+paste from all.log: $01:ABD8
LDA $AA,x
BEQ .end
ASL #4
CLC
ADC $14EC,x
STA $14EC,x
PHP
PHP
LDY #$00
LDA $AA,x
LSR #4
CMP #$08
BCC +
ORA #$F0
DEY
+
PLP
PHA
ADC $D8,x
STA $D8,x
TYA
ADC $14D4,x
STA $14D4,x
PLA
PLP
ADC #$00
STA $1491
.end
RTS

UpdateSpdY:
LDA $0DB9
BIT #$04
BNE .underwater
LDY #$01
LDA $0DA3
ORA $0DA5
BMI +
LDY #$00
+
LDA #$40
STA $00
LDA $0DB9
AND #$18
CMP #$10
BNE +
LDA $0DA3
ORA $0DA5
BPL +
LDA #$0D
STA $00
+
LDA $AA,x
BMI +
CMP $00
BCC +
LDA $00
+
CLC
ADC GravityData,y
STA $AA,x
.underwater
RTS

SuperReturn:
PLB
RTS

LoadCoopSprite:
PHB
PHK						;data bank = code bank
PLB
LDX $0F65
LDA $14C8,x
BEQ .plzload
LDA $9E,x
CMP #$69
BEQ SuperReturn
.plzload
JSL $02A9DE				;find good sprite slot
BMI SuperReturn
TYX						;stick in X
LDA #$69				;set sprite number
STA $9E,x
JSL $07F7D2				;load sprite tables
;JSL $0187A7			;THIS ROUTINE LITERALLY DOES NOTHING BUT NOP; RTS; /RTS/!!!! WHAT???
LDA #$08
STA $14C8,x				;set sprite status: normal
STZ $151C,x				;zero animation timer
LDA #$75				;set aspects: state, direction, identifier, index, animation timer
STA $1528,x
STX $0F65				;save sprite index
LDA #$01
STA $157C,x
LDA $0F63
BIT #$08			;if p2 isn't active
BNE +
LDA #$80
STA $14D4,x
LDA #$0C			;deactivate
TRB $0F63
JMP .skipposition
+
LDA #$0C
TSB $0F63			;set sprite: alive and well
LDA $94
SEC
SBC #$10
STA $E4,x
LDA $95
SBC #$00
STA $14E0,x
LDA $96				;set position behind mario
CLC
ADC #$10
STA $D8,x
LDA $97
ADC #$00
STA $14D4,x
LDA $192A
AND #$07
CMP #$07
BNE +
LDA #$04
+
STA $00				;setup pipe entry
LDA $0F63			;if mario shouldn't enter
BIT #$02
BNE +
LDA #$80			;shift away mario
STA $97
LDA #$03
TRB $0F63			;absolutely no mario
LDA $94
STA $E4,x
LDA $95
STA $14E0,x			;luigi exactly where mario was
BRA .skipfup		;skip relative positioning
+
LDA $00
CMP #$01
BEQ ++
CMP #$04
BEQ +
CMP #$03
BNE .skipfup		;horizontal pipes skip vertical bump
+
LDA $94
STA $E4,x
LDA $95
STA $14E0,x			;bump forward eight pixels
LDA $00
CMP #$03
BEQ +
LDA $D8,x
SEC
SBC #$28
STA $D8,x
LDA $14D4,x
SBC #$00
STA $14D4,x			;down pipe: bump up 28
BRA .skipfup
+
LDA $D8,x
CLC
ADC #$28
STA $D8,x
LDA $14D4,x
ADC #$00
STA $14D4,x			;up pipe: bump down 28
BRA .skipfup
++
LDA $E4,x
CLC
ADC #$20
STA $E4,x			;left pipe: shift right 20
LDA $14E0,x
ADC #$00
STA $14E0,x
.skipfup
LDA $00
BEQ .skipposition
CMP #$05
BEQ .skipposition
CMP #$06
BNE +
LDA #$40
STA $B6,x
LDA #$01
TSB $0F6A
LDA #$C0
STA $AA,x
LDA #$09
STA $1504,x
LDA #$20			;shoot from pipe
STA $151C,x
BRA .skipposition

.pipetimes
db $3C,$3C,$47,$43
db $1C,$1C,$1C,$1B
+
STA $1504,x
DEC
TAY
LDA $0F63
BIT #$02
BNE +
INY #4
+
LDA.w .pipetimes,y
STA $151C,x
.skipposition
LDA #$08
STA $7FAB10,x
PLB
RTS

;;;;;;;;;
;
;Make Positive - now with sixteen bit handler!
;
;;;;;;;;;

FrcPlus:
BPL .return
PHA
PHP
PHP
SEP #$20
PLA
BIT #$20
BEQ .sixteenbit
PLP
PLA
EOR #$FF
INC
.return
RTS
.sixteenbit
PLP
PLA
EOR #$FFFF
INC
RTS

;;;;;;;;;
;
;Hurt luigi
;
;;;;;;;;;

HurtLuigi:
LDX $0F65
LDA $1540,x
BNE .end
LDA $0DB9
AND #$18
CMP #$08
BEQ KillLuigi
;LDA #$80
;STA $1540,x
LDA #$04
STA $1DF9
LDA #$18
TRB $0DB9
LDA #$08
TSB $0DB9
;LDA #$31
;STA $151C,x
;LDA #$06
;STA $1504,x
;LDA #$02
;STA $0F42
;STA $9D
LDA #$D8
STA $AA,x
LDA $157C,x
BNE +
LDA #$18
BRA $02
+
LDA #$E8
STA $B6,x
LDA #$60
STA $1540,x
.end
RTS

KillBoth:
JSL $00F606
KillLuigiLong:
JSR KillLuigi
RTL

;;;;;;;;;
;
;Kill luigi
;
;;;;;;;;;

KillLuigi:
LDA $0F63
AND #$0C
CMP #$0C
BNE .end
PHX
LDX $0F65				; Get sprite index
STZ $1588,x				; Clear player blocked status
LDA #$90				; Set upward Y speed
STA $AA,x
STZ $B6,x				; Zero X speed
DEC $0DB5				; Decrease lives
LDA #$0C
TRB $0F63				; Mark p2 dead
STZ $0DB9				; Clear misc. flags
PLX
LDA $0F63
BIT #$02
BNE .mariookay
LDA #$09				; Do this if mario is also dead
STA $1DFB
LDA #$FF
STA $0DDA
LDA #$09
STA $71
LDA #$30
STA $9D
STA $1496
RTS
.mariookay
LDA #$A0				; Do this if mario is not dead
STA $0F66				; Set bubble respawn timer
LDA #$23
STA $1DF9				; Play pwoooooo sound effect
.end
RTS

;;;;;;;;;
;
;Where on the sprite
;if A is 1, 'win' is defined as below the sprite
;returns A as 1 if our sprite wins
;
;;;;;;;;;

LocateContact:
PHA		;preserve win settings
LDA $14D4,y	;\set enemy ypos to scratch
STA $01		; |
LDA $00D8,y	; |
STA $00		;/
LDA $14D4,x	;\get self ypos to scratch
STA $03
LDA $D8,x	;
STA $02
PLA
BNE casebottom
REP #$20
LDA $02
CLC
ADC #$0004
SEC
CMP $00		;carry clear = on top
BCC ontop
SEP #$20
LDA #$00
RTS
ontop:
SEP #$20
LDA #$01
RTS
casebottom:
REP #$20
LDA $02
SEC
SBC #$000C
SEP #$20
CLC
CMP $00		;carry set = below
BCS onbottom
LDA #$00
RTS
onbottom:
LDA #$01
RTS

;;;;;;;;;
;
; BoostSpeed
;
; Boost's Luigi's speed as though he stomped on an enemy.
;;;;;;;;;

BoostSpeed:
;PHX
;TYX
JSL $01AB72		;white-star
;PLX
LDA $0DA3
ORA $0DA5
BIT #$80
BNE LargeJump
LDA #$E0
STA $AA,x
RTS
LargeJump:
LDA #$B0
STA $AA,x
RTS

;;;;;;;;;
;
; AddToYpos
;
; Adds a 16-bit value to sprite ypos
;;;;;;;;;

AddToYpos:
REP #$20
PHA
SEP #$20
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
STA $04
PLA
CLC
ADC $04
SEP #$20
STA $D8,x
XBA
STA $14D4,x
RTS

;;;;;;;;
;
; ProcessCarryableItem
;
; return: --LBSKTN
;;;;;;;;

ProcessCarryableItem:
LDA $14C8,y
CMP #$09
BEQ StunCQ
CMP #$0A
BEQ KickCQ
CMP #$0B
BEQ CheckSelfCarry
LDA #$09
RTS

StunCQ:
LDA $0DA3
ORA $0DA5
BIT #$40
BNE StunBP
LDA #$11
RTS

StunBP:
LDA #$0B
STA $14C8,y
LDA #$80
TSB $0DB9
LDA #$00
RTS

KickCQ:
LDA #$00
JSR LocateContact
CLC
ASL
ORA #$05
STA $06
LDA $0DA3
ORA $0DA5
AND #$40
EOR #$40
LSR
LSR
ORA $06
RTS

CheckSelfCarry:
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ LetGo
UpdatePosByCarry:
LDA $157C,x
BNE HoldLeft
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC #$000A
BRA EndHoldDir
HoldLeft:
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CLC
ADC #$000A
EndHoldDir:
SEP #$20
STA $00E4,y
XBA
STA $14E0,y
LDA $D8,x
SEC
SBC #$01
STA $00D8,y
LDA $14D4,x
SBC #$00
STA $14D4,y
LDA #$00
STA $00AA,y
STA $00B6,y
RTS

LetGo:
LDA #$80
TRB $0DB9
LDA #$08
STA $154C,y
LDA $0DA3
BIT #$04
BNE DropDown
PHX
TYX
JSL $01AB72
TXY
PLX
LDA #$08
STA $154C,x
LDA $0DA3
BIT #$08
BNE TossUp
LDA $157C,x
BNE KickLeft
KickRight:
LDA #$C0
STA $00B6,y
LDA #$0A
STA $14C8,y
LDA #$13
STA $1DF9
LDA #$00
RTS

KickLeft:
STA $157C,y
LDA #$40
STA $00B6,y
LDA #$0A
STA $14C8,y
LDA #$13
STA $1DF9
LDA #$00
RTS

DropSpeedTable:
db $F6,$0A

DropDown:
PHY
TXY
LDA $157C,y
TAX
LDA $00B6,y
CLC
ADC.w DropSpeedTable,x
TYX
PLY
STA $00B6,y
LDA #$09
STA $14C8,y
LDA #$00
RTS

TossUp:
LDA $B6,x
STA $00B6,y
LDA #$90
STA $00AA,y
LDA #$13
STA $1DF9
LDA #$09
STA $14C8,y
LDA #$00
RTS

SubHorzPosLuigi:
STZ $0F
LDA $14E0,x
STA $01
LDA $E4,x
STA $00
LDA $14E0,y
XBA
LDA $00E4,y
REP #$20
CMP $00
BCS +
INC $0F
+
SEP #$20
RTS

SpinKillSprite:
LDX $15E9		;get luigi sprite index (?)
JSL $01AB6F		;contact star

PHX			;preserve X
TYX			;X=Y
STY $15E9		;fool the game into thinking we're processing another sprite so that it'll display the
JSL $07FC3B		;spin jump star GFX correctly.
TXY
PLX
STX $15E9		;restore normality
LDA #$FA
STA $AA,x		;zero Y-speed
LDA #$04
STA $14C8,y		;mark sprite as "dissapear in puff of smoke"
LDA #$08
STA $1DF9		;play sound effect
LDA #$18
STA $1540,y
JSR SpinKillEntry	;get points
STZ $1DFC
RTS

KillWithStar:
JSR StarKillEntry
LDA #$02
STA $14C8,y
LDA $1658,y
BIT #$80
BEQ FallDown
LDA #$03
STA $14C8,y
LDA #$20
STA $1540,y
FallDown:
LDA #$E0
STA $00AA,y
STA $00B6,y
PHY
JSR ADDR_02D4FA
CPY #$00
BEQ KillStarEnd
PLY
LDA #$30
STA $00B6,y
RTS
KillStarEnd:
PLY
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; BounceSquash
;
; Squashes a sprite by bouncing on it
;
; Parameter: A=sprite state to put bounced sprite in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BounceSquash:
STA $14C8,y		;set state to whatev~
JSR BoostSpeed
SpinKillEntry:
PHY			;preserve/zero Y
LDY #$00
BRA Sensible
StarKillEntry:		;Y=counter to use. 0=regular 1=star
PHY
LDY #$01
Sensible:
LDA $0F61,y
INC
STA $0F61,y
CMP #$08
BCC Lessthan1up
DEC
STA $0F61,y
LDA #$02
STA $1DF9
PLY
JMP OneUpRex
Lessthan1up:
LDA $0F61,y
CLC
ADC #$46
STA $1DFC
LDA $0F61,y
PLY
GetPointsFromY:
PHY
PHX
TYX
JSL $82ACE5		;get points
PLX
PLY
RTS

PushEdges:											;DON'T WALK OFF SCREEN
LDA $0F63
AND #$0C
CMP #$0C
BNE +
LDA $1B96
BNE CheckReallyFar
LDA $0F63
+
CMP #$00
BEQ NotFarRight
LDA $E4,x
SEC
SBC $1A
CMP #$08
BCS NotFarLeft
REP #$20
LDA $1A			;layer 1 xpos
CLC
ADC #$0008
SEP #$20
STA $E4,x
XBA
STA $14E0,x		;...plus 8 to sprite xpos
LDA $1588,x
ORA #$02
STA $1588,x
LDA $B6,x
BPL NotFarRight
STZ $B6,x
LDA $1588,x
ORA #$02
STA $1588,x
BRA NotFarRight
NotFarLeft:
CMP #$E9
BCC NotFarRight
REP #$20
LDA $1A
CLC
ADC #$00E8
SEP #$20
STA $E4,x
XBA
STA $14E0,x
LDA $1588,x
ORA #$01
STA $1588,x
LDA $B6,x
BMI NotFarRight
STZ $B6,x
LDA $1588,x
ORA #$01
STA $1588,x
NotFarRight:
RTS

CheckReallyFar:
LDA $E4,x
SEC
SBC $1A
STA $00
LDA $14E0,x
SBC $1B
BNE .offscreen
LDA $00
CMP #$F1
BCS .offscreen
RTS
.offscreen
LDA #$0B
STA $0100
RTS
