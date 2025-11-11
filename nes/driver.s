	.segment "CODE"
	.proc main
    sei
    cld
    jsr init_ntsc ; ;; placeholder: 実環境に合わせ NMI/IRQ/PPU 初期化を行うコードに置換
.loop
    jmp .loop
	.endproc

	.segment "VECTORS"
	.word NMIHandler
	.word Reset
	.word IRQHandler

NMIHandler:
    rti
Reset:
    jmp main
IRQHandler:
    rti
