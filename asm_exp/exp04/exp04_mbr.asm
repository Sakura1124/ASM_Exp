         ;代码清单4-1
         ;文件名：exp04_mbr.asm
         ;文件说明：硬盘主引导扇区代码 ，进入保护模式，计算1+...100 和 10！

         ;设置堆栈段和栈指针 
         mov ax,cs      
         mov ss,ax
         mov sp,0x7c00
      
         ;计算GDT所在的逻辑段地址 
         mov ax,[cs:gdt_base+0x7c00]        ;低16位 
         mov dx,[cs:gdt_base+0x7c00+0x02]   ;高16位 
         mov bx,16        
         div bx            
         mov ds,ax                          ;令DS指向该段以进行操作
         mov bx,dx                          ;段内起始偏移地址 
      
         ;创建0#描述符，它是空描述符，这是处理器的要求
         mov dword [bx+0x00],0x00
         mov dword [bx+0x04],0x00  

         ;创建#1描述符，保护模式下的代码段描述符
         mov dword [bx+0x08],0x7c0001ff   ;线性基地址为 0x00007C00  
         mov dword [bx+0x0c],0x00409800     

         ;创建#2描述符，保护模式下的数据段描述符（文本模式下的显示缓冲区） 
         mov dword [bx+0x10],0x8000ffff    ;线性基地址为 0x000B8000。 
         mov dword [bx+0x14],0x0040920b     

         ;创建#3描述符，保护模式下的堆栈段描述符
         mov dword [bx+0x18],0x00007a00     ;线性基地址为 0x00000000
         mov dword [bx+0x1c],0x00409600

         ;初始化描述符表寄存器GDTR
         mov word [cs: gdt_size+0x7c00],31  ;描述符表的界限（总字节数减一）   
                                             
         lgdt [cs: gdt_size+0x7c00]
      
         in al,0x92                         ;南桥芯片内的端口 
         or al,0000_0010B
         out 0x92,al                        ;打开A20

         cli                                ;保护模式下中断机制尚未建立，应 
                                            ;禁止中断 
         mov eax,cr0
         or eax,1
         mov cr0,eax                        ;设置PE位
      
         ;以下进入保护模式... ...
         jmp dword 0x0008:flush             ;16位的描述符选择子：32位偏移
                                            ;清流水线并串行化处理器 
         [bits 32] 

    flush:
         mov cx,00000000000_10_000B         ;加载数据段选择子(0x10)
         mov ds,cx
         
         mov cx,00000000000_11_000B         ;加载堆栈段选择子
         mov ss,cx
         mov esp,0x7c00

         ;以下在屏幕上显示"1+2+3+...+1000=" 
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
      @sum:               ;计算1+2+3+...+1000 
         add eax,ecx
         inc ecx
         cmp ecx,1000
         jle @sum

         mov ebx,10
         xor ecx,ecx
      @num1:             ;计算各个数位 
         inc ecx
         xor dx,dx
         div ebx
         or dl,0x30
         push dx
         cmp eax,0
         jne @num1


         ;显示各个数位
         mov di,0x1e 
      @print1:
         pop dx
         mov byte [di],dl
         add di,2
         loop @print1
         
         
         mov byte [di],' '       ;显示'10!=' 
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
     @mul:                     ;计算10！ 
         mul ecx
         inc ecx
         cmp ecx,10
         jle @mul

         mov ebx,10
         xor ecx,ecx
     @num2:                    ;计算各个数位 
         inc ecx
         xor edx,edx
         div ebx
         add edx,0x30
         push edx
         cmp eax,0
         jne @num2

     @print2:                 ;显示各个数位
         pop edx
         mov [di],dl
         add di,2
         loop @print2  

      
  ghalt:     
         hlt                                ;已经禁止中断，将不会被唤醒 

;-------------------------------------------------------------------------------
     
         gdt_size         dw 0
         gdt_base         dd 0x00007e00     ;GDT的物理地址 
                             
         times 510-($-$$) db 0
                          db 0x55,0xaa