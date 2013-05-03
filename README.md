[Description]:
====================================================================================
                Here're VIM syntax, ctags plugin for AMI SDL and Debug message. 
                1. SDL language syntax highlight.
                2. Debug message language syntax highlight.
                3. ctags language extention.

                If you like view codes via VIM, 
                it's good for you !
[Author]:
====================================================================================
                0xeuclid@gmail.com

[Revision]:     
====================================================================================
                2013/5/3 am 10:19:26

[Note]:
====================================================================================

1.[Syntax]:
    Usage : Just copy&paste "c.vim", "efilog.vim", "sdl.vim" to $VIMRUNTIME/syntax. 

2.[ctags]:
    If you have experiences with tagbar, taglist, or OmniComplete, 
    you should have ctags supporting first. 
    
    Here's simple AMI SDL parser and debug message parser which can extract symbols. 
    Feel free to modify for your own need !

    Don't forget adding SDL variable for Tagbar in your VIMRC 
3. [vimrc setting] Ex:
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
"---
