.model tiny
.code
org 100h

CORRECT_LEN equ 8
BUFFER_SIZE equ 50
KEY_VALUE   equ 055h

CR  equ 0Dh
LF  equ 0Ah

Start:
            mov ah, 9               ;функция доса для вывода строки не экран
            mov dx, offset request_msg
            int 21h

            mov ah, 0Ah             ;функция доса для ввода строки с клавиатуры в буфер
            mov dx, offset input_buf
            int 21h

	        mov ah, 9
	        mov dx, offset new_line
	        int 21h

	        call CheckPassword

            cmp al, 0
            je denied

granted:
            mov ah, 9
            mov dx, offset granted_msg
            int 21h
            jmp exit
denied:
            mov ah, 9
            mov dx, offset denied_msg
            int 21h
exit:
            mov ax, 4C00h
            int 21h

CheckPassword proc
            push bp         ;не хотим портить bp
            mov bp, sp
            sub sp, 16      ; 16 байт для буфера (уже нет флагов)

            mov si, offset input_buf + 2;
            mov di, bp
            sub di, 16                  ;начало буфера
            mov cl, [input_buf + 1]     ; длина введенной строки
            mov ch, 0
            mov dl, cl                  ; сохр длину в dl
            cld
            rep movsb               ;копируем БЕЗ КОНТРОЛЯ ДЛИНЫ

            mov si, offset correct_pw
            mov di, bp
            sub di, 16                 ;снова начало буфера
            mov cx, CORRECT_LEN
            mov bx, KEY_VALUE               ;КЛЮЮЮЮЮЮЧ
compare_loop:
            mov al, [si]
            xor al, bl
            cmp al, [di]
            jne not_equal
            inc si
            inc di
            loop compare_loop

            cmp dl, CORRECT_LEN
            jne not_equal
            mov al, 1
            jmp done
not_equal:
            mov al, 0
done:
            mov sp, bp
            pop bp
            ret

            endp

new_line    db CR, LF, '$'
request_msg db 'Password: $'
granted_msg db 'Access granted!$'
denied_msg  db 'Access denied.$'
input_buf   db BUFFER_SIZE, 0, BUFFER_SIZE dup(?)         ; 1-ое макс длина, потом 2-ое фактическая длина и 50 неинициализированных значений
correct_pw  db 05h, 27h, 3Ch, 3Bh, 21h, 33h, 66h, 67h   ;"Printf32"

pwd         db 07h, 18h, 4Dh, 1Bh, 12h, 77h, 77h, 52h   ;типа пранк
key         db 0CAh
real_key    db 0F1h

end         Start
