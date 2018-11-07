         ;代码清单2-2
         ;文件名：exp02.asm
         ;文件说明：用户程序，计算1+...100 和 10！ 



SECTION header vstart=0                     ;定义用户程序头部段
    program_length  dd program_end          ;程序总长度[0x00]

    ;用户程序入口点
    code_entry      dw start                ;偏移地址[0x04]
                    dd section.code_1.start ;段地址[0x06]

    realloc_tbl_len dw (header_end-code_1_segment)/4
                                            ;段重定位表项个数[0x0a]

    ;段重定位表
    code_1_segment  dd section.code_1.start ;[0x0c]
    data_1_segment  dd section.data_1.start ;[0x10]
    data_2_segment  dd section.data_2.start ;[0x14]
    stack_segment   dd section.stack.start  ;[0x18]

header_end: 


SECTION code_1 align=16 vstart=0           ;代码段1 
     
    start:
         
         mov ax,[stack_segment]           ;设置到用户程序自己的堆栈
         mov ss,ax
         mov sp,stack_end

         mov ax,[data_1_segment]          ;设置到用户程序自己的数据段
         mov ds,ax

         
         call sum_100
         mov bx,exp1
         call put_string                  ;显示第一段信息

         mov ax,[es:data_2_segment]       ;段寄存器DS切换到数据段2
         mov ds,ax

         call mul_10
         mov bx,exp2
         call put_string                  ;显示第二段信息

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
       ;  mov si,dx      ;高16位保存 
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
          
    put_string:                              ;显示串(0结尾)。
                                         ;输入：DS:BX=串地址
         mov cl,[bx]
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;是的，返回主程序
         call put_char
         inc bx                          ;下一个字符
         jmp put_string
    .exit:
         ret
    
    put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;以下取当前光标位置
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;高8位
         mov ah,al

         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;低8位
         mov bx,ax                       ;BX=代表光标位置的16位数

         cmp cl,0x0d                     ;回车符？
         jnz .put_0a                     ;不是。看看是不是换行等字符
         ;mov ax,bx                       此句略显多余，但去掉后还得改书，麻烦
         mov bl,80
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

     .put_0a:
         cmp cl,0x0a                     ;换行符？
         jnz .put_other                  ;不是，那就正常显示字符
         add bx,80
         jmp .roll_screen

     .put_other:                             ;正常显示字符
         mov ax,0xb800
         mov es,ax
         shl bx,1
         mov [es:bx],cl

         ;以下将光标位置推进一个字符
         shr bx,1
         add bx,1

     .roll_screen:
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor

         mov ax,0xb800
         mov ds,ax
         mov es,ax
         cld
         mov si,0xa0
         mov di,0x00
         mov cx,1920
         rep movsw
         mov bx,3840                     ;清除屏幕最底一行
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
                             
SECTION data_1 align=16 vstart=0  ;表达式1 

    exp1 db '1+2+3+...+100='
    result1  resb 16   
SECTION data_2 align=16 vstart=0   ;表达式2 

    exp2 db '10!='
    result2  resb 32
SECTION stack align=16 vstart=0

         resb 256

stack_end:    
       
SECTION trail align=16
program_end: