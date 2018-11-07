         ;�����嵥2-2
         ;�ļ�����exp02.asm
         ;�ļ�˵�����û����򣬼���1+...100 �� 10�� 



SECTION header vstart=0                     ;�����û�����ͷ����
    program_length  dd program_end          ;�����ܳ���[0x00]

    ;�û�������ڵ�
    code_entry      dw start                ;ƫ�Ƶ�ַ[0x04]
                    dd section.code_1.start ;�ε�ַ[0x06]

    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;���ض�λ�������[0x0a]

    ;���ض�λ��
    code_1_segment  dd section.code_1.start ;[0x0c]
    data_1_segment  dd section.data_1.start ;[0x10]
    data_2_segment  dd section.data_2.start ;[0x14]
    stack_segment   dd section.stack.start  ;[0x18]

header_end: 


SECTION code_1 align=16 vstart=0           ;�����1 
     
    start:
         
         mov ax,[stack_segment]           ;���õ��û������Լ��Ķ�ջ
         mov ss,ax
         mov sp,stack_end

         mov ax,[data_1_segment]          ;���õ��û������Լ������ݶ�
         mov ds,ax

         
         call sum_100
         mov bx,exp1
         call put_string                  ;��ʾ��һ����Ϣ

         mov ax,[es:data_2_segment]       ;�μĴ���DS�л������ݶ�2
         mov ds,ax

         call mul_10
         mov bx,exp2
         call put_string                  ;��ʾ�ڶ�����Ϣ

         jmp $
    sum_100:
         xor ax,ax
         mov cx,1
     @sum:
         add ax,cx
         inc cx
         cmp cx,100
         jle @sum
         
         mov bx,10
         xor cx,cx
     @num: 
         inc cx
         xor dx,dx
         div bx
         or dl,0x30
         push dx
         cmp ax,0
         jne @num
         
         xor di,result1
     @print:
         pop dx
         mov [di],dl
         inc di
         loop @print
         
         mov byte [di],0x0d
         inc di
         mov byte [di],0x0a
         inc di
         mov byte [di],0
    ret
    
    mul_10:
         xor edx,edx
         mov eax,1
         mov ecx,1
         
     @m:
         mul ecx
         inc ecx
         cmp ecx,10
         jle @m
         
         
         mov ebx,10
         xor ecx,ecx
       ;  mov si,dx      ;��16λ���� 
     @n:
         inc ecx
         xor edx,edx
         div ebx
         add edx,0x30
         push edx
         cmp eax,0
         jne @n

     mov edi,result2
     @p:
         pop edx
         mov [edi],dl
         inc edi
         loop @p
         
         mov byte [di],0x0d
         inc edi
         mov byte [di],0x0a
         inc edi
         mov byte [di],0    
         
      ret
          
    put_string:                              ;��ʾ��(0��β)��
                                         ;���룺DS:BX=����ַ
         mov cl,[bx]
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;�ǵģ�����������
         call put_char
         inc bx                          ;��һ���ַ�
         jmp put_string
    .exit:
         ret
    
    put_char:                                ;��ʾһ���ַ�
                                         ;���룺cl=�ַ�ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;����ȡ��ǰ���λ��
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;��8λ
         mov ah,al

         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;��8λ
         mov bx,ax                       ;BX=������λ�õ�16λ��

         cmp cl,0x0d                     ;�س�����
         jnz .put_0a                     ;���ǡ������ǲ��ǻ��е��ַ�
         ;mov ax,bx                       �˾����Զ��࣬��ȥ���󻹵ø��飬�鷳
         mov bl,80
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

     .put_0a:
         cmp cl,0x0a                     ;���з���
         jnz .put_other                  ;���ǣ��Ǿ�������ʾ�ַ�
         add bx,80
         jmp .roll_screen

     .put_other:                             ;������ʾ�ַ�
         mov ax,0xb800
         mov es,ax
         shl bx,1
         mov [es:bx],cl

         ;���½����λ���ƽ�һ���ַ�
         shr bx,1
         add bx,1

     .roll_screen:
         cmp bx,2000                     ;��곬����Ļ������
         jl .set_cursor

         mov ax,0xb800
         mov ds,ax
         mov es,ax
         cld
         mov si,0xa0
         mov di,0x00
         mov cx,1920
         rep movsw
         mov bx,3840                     ;�����Ļ���һ��
         mov cx,80
     .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         mov bx,1920

     .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh
         out dx,al
         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         mov al,bl
         out dx,al

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret
                             
SECTION data_1 align=16 vstart=0  ;���ʽ1 

    exp1 db '1+2+3+...+100='
    result1  resb 16   
SECTION data_2 align=16 vstart=0   ;���ʽ2 

    exp2 db '10!='
    result2  resb 32
SECTION stack align=16 vstart=0

         resb 256

stack_end:    
       
SECTION trail align=16
program_end: