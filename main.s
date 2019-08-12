; writers Boris Sobol and Stav Elkabetz
; id: 314138892		205625452

default rel

global main
global derivativ
global mul
global sum
global sub
global divide
global power
global polyValueInPoint
global calculateNextPoint
global normal
global error

extern __stack_chk_fail                                 
extern free                                             
extern puts                                             
extern printf                                           
extern malloc                                           
extern __isoc99_scanf                                   


SECTION .text                            

main:   ; Function begin
        push    rbp                                     
        mov     rbp, rsp                                
        push    rbx                                     
        sub     rsp, 152                                ; make room for all the variables
        mov     rax, qword [fs:abs 28H]                 
        mov     qword [rbp-18H], rax                    
        xor     eax, eax                                
        pxor    xmm0, xmm0                  		; epsilon = 0            
        movsd   qword [rbp-80H], xmm0       		; epsilon = 0           
        mov     qword [rbp-78H], 0          		; long order = 0           
        lea     rdx, [rbp-81H]              		; rdx = char c          
        lea     rax, [rbp-80H]              		; rax = epsilon          
        mov     rsi, rax                              
        mov     edi, epsilon_scan          		; edi gets format                 
        mov     eax, 0                                 
        call    __isoc99_scanf              		;scan epsilon            
        lea     rdx, [rbp-81H]              		; rdx = char c           
        lea     rax, [rbp-78H]              		; rax = order           
        mov     rsi, rax                                
        mov     edi, order_scan             		; edi gets format                 
        mov     eax, 0                                 
        call    __isoc99_scanf              		;scan order           
        mov     rax, qword [rbp-78H]   		     	; rax = order           
        add     rax, 1                      		;rax = order + 1           
        shl     rax, 4                      		; rax*16 for size of complex malloc           
        mov     rdi, rax                              
        call    malloc                     		; malloc coeff           
        mov     qword [rbp-60H], rax                    
        mov     qword [rbp-70H], 0          		; i = 0           
        jmp     coeff_for_loop_check                                   

coeff_for_loop:  
        mov     qword [rbp-30H], 0     			; index = 0               
        lea     rax, [rbp-30H]         			; rax = index                
        mov     rsi, rax                               
        mov     edi, coeff_order_scan  			; edi get format                           
        mov     eax, 0                  	               
        call    __isoc99_scanf         			;scan index                
        mov     rax, qword [rbp-30H]   			; rax = index                 
        shl     rax, 4                 			; rax*16 coeff[index]                
        mov     rdx, rax                	                
        mov     rax, qword [rbp-60H]   			;rax = coeff                
        add     rax, rdx               			; rax = coeff[index]                
        lea     rdx, [rax+8H]                           
        mov     rax, qword [rbp-30H]                    
        shl     rax, 4                                  
        mov     rcx, rax                                
        mov     rax, qword [rbp-60H]                    
        add     rax, rcx                                
        mov     rsi, rax                                
        lea     rax, [rbp-81H]                          
        mov     rcx, rax                                
        mov     edi, coeff_scan        			; scan coeff                      
        mov     eax, 0                                  
        call    __isoc99_scanf                          
        add     qword [rbp-70H], 1     			; i++                 
coeff_for_loop_check:  
        mov     rdx, qword [rbp-70H] 			; rdx = order                   
        mov     rax, qword [rbp-78H] 			; rax = i                  
        cmp     rdx, rax             			; i ? order                   
        jbe     coeff_for_loop       			; if i<= order scan coeff                  
        mov     rax, qword [rbp-78H] 			; rax = order                   
        mov     qword [rbp-38H], rax 			; poly.order = order                   
        mov     rax, qword [rbp-60H] 			; rax = coeff                   
        mov     qword [rbp-40H], rax 			; poly.coeff = coeff                   
        lea     rdx, [rbp-81H]       			; rdx = c                   
        lea     rax, [rbp-30H]                         
        lea     rsi, [rax+8H]                           
        lea     rax, [rbp-30H]                          
        mov     rcx, rdx                               
        mov     rdx, rsi                                
        mov     rsi, rax                               
        mov     edi, initial_scan   			; scan initial                           
        mov     eax, 0                                  
        call    __isoc99_scanf                          
        movsd   xmm0, qword [rbp-30H]  			; xmm0 = initial.real               
        movsd   qword [rbp-50H], xmm0  			; point.real = xmm0                 
        movsd   xmm0, qword [rbp-28H]  			; xmm0 = initial.imagin                 
        movsd   qword [rbp-48H], xmm0  			; point.imagin = xmm0                 
        mov     rdx, qword [rbp-50H]   			; rdx = point.real                
        movsd   xmm1, qword [rbp-48H]  			; xmm1 = point.imagin                 
        lea     rax, [rbp-40H]         			; rax = poly.coeff                 
        mov     qword [rbp-98H], rdx                    
        movsd   xmm0, qword [rbp-98H]  			; xmm0 = point.real                 
        mov     rdi, rax               			; rdi = poly.coeff                 
        call    polyValueInPoint                        
        movq    rcx, xmm0                              
        movapd  xmm0, xmm1                              
        mov     eax, 0                                  
        mov     edx, 0                                 
        mov     rax, rcx                                
        movq    rdx, xmm0                              
        mov     rcx, rax                                
        mov     rbx, rdx                                
        mov     qword [rbp-98H], rcx                    
        movsd   xmm0, qword [rbp-98H]                   
        mov     qword [rbp-98H], rdx                    
        movsd   xmm1, qword [rbp-98H]                   
        call    normal                                  
        movq    rax, xmm0                               
        mov     qword [rbp-68H], rax             	; value = normal       
        lea     rax, [rbp-40H]                          
        mov     rdi, rax                                
        call    derivative                              
        mov     qword [rbp-58H], rax                    ; deriv = derivtive(poly)
        jmp     while_calc_check

while_calc:
	mov     rcx, qword [rbp-50H]                    ; rcx = point.real
        movsd   xmm1, qword [rbp-48H]                   ; xmm1 = point.imagin
        mov     rdx, qword [rbp-58H]                    ; rdx = &deriv
        lea     rax, [rbp-40H]                          ; rax = &poly.coeff
        mov     qword [rbp-98H], rcx                    
        movsd   xmm0, qword [rbp-98H]                   ; xmm0 = point.real
        mov     rsi, rdx                                
        mov     rdi, rax                              
        call    calculateNextPoint                      ; calculateNextPoint(&polyn, deriv, point)
        movq    rax, xmm0                               ; rax = num.real
        movapd  xmm0, xmm1                              ; xmm0 = num.imagin
        mov     qword [rbp-50H], rax                    ; point.real = rax
        movsd   qword [rbp-48H], xmm0                   ; point.imagin = xmm0
        mov     eax, dword [rel error]                  ; eax = error
        cmp     eax, 1                                  ; error ? 1
        je      break_while                             ; if error == 1, break_while
        mov     rdx, qword [rbp-50H]                    ; else calculate value of the point
        movsd   xmm1, qword [rbp-48H]                   ; xmm1 = point.imagin
        lea     rax, [rbp-40H]                          ; rax = polyn.coeff
        mov     qword [rbp-98H], rdx                    
        movsd   xmm0, qword [rbp-98H]                   ; xmm0 = point.real
        mov     rdi, rax                               
        call    polyValueInPoint                        ; polyValueInPoint(&poly, point)
        movq    rcx, xmm0                               ; rcx = point.real
        movapd  xmm0, xmm1                              ; xmm0 = xmm1
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                                ; rax = point.real
        movq    rdx, xmm0                               ; rdx = point.imagin
        mov     rcx, rax                                ; rcx = point.real
        mov     rbx, rdx                                ; rbx = point.imagin
        mov     qword [rbp-98H], rcx                    ; 
        movsd   xmm0, qword [rbp-98H]                   ; xmm0 = point.real
        mov     qword [rbp-98H], rdx                    ; 
        movsd   xmm1, qword [rbp-98H]                   ; xmm1 = point.imagin
        call    normal                                  ; normal(num)
        movq    rax, xmm0                               ; rax = normal
        mov     qword [rbp-68H], rax                    ; value = rax

while_calc_check:
	movsd   xmm1, qword [rbp-80H]                   ; xmm1 = epsilon
        movsd   xmm0, qword [rbp-80H]                   ; xmm0 = epsilon
        mulsd   xmm0, xmm1                              ; xmm0 = epsilon * epsilon
        movsd   xmm1, qword [rbp-68H]                   ; xmm1 = value
        ucomisd xmm1, xmm0                              ; value ? xmm0
        ja      while_calc                              ; if greater do calc
        jmp     error_check                             ; error_check

break_while:  nop                                       ; break

error_check:
	mov     eax, dword [rel error]                  ; eax = error
        test    eax, eax                                ; eax ? 0
        jnz     print_error_zero                        ; if not print_error_zero
        movsd   xmm0, qword [rbp-48H]                   ; else print root; xmm0 = point.imagin
        mov     rax, qword [rbp-50H]                    ; rax = point.real
        movapd  xmm1, xmm0                              ; xmm1 = point.imagin
        mov     qword [rbp-98H], rax                    
        movsd   xmm0, qword [rbp-98H]                   ; xmm0 = point.real
        mov     edi, root_print                         ; edi gets format
        mov     eax, 2                                  ; 2 floating point numbers
        call    printf                                  ; printf
        jmp     free_poly                               ; free poly & deriv

print_error_zero:  
	mov     edi, error_print                        
        call    puts                                    

free_poly:  
	mov     rax, qword [rbp-58H]                    ; rax = &deriv
        mov     rax, qword [rax]                        ; rax = deriv.coeff
        mov     rdi, rax                                ; rdi = rax
        call    free                                    ; free(deriv->coeff)
        mov     rax, qword [rbp-58H]                    ; rax = &deriv
        mov     rdi, rax                                ; rdi = rax
        call    free                                    ; free(deriv);
	mov     rax, qword [rbp-40H]                    ; rax = poly.coeff
        mov     rdi, rax                                ; rdi = rax
        call    free                                    ; free(polyn.coeff)
        mov     eax, 0                                  ; eax = 0
        mov     rbx, qword [rbp-18H]                    ; check if all good for exit


        xor     rbx, qword [fs:abs 28H]                 ; check fs
        jz      finish                                  ; if all good return 0
        call    __stack_chk_fail                        ; else stack check fail
finish:
	add     rsp, 152                                ; return the stack to normal
        pop     rbx                                     
        pop     rbp                                     
        ret                                             
; main End of function

derivative:; Function begin
        push    rbp                                    
        mov     rbp, rsp                               
        sub     rsp, 64                                
        mov     qword [rbp-38H], rdi                    
        mov     rax, qword [rbp-38H]                    ; rax = &poly
        mov     rax, qword [rax+8H]                     ; rax = poly.order
        test    rax, rax                                ; rax ? 0
        jnz     find_deriv                              ; if not zero find_deriv
        mov     edi, 16                                 ; else 16 bytes for poly size
        call    malloc                                  ; malloc
        mov     qword [rbp-20H], rax                    ; &deriv = rax
        mov     rax, qword [rbp-20H]                    ; rax = &deriv
        mov     qword [rax+8H], 0                       ; deriv.order = 0
        mov     edi, 16                                 ; 16 bytes for coeff
        call    malloc                                  ; malloc
        mov     qword [rbp-18H], rax                    ; deriv.coeff = rax
        mov     rax, qword [rbp-18H]                    ; rax = &deriv.coeff
        pxor    xmm0, xmm0                              ; xmm0 = 0
        movsd   qword [rax], xmm0                       ; deriv.coeff[0].real = 0
        mov     rax, qword [rbp-18H]                    ; rax = &deriv.coeff
        pxor    xmm0, xmm0                              ; xmm0 = 0
        movsd   qword [rax+8H], xmm0                    ; deriv.coeff[0].imagin = 0
        mov     rax, qword [rbp-20H]                    ; rax = &deriv
        mov     rdx, qword [rbp-18H]                    ; rdx = &deriv.coeff
        mov     qword [rax], rdx                        ; deriv.coeff = rdx
        mov     rax, qword [rbp-20H]                    ; rax = deriv
        jmp     return_deriv                            ; return deriv

find_deriv:  
	mov     rax, qword [rbp-38H]                    ; rax = &poly
        mov     rax, qword [rax+8H]                     ; rax = poly.order
        shl     rax, 4                                  ; *sizeof(complex)
        mov     rdi, rax                                ; rdi = rax
        call    malloc                                  ; malloc
        mov     qword [rbp-10H], rax                    ; d = rax
        mov     qword [rbp-28H], 1                      ; i = 1
        jmp     for_deriv_check                         ; for_deriv_check

for_deriv:  
	mov     rax, qword [rbp-28H]                    ; rax = i
        shl     rax, 4                                  ; rax*16 for correct index for coeff
        lea     rdx, [rax-10H]                          ; rdx = [i-1]
        mov     rax, qword [rbp-10H]                    ; rax = &d
        add     rdx, rax                                ; rdx = d[i-1]
        mov     rax, qword [rbp-38H]                    ; rax = poly.coeff
        mov     rax, qword [rax]                        ; rax = poly.coeff[0]
        mov     rcx, qword [rbp-28H]                    ; rcx = i
        shl     rcx, 4                                  ; rcx*16 for correct index for coeff
        add     rax, rcx                                ; rax = poly.coeff[i]
        movsd   xmm1, qword [rax]                       ; xmm1 = poly.coeff[i].real
        pxor    xmm0, xmm0                              ; xmm0 = 0
        cvtsi2sd xmm0, qword [rbp-28H]                  ; xmm0 = long i
        mulsd   xmm0, xmm1                              ; polyn->coeff[i].real*(i)
        movsd   qword [rdx], xmm0                       ; d[i-1] = polyn->coeff[i].real*(i)
        mov     rax, qword [rbp-28H]                    ; rax = i
        shl     rax, 4                                  ; rax*16 for correct index for coeff
        lea     rdx, [rax-10H]                          ; rdx = [i-1]
        mov     rax, qword [rbp-10H]                    ; rax = &d
        add     rdx, rax                                ; rdx = [i-1]
        mov     rax, qword [rbp-38H]                    ; rax = poly.coeff
        mov     rax, qword [rax]                        ; rax = poly.coeff[0]
        mov     rcx, qword [rbp-28H]                    ; rcx = i
        shl     rcx, 4                                  ; rcx*16 for correct index for coeff
        add     rax, rcx                                ; rax = poly.coeff[i]
        movsd   xmm1, qword [rax+8H]                    ; xmm1 = poly.coeff[i].imagin
        pxor    xmm0, xmm0                              ; xmm0 = 0
        cvtsi2sd xmm0, qword [rbp-28H]                  ; xmm0 = long i
        mulsd   xmm0, xmm1                              ; polyn->coeff[i].imaginary*(i)
        movsd   qword [rdx+8H], xmm0                    ; d[i-1].imagin = polyn->coeff[i].imagin*(i)
        add     qword [rbp-28H], 1                      ; i++

for_deriv_check:  
	mov     rax, qword [rbp-38H]                    ; rax = &poly
        mov     rax, qword [rax+8H]                     ; rax = poly.order
        cmp     rax, qword [rbp-28H]                    ; order ? i
        jge     for_deriv                               ; if i < = rax for_deriv
        mov     edi, 16                                 ; else 16 bytes for deriv
        call    malloc                                  ; malloc
        mov     qword [rbp-8H], rax                     ; deriv = rax
        mov     rax, qword [rbp-38H]                    ; rax = &poly
        mov     rax, qword [rax+8H]                     ; rax = poly.order
        lea     rdx, [rax-1H]                           ; rdx = rax -1
        mov     rax, qword [rbp-8H]                     ; rax = &deriv
        mov     qword [rax+8H], rdx                     ; &deriv.order = rdx
        mov     rax, qword [rbp-8H]                     ; rax = &deriv
        mov     rdx, qword [rbp-10H]                    ; rdx = &d
        mov     qword [rax], rdx                        ; deriv.coeff = d
        mov     rax, qword [rbp-8H]                     ; rax = deriv

return_deriv:  
	leave                                           
        ret                                             
; derivative End of function

mul:    ; Function begin
        push    rbp                                     
        mov     rbp, rsp                                
        push    rbx                                    
        movq    rcx, xmm0                               
        movapd  xmm0, xmm1                              
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                                
        movq    rdx, xmm0                               
        mov     qword [rbp-50H], rax                    
        mov     qword [rbp-48H], rdx                    
        movapd  xmm1, xmm2                              
        movapd  xmm0, xmm3                              
        mov     eax, 0                                  
        mov     edx, 0                                  
        movq    rax, xmm1                               
        movq    rdx, xmm0                               
        mov     qword [rbp-60H], rax                    
        mov     qword [rbp-58H], rdx                    
        movsd   xmm0, qword [rbp-50H]                   
        movsd   qword [rbp-40H], xmm0                   
        movsd   xmm0, qword [rbp-48H]                   
        movsd   qword [rbp-38H], xmm0                  
        movsd   xmm0, qword [rbp-60H]  			   ; xmm0 = num1.real              
        movsd   qword [rbp-30H], xmm0  			   ; a = xmm0              
        movsd   xmm0, qword [rbp-58H]  			   ; xmm0 = num1.imagin            
        movsd   qword [rbp-28H], xmm0  			   ; b = xmm0            
        movsd   xmm0, qword [rbp-40H]  			   ; xmm0 = num2.real (c)              
        mulsd   xmm0,  [rbp-30H]       			   ; a*c        
        movsd   xmm1, qword [rbp-38H]  			   ; xmm1 = num2.imagin (d)            
        mulsd   xmm1,  [rbp-28H]       			   ; b*d          
        subsd   xmm0, xmm1             			   ; a*c - b*d              
        movsd   qword [rbp-20H], xmm0  			   ; ans.real = a*c - b*d             
        movsd   xmm0, qword [rbp-40H]  			   ; xmm0 = num2.real              
        movapd  xmm1, xmm0                              
        mulsd   xmm1,  [rbp-28H]       			   ; b*c        
        movsd   xmm0, qword [rbp-38H]  			   ; xmm0 = num2.imagin             
        mulsd   xmm0,  [rbp-30H]       			   ; a*d        
        addsd   xmm0, xmm1             			   ; a*d + b*c            
        movsd   qword [rbp-18H], xmm0  			   ; ans.iamgin = a*d + b*c      
        mov     rax, qword [rbp-20H]                 
        mov     rdx, qword [rbp-18H]              
        mov     rcx, rax                             
        mov     rbx, rdx                           
        mov     qword [rbp-68H], rcx               
        movsd   xmm0, qword [rbp-68H]             
        mov     qword [rbp-68H], rdx               
        movsd   xmm1, qword [rbp-68H]            
        pop     rbx                                
        pop     rbp                                   
        ret
; mul End of function

sum:    ; Function begin
        push    rbp                                     
        mov     rbp, rsp                                
        push    rbx                                    
        movq    rcx, xmm0                             
        movapd  xmm0, xmm1                             
        mov     eax, 0                                 
        mov     edx, 0                                
        mov     rax, rcx                               
        movq    rdx, xmm0                             
        mov     qword [rbp-30H], rax                   
        mov     qword [rbp-28H], rdx                   
        movapd  xmm1, xmm2                            
        movapd  xmm0, xmm3                             
        mov     eax, 0                                 
        mov     edx, 0                              
        movq    rax, xmm1                           
        movq    rdx, xmm0                              
        mov     qword [rbp-40H], rax                   
        mov     qword [rbp-38H], rdx                  
        movsd   xmm1, qword [rbp-30H]			; xmm1 = num2.real          
        movsd   xmm0, qword [rbp-40H]		        ; xmm0 = num1.real            
        addsd   xmm0, xmm1           		        ; xmm1 + xmm0          
        movsd   qword [rbp-20H], xmm0		        ; ans.real = xmm0 + xmm1           
        movsd   xmm1, qword [rbp-28H]		        ; xmm1 = num2.imagin           
        movsd   xmm0, qword [rbp-38H]		        ; xmm0 = num1.imagin            
        addsd   xmm0, xmm1           		        ; xmm1 + xmm0           
        movsd   qword [rbp-18H], xmm0		        ; ans.imagin = xmm1 + xmm0           
        mov     rax, qword [rbp-20H]                  
        mov     rdx, qword [rbp-18H]                   
        mov     rcx, rax                           
        mov     rbx, rdx                             
        mov     qword [rbp-48H], rcx               
        movsd   xmm0, qword [rbp-48H]                 
        mov     qword [rbp-48H], rdx                 
        movsd   xmm1, qword [rbp-48H]                 
        pop     rbx                                 
        pop     rbp                                 
        ret                                          
; sum End of function

sub:    ; Function begin
        push    rbp                                     
        mov     rbp, rsp                              
        push    rbx                                    
        movq    rcx, xmm0                            
        movapd  xmm0, xmm1                            
        mov     eax, 0                                 
        mov     edx, 0                                 
        mov     rax, rcx                              
        movq    rdx, xmm0                              
        mov     qword [rbp-30H], rax                   
        mov     qword [rbp-28H], rdx                   
        movapd  xmm1, xmm2                              
        movapd  xmm0, xmm3                            
        mov     eax, 0                                
        mov     edx, 0                                
        movq    rax, xmm1                             
        movq    rdx, xmm0                              
        mov     qword [rbp-40H], rax                   
        mov     qword [rbp-38H], rdx                   
        movsd   xmm0, qword [rbp-30H]        		  ; xmm0 = num1.real      
        movsd   xmm1, qword [rbp-40H]     		  ; xmm1 = num2.real         
        subsd   xmm0, xmm1             		          ; xmm0 - xmm1     
        movsd   qword [rbp-20H], xmm0         		  ; ans.real = xmm0 - xmm1        
        movsd   xmm0, qword [rbp-28H] 		          ; xmm0 = num1.imagin        
        movsd   xmm1, qword [rbp-38H]  		          ; xmm1 = num2.imagin        
        subsd   xmm0, xmm1              		  ; xmm0 - xmm1       
        movsd   qword [rbp-18H], xmm0         		  ; ans.imagin = xmm0 - xmm1      
        mov     rax, qword [rbp-20H]                   
        mov     rdx, qword [rbp-18H]                 
        mov     rcx, rax                               
        mov     rbx, rdx                              
        mov     qword [rbp-48H], rcx                  
        movsd   xmm0, qword [rbp-48H]                  
        mov     qword [rbp-48H], rdx                  
        movsd   xmm1, qword [rbp-48H]                  
        pop     rbx                                     
        pop     rbp                                    
        ret                                           
; sub End of function

divide: ; Function begin
        push    rbp                                     
        mov     rbp, rsp                                 
        push    rbx                                     
        movq    rcx, xmm0                                
        movapd  xmm0, xmm1                               
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                                 
        movq    rdx, xmm0                               
        mov     qword [rbp-50H], rax                     
        mov     qword [rbp-48H], rdx                     
        movapd  xmm1, xmm2                               
        movapd  xmm0, xmm3                               
        mov     eax, 0                                  
        mov     edx, 0                                   
        movq    rax, xmm1                                
        movq    rdx, xmm0                                
        mov     qword [rbp-60H], rax                    
        mov     qword [rbp-58H], rdx                     
        movsd   xmm0, qword [rbp-50H]                    
        movsd   qword [rbp-40H], xmm0                   ; a = num1.real
        movsd   xmm0, qword [rbp-48H]                   ; 
        movsd   qword [rbp-38H], xmm0                   ; b = num1.imagin
        movsd   xmm0, qword [rbp-60H]                   ; 
        movsd   qword [rbp-30H], xmm0                   ; c = num2.real
        movsd   xmm0, qword [rbp-58H]                   ; 
        movsd   qword [rbp-28H], xmm0                   ; d = num2.imagin
        movsd   xmm0, qword [rbp-40H]                   ; 
        movapd  xmm1, xmm0                              ; 
        mulsd   xmm1,  [rbp-30H]                        ; a*c
        movsd   xmm0, qword [rbp-38H]                   ; 
        mulsd   xmm0,  [rbp-28H]                        ; b*d
        addsd   xmm0, xmm1                              ; a*c + b*d
        movsd   xmm1, qword [rbp-30H]                   ; 
        movapd  xmm2, xmm1                              ; xmm2 = c
        mulsd   xmm2,  [rbp-30H]                        ; c*c
        movsd   xmm1, qword [rbp-28H]                   ; xmm1 = d
        mulsd   xmm1,  [rbp-28H]                        ; d*d
        addsd   xmm1, xmm2                              ; c*c + d*d
        divsd   xmm0, xmm1                              ; (a*c + b*d)/(c*c + d*d)
        movsd   qword [rbp-20H], xmm0                   ; ans.real = (a*c + b*d)/(c*c + d*d)
        movsd   xmm0, qword [rbp-38H]                   ; xmm0 = b
        mulsd   xmm0,  [rbp-30H]                        ; b*c
        movsd   xmm1, qword [rbp-40H]                   ; xmm1 = a
        mulsd   xmm1,  [rbp-28H]                        ; a*d
        subsd   xmm0, xmm1                              ; b*c - a*d
        movsd   xmm1, qword [rbp-30H]                   ; xmm1 = c
        movapd  xmm2, xmm1                              ; xmm2 = c
        mulsd   xmm2,  [rbp-30H]                        ; c*c
        movsd   xmm1, qword [rbp-28H]                   ; xmm1 = d
        mulsd   xmm1,  [rbp-28H]                        ; d*d
        addsd   xmm1, xmm2                              ; c*c + d*d
        divsd   xmm0, xmm1                              ; (b*c - a*d)/(c*c + d*d)
        movsd   qword [rbp-18H], xmm0                   ; ans.imagin =  (b*c - a*d)/(c*c + d*d) 
        mov     rax, qword [rbp-20H]                     
        mov     rdx, qword [rbp-18H]                    
        mov     rcx, rax                                 
        mov     rbx, rdx                                 
        mov     qword [rbp-68H], rcx                    
        movsd   xmm0, qword [rbp-68H]                   
        mov     qword [rbp-68H], rdx                     
        movsd   xmm1, qword [rbp-68H]                    
        pop     rbx                                     
        pop     rbp                                      
        ret                                             
; divide End of function

power:  ; Function begin
        push    rbp                                     
        mov     rbp, rsp                               
        push    rbx                                     
        sub     rsp, 72                                 
        movq    rcx, xmm0     				; rcx gets real part
	movapd  xmm0, xmm1 			 	; xmm0 gets imagin part   
        mov     eax, 0                                 
        mov     edx, 0                                 
        mov     rax, rcx                               
        movq    rdx, xmm0     				;rdx gets imagin part
        mov     qword [rbp-40H], rax                   
        mov     qword [rbp-38H], rdx                    
        mov     qword [rbp-48H], rdi                    
        movsd   xmm0, qword [rel one]                
        movsd   qword [rbp-20H], xmm0                   
        pxor    xmm0, xmm0                             
        movsd   qword [rbp-18H], xmm0                 
        mov     qword [rbp-28H], 0   ; i=0                  
        jmp     check_power_loop 

power_loop:
	movsd   xmm2, qword [rbp-40H]                  
        movsd   xmm0, qword [rbp-38H]                  
        mov     rax, qword [rbp-20H]                   
        movsd   xmm1, qword [rbp-18H]                  
        movapd  xmm3, xmm0                              
        mov     qword [rbp-50H], rax                   
        movsd   xmm0, qword [rbp-50H]                   
        call    mul                      		;mul(ans, point) 
        movq    rax, xmm0                               
        movapd  xmm0, xmm1                             
        mov     qword [rbp-20H], rax     		; ans.real = mul.real             
        movsd   qword [rbp-18H], xmm0    		; ans.imagin = mul.imagin             
        add     qword [rbp-28H], 1       		; i++  
            
check_power_loop:
	mov     rax, qword [rbp-28H]   			; rax = i                
        cmp     rax, qword [rbp-48H]  			; rax ? order                
        jl      power_loop                                
        mov     rax, qword [rbp-20H]   			; rax = ans.real                
        mov     rdx, qword [rbp-18H]   			; rdx = ams. imagin               
        mov     rcx, rax                               
        mov     rbx, rdx                              
        mov     qword [rbp-50H], rcx                   
        movsd   xmm0, qword [rbp-50H]                 
        mov     qword [rbp-50H], rdx                   
        movsd   xmm1, qword [rbp-50H]                  
        add     rsp, 72                                
        pop     rbx                                     
        pop     rbp                                    
        ret                                            
; power End of function

polyValueInPoint:; Function begin
        push    rbp                                    
        mov     rbp, rsp                                
        push    rbx                                     
        sub     rsp, 72                                 
        mov     qword [rbp-38H], rdi                    
        movq    rcx, xmm0                               
        movapd  xmm0, xmm1                              
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                               
        movq    rdx, xmm0                              
        mov     qword [rbp-50H], rax                   
        mov     qword [rbp-48H], rdx                   
        mov     rax, qword [rbp-38H]                  
        mov     rax, qword [rax+8H]                    
        test    rax, rax                   		; poly->order ? 0            
        jnz     prepare_ans_4_for                                  
        mov     rax, qword [rbp-38H]                   
        mov     rax, qword [rax]                        
        mov     rdx, qword [rax+8H]                     
        mov     rax, qword [rax]                       
        jmp     finish_polyValue                                  

prepare_ans_4_for:  
        mov     rax, qword [rbp-38H]                   
        mov     rax, qword [rax]                        
        movsd   xmm0, qword [rax]                      
        movsd   qword [rbp-20H], xmm0  			; ans.real = point.real            
        mov     rax, qword [rbp-38H]                  
        mov     rax, qword [rax]                       
        movsd   xmm0, qword [rax+8H]                   
        movsd   qword [rbp-18H], xmm0  			; ans.imagin = point.imagin               
        mov     qword [rbp-28H], 1      		; i = 1               
        jmp     check_for_polyValue                                  

for_polyValue:  
        mov     rax, qword [rbp-38H]                    
        mov     rax, qword [rax]                        
        mov     rdx, qword [rbp-28H]                   
        shl     rdx, 4                                 
        lea     rbx, [rax+rdx]                      
        mov     rdx, qword [rbp-28H]                  
        mov     rax, qword [rbp-50H]    		; rax = point.real                
        movsd   xmm1, qword [rbp-48H]   		; rax = point.imagin                
        mov     rdi, rdx                               
        mov     qword [rbp-40H], rax                   
        movsd   xmm0, qword [rbp-40H]                 
        call    power                   		; power(point,i)               
        movq    rcx, xmm0                              
        movapd  xmm0, xmm1                             
        mov     eax, 0                                 
        mov     edx, 0                                 
        mov     rax, rcx                                
        movq    rdx, xmm0                               
        movsd   xmm1, qword [rbx]                      
        movsd   xmm0, qword [rbx+8H]                   
        mov     rcx, rax                                
        mov     rbx, rdx                                
        mov     qword [rbp-40H], rcx                    
        movsd   xmm4, qword [rbp-40H]                   
        mov     qword [rbp-40H], rdx                   
        movsd   xmm5, qword [rbp-40H]                   
        movapd  xmm2, xmm1                              
        movapd  xmm3, xmm0                              
        movapd  xmm0, xmm4                              
        movapd  xmm1, xmm5                              
        call    mul                                    
        movq    rcx, xmm0                               
        movapd  xmm0, xmm1                              
        mov     eax, 0                                 
        mov     edx, 0                                  
        mov     rax, rcx                                
        movq    rdx, xmm0                              
        mov     rcx, rax                               
        mov     rbx, rdx                                
        mov     qword [rbp-40H], rcx                   
        movsd   xmm2, qword [rbp-40H]                   
        mov     qword [rbp-40H], rdx                   
        movsd   xmm0, qword [rbp-40H]                   
        mov     rax, qword [rbp-20H]                    
        movsd   xmm1, qword [rbp-18H]                  
        movapd  xmm3, xmm0                             
        mov     qword [rbp-40H], rax                   
        movsd   xmm0, qword [rbp-40H]                  
        call    sum                                     
        movq    rax, xmm0                              
        movapd  xmm0, xmm1                             
        mov     qword [rbp-20H], rax     		; ans.real = rax               
        movsd   qword [rbp-18H], xmm0    		; ans.imagin = xmm0               
        add     qword [rbp-28H], 1    			; i++    
              
check_for_polyValue:  
        mov     rax, qword [rbp-38H]                   
        mov     rax, qword [rax+8H]                     
        cmp     rax, qword [rbp-28H]    		; i ? order               
        jge     for_polyValue                                  
        mov     rax, qword [rbp-20H]    		; rax = ans.real               
        mov     rdx, qword [rbp-18H]    		; rdx = ans.imagin 
              
finish_polyValue:  
        mov     rcx, rax                              
        mov     rbx, rdx                               
        mov     qword [rbp-40H], rcx                    
        movsd   xmm0, qword [rbp-40H]                  
        mov     qword [rbp-40H], rdx                   
        movsd   xmm1, qword [rbp-40H]                   
        add     rsp, 72                                 
        pop     rbx                                    
        pop     rbp                                    
        ret                                             
; polyValueInPoint End of function

calculateNextPoint:; Function begin
        push    rbp                                   
        mov     rbp, rsp                           
        push    rbx                                   
        sub     rsp, 88                                 
        mov     qword [rbp-38H], rdi			; 
        mov     qword [rbp-40H], rsi    		;
        movq    rcx, xmm0          			; rcx = point. real
        movapd  xmm0, xmm1        			; xmm0 = point.imagin
        mov     edx, 0      				; edx = 0
        mov     rax, rcx    				; rax = point.real
        movq    rdx, xmm0                               ; rdx = point.imagin
        mov     qword [rbp-50H], rax                    ; tmp.real = point.real
        mov     qword [rbp-48H], rdx                    ; tmp.imagin = point.imagin
        mov     rdx, qword [rbp-50H]                    ; rdx = tmp
        movsd   xmm1, qword [rbp-48H]                   ; xmm1 = point.imagin
        mov     rax, qword [rbp-38H]                    ; rax = &poly
        mov     qword [rbp-58H], rdx                    ; num = tmp
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = point.real
        mov     rdi, rax                                ; rdi = &poly
        call    polyValueInPoint                        ; polyValueInPoint(polyn, point)
        movq    rax, xmm0                               ; rax = num.real
        movapd  xmm0, xmm1                              ; xmm0 = num.imagin
        mov     qword [rbp-30H], rax                    ; funcPoint.real = rax
        movsd   qword [rbp-28H], xmm0                   ; funcPoint.imagin = xmm0
        mov     rdx, qword [rbp-50H]                    ; rdx = point.real
        movsd   xmm1, qword [rbp-48H]                   ; xmm1 = point.imagin
        mov     rax, qword [rbp-40H]                    ; rax = &deriv
        mov     qword [rbp-58H], rdx                    ; num.real = point.real
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = point.real
        mov     rdi, rax                                ; 0A68 _ 48: 89. C7
        call    polyValueInPoint                        ; polyValueInPoint(deriv, point)
        movq    rax, xmm0                               ; rax = num.real
        movapd  xmm0, xmm1                              ; xmm0 = num.imagin
        mov     qword [rbp-20H], rax                    ; derivPoint.real = rax
        movsd   qword [rbp-18H], xmm0                   ; derivPoint.imagin = xmm0
        movsd   xmm0, qword [rbp-20H]                   ; xmm0 = derivPoint.real
        pxor    xmm1, xmm1                              ; xmm1 = 0
        ucomisd xmm0, xmm1                              ; derivPoint.real ? 0
        jpe     calculateNextPoint_start          	; if derivPoint.real != 0, calculateNextPoint_start 
        pxor    xmm1, xmm1                              ; xmm1 = 0
        ucomisd xmm0, xmm1                              ; derivPoint.real ? 0
        jnz     calculateNextPoint_start   		; if derivPoint.real != 0, calculateNextPoint_start
        movsd   xmm0, qword [rbp-18H]                   ; xmm0 = derivPoint.imagin
        pxor    xmm1, xmm1                              ; xmm1 = 0
        ucomisd xmm0, xmm1                              ; derivPoint.imagin ? 0
        jpe     calculateNextPoint_start       		; if derivPoint.imagin != 0, calculateNextPoint_start
        pxor    xmm1, xmm1                              ; xmm1 = 0
        ucomisd xmm0, xmm1                              ; derivPoint.imagin ? 0
        jnz     calculateNextPoint_start         	; if derivPoint.imagin != 0, calculateNextPoint_start
        mov     dword [rel error], 1                    ; error = 1
        mov     rax, qword [rbp-30H]                    ; rax = funcPoint.real
        mov     rdx, qword [rbp-28H]                    ; rdx = funcPoint.imagin
        jmp     finish_calculateNextPoint       	; finish_calculateNextPoint

calculateNextPoint_start:  
	movsd   xmm2, qword [rbp-20H]                   ; xmm2 = derivPoint.real
        movsd   xmm0, qword [rbp-18H]                   ; xmm0 = derivPoint.imagin
        mov     rax, qword [rbp-30H]                    ; rax = funcPoint
        movsd   xmm1, qword [rbp-28H]                   ; xmm1 = funcPoint.imagin
        movapd  xmm3, xmm0                              ; xmm3 = derivPoint.imagin
        mov     qword [rbp-58H], rax                    ; num.real = funcPoint.real
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = funcPoint.real
        call    divide                                  ; divide(num1, num2)
        movq    rcx, xmm0                               ; rcx = num.real
        movapd  xmm0, xmm1                              ; xmm0 = num.imagin
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                                ; rax = num
        movq    rdx, xmm0                               ; rdx = num.imagin
        mov     rcx, rax                                ; rcx = num
        mov     rbx, rdx                                ; rbx = num.imagin
        mov     qword [rbp-58H], rcx                    
        movsd   xmm2, qword [rbp-58H]                   ; xmm2 = num.real
        mov     qword [rbp-58H], rdx                    
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = num.imagin
        mov     rax, qword [rbp-50H]                    ; rax = point.real
        movsd   xmm1, qword [rbp-48H]                   ; xmm1 = point.imagin
        movapd  xmm3, xmm0                              ; xmm3 = num.imagin
        mov     qword [rbp-58H], rax                    
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = point.real
        call    sub                                     ; sub(point, num)
        movq    rcx, xmm0                               ; rcx = num.real
        movapd  xmm0, xmm1                              ; xmm0 = num.imagin
        mov     eax, 0                                  
        mov     edx, 0                                 
        mov     rax, rcx                                ; rax = num
        movq    rdx, xmm0                               ; rdx = num.imagin

finish_calculateNextPoint:  
	mov     rcx, rax                                
        mov     rbx, rdx                                
        mov     qword [rbp-58H], rcx                   
        movsd   xmm0, qword [rbp-58H]                   ; xmm0 = num.real
        mov     qword [rbp-58H], rdx                    ; 
        movsd   xmm1, qword [rbp-58H]                   ; xmm1 = num.imagin
        add     rsp, 88                                 
        pop     rbx                                    
        pop     rbp                                    
        ret                                             
; calculateNextPoint End of function

normal: ; Function begin
        push    rbp                                     
        mov     rbp, rsp                                
        movq    rcx, xmm0                               
        movapd  xmm0, xmm1                             
        mov     eax, 0                                  
        mov     edx, 0                                  
        mov     rax, rcx                               
        movq    rdx, xmm0                               
        mov     qword [rbp-10H], rax                    
        mov     qword [rbp-8H], rdx                    
        movsd   xmm1, qword [rbp-10H]                   ; xmm1 = num1.real
        movsd   xmm0, qword [rbp-10H]                   ; xmm0 = num1.real
        mulsd   xmm1, xmm0                              ; xmm0 * xmm1
        movsd   xmm2, qword [rbp-8H]                    ; xmm2 = num1.imagin
        movsd   xmm0, qword [rbp-8H]                    ; xmm0 = num1.imagin
        mulsd   xmm0, xmm2                              ; xmm0 * xmm2
        addsd   xmm0, xmm1                              
        pop     rbp                                     
        ret                                             
; normal End of function


SECTION .data                			        ; section number 2, data


SECTION .bss                 			        ; section number 3, bss

error:                                                  ; dword
        resd    1                                       ; 0000


SECTION .rodata                  		        ; section number 4, const

epsilon_scan:                                                  ; byte
        db 65H, 70H, 73H, 69H, 6CH, 6FH, 6EH, 20H       ; 0000 _ epsilon 
        db 3DH, 20H, 25H, 6CH, 66H, 25H, 63H, 00H       ; 0008 _ = %lf%c.

order_scan:                                                  ; byte
        db 6FH, 72H, 64H, 65H, 72H, 20H, 3DH, 20H       ; 0010 _ order = 
        db 25H, 6CH, 75H, 25H, 63H, 00H                 ; 0018 _ %lu%c.

coeff_order_scan:                                                  ; byte
        db 63H, 6FH, 65H, 66H, 66H, 20H, 25H, 6CH       ; 001E _ coeff %l
        db 75H, 20H, 3DH, 20H, 00H                      ; 0026 _ u = .

coeff_scan:                                                  ; byte
        db 25H, 6CH, 66H, 20H, 25H, 6CH, 66H, 25H       ; 002B _ %lf %lf%
        db 63H, 00H                                     ; 0033 _ c.

initial_scan:                                                  ; byte
        db 69H, 6EH, 69H, 74H, 69H, 61H, 6CH, 20H       ; 0035 _ initial 
        db 3DH, 20H, 25H, 6CH, 66H, 20H, 25H, 6CH       ; 003D _ = %lf %l
        db 66H, 25H, 63H, 00H                           ; 0045 _ f%c.

root_print:                                                  ; byte
        db 72H, 6FH, 6FH, 74H, 20H, 3DH, 20H, 25H       ; 0049 _ root = %
        db 2EH, 32H, 33H, 67H, 20H, 25H, 2EH, 32H       ; 0051 _ .23g %.2
        db 33H, 67H, 0AH, 00H                           ; 0059 _ 3g..

error_print:                                                  ; byte
        db 65H, 72H, 72H, 6FH, 72H, 3AH, 20H, 64H       ; 005D _ error: d
        db 69H, 76H, 69H, 73H, 69H, 6FH, 6EH, 20H       ; 0065 _ ivision 
        db 62H, 79H, 20H, 7AH, 65H, 72H, 6FH, 00H       ; 006D _ by zero.

one:  dq 3FF0000000000000H                            ; 0088 _ 1.0
