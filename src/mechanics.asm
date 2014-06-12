Mechanics:
JSR JumpShift
JSR GoalCheck
JSR GoalWalk
JSR Climbing
JSR DuckUp
LDA $0DB9
BIT #$04
BEQ +
JSR Swimming
BRA .endrunjump
+
JSR Jumping
JSR HandleDashTimer
JSR Movement
JSR DoSlideSmoke
.endrunjump
JSR Fireballs
JSR PushEdges
JSR KillMe
JSR ResetStar
RTS

JumpShift:
LDA $0F64		;do the jump autocorrect
BEQ +
LDA $D8,x
CLC
ADC #$05
STA $D8,x
LDA $14D4,x
ADC #$00
STA $14D4,x
LDA $163E,x
CMP #$6F
BCC +
LDA #$01
TSB $0F6A
+
STZ $0F64
RTS

GoalCheck:
LDY #$0B
GoalLoop:										;GOAL
LDA $009E,y
CMP #$7B
BEQ CheckSprite
NotIt:
DEY
BPL GoalLoop
BRA EndGoal
CheckSprite:
LDA $14C8,y
CMP #$08
BNE NotIt
LDA $1534,y
AND #$01
STA $01
LDA $1528,y
STA $00
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
DEC
CMP $00
SEP #$20
BCS NotIt
LDA $14E0,y
STA $01
LDA $00E4,y
STA $00
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CLC
ADC #$0008
SEC
SBC $00
CMP #$0010
SEP #$20
BCS NotIt
TYX
JSL EndLevel
LDX $0F65
EndGoal:
RTS

GoalWalk:
LDA $1493
BEQ .end
STZ $0DA3
STZ $0DA5
STZ $14A7
STZ $14A9
LDA #$05
STA $B6,x
.end
RTS

Climbing:
LDA $0F6A
BIT #$04
BEQ ClimbEnd
STZ $AA,x
STZ $B6,x
LDA $0F6A
BIT #$08
PHP
LDA $0DA3
PLP
BNE ++
LDA $1588,x
BIT #$08
PHP
LDA $0DA3
PLP
BNE +
BIT #$08
BNE .climbup
+
BIT #$04
BNE .climbdown
++
BIT #$04
BNE .stopclimb
.sideoption
BIT #$02
BNE .climbleft
BIT #$01
BNE .climbright
BRA ClimbEnd
.climbup
LDA #$F0
STA $AA,x
BRA .possiblediag
.stopclimb
LDA #$0E
TRB $0F6A
BRA ClimbEnd
.climbdown
LDA $1588,x
BIT #$04
BEQ +
LDA #$06
TRB $0F6A
BRA ClimbEnd
+
LDA #$10
STA $AA,x
.possiblediag
LDA $0F6A
BIT #$02
PHP
LDA $0DA3
PLP
BNE .sideoption
BRA ClimbEnd
.climbleft
LDA $1588,X
BIT #$02
BNE ClimbEnd
LDA #$F0
STA $B6,x
BRA ClimbEnd
.climbright
LDA $1588,X
BIT #$01
BNE ClimbEnd
LDA #$10
STA $B6,x
ClimbEnd:
RTS

DuckUp:											;DUCKING/LOOKING UP
LDA $0F6A
BIT #$20
BNE .nodown
LDA $1588,x
BIT #$04
BEQ .inAir
LDA $B6,x
BNE .trydown
LDA $0DA3
BIT #$08
BEQ .noup
LDA #$20
TSB $0DB9
BRA .trydown
.noup
LDA #$20
TRB $0DB9
.trydown
LDA $0DA3
BIT #$04
BEQ .nodown
LDA #$02
TSB $0DB9
BRA .end
.nodown
LDA $1588,x
BIT #$04
BEQ .end
LDA #$02
TRB $0DB9
BRA .end
.inAir
LDA #$20		;cancel looking up
TRB $0DB9
.end
LDA $B6,x
BEQ .ngngngng
LDA #$20
TRB $0DB9
.ngngngng
RTS

Swimming:
LDA #$23
TRB $0DB9
LDY $AA,x
LDA $0DB9
BPL .regswim
LDA $1588,x
BIT #$04
BEQ .carryswim
LDA $0DA7
ORA $0DA9
BPL .carryswim
;???
BRA +
.carryswim
LDA $0DA3
BIT #$04
BEQ .notdowncarry
+
LDA #$0E
STA $1DF9
LDA #$10
ORA $15AC,x
STA $15AC,x
TYA
CLC
ADC #$08
TAY
.notdowncarry
INY
LDA $0F6A
BIT #$40
BNE .surfacecarry
DEY
LDA $14
AND #$03
BNE .surfacecarry
DEY #2
.surfacecarry
TYA
BMI +
CMP #$10
BCC .mediancarry
LDA #$10
BRA .mediancarry
+
CMP #$F0
BCS .mediancarry
LDA #$F0
.mediancarry
STA $AA,x
LDA $157C,x
BRA .carrycontinue
.regswim
LDA $0DA7
ORA $0DA9
BPL .nobutton
LDA $0F6A
BIT #$40
BNE .nobutton
LDA #$0E
STA $1DF9
LDA #$10
ORA $15AC,x
STA $15AC,x
LDA $1588,x
BIT #$04
BEQ +
LDY #$F0
+
TYA
SEC
SBC #$20
TAY
.nobutton
LDA $14
AND #$03
BNE +
INY #2
+
LDA $0DA3
AND #$0C
LSR
LSR
PHX
TAX
TYA
BMI +
CMP #$40
BCC .median
LDA #$40
BRA .median
+
CMP.l $00D984,x
BCS .median
LDA.l $00D984,x
.median
PLX
STA $AA,x
LDA $1588,x
BIT #$04
BEQ +
LDA $0DA3
BIT #$04
BEQ +
LDA #$02
TSB $0DB9
BRA .waynextsection
+
LDA $0DA3
BIT #$03
BEQ .waynextsection
.carrycontinue
LDY #$78
STY $00
AND #$01
STA $157C,x
ASL
ASL
STA $03
LSR
LSR
ORA $00
LDY $1403		;layer 3 tide
BEQ +
CLC
ADC #$04
+
TAY
LDA $1588,x
BIT #$04
BNE +
INY #2
+
JSR RandomSwimRt
BRA .pastnecissaryrt
.waynextsection
LDY #$00
STY $04
LDA $1403
BEQ .necissaryrt
LDA #$1E
STA $04
LDA $1588,x
BIT #$04
BEQ .necissaryrt
INC $04
INC $04
.necissaryrt
JSR NecissaryRoutine
.pastnecissaryrt
RTS
RandomSwimRt:			;gotta set up a bunch of stuff
LDA #$00
PHA
PLB						;data bank 0
LDA $B6,x
STA $01
LDA $14F8,x
STA $00					;I sure hope this actually works
LDA $1588,x
AND #$04
EOR #$04
STA $02
LDA $01
SEC
SBC $D535,y
BEQ .second
EOR $D535,y
BPL .second
REP #$20
LDX $03
LDA $D345,x
LDY $86
BEQ +
LDY $02
BNE +
LDA $D43D,x
+
CLC
ADC $00
BRA .farfuture
.second
LDA $0F69
LSR
TAY
LSR
TAX
LDA $01
SEC
SBC $D5CA,x
BPL +
INY #2
+
LDA $1493
ORA $02
REP #$20
BNE +
LDA $D309,y
BIT $85
BMI ++
+
LDA $D2CD,y
++
CLC
ADC $00
STA $00
SEC
SBC $D5C9,x
EOR $D2CD,y
BMI +
LDA $0D5C9,x
.farfuture
STA $00
+
SEP #$20
PHK
PLB
LDX $0F65
LDA $00
STA $14F8,x
LDA $01
STA $B6,x
RTS
NecissaryRoutine:
LDA #$00
PHA
PLB
LDA $1588,x
AND #$04
EOR #$04
STA $02
LDA $B6,x
STA $01
LDA $14F8,x
STA $00
LDX $04
LDA $01
SEC
SBC $D5CA,x
BPL +
INY
INY
+
LDA $1493
ORA $02
REP #$20
BNE +
LDA $D309,y
BIT $85
BMI ++
+
LDA $D2CD,y
++
CLC
ADC $00
STA $00
SEC
SBC $D5C9,x
EOR $D2CD,y
BMI +
LDA $D5C9,x
STA $00
+
SEP #$20
PHK
PLB
LDX $0F65
LDA $00
STA $14F8,x
LDA $01
STA $B6,x
RTS

Jumping:
LDA $0F6A
BIT #$04
BNE +
LDA $1588,x		;\If not on ground
BIT #$04		; |
BEQ .end		;/don't jump
+
LDA #$01
TRB $0DB9
STZ $0F61
LDA $0DA7		;\if pressing B
ORA $0DA9		; |or A
BPL .end		;/jump
LDA $B6,x
BPL +
EOR #$FF
INC
+
LSR
LSR
AND #$FE
TAX
LDA $0DA9
BPL .normaljump
LDA $0F6A
BIT #$04
BNE .end
LDA $0DB9
BMI .normaljump
LDA #$01
TSB $0DB9
LDA #$22
TRB $0DB9
LDA #$04
STA $1DFC
INX
BRA +
.normaljump
LDA #$06
TRB $0F6A
LDA #$01
STA $1DFA
+
LDA $00D2BD,x
LDX $0F65
STA $AA,x
INC $0F64
.end
LDX $0F65
RTS

HandleDashTimer:
LDA $0DB9
BIT #$02
BNE .nope
LDA $0DA3
BIT #$03
BEQ .nope
ORA $0DA5
BIT #$40
BEQ .nope
LDA $B6,x
SEC
SBC #$21
CMP #$BE
BCS .nope
LDA $0F6A
BIT #$01
BNE +
LDA $1588,x
BIT #$04
BEQ .nope
+
LDA $B6,x
BMI .goingleft
LDA $0DA3
BIT #$01
BEQ .nope
BRA .yep
.goingleft
LDA $0DA3
BIT #$02
BEQ .nope
.yep
LDA $163E,x
INC #3
CMP #$71
BCC .under
LDA #$71
.under
STA $163E,x
.nope
RTS

Movement:
LDA $0F6A
BIT #$04
BEQ +
JMP .end
+
LDY #$00
LDA $0DA3
ORA $0DA5
BIT #$40
BEQ .start
INY
LDA $163E,x
CMP #$70
BCC .start
INY
.start
LDA $1588,x						;\				;MOVEMENT
BIT #$04						; |if in air, don't slow down
BEQ .bypassduck					;/
LDA #$01
TRB $0F6A
LDA $0DB9						;\
BIT #$02						; |if ducking, slow down
BNE .slowdown					;/
LDA $0DA3						;\
BIT #$03						; |if not pressing right/left, slow down
BEQ .slowdown					;/
.bypassquack
BIT #$02
BNE .goleft
LDA $B6,x
BMI .turnright
LDA $14
AND #$01
INC
CLC
ADC $B6,x
CMP.w PlusMax,y
BMI .okaystore
BRA .slowdown
.bypassduck
LDA $0DA3						;\
BIT #$03						; |if not pressing right/left, slow down
BNE .bypassquack				;/
JMP .end
.goleft
LDA $B6,x
BEQ .sigh
BPL .turnleft
.sigh
LDA $14
AND #$01
EOR #$FF
CLC
ADC $B6,x
CMP.w MinusMax,y
BMI .slowdown
.okaystore
STA $B6,x
BRA .end

.turnrightfast
LDA #$05
BRA .okayadd

.turnright
INC $1558,x
LDA $0DA3
ORA $0DA5
BIT #$40
BNE .turnrightfast
LDA $14
AND #$01
INC
INC
BRA .okayadd

.turnleftfast
LDA #$FB
BRA .okayadd

.turnleft
INC $1558,x
LDA $0DA3
ORA $0DA5
BIT #$40
BNE .turnleftfast
LDA $14
AND #$01
EOR #$FF
DEC
.okayadd
CLC
ADC $B6,x
STA $B6,x
BRA .end

.slowdown
LDA $B6,x
BMI .slowneg
BEQ .end
DEC
DEC
.slowneg
INC
STA $B6,x
.end
RTS

DoSlideSmoke:
LDA $1588,x
BIT #$04
BEQ .end
LDA $1558,x
BNE .yesyesyes
LDA $0DB9
AND #$02
BEQ .end
LDA $B6,x
BEQ .end
.yesyesyes
LDA $14
BIT #$03
BNE .end
LDY #$00
.loopstart
LDA $17C0,y
BEQ .loopsuccess
INY
CPY #$04
BNE .loopstart
BRA .end
.loopsuccess
LDA #$03
STA $17C0,y
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CLC
ADC #$0006
SEP #$20
STA $17C8,y
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
CLC
ADC #$0009
SEP #$20
STA $17C4,y
LDA #$12
STA $17CC,y
.end
RTS

Fireballs:
LDA $0DB9										;FIREBALL TOSSING
AND #$18
EOR #$18
BNE .nofiresa		;decide if tossing should actually occour

LDA $0F6A
BIT #$04
BNE .nofiresa
LDA $0DB9
BIT #$02
BNE .nofiresa
STZ $00
LDA $0DB9
BIT #$01
BEQ .trybutton
LDA $14
AND #$0F
BNE .nofiresa
LDA #$01
STA $00
BRA .continue

.trybutton
LDA $0DA7
ORA $0DA9
BIT #$40
BNE .continue
.nofiresa
JMP .end

.continue
LDY #$00
-
LDA $1713,y
BEQ +		;get new extended sprite index
INY
CPY #$02
BNE -
BRA .end
+

LDA #$05
STA $1713,y		;set fireball exists
LDA #$10
STA $1745,y		;y-speed
LDA $00
BEQ +
LDA $157C,x
PHA
LDA $14
AND #$10
LSR
LSR
LSR
LSR
STA $157C,x
+
LDA $157C,x
BEQ .left	; = 03 if facing right
LDA #$03		;if facing right, shoot right
STA $174F,y
BRA +
.left
LDA #$FD		;if facing left, shoot left
STA $174F,y
+
LDA $00
BEQ +
PLA
STA $157C,x
+
LDA $14D4,x		;ypos, high byte
XBA
LDA $D8,x		;ypos, low byte
REP #$20
SEC
SBC #$0005
SEP #$20
STA $171D,y
XBA
STA $1731,y
LDA $E4,x		;xpos, low byte
STA $1727,y
LDA $14E0,x		;xpos, high byte
STA $173B,y
LDA $157C,x
BEQ .rawrz
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
CLC
ADC #$0008
SEP #$20
STA $1727,y
XBA
STA $173B,y
.rawrz
LDA #$06
STA $1DFC
LDA $00
BNE .end
LDA #$0A
STA $1564,x
.end
RTS

KillMe:											;KILL IF SQUASHED
LDA $1588,x
AND #$03
CMP #$03
BNE +
-
JMP KillLuigi
+
LDA $1588,x
AND #$0C
CMP #$0C
BEQ -											;DIE IF FALL OFF SCREEN
LDA $5B
BIT #$01
BNE .vertical
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
CMP #$01C0
SEP #$20
BMI .end
.yeahdie
JSR KillLuigi
STZ $AA,x
RTS
.vertical
REP #$20
LDA $5D
AND #$00FF
ASL #4
STA $00
SEP #$20
LDA $14D4,x
XBA
LDA $D8,x
REP #$20
CMP $00
SEP #$20
BPL .yeahdie
.end
RTS

ResetStar:
LDA $1570,x											;RESET STAR MUSIC
CMP #$01
BNE +
LDA $0DDA
STA $1DFB
+
RTS