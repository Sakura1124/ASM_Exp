         ;�����嵥7-2
         ;�ļ�����exp07_t1.asm
         ;�ļ�˵�����û����� ������1+2+3+...+100
      

;===============================================================================
SECTION header vstart=0

         program_length   dd program_end          ;�����ܳ���#0x00
         
         head_len         dd header_end           ;����ͷ���ĳ���#0x04

         stack_seg        dd 0                    ;���ڽ��ն�ջ��ѡ����#0x08
         stack_len        dd 1                    ;������Ķ�ջ��С#0x0c
                                                  ;��4KBΪ��λ
                                                  
         prgentry         dd start                ;�������#0x10 
         code_seg         dd section.code.start   ;�����λ��#0x14
         code_len         dd code_end             ;����γ���#0x18

         data_seg         dd section.data.start   ;���ݶ�λ��#0x1c
         data_len         dd data_end             ;���ݶγ���#0x20
;-------------------------------------------------------------------------------
         ;���ŵ�ַ������
         salt_items       dd (header_end-salt)/256 ;#0x24
         
         salt:                                     ;#0x28
         PrintString      db  '@PrintString'
                     times 256-($-PrintString) db 0
                     
         TerminateProgram db  '@TerminateProgram'
                     times 256-($-TerminateProgram) db 0
                     
         ReadDiskData     db  '@ReadDiskData'
                     times 256-($-ReadDiskData) db 0
                 
header_end:
  
;===============================================================================
SECTION data vstart=0                

         message_1        db  0x0d,0x0a
                          db  '[USER TASK1]: Hi! nice to meet you,'
                          db  'I am run at CPL='
         cpl              db 0
                          db  0x0d,0x0a,0
         message_2        db '1+2+3+...100='
         result           resb 8
                          
                          
         
data_end:

;===============================================================================
      [bits 32]
;===============================================================================
SECTION code vstart=0
start:
         ;��������ʱ��DSָ��ͷ���Σ�Ҳ����Ҫ���ö�ջ 
         mov eax,ds
         mov fs,eax
     
         mov eax,[data_seg]
         mov ds,eax
     
         mov ax,cs
         and al,0000_0011B
         or al,0x0030
         mov [cpl],al
         
         mov ebx,message_1
         call far [fs:PrintString]
         
         xor eax,eax
         mov ecx,1
      @sum:               ;����1+2+3+...+100
         add eax,ecx
         inc ecx
         cmp ecx,100
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
         mov edi,result
      @print1:
         pop dx
         mov [edi],dl
         inc edi
         loop @print1
         
         mov ebx,message_2
         call far [fs:PrintString]
         
         
     
         call far [fs:TerminateProgram]      ;�˳�����������Ȩ���ص����� 
    
code_end:

;-------------------------------------------------------------------------------
SECTION trail
;-------------------------------------------------------------------------------
program_end: