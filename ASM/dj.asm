.MODEL MEDIUM
.STACK 64
.DATA
	
	SYS_TIME DB 0 ; USED FOR TIME CHECKING, CHECKS IF IT IS TIME TO PRINT A FRAME ON THE SCREEN. (FPS CONTROLER)
	BALL_POS_X DW 158 ; COORDINATES OF THE TOP 
	BALL_POS_Y DW 190 ; LEFT CORNER OF THE BALL
	BALL_SIZE DW 4 ; HEIGHT AND WIDTH OF THE BALL
	BALL_I_SPEED DB 12 ; INITIAL SPEED OF THE BALL
	BALL_HORIZONTAL_SPEED DB 5 ; HORIZONTAL SPEED OF THE BALL "IF ONE OF A/a, D/d KEYS WERE PRESSED".
	BALL_SPEED_VECTOR DW 256 DUP(?) ; THE BALL'S SPEED(VELOCITY) IN DIFFERENT FRAMES WHILE IT'S JUMPING (THE BALL MOVMENT IS ACCELERATED).
	VECTOR_INDEX DW 0 ; INDEX OF THE CURRENT SPEED IN BALL_SPEED_VECTOR.
	VECTOR_SIZE DW 0 ; SIZE OF SPEED VECTOR.
	FIRST_PRESS_COUNTER DB 0 ; COUNTER FOR FIRST PRESS.
	
	RANDOM_NUMBER DW 0 ; THIS RANDOM NUMBER IS USED TO STORE RANDOM NUMBERS GENERATED BY GEN_RANDOM FUNCTION.
					   ; THIS VARIABLE SHOULD BE INITIALIZED BY A VALUE CALLED SEED, AND IT WOULD BE THE SYSTEM TIME IN THIS CASE.
	
	STAND_HEIGHT DW 5  ; HEIGHT OF THE STANDS.
	STAND_WIDTH DW 40 ; WIDTH OF THE STANDS.
	
	STAND_POS_X DW 0
	STAND_POS_Y DW 0
	
	STAND_QUEUE_X DW 31 DUP(?) ; COLLECTION OF STANDS THAT APPEAR ON THE SCREEN.
	STAND_QUEUE_Y DW 31 DUP(?)
	
	
	STAND_QUEUE_FRONT DB 0 ; IT'S A CIRCULAR QUEUE.
	STAND_QUEUE_REAR DB 0
	
	FIRST_COLLISION DB 0 ; A BOOLEAN VARIABLE. IF FIRST_COLLISION WAS TRUE, AND THE BALL HIT THE GROUND, THEN THE GAME IS OVER.
	GAME_OVER DB 0
	ESC_PRESSED DB 0 ; INDICATES IF THE USER HAS PAUSED THE GAME OR NOT.
	
	COLOR DB 00H ; A VARIABLE TO INDICATE THE COLLOR OF PIXELS WHICH IS GOING TO BE PRINTED INTO THE SCREEN.
	
	;COLLISION_COUNT DB 0 --> DEBUGGING PURPOSES.
	
	DISTANCE DW 0
	SCORE DW 0
	HIGH_SCORE DW 0
	HIGH_SCORE_FNAME DB "HS.txt", 0 ; THIS FILE STORES THE HIGHEST SCORE.
	HIGH_SCORE_FHANDLE DW ?
	FILE_BUFFER DW ? ; FILE READ/WRITE BUFFER.
	
	BUFFER DB 5 DUP(?) ; MAXIMUM SCORE IS 65535.
	BUFFER_SIZE DW 0
	ROW DB 0 ; ROW OF THE CURSOR.
	COLUMN DB 0 ; COLUMN OF THE CURSOR.
	
	MAIN_MENU_TITLE DB "DOODLE JUMP :)$"
	MAIN_MENU_ITEM_0 DB "PLAY$"
	MAIN_MENU_ITEM_1 DB "CREDIT$"
	MAIN_MENU_ITEM_2 DB "DELETE HIGH SCORE$"
	MAIN_MENU_ITEM_3 DB "EXIT$"
	MAIN_MENU_INDEX DB 0 ; INDICATES WHICH OF THE MAIN_MENU_ITEMS SHOULD BE PRINTED IN YELLOW COLOR (SHOULD NOT EXCEED 4).
	
	PAUSE_TITLE DB "PAUSE$"
	PAUSE_ITEM_0 DB "RESUME$"
	PAUSE_ITEM_1 DB "RESTART$"
	PAUSE_ITEM_2 DB "MAIN MENU$"
	PAUSE_ITEM_3 DB "EXIT$"
	PAUSE_INDEX DB 0 ; THIS VALUE SHOULD NOT EXCEED 4.
	
	GAME_OVER_TITLE DB "GAME OVER !$"
	GAME_OVER_ITEM_0 DB "RESTART$"
	GAME_OVER_ITEM_1 DB "MAIN MENU$"
	GAME_OVER_ITEM_2 DB "EXIT$"
	GAME_OVER_ITEM_3 DB "YOUR SCORE : $"
	GAME_OVER_ITEM_4 DB "HIGH SCORE : $"
	GAME_OVER_INDEX DB 0 ; THIS VALUE SHOULD NOT EXCEED 3.
	
	GAME_MODE DB 0 ; 0 -> MAIN MENU, 1 -> GAME PLAY, 2 -> PAUSE SCREEN, 3 -> GAME OVER, 4 -> CREDIT PAGE, 5 -> DEBUG.
	
	CREDIT_LINE_1 DB "HI, THIS GAME IS DESIGNED BY:$" 
	CREDIT_LINE_2 DB "AMIR ARSALAN  SANATI, COMPUTER SCIENCE$"
	CREDIT_LINE_3 DB "STUDENT IN SHAHID BEHESHTI UNIVERSITY,$"
	CREDIT_LINE_4 DB "IRAN, TEHRAN. IF YOU HAD ANY  COMMENTS$"
	CREDIT_LINE_5 DB "ABOUT THE GAME, OR  YOU JUST WANTED TO$"
	CREDIT_LINE_6 DB "CONTACT  ME, HERE  IS MY  SOCIAL MEDIA$"
	CREDIT_LINE_7 DB "LINKS WHICH YOU CAN CONTACT:$"
	CREDIT_LINE_8 DB "TELEGRAM : @Amirarsalan_sn$"
	CREDIT_LINE_9 DB "INSTAGRAM : @amirarsalan.sn$"
	CREDIT_LINE_10 DB "GMAIL : amirarsalan.sanati81@gmail.com$"
	CREDIT_LINE_11 DB "HOPE YOU ENJOY THE GAME :).$"
	CREDIT_ITEM_0 DB "DONE!$"
	
	OPEN_ERROR DB "CAN'T OPEN FILE$"
	CLOSE_ERROR DB "CAN'T CLOSE FILE$"
.CODE
	MAIN PROC FAR
		MOV AX, @DATA
		MOV DS, AX ; NOW DS REGISTER HAS THE ADDRES OF DATA SEGMENT
		
		MOV AH, 03H ; SETTING THE KEYBOARD SPEED TO FASTEST.
		MOV AL, 05H
		MOV BL, 05H
		MOV BH, 00H
		INT 16H
		
		MOV AH, 00H ; INITIALIZING THE RANDOM_NUMBER WITH SYSTEM TIME.
		INT 1AH
		MOV RANDOM_NUMBER, DX
		;MOV RANDOM_NUMBER, 3 --> DEBUGGING PURPOSES.
		CALL CALC_SPEED_VECTOR
		;CALL INIT_STAND_QUEUE --> DON'T NEED IT HERE, BECAUSE RESTART_GAME USES IT.
		CALL CLEAR_SCREEN
		CHECK_TIME:
			MOV AH, 2CH
			INT 21H
			CMP SYS_TIME, DL
			JZ CHECK_TIME
			MOV SYS_TIME, DL
			;CALL CLEAR_SCREEN
			
			CMP GAME_MODE, 0
			JE GAME_MODE_0
			CMP GAME_MODE, 1
			JE GAME_MODE_1
			CMP GAME_MODE, 2
			JE GAME_MODE_2
			CMP GAME_MODE, 3
			JE GAME_MODE_3
			CMP GAME_MODE, 4
			JE GAME_MODE_4
			CMP GAME_MODE, 5
			JE GAME_MODE_5
			JMP GAME_EXIT
			
			GAME_MODE_0:
			
			CALL PRINT_MAIN_MENU
			CALL CHECK_MAIN_MENU
			JMP GAME_MODE_DEFAULT
			
			GAME_MODE_1:
				MOV COLOR, 00H ; COLOR BLACK.
				CALL DRAW_BALL ; CLEARING THE BALL.
			
				CALL MOVE_BALL
			
				MOV COLOR, 0FH ; COLOR WHITE.
				CALL DRAW_BALL
				MOV COLOR, 0FH ; COLOR WHITE.
				CALL DRAW_STANDS
			
				MOV COLOR, 0AH ; COLOR LIGHT GREEN.
				MOV ROW, 1
				MOV COLUMN, 0
				CALL PRINT_SCORE
				
				CALL CHECK_GAME_PLAY
				JMP GAME_MODE_DEFAULT
				
			GAME_MODE_2:
				CALL PRINT_PAUSE
				CALL CHECK_PAUSE
				JMP GAME_MODE_DEFAULT
			GAME_MODE_3:
				CALL PRINT_GAME_OVER
				CALL CHECK_GAME_OVER
				JMP GAME_MODE_DEFAULT
				
			GAME_MODE_4:
				CALL PRINT_CREDIT
				CALL CHECK_CREDIT
				JMP GAME_MODE_DEFAULT
				
			GAME_MODE_5:
				CALL OPEN_FILE
				;CALL READ_HIGH_SCORE
				;LEA DX, HIGH_SCORE
				;MOV AH, 09H
				;INT 21H
				CALL CLOSE_FILE
				MOV AH, 00H
				INT 16H
				
			GAME_MODE_DEFAULT:
			JMP CHECK_TIME
			
		
		GAME_EXIT:
			MOV AH, 4CH
			INT 21H
	MAIN ENDP
	
	CLEAR_SCREEN PROC NEAR
	
		MOV AH, 00H ; INTERRUPT FOR SETTING THE VIDEO MODE
		MOV AL, 13H ; SPECIFING THE VIDEO MODE AS 320 * 200 256 COLOR GRAPHICS (MCGA, VGA)
		INT 10H ; CALLING THE INTERRUPT
		MOV AH, 0BH ; INTERRUPT FOR SETTING THE BACKGROUND COLOR
		MOV BH, 00H
		MOV BL, 00H ; WE WANT A BLACK BACKGROUND
		INT 10H ; CALLING THE INTERRUPT
		
		RET
	CLEAR_SCREEN ENDP
	
	CALC_SPEED_VECTOR PROC NEAR ; THIS FUNCTION CALCULATES THE VALUES FOR BALL_SPEED_VECTOR
	
		MOV BX, OFFSET BALL_SPEED_VECTOR
		MOV AL, BALL_I_SPEED ; SIZE OF BALL_SPEED_VECTOR IS A FUNCTION OF BALL_I_SPEED. 
							 ; BECASUE, THE BALL STARTS TO MOVE UP WITH SPEED BALL_I_SPEED,
							 ; AND ITS SPEED IS DECREMENTED BY 1 AFTER EACH 10 FRAMES. THAT MEANS,
							 ; THE BALL  WILL GO UP UNTIL ITS SPEED REACHES ZERO ( THE HIGHEST JUMPING POINT ).
							 ; AFTER THAT, THE BALL STARTS TO FALL DOWN AND IT WILL CONTINUE FALLING DOWN UNTIL 
							 ; ITS VELOCITY REACHES MINUS BALL_I_SPEED (THAT'S WHEN YOU CAN SAY THE BALL IS AT THE SAME HEIGHT WHERE IT LEFT THE GROUND). 
							 ; THEREFORE, 2 * 10 * BALL_I_SPEED VALUES ARE NEEDED,
							 ; PLUS 10 MORE VALUES FOR SPEED ZERO. (E.G. 4, 4, 4, ...., 3, 3, 3, ...., 2, 2, 2, ...., 1, 1, 1, ...., 0, 0, 0, ...., -1, -1, -1, ........., -4, -4, -4)
							 ; => VECTOR_SIZE = 10 * (2*N + 1)
		SHL AL, 1 ; 2*N
		INC AL ; 2*N + 1
		MOV CL, 1 
		MUL CL ; 10 * (2*N + 1).
		MOV DH, 00H
		MOV DL, BALL_I_SPEED ; A TEMP VARIABLE WHICH STORES BALL_I_SPEED
		CALC_WHILE:
			CMP VECTOR_SIZE, AX
			JAE CALC_AFTER
			MOV CH, 0 
			CALC_FOR:
				CMP CH, 1
				JAE CALC_FOR_AFTER
				MOV SI, VECTOR_SIZE
				SHL SI, 1 ; BECAUSE VALUES HAVE 16 BITS, THEY SHOULD BE WRITTEN IN EVEN ADDRESSES
				MOV [BX][SI], DX
				INC VECTOR_SIZE
				INC CH
				JMP CALC_FOR
			CALC_FOR_AFTER:
			DEC DX
			JMP CALC_WHILE
		CALC_AFTER:
		RET
		
	CALC_SPEED_VECTOR ENDP
	
	MOVE_BALL PROC NEAR
		
		; FIRST, WE NEED CHECK IF THE X POSITION OF THE BALL IS OUT OF RANGE (320) OR NOT.
		; IF IT WAS, NEW_POSITION = OUT_OF_RANGE_POSITION % WIDTH .
		; IT IS ONE OF THE FEATURES OF THE GAME THAT, IF THE BALL IS MOVED OUT OF THE SCREEN FROM ONE SIDE (LEFT OR RIGHT),
		; IT SHOULD APPEAR FROM THE OTHER SIDE OF THE SCREEN.
		CMP BALL_POS_X, 0
		JGE CHECK_RIGHT_SIDE 
		ADD BALL_POS_X, 320 ; OUT_OF_RANGE_POSITION < 0 THEN, OUT_OF_RANGE_POSITION % WIDTH = OUT_OF_RANGE_POSITION + WIDTH.
		JMP MOVE_BALL_START_PROC
		CHECK_RIGHT_SIDE:
		MOV AX, BALL_POS_X
		MOV DX, 00H
		MOV CX, 320
		DIV CX 
		MOV BALL_POS_X, DX ; DX = OUT_OF_RANGE_POSITION % WIDTH.
		
		MOV BX, OFFSET BALL_SPEED_VECTOR ; LOADING THE ADDRES OF ARRAY INTO THE BX REGISTER.
		MOV SI, VECTOR_INDEX
		SHL SI, 1 ; EVEN ADDRESSES
		MOV CX, [BX][SI] ; READING BALL_SPEED_VECTOR[VECTOR_INDEX].
		
		CMP BALL_POS_Y, 90 ; AFTER CHECKING X POSITION, IT IS TIME TO CHECK Y POSITION OF THE BALL.
							; IF THE BALL_POS_Y WAS LESS THAN 100(THE BALL IS IN THE UPPER HALF OF THE SCREEN) AND IT WAS MOVING UP,
							; WE SHOULD MOVE STANDS INSTEAD OF THE BALL.
		JG MOVE_BALL_START_PROC
		CMP CX, 0		
		JLE MOVE_BALL_START_PROC
		
		CALL MOVE_STANDS
		JMP CHECK_LEFT_RIGHT
		MOVE_BALL_START_PROC:
		
		SUB BALL_POS_Y, CX ; SUBTRACTING THE VELOCITY FROM CURRENT BALL POSITION.
						   ; THIS IS BECAUSE Y AXIS IN THE SCREEN IS INDEXED FROM TOP TO BOTTOM.
						   ; THEREFORE, TO MOVE THE BALL TO A HIGHER POSITION WE SHOULD REDUCE ITS Y POSITION.
						   ; AND VICE VERSA.
		ADD DISTANCE, CX
		MOV AX, DISTANCE
		CMP AX, SCORE
		JLE MOVE_BALL_INC_INDEX
		
		MOV SCORE, AX
		
		MOVE_BALL_INC_INDEX:
		MOV AX, VECTOR_SIZE 
		DEC AX
		CMP VECTOR_INDEX, AX
		JE MOVE_BALL_CHECK_COLLISION ; IF THE VECTOR_INDEX WAS POINTING AT THE LAST ELEMENT IN BALL_SPEED_VECTOR. IT SHOULDN'T CHANGE UNLESS IT HAS COLLIDED WITH SOMETHING.
		INC VECTOR_INDEX   ; INCREAMENTING THE INDEX FOR FUTURE CALLS OF MOVE_BALL.
		
		MOVE_BALL_CHECK_COLLISION:
		CMP CX, 0
		JG CHECK_LEFT_RIGHT ; IF THE BALL WAS MOVING UP, THEN, ITS COLLISION SHOULDN'T BE CHECKED.
		CALL CHECK_COLLISION
		
		
		CHECK_LEFT_RIGHT:
		MOV AH, 01H
		INT 16H ; SEE IF ANY KEY IS PRESSED.
		JZ _RET ; IF ANY KEY WAS PRESSED THE ZERO FLAG WILL BE SET TO 0, ELSE, IT WILL BE SET TO 1.
				; SO, IF ZF WAS 1 THEN THE PROCEDURE SHOULD RETURN.
		MOV BL, BALL_HORIZONTAL_SPEED ; CREATING A 16 BIT VERSION OF 8 BIT VALUE "BALL_HORIZONTAL_SPEED".
		MOV BH, 00H
	
	
		CMP AL, 41H ; IF THE PRESSED KEY WAS A OR a THEN, THE BALL SHOULD GO LEFT.
		JE BALL_MOVE_LEFT
		CMP AL, 61H
		JE BALL_MOVE_LEFT
		CMP AL, 44H  ; IF THE PRESSED KEY WAS D OR d THEN, THE BALL SHOULD GO RIGHT.
		JE BALL_MOVE_RIGHT
		CMP AL, 64H
		JE BALL_MOVE_RIGHT
		CMP AL, 1BH ; ESC KEY PRESSED.
		JE ESC_KEY_PRESSED
		MOV AH, 00H ; IF THE KEY WHICH WAS PRESSED WAS NOT A/a OR D/d, THEN THE PROCEDURE SHOULD RETURN.
		INT 16H     ; AND THE KEYBOARD BUFFER SHOULD BE CLEARED.
		RET
		
		ESC_KEY_PRESSED:
			MOV AH, 00H
			INT 16H
			MOV ESC_PRESSED, 1
			RET
		BALL_MOVE_LEFT:
			CMP FIRST_PRESS_COUNTER, 4
			JE READ_AND_MOVE_LEFT
			INC FIRST_PRESS_COUNTER
			SUB BALL_POS_X, BX ; MOVING TO THE LEFT.
			RET
			READ_AND_MOVE_LEFT:
			MOV AH, 00H
			INT 16H
			SUB BALL_POS_X, BX ; MOVING TO THE LEFT.
			RET
		BALL_MOVE_RIGHT:
			CMP FIRST_PRESS_COUNTER, 4
			JE READ_AND_MOVE_RIGHT
			INC FIRST_PRESS_COUNTER
			ADD BALL_POS_X, BX ; MOVING TO THE RIGHT.
			RET	
			READ_AND_MOVE_RIGHT:
			MOV AH, 00H
			INT 16H
			ADD BALL_POS_X, BX ; MOVING TO THE RIGHT.
			RET	
			
		_RET:
		MOV FIRST_PRESS_COUNTER, 0
		RET
	MOVE_BALL ENDP
	
	CHECK_COLLISION PROC NEAR
	
		MOV AL, STAND_QUEUE_REAR 
		MOV DX, BALL_POS_Y
		CMP DX, 190
		JL CHECK_COLLISION_FOR ; CHECKING IF THE BALL HAS HIT THE GROUND.
		MOV BALL_POS_Y, 190
		CMP FIRST_COLLISION, 1 ; IF FIRST_COLLISION = 0, THAT MEANS, THE BALL HASN'T HAD ANY COLLISIONS YET, SO IT IS OK TO HIT THE GROUND.
							   ; IT'S THE BEGINNING OF THE GAME.
		JE CHECK_COLLISION_GAME_OVER
		MOV VECTOR_INDEX, 0
		RET
		CHECK_COLLISION_GAME_OVER:
		MOV GAME_OVER, 1
		RET
		CHECK_COLLISION_FOR: ; FOR LOOP WHICH ITERATES BETWEEN STANDS AND CHECKS IF THE BALL HAS COLLIDED TO ANY OF THEM.
			CMP AL, STAND_QUEUE_FRONT
			JE CHECK_COLLISION_AFTER
			INC AL
			MOV AH, 00H
			MOV CL, 31
			DIV CL
			MOV AL, AH
			MOV DX, BALL_POS_Y ; CALCULATING THE BOTTOM RIGHT POSITION OF THE BALL IN THE Y AXIS.
			ADD DX, BALL_SIZE
			MOV BX, OFFSET STAND_QUEUE_Y
			MOV AH, 00H
			MOV SI, AX
			SHL SI, 1 ; EXPLAINED IN ADD_FRONT FUNCTION.
			MOV CX, [BX][SI] ; CX = STAND_QUEUE_Y[REAR + 1].
			SUB DX, CX
			CMP DX, 12
			JGE NOT_COLLIDE
			CMP DX, 0
			JL NOT_COLLIDE ; IF 0 <= (CX - DX) < 5, THEN, THE BALL MAY HAVE COLLIDED WITH A STAND.
			MOV BX, OFFSET STAND_QUEUE_X
			MOV DX, BALL_POS_X
			ADD DX, BALL_SIZE ; CALCULATING THE BOTTOM RIGHT POSITION OF THE BALL IN THE X AXIS. 
			MOV CX, [BX][SI] ; CX = STAND_QUEUE_X[REAR + 1].
			CMP DX, CX
			JLE NOT_COLLIDE
			MOV DX, BALL_POS_X
			ADD CX, STAND_WIDTH
			CMP DX, CX
			JGE NOT_COLLIDE ; IF THE DISTANCE BETWEEN THE BALL AND ONE OF THE STANDS WAS LESS THAN BALL_I_SPEED,
						   ; AND THE BALL'S LEFT BORDER WAS LESS THAN THE STAND'S RIGHT BORDER(ALSO THE RIGHT BORDER SHOULD NOT BE LESS THAN THE STAND'S LEFT BORDER),
						   ; OR THE BALL'S RIGHT BORDER WAS GREATER THAN THE STAND'S LEFT BORDER(ALSO THE LEFT BORDER SHOULD NOT BE GREATER THEN THE STAND'S RIGHT BORDER),
						   ; THEN THE BALL HAS DEFFINATELY COLLIDED WITH THAT PARTICULAR STAND.
						   ; OTHERWISE, IT HAS NOT AND WE SHOULD CHECK OTHER STANDS FOR COLLITION.
			
			
			MOV BX, OFFSET STAND_QUEUE_Y
			MOV CX, [BX][SI]
			SUB CX, BALL_SIZE
			SUB CX, 3 ; IT'S MORE BEAUTIFUL THIS WAY :).
			MOV BALL_POS_Y, CX
			MOV VECTOR_INDEX, 0
			;INC COLLISION_COUNT --> DEBUGGING PURPOSES.
			MOV FIRST_COLLISION, 1
			RET
			NOT_COLLIDE:
				JMP CHECK_COLLISION_FOR
		CHECK_COLLISION_AFTER:
		RET
	CHECK_COLLISION ENDP
	
	MOVE_STANDS PROC NEAR
	
		MOV COLOR, 00H ; FIRST, LETS CLEAR STANDS FROM THE SCREEN.
		CALL DRAW_STANDS
		MOV SI, VECTOR_INDEX
		SHL SI, 1
		MOV BX, OFFSET BALL_SPEED_VECTOR
		MOV CX, [BX][SI] ; READING THE SPEED WHICH STANDS SHOULD MOVE.
						 ; THIS IS THE SPEED OF BALL, TO CREAT THE ILLUSION THAT BALL IS STILL MOVING UP, STANDS ARE MOVED DOWN WITH THE SAME SPEED(OPPOSITE DIRECTION).
						 ; THERFORE, THE BALL WOULD REMAIN IN ITS POSSITION AND STANDS MOVE DOWN AND YOU THINK IT'S THE BALL THAT'S MOVING UP.
						 ; WHY THIS WORKS ?? BECAUSE OF THE RELATIVITY THEORY (R.I.P Einstein).
		MOV AL, STAND_QUEUE_REAR
		MOV BX, OFFSET STAND_QUEUE_Y
		
		MOVE_STANDS_FOR:
			CMP AL, STAND_QUEUE_FRONT
			JE MOVE_STANDS_AFTER
			INC AL
			MOV AH, 00H
			MOV DL, 31
			DIV DL
			MOV AL, AH
			MOV AH, 00H
			MOV SI, AX
			SHL SI, 1
			MOV DX, [BX][SI]
			ADD DX, CX ; MOVE DOWN.
			MOV [BX][SI], DX
			JMP MOVE_STANDS_FOR
			
		MOVE_STANDS_AFTER:
		
		ADD DISTANCE, CX
		MOV AX, DISTANCE
		CMP AX, SCORE
		JLE MOVE_STANDS_CHECK_FRONT
		
		MOV SCORE, AX
		
		MOVE_STANDS_CHECK_FRONT:
		MOV AL, STAND_QUEUE_FRONT ; THIS PART CHECKS IF THERE IS ANY STAND IN SECTION 0, IF THERE WAS NONE, IT DECIDES TO PUT OR NOT TO PUT NEW STAND(USING RANDOM NUMBERS).
		MOV AH, 00H
		MOV SI, AX
		SHL SI, 1
		MOV CX, [BX][SI]
		CMP CX, 10
		JL MOVE_STAND_CHECK_REAR
		CALL GEN_RANDOM
		MOV AX, RANDOM_NUMBER
		MOV BX, 2
		MUL BX
		AND DX, 01H
		JZ MOVE_STAND_CHECK_REAR
		CALL GEN_RANDOM
		MOV AX, RANDOM_NUMBER
		MOV BX, 280
		MUL BX
		MOV STAND_POS_X, DX
		MOV STAND_POS_Y, 0
		CALL ADD_FRONT
		MOVE_STAND_CHECK_REAR:
		MOV BX, OFFSET STAND_QUEUE_Y
		MOV AL, STAND_QUEUE_REAR ; THIS PART CHECKS IF THERE IS ANY STAND IN SECTION 0, IF THERE WAS NONE, IT DECIDES TO PUT OR NOT TO PUT NEW STAND(USING RANDOM NUMBERS).
		INC AL
		MOV AH, 00H
		MOV CL, 31
		DIV CL
		MOV AL, AH
		MOV AH, 00H
		MOV SI, AX
		SHL SI, 1
		MOV CX, [BX][SI]
		CMP CX, 185
		JL RET_MOVE_STANDS
		CALL DEL_REAR
		RET_MOVE_STANDS:
		INC VECTOR_INDEX
		RET
	MOVE_STANDS ENDP
	
	DRAW_BALL PROC NEAR
		
		MOV AH, 0CH ; INTERRUPT FOR WRITING A SINGLE PIXEL ON THE SCREEN.
		MOV DX, BALL_POS_Y ; GET A COPY OF BALL_POS_Y.
		MOV SI, 0 ; THE FIRST LOOP COUNTER.
		DRAW_FOR_1: ; FOR LOOP WHICH ITERATES BETWEEN ROWS.
			CMP SI, BALL_SIZE
			JAE DRAW_FOR_1_AFTER
			MOV CX, BALL_POS_X ; GET A COPY OF BALL_POS_X.
			MOV DI, 0 ; THE SECOND LOOP COUNTER.
			DRAW_FOR_2: ; FOR LOOP WHICH DRAWS A SINGLE ROW.
				CMP DI, BALL_SIZE
				JAE DRAW_FOR_2_AFTER
				MOV AL, COLOR ; SPECIFYING COLOR OF THE PIXEL.
				MOV BH, 00H ; SELECTING THE PAGE NUMBER.
				INT 10H ; CALLING THE INTERRUPT.
				INC DI
				INC CX
				JMP DRAW_FOR_2
			DRAW_FOR_2_AFTER:
			INC SI
			INC DX
			JMP DRAW_FOR_1
		DRAW_FOR_1_AFTER:
		
		CALL DRAW_CIRCLE ; THIS FUNCTION MAKES THE BALL MORE LIKE A CIRCLE.
		RET
		
	DRAW_BALL ENDP
	
	DRAW_CIRCLE PROC NEAR
		MOV AH, 0CH
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV AL, COLOR
		MOV BH, 00H
		MOV SI, 02H
		DEC DX
		DRAW_CIRCLE_UPPER_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_UPPER_1_AFTER 
			INC CX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_UPPER_1_FOR
		DRAW_CIRCLE_UPPER_1_AFTER:
		;MOV DX, BALL_POS_Y
		;MOV CX, BALL_POS_X
		;MOV SI, 04H
		;SUB DX, 02H
		;INC CX
		;DRAW_CIRCLE_UPPER_2_FOR:
		;	CMP SI, BALL_SIZE
		;	JE DRAW_CIRCLE_UPPER_2_AFTER
		;	INC CX
		;	INT 10H
		;	INC SI
		;	JMP DRAW_CIRCLE_UPPER_2_FOR
		;DRAW_CIRCLE_UPPER_2_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		ADD DX, BALL_SIZE
		DRAW_CIRCLE_LOWER_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_LOWER_1_AFTER
			INC CX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_LOWER_1_FOR
		DRAW_CIRCLE_LOWER_1_AFTER:
		;MOV DX, BALL_POS_Y
		;MOV CX, BALL_POS_X
		;MOV SI, 04H
		;INC DX
		;ADD DX, BALL_SIZE
        ;INC CX
		;DRAW_CIRCLE_LOWER_2_FOR:
		;	CMP SI, BALL_SIZE
		;	JE DRAW_CIRCLE_LOWER_2_AFTER
		;	INC CX
		;	INT 10H
		;	INC SI
		;	JMP DRAW_CIRCLE_LOWER_2_FOR
		;DRAW_CIRCLE_LOWER_2_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		DEC CX
		DRAW_CIRCLE_LEFT_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_LEFT_1_AFTER
			INC DX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_LEFT_1_FOR
		DRAW_CIRCLE_LEFT_1_AFTER:
		;MOV DX, BALL_POS_Y
		;MOV CX, BALL_POS_X
		;MOV SI, 04H
		;SUB CX, 02H
		;INC DX
		;DRAW_CIRCLE_LEFT_2_FOR:
		;	CMP SI, BALL_SIZE
		;	JE DRAW_CIRCLE_LEFT_2_AFTER
		;	INC DX
		;	INT 10H
		;	INC SI
		;	JMP DRAW_CIRCLE_LEFT_2_FOR
		;DRAW_CIRCLE_LEFT_2_AFTER:
		MOV DX, BALL_POS_Y
		MOV CX, BALL_POS_X
		MOV SI, 02H
		ADD CX, BALL_SIZE
		DRAW_CIRCLE_RIGHT_1_FOR:
			CMP SI, BALL_SIZE
			JE DRAW_CIRCLE_RIGHT_1_AFTER
			INC DX
			INT 10H
			INC SI
			JMP DRAW_CIRCLE_RIGHT_1_FOR
		DRAW_CIRCLE_RIGHT_1_AFTER:
		;MOV DX, BALL_POS_Y
		;MOV CX, BALL_POS_X
		;MOV SI, 04H
		;ADD CX, BALL_SIZE
		;INC CX
		;INC DX
		;DRAW_CIRCLE_RIGHT_2_FOR:
		;	CMP SI, BALL_SIZE
		;	JE DRAW_CIRCLE_RIGHT_2_AFTER
		;	INC DX
		;	INT 10H
		;	INC SI
		;	JMP DRAW_CIRCLE_RIGHT_2_FOR
		;DRAW_CIRCLE_RIGHT_2_AFTER:
		RET
	DRAW_CIRCLE ENDP 
	
	GEN_RANDOM PROC NEAR
		
		MOV AX, 25173 ; LCG MULTIPLIER
		MUL RANDOM_NUMBER ; DX:AX = LCG MULTIPLIER * SEED( OR THE LAST RANDOM NUMBER GENERATED).
		ADD AX, 13849 ; ADD LCG INCREMENT VALUE
		MOV RANDOM_NUMBER, AX ; THE MODULO VALUE IS 65536 (2^16) SO THE RESULT OF ADDITION IS ENOUGH.
		RET 
	GEN_RANDOM ENDP
	
	ADD_FRONT PROC NEAR
	
		MOV AL, STAND_QUEUE_FRONT ; CHECKING IF THE QUEUE IS FULL OR NOT.
		INC AL
		MOV AH, 00H
		MOV CL, 31
		DIV CL
		MOV AL, AH
		CMP AL, STAND_QUEUE_REAR
		JE QUEUE_FULL
		MOV AH, 00H ; LETS CALCULATE (FRONT + 1) % SIZE.
		MOV AL, STAND_QUEUE_FRONT 
		INC AX
		MOV CL, 31
		DIV CL ; AH CONTAINS THE (FRONT + 1) % SIZE.
		MOV STAND_QUEUE_FRONT, AH ; UPDATING STAND_QUEUE_FRONT.
		MOV BX, OFFSET STAND_QUEUE_X ; ADDING THE NEW ELEMENT IN QUEUE[ (FRONT + 1) % SIZE ].
		MOV AL, STAND_QUEUE_FRONT
		MOV AH, 00
		MOV SI, AX
		SHL SI, 1 ; STAND_POS_X AND STAND_POS_Y ARE 16 BIT VARIABLES (2 BYTES).
				  ; SINCE MEMORY IS BYTE ADDRESSABLE, AND EACH WORD IS 2 BYTES,
				  ; VALUES SHOULD BE WRITTEN IN ADDRESSES SEPRARTED BY 2 (E.G. BS + 00, BS + 02, BS + 04 ...).
		MOV AX, STAND_POS_X
		MOV [BX][SI], AX
		MOV BX, OFFSET STAND_QUEUE_Y
		MOV AX, STAND_POS_Y
		MOV [BX][SI], AX
		
		QUEUE_FULL:
		RET
	ADD_FRONT ENDP
		
	DEL_REAR PROC NEAR
	
		
		MOV AL, STAND_QUEUE_REAR ; CHECKING IF THE QUEUE IS EMPTY.
		MOV AH, STAND_QUEUE_FRONT ; IF THE FRONT AND REAR WERE AT THE SAME POSITION, THEN, THE QUEUE IS FULL.
		CMP AL, AH
		JE QUEUE_EMPTY
		MOV AH, 00H ; NOW LETS CALCULATE (REAR + 1) % SIZE.
		INC AX
		MOV CL, 31
		DIV CL ; AH CONTAINS THE (REAR + 1) % SIZE.
		MOV STAND_QUEUE_REAR, AH ; UPDATING STAND_QUEUE_FRONT.
		QUEUE_EMPTY:
		RET
	DEL_REAR ENDP
	
	INIT_STAND_QUEUE PROC NEAR ; THIS FUNCTION INITIATES STAND QUEUE.
					  ; TO PREVENT OVERLAP OF STANDS. THE HEIGHT OF THE SCREEN IS DEVIDED INTO 20 SECTIONS (10 PIXELS EACH).
					  ; AT FIRST, THE ALGORITHM WILL GENERATE A RANDOM NUMBER. THEN, IF THE RESULT WAS 1 (THE RADNDOM NUMBER WAS ODD), 
					  ; THE ALGORITHM WILL GENERATE ANOTHER RANDOM NUMBER IN ORDER TO CHOOSE THE COLUMN POSITION OF THE STAND (STAND_POS_X).
					  ; AFTER THAT, IT WILL SET THE ROW POSITION (STAND_POS_Y) AS THE NUMBER OF SECTION WHICH IT IS PUTTING A STAND INTO.
					  ; THE CX REGISTER HOLDS THE NUMBER OF SECTION IN THIS CASE.
					  ; THAT'S WHY CX IS STARTED FROM 170 AND IT IS DECREMENTED BY 10 AT THE END OF THE FOR LOOP.
					  ; (THE BOTTOM 20 PIXELS OF THE SCREEN IS ASSUMED TO BE EMPTY (IT IS MORE BEAUTIFUL THIS WAY))
		
		MOV CX, 170
		INIT_STAND_FOR: ; A LOOP WHICH ITERATES 20 TIMES.
			CMP CX, 0
			JL INIT_STAND_AFTER ; CX < 0 --> RETURN.
			PUSH CX ; PUSHING CX BECAUSE GEN_RANDOM MAY CHANGE ITS VALUE.
			CALL GEN_RANDOM ; GENERATING THE FIRST RANDOM NUMBER.
			MOV AX, RANDOM_NUMBER
			MOV BX, 2                  
			MUL BX       ;  floor of (r*random_number/m) is a much higher-quality result than X mod r (EXPLAINED IN DOCUMENTATIONS).    
			AND DX, 01H           
			JE RANDOM_NUMBER_EVEN  ; THE ALGORITHM SHOULDN'T PUT ANY STANDS INTO THIS SECTION.
			CALL GEN_RANDOM ; THE RANDOM NUMBER WAS ODD, SO, IT IS TIME TO CHOOSE STAND_POS_X. 
			MOV AX, RANDOM_NUMBER
			MOV BX, 280 ; (RANDOM NUMBER) % ( 320(WIDTH OF THE SCREEN) - STAND_WIDTH ).
			MUL BX      ; FOR (RANDOM NUMBER) % ( 320(WIDTH OF THE SCREEN) - STAND_WIDTH ), CALCULATING FLOOR OF (R*RANDOM/M) IS BETTER.
			MOV STAND_POS_X, DX ; DX = (RANDOM NUMBER) % ( 320(WIDTH OF THE SCREEN) - STAND_WIDTH ).
			MOV STAND_POS_Y, CX ; STAND_POS_Y = NUMBER OF SECTION.
			CALL ADD_FRONT ; ADDING THE NEW ELEMENT TO THE QUEUE.
			RANDOM_NUMBER_EVEN:
				POP CX
				SUB CX,10
				JMP INIT_STAND_FOR
	     
		INIT_STAND_AFTER:
			RET
	INIT_STAND_QUEUE ENDP
	
	
	DRAW_STANDS PROC NEAR
	
		MOV AL, STAND_QUEUE_REAR
		DRAW_STANDS_WHILE: ; WHILE (REAR != FRONT) -> CONTINUE DRAWING STANDS
			CMP AL, STAND_QUEUE_FRONT
			JE DRAW_STANDS_AFTER
			INC AL
			MOV AH, 00H ; CALCULATING (REAR + 1) % SIZE.
			MOV CL, 31
			DIV CL
			MOV AL, AH ; AH = (REAR + 1) % SIZE.
			MOV AH, 00H ; MAKING A 16 BIT VERSION OF AL.
			MOV SI, AX
			SHL SI, 1 ; EXPLAINED IN ADD_FRONT.
			MOV BX, OFFSET STAND_QUEUE_X ; SETTING INPUTS FOR FUNCTION DRAW_SINGLE_STAND
			MOV DX, [BX][SI]
			MOV STAND_POS_X, DX
			MOV BX, OFFSET STAND_QUEUE_Y
			MOV DX, [BX][SI]
			MOV STAND_POS_Y, DX
			PUSH CX
			PUSH AX
			CALL DRAW_SINGLE_STAND ; CALLING PROCEDURE WHICH DRAWS A SINGLE STAND.
			POP AX
			POP CX
			JMP DRAW_STANDS_WHILE
			
		DRAW_STANDS_AFTER:
		RET
	DRAW_STANDS ENDP
	
	DRAW_SINGLE_STAND PROC NEAR
	
		MOV AH, 0CH ; INTERRUPT FOR WRITING A SINGLE PIXEL ON THE SCREEN.
		MOV DX, STAND_POS_Y ; GET A COPY OF BALL_POS_Y.
		MOV SI, 00H  ; THE FIRST LOOP COUNTER.
		DRAW_SINGLE_STAND_FOR_1: ; FOR LOOP WHICH ITERATES BETWEEN ROWS.
			CMP SI, STAND_HEIGHT
			JE DRAW_SINGLE_STAND_AFTER_1
			MOV CX, STAND_POS_X ; GET A COPY OF BALL_POS_X.
			MOV DI, 00H ; THE SECOND LOOP COUNTER.
			DRAW_SINGLE_STAND_FOR_2: ; FOR LOOP WHICH DRAWS A SINGLE ROW.
				CMP DI, STAND_WIDTH 
				JE DRAW_SINGLE_STAND_AFTER_2
				MOV AL, COLOR ; SPECIFYING THE COLOR OF PIXEL.
				MOV BH, 00H ; SELECTING THE PAGE NUMBER.
				INT 10H ; CALLING THE INTERRUPT.
				INC DI
				INC CX
				JMP DRAW_SINGLE_STAND_FOR_2
			DRAW_SINGLE_STAND_AFTER_2:
				INC SI
				INC DX
				JMP DRAW_SINGLE_STAND_FOR_1
		DRAW_SINGLE_STAND_AFTER_1:
			
		RET
	DRAW_SINGLE_STAND ENDP
	
	CHECK_GAME_PLAY PROC NEAR
		
		CMP GAME_OVER, 1
		JNE GAME_NOT_OVER
		CALL CLEAR_SCREEN
		MOV GAME_OVER_INDEX, 0
		MOV GAME_MODE, 3
		RET
		GAME_NOT_OVER:
		CMP ESC_PRESSED, 1
		JNE ESC_KEY_NOT_PRESSED
		CALL CLEAR_SCREEN
		MOV PAUSE_INDEX, 0
		MOV GAME_MODE, 2
		ESC_KEY_NOT_PRESSED:
		RET
	CHECK_GAME_PLAY ENDP
	
	PRINT_SCORE PROC NEAR
	
		CALL SPLIT_SCORE_BUFFER
		
		PRINT_SCORE_PRNT:
			MOV SI, BUFFER_SIZE ; i = n
			SUB SI, 1
			MOV DH, ROW
			MOV DL, COLUMN
			MOV BH, 00H
			PRINT_SCORE_FOR:
				INC DL
				MOV AH, 02H
				INT 10H
				CMP SI, 0
				JL PRINT_SCORE_EXIT
				MOV BX, OFFSET BUFFER
				MOV AL, [BX][SI]
				MOV BH, 00H
				MOV BL, COLOR
				MOV AH, 09H
				MOV CX, 1
				INT 10H
				SUB SI, 1
				JMP PRINT_SCORE_FOR
   
     
		PRINT_SCORE_EXIT:
		RET	
	PRINT_SCORE ENDP
	
	SPLIT_SCORE_BUFFER PROC NEAR ; THIS FUNCTION SPLITS THE SCORE INTO CHARACTERS REPRESENTING ITS DIGITS.
	
		MOV BX, OFFSET BUFFER
		MOV BUFFER_SIZE, 0
		MOV DX, SCORE
		MOV CX, 10
		SPLIT_SCORE_DO_WHILE:   	; DO {
			MOV AX, DX				;
			MOV DX, 00H				;
			DIV CX					;	SCORE = SCORE % 10;
			MOV SI, BUFFER_SIZE 	;	
			ADD DL, '0'				;
			MOV [BX][SI], DL		;	PUSH(SCORE);
			MOV DX, AX 				;
			ADD BUFFER_SIZE, 1		;
			CMP DX, 0				;
			JZ SPLIT_SCORE_AFTER	;
			JMP SPLIT_SCORE_DO_WHILE; } WHILE (SCORE != 0);
        
		SPLIT_SCORE_AFTER:
		RET
	SPLIT_SCORE_BUFFER ENDP
	
	CHECK_MAIN_MENU PROC NEAR
		
		MOV AH, 01H
		INT 16H
		JZ CHECK_MAIN_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 'W'
		JE MAIN_INDEX_UP
		CMP AL, 'w'
		JE MAIN_INDEX_UP
		CMP AL, 'S'
		JE MAIN_INDEX_DOWN
		CMP AL, 's'
		JE MAIN_INDEX_DOWN
		CMP AL, 0DH ; ENTER KEY.
		JE MAIN_ENTER
		RET
		
		MAIN_ENTER:
			CMP MAIN_MENU_INDEX, 0
			JE MAIN_ITEM_0
			CMP MAIN_MENU_INDEX, 1
			JE MAIN_ITEM_1
			CMP MAIN_MENU_INDEX, 2
			JE MAIN_ITEM_2
			CMP MAIN_MENU_INDEX, 3
			JE MAIN_ITEM_3
			RET
			
			MAIN_ITEM_0:
				CALL CLEAR_SCREEN
				CALL RESTART_GAME
				MOV GAME_MODE, 1
				RET
			
			MAIN_ITEM_1:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 4
				RET
				
			MAIN_ITEM_2:
				MOV HIGH_SCORE, 0
				CALL WRITE_HIGH_SCORE
				MOV MAIN_MENU_INDEX, 0
				RET
				
			MAIN_ITEM_3:
				CALL EXIT_GAME
				RET
		MAIN_INDEX_UP:
		MOV AL, MAIN_MENU_INDEX
		DEC AL
		CMP AL, 0
		JGE SET_MENU_INDEX
		ADD AL, 4
		SET_MENU_INDEX:
		MOV MAIN_MENU_INDEX, AL
		RET
		MAIN_INDEX_DOWN:
		MOV AL, MAIN_MENU_INDEX
		INC AL
		MOV CL, 4
		MOV AH, 00H
		DIV CL
		MOV MAIN_MENU_INDEX, AH
		RET
		
		CHECK_MAIN_RET:
		RET
	CHECK_MAIN_MENU ENDP
	
	PRINT_MAIN_MENU PROC NEAR
		
		MOV ROW, 1
		MOV COLUMN, 0
		
		MOV BX, OFFSET MAIN_MENU_TITLE
		MOV COLOR, 0FH ; COLOR WHITE.
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 0
		JNE MAIN_MENU_ITEM_0_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP MAIN_MENU_PRINT_ITEM_0
		MAIN_MENU_ITEM_0_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_0:
		MOV BX, OFFSET MAIN_MENU_ITEM_0
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 1
		JNE MAIN_MENU_ITEM_1_WHITE
		MOV COLOR, 0EH
		JMP MAIN_MENU_PRINT_ITEM_1
		MAIN_MENU_ITEM_1_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_1:
		MOV BX, OFFSET MAIN_MENU_ITEM_1
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 2
		JNE MAIN_MENU_ITEM_2_WHITE
		MOV COLOR, 0EH
		JMP MAIN_MENU_PRINT_ITEM_2
		MAIN_MENU_ITEM_2_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_2:
		MOV BX, OFFSET MAIN_MENU_ITEM_2
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP MAIN_MENU_INDEX, 3
		JNE MAIN_MENU_ITEM_3_WHITE
		MOV COLOR, 0EH
		JMP MAIN_MENU_PRINT_ITEM_3
		MAIN_MENU_ITEM_3_WHITE:
		MOV COLOR, 0FH
		MAIN_MENU_PRINT_ITEM_3:
		MOV BX, OFFSET MAIN_MENU_ITEM_3
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		RET
	PRINT_MAIN_MENU ENDP
	
	CHECK_PAUSE PROC NEAR
		
		MOV AH, 01H
		INT 16H
		JNZ CHECK_PAUSE_START
		RET
		CHECK_PAUSE_START:
		MOV AH, 00H
		INT 16H
		CMP AL, 'W'
		JE PAUSE_INDEX_UP
		CMP AL, 'w'
		JE PAUSE_INDEX_UP
		CMP AL, 'S'
		JE PAUSE_INDEX_DOWN
		CMP AL, 's'
		JE PAUSE_INDEX_DOWN
		CMP AL, 0DH
		JE CHECK_PAUSE_ENTER
		RET
		CHECK_PAUSE_ENTER:
			CMP PAUSE_INDEX, 0
			JE CHECK_PAUSE_ITEM_0
			CMP PAUSE_INDEX, 1
			JE CHECK_PAUSE_ITEM_1
			CMP PAUSE_INDEX, 2
			JE CHECK_PAUSE_ITEM_2
			CMP PAUSE_INDEX, 3
			JE CHECK_PAUSE_ITEM_3
			RET
			CHECK_PAUSE_ITEM_0:
				CALL CLEAR_SCREEN
				MOV ESC_PRESSED, 0
				MOV GAME_MODE, 1
				RET
			CHECK_PAUSE_ITEM_1:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 1
				CALL RESTART_GAME
				RET
			CHECK_PAUSE_ITEM_2:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 0
				MOV MAIN_MENU_INDEX, 0
				RET
			CHECK_PAUSE_ITEM_3:
				CALL EXIT_GAME
				RET
		PAUSE_INDEX_UP:
		MOV AL, PAUSE_INDEX
		DEC AL
		CMP AL, 0
		JGE SET_PAUSE_INDEX
		ADD AL, 4
		SET_PAUSE_INDEX:
		MOV PAUSE_INDEX, AL
		RET
		PAUSE_INDEX_DOWN:
		MOV AL, PAUSE_INDEX
		INC AL
		MOV CL, 4
		MOV AH, 00H
		DIV CL
		MOV PAUSE_INDEX, AH
		RET
	CHECK_PAUSE ENDP
	
	PRINT_PAUSE PROC NEAR
		
		MOV ROW, 1
		MOV COLUMN, 0
		
		MOV BX, OFFSET PAUSE_TITLE
		MOV COLOR, 0FH ; COLOR WHITE.
		CALL PRINT_STRING
		
		CMP PAUSE_INDEX, 0
		JNE PAUSE_ITEM_0_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP PAUSE_PRINT_ITEM_0
		PAUSE_ITEM_0_WHITE:
		MOV COLOR, 0FH
		PAUSE_PRINT_ITEM_0:
		MOV BX, OFFSET PAUSE_ITEM_0
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP PAUSE_INDEX, 1
		JNE PAUSE_ITEM_1_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP PAUSE_PRINT_ITEM_1
		PAUSE_ITEM_1_WHITE:
		MOV COLOR, 0FH
		PAUSE_PRINT_ITEM_1:
		MOV BX, OFFSET PAUSE_ITEM_1
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP PAUSE_INDEX, 2
		JNE PAUSE_ITEM_2_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP PAUSE_PRINT_ITEM_2
		PAUSE_ITEM_2_WHITE:
		MOV COLOR, 0FH
		PAUSE_PRINT_ITEM_2:
		MOV BX, OFFSET PAUSE_ITEM_2
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP PAUSE_INDEX, 3
		JNE PAUSE_ITEM_3_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP PAUSE_PRINT_ITEM_3
		PAUSE_ITEM_3_WHITE:
		MOV COLOR, 0FH
		PAUSE_PRINT_ITEM_3:
		MOV BX, OFFSET PAUSE_ITEM_3
		ADD ROW, 5
		MOV COLUMN, 0
		CALL PRINT_STRING
		RET
	PRINT_PAUSE ENDP
	
	CHECK_GAME_OVER PROC NEAR
		
		MOV AH, 01H
		INT 16H
		JZ CHECK_GAME_OVER_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 'W'
		JE GAME_OVER_INDEX_UP
		CMP AL, 'w'
		JE GAME_OVER_INDEX_UP
		CMP AL, 'S'
		JE GAME_OVER_INDEX_DOWN
		CMP AL, 's'
		JE GAME_OVER_INDEX_DOWN
		CMP AL, 0DH
		JE GAME_OVER_ENTER
		RET
		
		GAME_OVER_ENTER:
			CMP GAME_OVER_INDEX, 0
			JE CHECK_GAME_OVER_ITEM_0
			CMP GAME_OVER_INDEX, 1
			JE CHECK_GAME_OVER_ITEM_1
			CMP GAME_OVER_INDEX, 2
			JE CHECK_GAME_OVER_ITEM_2
			RET
			
			CHECK_GAME_OVER_ITEM_0:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 1
				CALL WRITE_HIGH_SCORE ; WE SHOULD WRITE HIGH SCORE, BEFORE RESTARTING THE GAME.
				CALL RESTART_GAME
				RET
			CHECK_GAME_OVER_ITEM_1:
				CALL CLEAR_SCREEN
				MOV GAME_MODE, 0
				MOV MAIN_MENU_INDEX, 0
				RET
			CHECK_GAME_OVER_ITEM_2:
				CALL EXIT_GAME
				RET
			
		GAME_OVER_INDEX_UP:
		MOV AL, GAME_OVER_INDEX
		DEC AL
		CMP AL, 0
		JGE SET_GAME_OVER_INDEX
		ADD AL, 3
		SET_GAME_OVER_INDEX:
		MOV GAME_OVER_INDEX, AL
		RET
		GAME_OVER_INDEX_DOWN:
		MOV AL, GAME_OVER_INDEX
		INC AL
		MOV CL, 3
		MOV AH, 00H
		DIV CL
		MOV GAME_OVER_INDEX, AH
		RET
		
		CHECK_GAME_OVER_RET:
		RET
	CHECK_GAME_OVER ENDP
	
	PRINT_GAME_OVER PROC NEAR
		
		MOV ROW, 1
		MOV COLUMN, 0
		
		MOV AX, SCORE
		CMP AX, HIGH_SCORE
		JBE PRINT_GAME_OVER_START
		MOV HIGH_SCORE, AX
		PRINT_GAME_OVER_START:
		
		MOV BX, OFFSET GAME_OVER_TITLE
		MOV COLOR, 0FH ; COLOR WHITE.
		CALL PRINT_STRING
		
		CMP GAME_OVER_INDEX, 0
		JNE GAME_OVER_ITEM_0_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP GAME_OVER_PRINT_ITEM_0
		GAME_OVER_ITEM_0_WHITE:
		MOV COLOR, 0FH
		GAME_OVER_PRINT_ITEM_0:
		MOV BX, OFFSET GAME_OVER_ITEM_0
		ADD ROW, 3
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP GAME_OVER_INDEX, 1
		JNE GAME_OVER_ITEM_1_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP GAME_OVER_PRINT_ITEM_1
		GAME_OVER_ITEM_1_WHITE:
		MOV COLOR, 0FH
		GAME_OVER_PRINT_ITEM_1:
		MOV BX, OFFSET GAME_OVER_ITEM_1
		ADD ROW, 3
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		CMP GAME_OVER_INDEX, 2
		JNE GAME_OVER_ITEM_2_WHITE
		MOV COLOR, 0EH ; COLOR YELLOW.
		JMP GAME_OVER_PRINT_ITEM_2
		GAME_OVER_ITEM_2_WHITE:
		MOV COLOR, 0FH
		GAME_OVER_PRINT_ITEM_2:
		MOV BX, OFFSET GAME_OVER_ITEM_2
		ADD ROW, 3
		MOV COLUMN, 0
		CALL PRINT_STRING
		
		MOV COLOR, 03H ; COLOR CYAN.
		MOV BX, OFFSET GAME_OVER_ITEM_3
		ADD ROW, 3
		MOV COLUMN, 0
		CALL PRINT_STRING
		CALL PRINT_SCORE
		
		MOV COLOR, 0CH ; COLOR LIGHT RED.
		MOV BX, OFFSET GAME_OVER_ITEM_4
		ADD ROW, 3
		MOV COLUMN, 0
		CALL PRINT_STRING
		MOV AX, SCORE
		PUSH AX
		MOV AX, HIGH_SCORE
		MOV SCORE, AX
		CALL PRINT_SCORE
		POP AX
		MOV SCORE, AX
		
		RET
	PRINT_GAME_OVER ENDP
	
	CHECK_CREDIT PROC NEAR
		
		MOV AH, 01H
		INT 16H
		JZ CHECK_CREDIT_RET
		
		MOV AH, 00H
		INT 16H
		
		CMP AL, 0DH ; ASCII CODE FOR ENTER KEY.
		JNE CHECK_CREDIT_RET
		CALL CLEAR_SCREEN
		MOV GAME_MODE, 0
		
		CHECK_CREDIT_RET:
		RET
	CHECK_CREDIT ENDP
	
	PRINT_CREDIT PROC NEAR
		
		MOV ROW, 1
		MOV COLUMN, 0
		
		MOV BX, OFFSET CREDIT_LINE_1
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		MOV BX, OFFSET CREDIT_LINE_2
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_3
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_4
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_5
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_6
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_7
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_8
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_9
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_10
		MOV COLOR, 0FH
		CALL PRINT_STRING
		ADD ROW, 2
		MOV COLUMN, 0
		
		
		MOV BX, OFFSET CREDIT_LINE_11
		MOV COLOR, 0FH
		CALL PRINT_STRING
		
		MOV BX, OFFSET CREDIT_ITEM_0
		MOV COLOR, 0EH
		MOV ROW, 24
		MOV COLUMN, 34
		CALL PRINT_STRING

		
		RET
	PRINT_CREDIT ENDP
	PRINT_STRING PROC NEAR ; THIS FUNCTION PRINTS A STRING IN A SPECIFIED POSITION WITH A SPECIFIED COLOR.
	
		MOV SI, 0 
		MOV DH, ROW
		MOV DL, COLUMN
		
		PRINT_STRING_WHILE:
			MOV AL, [BX][SI]
			CMP AL, '$'
			JE PRINT_STRING_AFTER
			PUSH BX
			INC DL
			MOV AH, 02H
			MOV BH, 00H
			INT 10H
			MOV BH, 00H
			MOV BL, COLOR
			MOV CX, 1
			MOV AH, 09
			INT 10H
			INC SI
			POP BX
			JMP PRINT_STRING_WHILE
		PRINT_STRING_AFTER:
		MOV ROW, DH
		MOV COLUMN, DL
		RET
	PRINT_STRING ENDP
	
	OPEN_FILE PROC NEAR
		
		MOV AH, 3DH
		MOV AL, 2
		LEA DX, HIGH_SCORE_FNAME
		INT 21H
		JC OPEN_ERR
		MOV HIGH_SCORE_FHANDLE, AX
		RET
		OPEN_ERR:
		LEA DX, OPEN_ERROR
		MOV AH, 09H
		INT 21H
		RET
	OPEN_FILE ENDP
	
	CLOSE_FILE PROC NEAR
		
		MOV AH, 3EH
		MOV BX, HIGH_SCORE_FHANDLE
		INT 21H
		JC CLOSE_ERR
		RET
		CLOSE_ERR:
		LEA DX, CLOSE_ERROR
		MOV AH, 09H
		INT 21H
		RET
	CLOSE_FILE ENDP
	
	READ_HIGH_SCORE PROC NEAR
		CALL OPEN_FILE
		MOV HIGH_SCORE, 0 ; CURRENT READ NUMBER.
		LEA DX, FILE_BUFFER
		MOV BX, HIGH_SCORE_FHANDLE
		MOV CX, 2 ; READING 2 BYTES(HIGH SCORE SAVED PREVIOUSLY).
		MOV AH, 3FH
		INT 21H
		MOV AX, FILE_BUFFER
		MOV HIGH_SCORE, AX
		CALL CLOSE_FILE
		RET
	READ_HIGH_SCORE ENDP
	
	WRITE_HIGH_SCORE PROC NEAR
		CALL OPEN_FILE
	    
		MOV AX, HIGH_SCORE
		MOV FILE_BUFFER, AX
		LEA DX, FILE_BUFFER
		MOV BX, HIGH_SCORE_FHANDLE
		MOV CX, 2
		MOV AH, 40H
		INT 21H
		
		CALL CLOSE_FILE
		RET
	WRITE_HIGH_SCORE ENDP
	
	RESTART_GAME PROC NEAR ; THIS FUNCTION RESTARTS THE GAME.
						   ; IT SHOULD RESET THE BALL POSITION,
						   ; EMPTY THE STAND QUEUE,
						   ; RE-INITIALIZE THE STAND QUEUE,
						   ; RESET THE SCORE VARIABLE AND RESET OTHER VARIABLES.
						   ; IT ALSO RESETS THE HIGH_SCORE VARIABLE. (THE USER WON'T RESTART THE GAME IF HE/SHE HAS BROKEN THE GAMES RECORD :)).
		MOV BALL_POS_X, 158  
		MOV BALL_POS_Y, 190 
		MOV VECTOR_INDEX, 0
		MOV ESC_PRESSED, 0
		MOV STAND_QUEUE_FRONT, 0
		MOV STAND_QUEUE_REAR, 0
		MOV SCORE, 0
		MOV DISTANCE, 0
		MOV FIRST_COLLISION, 0
		MOV GAME_OVER, 0
		CALL INIT_STAND_QUEUE
		CALL READ_HIGH_SCORE
		RET
	RESTART_GAME ENDP
	
	EXIT_GAME PROC NEAR
		MOV AH, 00H ; RETURNING TO TEXT MODE.
		MOV AL, 02H
		INT 10H
		CALL WRITE_HIGH_SCORE
		MOV AH, 4CH
		INT 21H
	EXIT_GAME ENDP
		END MAIN