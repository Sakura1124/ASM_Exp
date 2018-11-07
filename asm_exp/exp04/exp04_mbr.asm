         ;�����嵥4-1
         ;�ļ�����exp04_mbr.asm
         ;�ļ�˵����Ӳ���������������� �����뱣��ģʽ������1+...100 �� 10��

         ;���ö�ջ�κ�ջָ�� 
         mov ax,cs      
         mov ss,ax
         mov sp,0x7c00
      
         ;����GDT���ڵ��߼��ε�ַ 
         mov ax,[cs:gdt_base+0x7c00]        ;��16λ 
         mov dx,[cs:gdt_base+0x7c00+0x02]   ;��16λ 
         mov bx,16        
         div bx            
         mov ds,ax                          ;��DSָ��ö��Խ��в���
         mov bx,dx                          ;������ʼƫ�Ƶ�ַ 
      
         ;����0#�����������ǿ������������Ǵ�������Ҫ��
         mov dword [bx+0x00],0x00
         mov dword [bx+0x04],0x00  

         ;����#1������������ģʽ�µĴ����������
         mov dword [bx+0x08],0x7c0001ff   ;���Ի���ַΪ 0x00007C00  
         mov dword [bx+0x0c],0x00409800     

         ;����#2������������ģʽ�µ����ݶ����������ı�ģʽ�µ���ʾ�������� 
         mov dword [bx+0x10],0x8000ffff    ;���Ի���ַΪ 0x000B8000�� 
         mov dword [bx+0x14],0x0040920b     

         ;����#3������������ģʽ�µĶ�ջ��������
         mov dword [bx+0x18],0x00007a00     ;���Ի���ַΪ 0x00000000
         mov dword [bx+0x1c],0x00409600

         ;��ʼ����������Ĵ���GDTR
         mov word [cs: gdt_size+0x7c00],31  ;��������Ľ��ޣ����ֽ�����һ��   
                                             
         lgdt [cs: gdt_size+0x7c00]
      
         in al,0x92                         ;����оƬ�ڵĶ˿� 
         or al,0000_0010B
         out 0x92,al                        ;��A20

         cli                                ;����ģʽ���жϻ�����δ������Ӧ 
                                            ;��ֹ�ж� 
         mov eax,cr0
         or eax,1
         mov cr0,eax                        ;����PEλ
      
         ;���½��뱣��ģʽ... ...
         jmp dword 0x0008:flush             ;16λ��������ѡ���ӣ�32λƫ��
                                            ;����ˮ�߲����л������� 
         [bits 32] 

    flush:
         mov cx,00000000000_10_000B         ;�������ݶ�ѡ����(0x10)
         mov ds,cx
         
         mov cx,00000000000_11_000B         ;���ض�ջ��ѡ����
         mov ss,cx
         mov esp,0x7c00

         ;��������Ļ����ʾ"1+2+3+...+1000=" 
         mov byte [0x00],'1'  
         mov byte [0x02],'+'
         mov byte [0x04],'2'
         mov byte [0x06],'+'
         mov byte [0x08],'3'
         mov byte [0x0a],'+'
         mov byte [0x0c],'.'
         mov byte [0x0e],'.'
         mov byte [0x10],'.'
         mov byte [0x12],'+'
         mov byte [0x14],'1'
         mov byte [0x16],'0'
         mov byte [0x18],'0'
         mov byte [0x1a],'0'
         mov byte [0x1c],'='
         
         
         xor eax,eax
         mov ecx,1
      @sum:               ;����1+2+3+...+1000 
         add eax,ecx
         inc ecx
         cmp ecx,1000
         jle @sum

         mov ebx,10
         xor ecx,ecx
      @num1:             ;���������λ 
         inc ecx
         xor dx,dx
         div ebx
         or dl,0x30
         push dx
         cmp eax,0
         jne @num1


         ;��ʾ������λ
         mov di,0x1e 
      @print1:
         pop dx
         mov byte [di],dl
         add di,2
         loop @print1
         
         
         mov byte [di],' '       ;��ʾ'10!=' 
         add di,2
         mov byte [di],'1'
         add di,2
         mov byte[di],'0'
         add di,2
         mov byte[di],'!'
         add di,2
         mov byte[di],'='
         add di,2
         
         xor edx,edx
         mov eax,1
         mov ecx,1
     @mul:                     ;����10�� 
         mul ecx
         inc ecx
         cmp ecx,10
         jle @mul

         mov ebx,10
         xor ecx,ecx
     @num2:                    ;���������λ 
         inc ecx
         xor edx,edx
         div ebx
         add edx,0x30
         push edx
         cmp eax,0
         jne @num2

     @print2:                 ;��ʾ������λ
         pop edx
         mov [di],dl
         add di,2
         loop @print2  

      
  ghalt:     
         hlt                                ;�Ѿ���ֹ�жϣ������ᱻ���� 

;-------------------------------------------------------------------------------
     
         gdt_size         dw 0
         gdt_base         dd 0x00007e00     ;GDT�������ַ 
                             
         times 510-($-$$) db 0
                          db 0x55,0xaa