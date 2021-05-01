IDEAL 
MODEL small
STACK 100h
DATASEG
					
					
	yay             db       "                                                                     ", 13, 10
					db       "                ,-.----.       ,----..            ,--.               ", 13, 10
					db       "                \    /  \     /   /   \         ,--.'|  ,----..      ", 13, 10
					db       "                |   :    \   /   .     :    ,--,:  : | /   /   \     ", 13, 10
					db       "                |   |  .\ : .   /   ;.  \,`--.'`|  ' :|   :     :    ", 13, 10
					db       "                .   :  |: |.   ;   /  ` ;|   :  :  | |.   |  ;. /    ", 13, 10
					db       "                |   |   \ :;   |  ; \ ; |:   |   \ | :.   ; /--`     ", 13, 10
					db      "                |   : .   /|   :  | ; | '|   : '  '; |;   | ;  __    ", 13, 10
					db       "                ;   | |`-' .   |  ' ' ' :'   ' ;.    ;|   : |.' .'   ", 13, 10
					db       "                |   | ;    '   ;  \; /  ||   | | \   |.   | '_.' :   ", 13 ,10
					db      "                 :   ' |     \   \  ',  / '   : |  ; .''   ; : \  |  ", 13 ,10
					db       "                 :   : :      ;   :    /  |   | '`--'  '   | '/  .'  ", 13, 10
					db       "                |   | :       \   \ .'   '   : |      |   :    /     ", 13, 10
					db       "                `---'.|        `---`     ;   |.'       \   \ .'      ", 13, 10
					db       "                  `---`                  '---'          `---`        ", 13 ,10, '$'
	
	
	names            db       "           Created By Itay Shnap 213631963. Teachers: Ayelet and Liran$"
	startmsg     db       "                                  Click P To Start Playing!$"

	score db 13,10,18 dup(' '),'0',' - ','0','$'
	
	
	player1_win db"                 ",13,10
				db 13 dup(' '),"PLAYER ONE WON",13,10
				db "press  space to continue or R to restart",13,10,'$'
	
	player2_win db"                 ",13,10
				db 14 dup(' '),"PLAYER TWO WON",13,10
				db "press  space to continue or R to restart",13,10,'$'
	
	ballx dw 0A0h ; מיקום x
	bally dw 64h ; מיקום y
	ball_right dw 0A4h ; הנקודה הכי ימנית בכדור
	ball_down dw 68h ; הנקודה הכי נמוכה בכדור
	ball_size dw 04h ;גודל
	ball_speed_x dw 04h ;מהירויות הכדור
	ball_speed_y dw 02h
	
	timer db 0; טיימר
	
	stick_left_point db 0
	stick_left_color db 0fh
	left_rightest_point dw 8h
	stick_left_x dw 4h
	stick_left_y dw 60h
	stick_left_bottom dw 80h
	
	stick_height dw 1eh
	stick_width dw 4h
	stick_speed dw 6h
	
	stick_right_point db 0
	stick_right_color db 0fh
	stick_right_x dw 138h
	stick_right_y dw 60h
	stick_right_bottom dw 80h
	
	
	line_height dw 0c8h
	line_width dw 2h
	
	screen_width dw 140h ; רוחב החלון
	screen_height dw 0c8h  ; גובה החלון 
	
CODESEG
	
	proc main  ; פעולה ראשית
		start_screen:
			mov [ballx],0A0h
			mov [bally],64h
			mov [ball_right],0A4h
			mov [ball_down],68h
			mov [stick_right_color],0fh
			mov [stick_left_color],0fh
			mov [stick_left_y],60h
			mov [stick_right_y],60h
			mov [score +20],30h
			mov [score +24],30h
			mov [stick_right_point],0h
			mov [stick_left_point],0h
			mov [stick_right_bottom],80h
			mov [stick_left_bottom], 80h
			
			mov ah, 0
			mov al, 2
			int 10h
			mov dx, offset yay
			mov ah, 9
			int 21h
			mov dx, offset names
			mov ah, 09h
			int 21h
			mov dx, offset startmsg
			mov ah, 09h
			int 21h
			mov ah, 0 ; there is a key in the buffer, read it and clear the buffer
			int 16h
			cmp ah,19h
			jne start_screen
			
		

		
		call screen_clr
		
		time_check:; בודק אם הזמן זז(כן- ממשיך את הקוד/לא- חוזר על הפעולה)
			mov ah,2ch; משיג את הזמן
			int 21h
			cmp dl,[timer]
			je time_check
			mov [timer],dl
			call screen_clr
			call draw_white_line
			call draw_score
			call ball_move
			call draw_ball
			call draw_stick_left
			call draw_stick_right
			mov ah, 1
			int 16h
			jz skip1
			mov ah, 0 ; there is a key in the buffer, read it and clear the buffer
			int 16h
			;ימין למטה
			cmp ah,25h
			jne right_up_key_check
			call right_down_check
			jmp skip1
			;ימין למעלה
			right_up_key_check:
			cmp ah,17h
			jne left_up_key_check
			call right_up_check
			jmp skip1
			;שמאל למעלה
			left_up_key_check:
			cmp ah,11h
			jne left_key_down_check
			call left_up_check
			jmp skip1
			;שמאל למטה
			left_key_down_check:
			cmp ah,1fh
			jne skip1
			call left_down_check
			
			skip1:
			cmp [stick_left_point],5h
			je ending_screen_1
			cmp [stick_right_point],5h
			je ending_screen_2
			
			
			jmp time_check
			
			ending_screen_1:
			call screen_clr
			call draw_white_line
			call draw_stick_left
			mov dx,offset player1_win
			mov ah,9h
			int 21h
			key_check2:
			mov ah, 0 ; there is a key in the buffer, read it and clear the buffer
			int 16h
			cmp ah,13h
			jne end_check
			call main
			jmp end_game
			end_check:
			cmp ah,39h
			jne key_check2
			jmp end_game
			
			ending_screen_2:
			call screen_clr
			call draw_white_line
			call draw_stick_right
			mov dx,offset player2_win
			mov ah,9h
			int 21h
			key_check:
			mov ah, 0 ; there is a key in the buffer, read it and clear the buffer
			int 16h
			cmp ah,13h
			jne end_check2
			call main
			jmp end_game
			end_check2:
			cmp ah,39h
			jne key_check
			jmp end_game
			
			
			;ending_screen_2:
			;call draw_score
			;mov dx,offset player2_win
			;mov ah,9h
			;int 21h
			;mov ah, 0 ; there is a key in the buffer, read it and clear the buffer
			;int 16h
			;cmp ah,39h
			;je start_screen
			;jmp ending_screen_1
			
		end_game:
		ret
		
	endp main 
	
		
		
	;המקל השמאלי פעולות	
	proc left_down_check
		mov ax, [screen_height]
		cmp [stick_left_bottom],ax
		je ret_jmp4
		call left_down
		ret_jmp4:
		ret
	endp left_down_check
	
	proc left_down 
			mov ax,[stick_speed]
			add [stick_left_y],ax
			add [stick_left_bottom],ax
			ret
	endp left_down
	
	proc left_up_check
			cmp [stick_left_y],00h
			je ret_jmp3
			call left_up
			ret_jmp3:
			ret
	endp left_up_check
			
	proc left_up
		mov ax,[stick_speed]
		sub [stick_left_y],ax
		sub [stick_left_bottom],ax
		ret
	endp left_up
	

	
	; המקל הימני פעולות
	proc right_down_check
		mov ax, [screen_height]
		cmp [stick_right_bottom],ax
		je ret_jmp
		call right_down
		ret_jmp:
		ret
	endp right_down_check
	
	proc right_down 
			mov ax,[stick_speed]
			add [stick_right_y],ax
			add [stick_right_bottom],ax
			ret
	endp right_down
	
	proc right_up_check
			cmp [stick_right_y],00h
			je ret_jmp
			call right_up
			ret_jmp2:
			ret
	endp right_up_check
			
	proc right_up
		mov ax,[stick_speed]
		sub [stick_right_y],ax
		sub [stick_right_bottom],ax
		ret
	endp right_up
	
	
	proc ball_move 
	
		mov ax, [ball_speed_x]
		add [ballx],ax
		add [ball_right],ax
	
		; הגיע הכי שמאלה
		cmp [ballx],00h
		je point_right
			
		;הגיע הכי ימינה
		mov ax,[screen_width]
		cmp [ball_right],ax
		je point_left
		
		;נגע בשמאלי
		mov ax,[left_rightest_point]
		cmp [ballx],ax
		jg hop
		mov ax,[bally]
		cmp ax,[stick_left_y]
		jl hop
		cmp ax,[stick_left_bottom]
		jle opposite_speed_x
		
		
		;נגע בימני
		hop:
		mov ax,[stick_right_x]
		cmp ax,[ball_right]
		jg hop2
		mov ax,[bally]
		cmp ax,[stick_right_y]
		jl hop2
		cmp ax,[stick_right_bottom]
		jle opposite_speed_x
		
		hop2:
		mov ax, [ball_speed_y]
		add [bally],ax
		add [ball_down],ax
		; הגיע הכי גבוה
		cmp [bally],0
		JLE opposite_speed_y
		
		; הגיע הכי נמוך
		mov ax,[screen_height]
		cmp [ball_down],ax
		jge opposite_speed_y
		
		ret

			
		opposite_speed_y:
			neg [ball_speed_y]
			ret
			
		opposite_speed_x:
			neg [ball_speed_x]
			ret
		
		point_right:
			inc [stick_right_point]
			mov [ballx],0A0h
			mov [bally],64h
			mov [ball_right],0A4h
			mov [ball_down],68h
			neg [ball_speed_x]
			dec [stick_right_color]
			ret
		
		
		point_left:
			inc [stick_left_point]
			mov [ballx],0A0h
			mov [bally],64h
			mov [ball_right],0A4h
			mov [ball_down],68h
			neg [ball_speed_x]
			dec [stick_left_color]
			ret
			
	
	endp
	
	
	
	
	
	
	proc screen_clr ;מנקה את המסך
	
		mov ah,0
		mov al,13h
		int 10h
		
		mov ah,0Bh
		mov bh,00h
		mov bl,00h
		int 10h
		ret
	endp screen_clr
	
	

	
	
	proc draw_ball  ; פעולה המציירת את הכדור
		
		mov cx,[ballx]
		mov dx,[bally]
		
		draw_ball_x: ; פעולה שמציירת את רוחב הכדור
			
			mov ah,0Ch
			mov al,0fh
			mov bh,00h 
			int 10h
			
			inc cx
			mov ax,cx
			sub ax,[ballx]
			cmp ax,[ball_size]
			jne draw_ball_x
			mov cx,[ballx]
			inc dx ; עובר לשורה אחרת
			
		draw_ball_end: ; בודק אם סיימנו את ציור הכדור (כן- מסיים/ לא- קורא לפעולה  עוד הפעם אבל על שורה אחרת)
		mov ax,dx
		sub ax,[bally]
		cmp ax,[ball_size]
		jng draw_ball_x
		
	
		ret
	endp draw_ball
	
	proc draw_stick_left 
		
		mov cx,[stick_left_x]
		mov dx,[stick_left_y]
		
		draw_stick_x: ; פעולה שמציירת את רוחב המקל
			
			mov ah,0Ch
			mov al,[stick_left_color]
			mov bh,00h 
			int 10h
			
			inc cx
			mov ax,cx
			sub ax,[stick_left_x]
			cmp ax,[stick_width]
			jne draw_stick_x
			mov cx,[stick_left_x]
			inc dx ; עובר לשורה אחרת
			
		draw_stick_end: ; בודק אם סיימנו את ציור המקל (כן- מסיים/ לא- קורא לפעולה  עוד הפעם אבל על שורה אחרת)
		mov ax,dx
		sub ax,[stick_left_y]
		cmp ax,[stick_height]
		jng draw_stick_x
		
		
		ret
		endp draw_stick_left
		
		
		proc draw_stick_right 
		
		mov cx,[stick_right_x]
		mov dx,[stick_right_y]
		
		draw_stick_x2: ; פעולה שמציירת את רוחב המקל
			
			mov ah,0Ch
			mov al,[stick_right_color]
			mov bh,00h 
			int 10h
			
			inc cx
			mov ax,cx
			sub ax,[stick_right_x]
			cmp ax,[stick_width]
			jne draw_stick_x2
			mov cx,[stick_right_x]
			inc dx ; עובר לשורה אחרת
			
		draw_stick_end2: ; בודק אם סיימנו את ציור המקל (כן- מסיים/ לא- קורא לפעולה  עוד הפעם אבל על שורה אחרת)
		mov ax,dx
		sub ax,[stick_right_y]
		cmp ax,[stick_height]
		jng draw_stick_x2
		
		
		ret
		endp draw_stick_right
	
		proc draw_white_line
			mov cx, 0A0h
			mov dx,0h
			
			draw_line_x: ; פעולה שמציירת את רוחב המקל
				
				mov ah,0Ch
				mov al,0fh
				mov bh,00h 
				int 10h
				
				inc cx
				mov ax,cx
				sub ax,0A0h
				cmp ax, [line_width]
				jne draw_line_x
				mov cx,0A0h
				inc dx ; עובר לשורה אחרת
				
			draw_white_end: ; בודק אם סיימנו את ציור המקל (כן- מסיים/ לא- קורא לפעולה  עוד הפעם אבל על שורה אחרת)
			mov ax,dx
			sub ax, 00h
			cmp ax,[line_height]
			jng draw_line_x
		
		
		ret
		endp draw_white_line
	
		proc draw_score
		mov dx,offset score
		mov ah,9h
		int 21h
		;צד ימין
		mov ah,[stick_left_point]
		add ah,30h
		mov [score +20],ah
		;צד שמאל
		mov ah,[stick_right_point]
		add ah,30h
		mov [score +24],ah
		ret
		endp draw_score
			
			
			
			
	
start:
	mov ax, @data
	mov ds, ax
	mov al,13h
	int 10h
	call main


exit: 
		call screen_clr
		mov ax,4c00h
		int 21h
END start