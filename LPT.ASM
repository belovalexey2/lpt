;******komarovev@info.sgu.ru   - ���������� ������ �� �����������


.MODEL small
.STACK 100h
.DATA

adr_Lpt1 dw 0  	; ���������� ��� �������� �������� ������ LPT1
wait_5 dw 90 	;90=5/0.055 �������� 5 ������
a db 0
Space db 0

no_ready db 'Printer is not ready', 10, 13,'$'
no_printerPaper db 'no paper', 10, 13,'$'
printer_off_line db 'printer off-line', 10, 13,'$'
no_portLpt1 db 'No port Lpt1', 10, 13, '$'
msg db '',10,13,'$'


.CODE
start:

 	mov ax, @data 
 	mov ds, ax
	call init_Lpt1		;����� ��������� ������������� LPT1

print_Loop:         	 ; ���� �����-������ �������		
	call analiz_Lpt1	;����� ��������� ������� �������� ���������	

	mov ah, 0ch			;������� ����� ����������
	mov al, 01			;�������� ������� ����� �������
	int 21h				;������ �����, ���� �����

	;push ax
	
	cmp al, 1bh     	 ;������ ������� ESC
 	je  exit        	; ��, �����
	
	cmp al, 0dh
	je m_Enter
	call out_Bite
	jmp print_Loop
	
m_Enter:	
	call out_Bite
	
	mov ah, 09h			;������� ������ �� ������
	mov dx, offset msg
	int 21h
	
	jmp print_Loop       ; ���������, ���� �� ����� ������ ������� ESC

exit: 
	mov ax,4C00h ; ��������� � ����� �������� 0
	int 21h	
	



init_Lpt1 proc		;��������� ������������� LPT1
	mov ax, 40h
 	mov es, ax   		; � es - ������� = 0040h
 	mov  dx, es:[08] 	; dx = ������� ����� ����� lpt1
 	mov adr_Lpt1, dx 	; ��������� ����� ����� lpt1 � ���������� adr_Lpt1
	cmp adr_Lpt1, 0
	je no_Lpt1

	inc  dx 	        ;���������� 2 � �������� ������
    inc  dx           
    mov  al, 8       	;�������� ��� �������������
    out  dx, al        	;�������� �������������
 	mov  ax, 1000      	;������ ������� �����
m1:	dec  ax  	        ;��������� �������
	jnz  m1           	;��������� 1000 ���
	mov  al, 12         ;������� �������� ��� ��������
    out  dx, al        	;����� �������������
	ret
	
no_Lpt1:
	mov ah, 09h
	mov dx, offset no_portLpt1
	int 21h
	jmp exit
	;ret
init_Lpt1 endp	


analiz_Lpt1 proc		;��������� ������� �������� ��������� 
	mov ah, 00
	int 1ah
	add wait_5, dx
	
loop2:
	int 1ah
	cmp dx, wait_5
	je no_readyPrint
	
	mov dx, adr_Lpt1
  	inc dx  	; ����� �������� ��������� (adr_Lpt1+1)
  	in  al, dx 	; ������ ������� ���������
  	test al, 10000000b 	; ��������� ���������� �������� "1 - ������� �����"
  	jz  loop2   	; ���� ���, �� �������� �����
  	
	test al, 00100000b	;��������� ������� ������
	jnz no_paper		;���, ��������� �� ������
	
	test al, 00010000b	;������� on-line
	jz off_line			;���, ��������� �� ������
	ret

no_readyPrint:
	mov ah, 09h
	mov dx, offset no_ready
	int 21h
	;RET	
	jmp exit

no_paper:
	mov ah, 09h
	mov dx, offset no_printerPaper
	int 21h
	;RET	
	jmp exit
	
off_line:
	mov ah, 09h
	mov dx, offset printer_off_line
	int 21h
	;RET
 	jmp exit

analiz_Lpt1 endp



out_Bite proc			;��������� ������ ������� �� �������
	mov dx, adr_Lpt1     	; ����� �������� ������ (adr_Lpt1)
	;pop ax
	out dx, al  	; ������ ����� � ������� ������
  	inc dx
  	inc dx      	; ����� �������� ���������� (adr_Lpt1+2)
  	in  al, dx  	; ������ ������� ����������
	

; ��������� ������������ ������
	and al, 11111110b 	; ��� 0 (Strobe):=0
  	out dx, al  	 	; ������ � ������� ����������
  	or  al, 00000001b 	; ��� 0 (Strobe):=1
  	out dx, al   		; ������ � ������� ����������
  	and al, 11111110b 	; ��� 0 (Strobe):=0
  	out dx, al   		; ������ � ������� ����������
  	;pop dx
	ret
out_Bite endp


end start