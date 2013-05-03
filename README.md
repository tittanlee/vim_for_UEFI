##Description:
Here're VIM syntax, ctags plugin for AMI SDL and Debug message.   

###1. VIM Syntax :  
* Intel UEFI syntax.
* SDL syntax.
* Debug message syntax.

###2. *Ctags* parser for SDL and Debug message.  
If you have experiences with *tagbar*, *taglist*, or *OmniComplete*, 
you should have ctags supporting first. 

Here's simple AMI SDL parser and debug message parser which can extract symbols.  
Feel free to modify for your own need !  

If you like view codes via VIM,  
It's good for you !

##Note:

###1.[VIM Syntax]:
#### Step1 :
Just copy&paste "c.vim", "efilog.vim", "sdl.vim" to $VIMRUNTIME/syntax. 
#### Step2 :
Add filetype to your vimrc:  
    |syntax setting|:
        "|#Syntax_and_Highlight|"{{{
        "--------------------------------------------------------------------------- 
        syntax enable     " Syntax Highlight
        " Syntax highlight for *.efilog 
        au BufRead,BufNewFile *.efilog set filetype=efilog
        au! Syntax efilog source $VIMRUNTIME/syntax/efilog.vim
        " Syntax highlight for *.dxs 
        au BufRead,BufNewFile *.dxs set filetype=dxs
        au! Syntax dxs source $VIMRUNTIME/syntax/dxs.vim
        " Syntax highlight for *.sd
        au BufRead,BufNewFile *.sd set filetype=c
        " Syntax highlight for *.asl
        au BufRead,BufNewFile *.asl set filetype=c
        "}}}

###2.[Ctags]:
#### Step1 :
*ctags.exe* is based on ctags source 5.8 (download form "http://ctags.sourceforge.net/" )
You can download source and use sdl.c, efilog.c to add language extension.  
Or just use *ctags.exe* I compiled for Windows OS.

#### Step2 :
Add language extension for tagbar or taglist (Here I demo via tagbar):

    |ctags and tagbar setting| :
        "---
        " set focus to TagBar when opening it
        set updatetime=500 " Shorten automatically timer

        " SDL Extend
        let g:tagbar_type_sdl = {
            \ 'ctagstype' : 'sdl',
            \ 'kinds'     : [
                \ 't:Token',
                \ 'e:Elink',
                \ 'p:Path',
                \ 'i:IO Dev',
                \ 'm:Module',
                \ 'q:IRQ Link',
                \ 'd:PCI Dev'
            \ ]
        \ }

        " Efilog Extend
        let g:tagbar_type_efilog = {
            \ 'ctagstype' : 'efilog',
            \ 'kinds'     : [
                \ 'x:Error',
                \ 'e:Entry'
            \ ]
        \ }
##Author:
    0xeuclid@gmail.com
##Revision:     
    2013/5/3 am 10:19:26
"---
