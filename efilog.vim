" Vim syntax file
" Language:	AMI SDL ( American Megatrends, System Description Lang. for EFI)"
" Orig Author:	Shengwei Hsu < ShegnweiHsu@ami.com.tw >
" Last Change:	$Date: 2007/04/21 13:20:15 $
" $Revision: 0.1 $

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

syn keyword sdlType         .Entry PPI DXE ACPI GCD PCI SIO SMM USB PEI SMI BUS 
syn match   guid            "\S*.Entry(.*)"
syn match   bds             "BDS.[a-zA-Z0-9_]*(\x*)"
syn match   myRegion        "######*#"
syn match   ffsName         "@\S*@"
syn match   guid            "\[\S*)"
syn keyword warn            WARNING 
syn match dellFeature       "\[DELL PROP SRV\]"
syn match   warn            "DXE IPL Entry"
syn match   error           "ERROR:.*"
syn match   error           "ERROR!.*"
syn match   dbstart         ".*\.Start(........)"
" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_masm_syntax_inits")
  if version < 508
    let did_masm_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink sdlType        Include
  HiLink myRegion       Type
  HiLink guid           Comment
  HiLink bds            Comment
  HiLink ffsName        Keyword
  HiLink dellFeature    Keyword
  HiLink warn           Error
  HiLink error           Error
  HiLink dbstart        Delimiter
  syntax sync minlines=50

  delcommand HiLink
endif

let b:current_syntax = "sml"

" vim: ts=8
