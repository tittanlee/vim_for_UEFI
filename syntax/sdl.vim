" Vim syntax file
" Language:	AMI SDL ( American Megatrends, System Description Lang. for EFI)"
" Orig Author:	Shengwei Hsu < ShegnweiHsu@ami.com.tw >
" Last Change:	$Date: 2013/03/05 13:20:15 $
" $Revision: 0.1 $

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case ignore

syn keyword sdlType             TOKEN ELINK IRQLINK PCIDEVICE IODEVICE IOAPIC PATH MODULE SEGMENT OUTPUTREGISTER INFCOMPONENT PCDMAPPING LIBRARYMAPPING END
syn keyword sdlAttr             Name Value TokenType TargetEQU TargetMAK TargetH Help Range Parent Priority InvokeOrder SrcFile ASLfile File Master TargetASL Lock Package PreProcess ModuleTypes GuidSpace PcdType Override Offset Length TargetDSC Class Instance TargetFDF Type Arch
syn keyword sdlConst            Yes No AfterParent Boolean Expression ReplaceParent
syn keyword sdlConst            Integer
syn match   sdlComment          "#.*"
syn match   sdlComment          "#.*"
syn match   sdlWarn             "ERROR*"
syn keyword sdlPCIDeviceAttr    Title Bus Dev Fun BridgeBus GPEbit SleepNum DeviceType PCIBusSize PCIBridge  WakeEnabled PWRBwake ROMMain IntA IntB IntC IntD Slot ASLdeviceName LPCBridge ROMFile DeviceID VendorID OptionROM
syn keyword sdlIRQLinkAttr              Reg IrqList InterruptType
syn region  String              start=+L\="+ skip=+\\\\\\"+ end=+"+
syn region  SdlPcd              start="\M=\d" end="[hH]$"

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
  HiLink sdlType        Statement
  HiLink sdlAttr        Include
  HiLink sdlConst       Identifier
  HiLink sdlComment     Comment
  HiLink sdlPCIDeviceAttr        Include
  HiLink sdlIRQLinkAttr          Include
  HiLink String         String
  HiLink sdlWarn        cError
  HiLink SdlPcd         Constant
  syntax sync minlines=50

  delcommand HiLink
endif

let b:current_syntax = "sdl"

" vim: ts=8
