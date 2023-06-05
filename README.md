# Doodle-Jump-with-assembly
Doodle Jump game implemented using 8086 assembly language.

## How to use ?
First you need to install and run dosbox in your computer. Then, you should mount the c directory to the ASM folder:
```
mount c path:\to\the\folder\ASM
c:
```
After that you can assemble the dj.asm file using commands below:
```
masm /a dj.asm
```
After typing this, it will ask you for object filename(OBJ), source listing(LST), and cross-reference(CRF) files, leave them blank by pressing `Enter` of type `;` and then press `Enter` to skip all those fields.
