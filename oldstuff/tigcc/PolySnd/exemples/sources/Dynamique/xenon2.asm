;--------------------------------
;Geoffrey ANNEHEIM
;08/08/03

;Simple exemple for PolySnd v2.0
;--------------------------------

	include		"doorsos.h"			;Incus Doorsos, ici on programme en Kernel
	include		"polysnd2.h"			;Inclus PolySnd v2.0 (ici Dynamique ASM)
	
	xdef		_ti89
	xdef		_ti92plus
	xdef		_main
	xdef		_comment
	
_main: 
 	move.w	#$0700,d0				;D�sactive toutes les interruptions
	trap	#1					;Appel routine du TIOS
	bclr.b	#2,($600001)				;Retire la protection de la table vectorielle
	move.l	$64,int1				;Sauvegarde l'adresse Int1
	move.l	$68,int2				;Sauvegarde l'adresse Int2
	move.l	#empty_handler,$64			;Redirige vers empty_handler
	move.l	#empty_handler2,$68			;Redirige vers ampty_handler2, inhibe clavier
	bset.b	#2,($600001)				;Remet protection m�moire
	moveq.w	#0,d0					;Active toutes les interruptions
	trap	#1					;Effectu� par d0
	
 	bsr	GetCalculator				;Renvoie le model de TI dans calc
 	
 	jsr	polysnd2::EnableSound			;Met le port I/O en son
	jsr	polysnd2::InstallSound			;Install l'interurption audio
 
	moveq.b  #_STEREO,d0				;Met PolySnd en mode STEREO
 	jsr	polysnd2::PlayMode			;Effectu� par PlayMode
 	 
 	move.w	#113,d0
 	jsr	polysnd2::SetTempo_voice1		;R�gle tempo voie1 et voie2
 	jsr	polysnd2::SetTempo_voice2
 	 
 	lea	channel1(PC),a0				;Adresse de channel1
 	jsr	polysnd2::PlaySound_voice1
 	lea	channel2(PC),a0	
 	jsr	polysnd2::PlaySound_voice2				
 	
	moveq.b  #_ALLVOICES,d0				;Pour toutes les voies
 	jsr	polysnd2::SetState			;Par d�faut PolySnd et en mode pause pour �viter
 	
 	
loop_key:						;Boucle clavier
 	jsr	polysnd2::VoiceState			;R�cup�re �tat des voies
 	tst.b	d0					;Si 0 alors musique finit
 	beq	fin					;Donc fin
 	
 	cmp.b	#0,calc					;Si TI89
	beq	key_89					;key_89
	bne	key_92					;key_92 focntionne aussi sur V200	

key_89: move.w	#6,d0					;Rep�re ESC
	bsr	masque
	btst.b	#0,d0
	beq	fin					;Si press� fin
	bne	loop_key				;Sinon loop

key_92: move.w	#8,d0					;Rep�r� ESC
	bsr	masque	
	btst.b	#6,d0
	beq	fin					;Si press� fin
	bra	loop_key				;sinon loop
 
fin:	
 	jsr	polysnd2::UninstallSound		;Desinstall l'interurption audio et la remet � son �tat courant
	jsr	polysnd2::DisableSound			;Idem pour l'interruption du port I/O
	
	move.w	#$0700,d0				;D�sactive interruptions
	trap	#1
	bclr.b	#2,($600001)
	move.l	int1(PC),$64				;Remet � son �tat courant l'auto int 1 et 2
	move.l	int2(PC),$68
	bset.b	#2,$600001
	moveq.w	#0,d0
	trap	#1
 	rts	


empty_handler:
	rte
	
empty_handler2:
	sf.b $60001b 					;Permet d'inhiber le clavier
	rte 
	
;----------------------------
;Detection de la calculatrice
;----------------------------
GetCalculator:
	movem.l	a1,-(a7)			;Sauvegarde a1
	move.l $C8,a0				;Addresse pour v�rifier si TI-89 ou TI-92 Plus
	move.b	#1,calc				;Pr�d�finis comme TI-92 Plus
	move.l	a0,d1				;Pr�pare d1
	and.l #$400000,d1			;Si ~0 alors TI-92 Plus sinon TI-89 ou V200
	bne	__calculator			;Dans cas TI-92 Plus alors Fin
	move.b	#0,calc				;Pr�d�finis comme TI-89
	move.l $2F*4(a0),a1			;Pr�pare condition
	cmp.b	#200,2(a1)			;Si 200 alors TI-89
	bcs	__calculator			;Donc Fin
	move.b	#2,calc				;Donc V200
__calculator:
	movem.l	(a7)+,a1			;Restaure a1
	rts
	
	
;--------------------------------------------
;Masque pour la lecture du clavier	
;********************************************
;********************************************
;masque une ligne du clavier
;--------------------------------------------
;d0=ligne -> d0=r�ponse
;********************************************
masque:
	movem.l	d1,-(a7)
	move.w	#$FFFE,d1
	rol.w	d0,d1
	clr.w	d0
	move.w	d1,($600018)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	($60001B),d0
	movem.l	(a7)+,d1
	RTS
	
		
_comment dc.b	"Song Xenon II",0
calc	 dc.b	0

int1	dc.l	0
int2	dc.l	0
	EVEN
	
	
;********************************************************************
;Channels obtenues avec PolySnd MIDI Converter.
;********************************************************************
channel1:
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,36
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,255
	dc.b	pause,255
	dc.b	pause,255
	dc.b	pause,207
	dc.b	_ad6,8
	dc.b	pause,24
	dc.b	_ad6,8
	dc.b	pause,24
	dc.b	_ad6,8
	dc.b	pause,24
	dc.b	_ad6,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad6,4
	dc.b	pause,255
	dc.b	pause,101
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_dd6,2
	dc.b	pause,38
	dc.b	_dd6,4
	dc.b	pause,4
	dc.b	_dd6,2
	dc.b	pause,7
	dc.b	_cd6,1
	dc.b	pause,6
	dc.b	_b5,1
	dc.b	pause,4
	dc.b	_a5,1
	dc.b	pause,4
	dc.b	_g5,1
	dc.b	pause,69
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,12
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_cd6,8
	dc.b	pause,8
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_f6,4
	dc.b	pause,4
	dc.b	_cd6,8
	dc.b	pause,16
	dc.b	_cd6,8
	dc.b	pause,24
	dc.b	_gd5,8
	dc.b	pause,8
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_gd5,4
	dc.b	pause,4
	dc.b	_c6,4
	dc.b	pause,4
	dc.b	_gd5,8
	dc.b	pause,16
	dc.b	_gd5,8
	dc.b	pause,24
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_cd6,4
	dc.b	pause,4
	dc.b	_ad5,8
	dc.b	pause,16
	dc.b	_ad5,8
	dc.b	pause,24
	dc.b	_ad5,16
	dc.b	pause,16
	dc.b	_ad5,16
	dc.b	pause,16
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,36
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,8
	dc.b	pause,8
	dc.b	_ad5,8
	dc.b	pause,72
	dc.b	_ad5,16
	dc.b	pause,16
	dc.b	_ad5,16
	dc.b	pause,16
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,36
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,12
	dc.b	_ad5,4
	dc.b	pause,4
	dc.b	255
	
channel2:
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,20
	dc.b	_ad3,1
	dc.b	pause,15
	dc.b	_ad3,4
	dc.b	pause,28
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,1
	dc.b	pause,15
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,1
	dc.b	pause,32
	dc.b	_ad3,1
	dc.b	pause,14
	dc.b	_ad3,4
	dc.b	pause,28
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,1
	dc.b	pause,15
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,1
	dc.b	pause,15
	dc.b	_ad3,4
	dc.b	pause,28
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,9
	dc.b	_f7,5
	dc.b	pause,3
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,9
	dc.b	_f7,5
	dc.b	pause,3
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	_ad6,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,9
	dc.b	_f7,8
	dc.b	_gd3,1
	dc.b	_f7,1
	dc.b	_gd3,11
	dc.b	pause,11
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,9
	dc.b	_f7,8
	dc.b	_ad3,1
	dc.b	_f7,1
	dc.b	_ad3,11
	dc.b	pause,11
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,2
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,2
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,2
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,1
	dc.b	_f6,1
	dc.b	_ad3,9
	dc.b	_f7,8
	dc.b	_ad3,1
	dc.b	_f7,1
	dc.b	_ad3,11
	dc.b	pause,11
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_ad6,1
	dc.b	_ad3,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,1
	dc.b	_f6,1
	dc.b	_cd4,9
	dc.b	_f7,8
	dc.b	_cd4,1
	dc.b	_f7,1
	dc.b	_cd4,11
	dc.b	pause,11
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	_ad6,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_cd4,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,1
	dc.b	_f6,1
	dc.b	_gd3,9
	dc.b	_f7,8
	dc.b	_gd3,1
	dc.b	_f7,1
	dc.b	_gd3,11
	dc.b	pause,11
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad6,1
	dc.b	_gd3,1
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,132
	dc.b	_ad6,8
	dc.b	pause,8
	dc.b	_c7,4
	dc.b	pause,4
	dc.b	_d7,4
	dc.b	pause,4
	dc.b	_e7,4
	dc.b	pause,4
	dc.b	_fd7,4
	dc.b	pause,4
	dc.b	_gd7,8
	dc.b	pause,13
	dc.b	_fd7,1
	dc.b	pause,2
	dc.b	_e7,1
	dc.b	pause,4
	dc.b	_d7,1
	dc.b	pause,3
	dc.b	_c7,1
	dc.b	pause,3
	dc.b	_ad6,1
	dc.b	pause,255
	dc.b	pause,43
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,12
	dc.b	pause,12
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,8
	dc.b	pause,8
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_cd4,4
	dc.b	pause,4
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,12
	dc.b	pause,12
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,8
	dc.b	pause,8
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_gd3,4
	dc.b	pause,4
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,12
	dc.b	pause,12
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,8
	dc.b	pause,8
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	_ad3,4
	dc.b	pause,4
	dc.b	255