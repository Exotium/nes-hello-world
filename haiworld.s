.segment "HEADER"
    .byte "NES", $1A
    .byte $02  ; 32KB PRG ROM
    .byte $01  ; 8KB  CHR ROM
    .byte $01, $00, $00, $00, $00
    .byte $00, $00, $00, $00, $00


.segment "RODATA"
palettes:
    .byte $0f,$26,$15,$30
    .byte $0f,$10,$28,$30
    .byte $0f,$2c,$29,$30
    .byte $0f,$34,$2c,$30

attributes:
    .byte $11,$40,$e0,$74

img:
    .byte $0f,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$10
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $0d,$00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$00,$0e
    .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    .byte $11,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c,$12


.segment "CODE"
reset:
    sei

    ldx #$40
    stx $4017 ; disable apu frame counter irq

    ldx #$ff
    txs

    inx ; x=0
    sta $2000 ; disable nmi at vblank start
    sta $2001 ; disable rendering
    sta $4010 ; disable dmc irqs
    sta $4015 ; disable all apu channels

    bit $2002 ; clear vblank flag
    ; wait for first vblank
:   bit $2002
    bpl :-
    
    ; fill 2k internal sram with 0
    txa ; a=0
    ldy #$ff
:   sta $000, X
    sta $100, X
    sta $200, X
    sta $300, X
    sta $400, X
    sta $500, X
    sta $600, X
    sta $700, X
    inx
    bne :-
    
    ; wait for second vblank
:   bit $2002
    bpl :-
    
    ; copy third page to oam
    lda #$02
    sta $4014

    ; zero out nametables
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldx #$08
    tay
:   sta $2007
    iny
    bne :-
    dex
    bne :-

    ; write img
    lda #$21
    sta $2006
    lda #$a9
    sta $2006
    ldx #$00
:   lda img, X
    sta $2007
    inx
    cpx #78
    bne :-

    ; load palettes
    lda #$3f
    sta $2006
    lda #$00
    tax
    sta $2006
:   lda palettes, X
    sta $2007
    inx
    cpx #16
    bne :-

    ; write attribute table
    ldx #$00
    lda #$23
    sta $2006
    lda #$da
    sta $2006
:   lda attributes, X
    sta $2007
    inx
    cpx #4
    bne :-

    lda #$00
    sta $2005
    sta $2005

    lda #$80
    sta $2000 ; enable vblank nmi
    lda #$0e
    sta $2001 ; enable rendering
    
    cli ; 
loop:
    jmp loop

irq:
nmi:
    rti


.segment "VECTORS"
    .word nmi, reset, irq


.segment "TILES"
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
    ; text
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $c0,$60,$6c,$76,$66,$66,$66,$23
    .byte $00,$00,$08,$0c,$0c,$0c,$0d,$06, $00,$00,$30,$60,$c0,$c0,$c0,$70
    .byte $c0,$c0,$00,$c0,$c0,$c0,$d0,$60, $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$04,$06,$0e,$06,$06,$03
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$11,$1b,$36,$b6,$b6,$63
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$e6,$3f,$36,$26,$66,$c6
    .byte $0e,$06,$06,$04,$0c,$0c,$0c,$07, $00,$00,$c0,$60,$60,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00, $0c,$0c,$3c,$6c,$cc,$cc,$cc,$76
    .byte $00,$01,$01,$00,$00,$01,$01,$00, $00,$00,$00,$00,$00,$00,$00,$00
    .byte $3f,$83,$86,$0e,$03,$83,$b3,$1e, $00,$00,$00,$00,$00,$00,$00,$00
    ; border
    .byte $ff,$ff,$00,$00,$00,$00,$00,$00, $ff,$ff,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$ff,$ff, $00,$00,$00,$00,$00,$00,$ff,$ff
    .byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0, $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
    .byte $03,$03,$03,$03,$03,$03,$03,$03, $03,$03,$03,$03,$03,$03,$03,$03
    .byte $0f,$3f,$7c,$70,$e0,$e0,$c0,$c0, $07,$1f,$38,$60,$60,$c0,$c0,$c0
    .byte $f0,$fc,$3e,$0e,$07,$07,$03,$03, $e0,$f8,$1c,$06,$06,$03,$03,$03
    .byte $c0,$c0,$e0,$e0,$70,$7c,$3f,$0f, $c0,$c0,$c0,$60,$60,$38,$1f,$07
    .byte $03,$03,$07,$07,$0e,$3e,$fc,$f0, $03,$03,$03,$06,$06,$1c,$f8,$e0


.segment "ZEROPAGE"
.segment "OAM"
.segment "BSS"
