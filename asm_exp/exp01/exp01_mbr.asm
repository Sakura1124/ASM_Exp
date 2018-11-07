         ;代码清单1-1
         ;文件名：exp01_mbr.asm
         ;文件说明：硬盘主引导扇区代码，输出学号姓名及其ASCII码和
      
         jmp near start
         
  mytext db 'Y',0x07,'o',0x07,'u',0x07,'r',0x07,'N',0x07,'a',0x07,'m',0x07,\
            'e',0x07,'a',0x07,'a',0x07,'a',0x07,'a',0x07,'0',0x07,'0',0x07,\
             '0',0x07,'0',0x07,'0',0x07,'0',0x07,'0',0x07,'0',0x07,':',0x07 
  number db 0,0,0,0,0
  
  start:
         mov ax,0x07c0                  ;设置数据段基地址 
         mov ds,ax
         
         mov ax,0xb800                 ;设置附加段基地址 
         mov es,ax
         
         cld                            ;设置方向位标志为0 
         mov si,mytext                 
         mov di,0
         mov cx,(number-mytext)/2      
         rep movsw
     
         ;得到ASCII码和 
         xor ax,ax   
         mov si,mytext
         mov cx,(number-mytext)/2-1      ;不能整除? 
  sum:
         add ax,[si] 
         add si,2
         loop sum
         
      
   
         ;计算各个数位
         mov bx,number 
         mov cx,5                      ;循环次数 
         mov si,10                     ;除数 
  digit: 
         xor dx,dx
         div si
         mov [bx],dl                   ;保存数位
         inc bx 
         loop digit
         
         ;显示各个数位
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