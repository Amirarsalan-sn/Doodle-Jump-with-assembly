# Doodle-Jump-with-assembly
Doodle Jump game implemented using 8086 assembly language.

## How to use it?
First, you need to install and run Dosbox on your computer. Then, you should mount the c directory to the ASM folder:
```
mount c path:\to\the\folder\ASM
c:
``` 
Next, you should assemble the dj.asm file using the commands below:
```
masm /a dj.asm
```
After typing this, it will ask you for object filename(OBJ), source listing(LST), and cross-reference(CRF) files, leave them blank by pressing `Enter` of type `;` and then press `Enter` to skip all those fields.
After assembling it is time to link the assembled file:
```
link dj
```
Again it will show you some fields just type `;` and press `Enter`.
And there you are :), you just need to type:
```
dj
```
and the game will start.
You can open the DOSBox options text file and type these commands at the end of the file so that every time you open the DOSBox, these commands will run automatically and you don't have to type them anymore.
You can also skip these steps as I have assembled and linked the dj.asm before, so you just need to type `dj` and start playing the game.
Hope you enjoy it :)
You can read the codes and the doc folder to understand the implementation and the policies used in this project.
## Gameplay preview (3 minunts long) :
![Gameplay gif](doc/Untitled-Project.gif)

