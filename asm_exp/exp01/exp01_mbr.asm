         ;�����嵥1-1
         ;�ļ�����exp01_mbr.asm
         ;�ļ�˵����Ӳ���������������룬���ѧ����������ASCII���
      
         jmp near start
         
  mytext db 'Y',0x07,'o',0x07,'u',0x07,'r',0x07,'N',0x07,'a',0x07,'m',0x07,\
            'e',0x07,'a',0x07,'a',0x07,'a',0x07,'a',0x07,'0',0x07,'0',0x07,\
             '0',0x07,'0',0x07,'0',0x07,'0',0x07,'0',0x07,'0',0x07,':',0x07 
  number db 0,0,0,0,0
  
  start:
         mov ax,0x07c0                  ;�������ݶλ���ַ 
         mov ds,ax
         
         mov ax,0xb800                 ;���ø��Ӷλ���ַ 
         mov es,ax
         
         cld                            ;���÷���λ��־Ϊ0 
         mov si,mytext                 
         mov di,0
         mov cx,(number-mytext)/2      
         rep movsw
     
         ;�õ�ASCII��� 
         xor ax,ax   
         mov si,mytext
         mov cx,(number-mytext)/2-1      ;��������? 
  sum:
         add ax,[si] 
         add si,2
         loop sum
         
      
   
         ;���������λ
         mov bx,number 
         mov cx,5                      ;ѭ������ 
         mov si,10                     ;���� 
  digit: 
         xor dx,dx
         div si
         mov [bx],dl                   ;������λ
         inc bx 
         loop digit
         
         ;��ʾ������λ
         mov bx,number 
         mov si,4                      
   show:
         mov al,[bx+si]
         add al,0x30
         mov ah,0x04
         mov [es:di],ax
         add di,2
         dec si
         jns show
         
         mov word [es:di],0x0744

         jmp near $

  times 510-($-$$) db 0
                   db 0x55,0xaa