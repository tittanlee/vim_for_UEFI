" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2009 Nov 17

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" A bunch of useful C keywords
syn keyword	cStatement	goto break return continue asm
syn keyword	cLabel		case default
syn keyword	cConditional	if else switch
syn keyword	cRepeat		while for do

syn keyword	cTodo		contained TODO FIXME XXX

" It's easy to accidentally add a space after a backslash that was intended
" for line continuation.  Some compilers allow it, which makes it
" unpredicatable and should be avoided.
syn match	cBadContinuation contained "\\\s\+$"

" cCommentGroup allows adding matches for special things in comments
syn cluster	cCommentGroup	contains=cTodo,cBadContinuation

" String and Character constants
" Highlight special characters (those which have a backslash) differently
syn match	cSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
  syn match	cSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif
if exists("c_no_cformat")
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,@Spell
else
  if !exists("c_no_c99") " ISO C99
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  else
    syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\([hlL]\|ll\)\=\([bdiuoxXDOUfeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
  endif
  syn match	cFormat		display "%%" contained
  syn region	cString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat,@Spell
  " cCppString: same as cString, but ends at end of line
  syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial,cFormat,@Spell
endif

syn match	cCharacter	"L\='[^\\]'"
syn match	cCharacter	"L'[^']*'" contains=cSpecial
if exists("c_gnu")
  syn match	cSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
else
  syn match	cSpecialError	"L\='\\[^'\"?\\abfnrtv]'"
  syn match	cSpecialCharacter "L\='\\['\"?\\abfnrtv]'"
endif
syn match	cSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	cSpecialCharacter display "'\\x\x\{1,2}'"
syn match	cSpecialCharacter display "L'\\x\x\+'"

"when wanted, highlight trailing white space
if exists("c_space_errors")
  if !exists("c_no_trail_space_error")
    syn match	cSpaceError	display excludenl "\s\+$"
  endif
  if !exists("c_no_tab_space_error")
    syn match	cSpaceError	display " \+\t"me=e-1
  endif
endif

" This should be before cErrInParen to avoid problems with #define ({ xxx })
if exists("c_curly_error")
  syntax match cCurlyError "}"
  syntax region	cBlock		start="{" end="}" contains=ALLBUT,cCurlyError,@cParenGroup,cErrInParen,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell fold
else
  syntax region	cBlock		start="{" end="}" transparent fold
endif

"catch errors caused by wrong parenthesis and brackets
" also accept <% for {, %> for }, <: for [ and :> for ] (C99)
" But avoid matching <::.
syn cluster	cParenGroup	contains=cParenError,cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom
if exists("c_no_curly_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "^[{}]\|^<%\|^%>"
elseif exists("c_no_bracket_error")
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cParen,cString,@Spell
  syn match	cParenError	display ")"
  syn match	cErrInParen	display contained "[{}]\|<%\|%>"
else
  syn region	cParen		transparent start='(' end=')' contains=ALLBUT,@cParenGroup,cCppParen,cErrInBracket,cCppBracket,cCppString,@Spell
  " cCppParen: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@cParenGroup,cErrInBracket,cParen,cBracket,cString,@Spell
  syn match	cParenError	display "[\])]"
  syn match	cErrInParen	display contained "[\]{}]\|<%\|%>"
  syn region	cBracket	transparent start='\[\|<::\@!' end=']\|:>' contains=ALLBUT,@cParenGroup,cErrInParen,cCppParen,cCppBracket,cCppString,@Spell
  " cCppBracket: same as cParen but ends at end-of-line; used in cDefine
  syn region	cCppBracket	transparent start='\[\|<::\@!' skip='\\$' excludenl end=']\|:>' end='$' contained contains=ALLBUT,@cParenGroup,cErrInParen,cParen,cBracket,cString,@Spell
  syn match	cErrInBracket	display contained "[);{}]\|<%\|%>"
endif

"integer number, or floating point number without a dot and with "f".
syn case ignore
syn match	cNumbers	display transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctalError,cOctal
" Same, but without octal error (for comments)
syn match	cNumbersCom	display contained transparent "\<\d\|\.\d" contains=cNumber,cFloat,cOctal
syn match	cNumber		display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
"hex number
syn match	cNumber		display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
" Flag the first zero of an octal number as something special
syn match	cOctal		display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=cOctalZero
syn match	cOctalZero	display contained "\<0"
syn match	cFloat		display contained "\d\+f"
"floating point number, with dot, optional exponent
syn match	cFloat		display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
"floating point number, starting with a dot, optional exponent
syn match	cFloat		display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
"floating point number, without dot, with exponent
syn match	cFloat		display contained "\d\+e[-+]\=\d\+[fl]\=\>"
if !exists("c_no_c99")
  "hexadecimal floating point number, optional leading digits, with dot, with exponent
  syn match	cFloat		display contained "0x\x*\.\x\+p[-+]\=\d\+[fl]\=\>"
  "hexadecimal floating point number, with leading digits, optional dot, with exponent
  syn match	cFloat		display contained "0x\x\+\.\=p[-+]\=\d\+[fl]\=\>"
endif

" flag an octal number with wrong digits
syn match	cOctalError	display contained "0\o*[89]\d*"
syn case match

if exists("c_comment_strings")
  " A comment can contain cString, cCharacter and cNumber.
  " But a "*/" inside a cString in a cComment DOES end the comment!  So we
  " need to use a special type of cString: cCommentString, which also ends on
  " "*/", and sees a "*" at the start of the line as comment again.
  " Unfortunately this doesn't very well work for // type of comments :-(
  syntax match	cCommentSkip	contained "^\s*\*\($\|\s\+\)"
  syntax region cCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=cSpecial,cCommentSkip
  syntax region cComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=cSpecial
  syntax region  cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cComment2String,cCharacter,cNumbersCom,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    " Use "extend" here to have preprocessor lines not terminate halfway a
    " comment.
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell extend
  else
    syntax region cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cCommentString,cCharacter,cNumbersCom,cSpaceError,@Spell fold extend
  endif
else
  syn region	cCommentL	start="//" skip="\\$" end="$" keepend contains=@cCommentGroup,cSpaceError,@Spell
  if exists("c_no_comment_fold")
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell extend
  else
    syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=@cCommentGroup,cCommentStartError,cSpaceError,@Spell fold extend
  endif
endif
" keep a // comment separately, it terminates a preproc. conditional
syntax match	cCommentError	display "\*/"
syntax match	cCommentStartError display "/\*"me=e-1 contained

syn keyword	cOperator	sizeof
if exists("c_gnu")
  syn keyword	cStatement	__asm__
  syn keyword	cOperator	typeof __real__ __imag__
endif
syn keyword	cType		int long short char void
syn keyword	cType		signed unsigned float double
if !exists("c_no_ansi") || exists("c_ansi_typedefs")
  syn keyword   cType		size_t ssize_t off_t wchar_t ptrdiff_t sig_atomic_t fpos_t
  syn keyword   cType		clock_t time_t va_list jmp_buf FILE DIR div_t ldiv_t
  syn keyword   cType		mbstate_t wctrans_t wint_t wctype_t
endif
if !exists("c_no_c99") " ISO C99
  syn keyword	cType		bool complex
  syn keyword	cType		int8_t int16_t int32_t int64_t
  syn keyword	cType		uint8_t uint16_t uint32_t uint64_t
  syn keyword	cType		int_least8_t int_least16_t int_least32_t int_least64_t
  syn keyword	cType		uint_least8_t uint_least16_t uint_least32_t uint_least64_t
  syn keyword	cType		int_fast8_t int_fast16_t int_fast32_t int_fast64_t
  syn keyword	cType		uint_fast8_t uint_fast16_t uint_fast32_t uint_fast64_t
  syn keyword	cType		intptr_t uintptr_t
  syn keyword	cType		intmax_t uintmax_t
endif
if exists("c_gnu")
  syn keyword	cType		__label__ __complex__ __volatile__
endif

syn keyword	cStructure	struct union enum typedef
syn keyword	cStorageClass	static register auto volatile extern const
if exists("c_gnu")
  syn keyword	cStorageClass	inline __attribute__
endif
if !exists("c_no_c99")
  syn keyword	cStorageClass	inline restrict
endif

if !exists("c_no_ansi") || exists("c_ansi_constants") || exists("c_gnu")
  if exists("c_gnu")
    syn keyword cConstant __GNUC__ __FUNCTION__ __PRETTY_FUNCTION__ __func__
  endif
  syn keyword cConstant __LINE__ __FILE__ __DATE__ __TIME__ __STDC__
  syn keyword cConstant __STDC_VERSION__
  syn keyword cConstant CHAR_BIT MB_LEN_MAX MB_CUR_MAX
  syn keyword cConstant UCHAR_MAX UINT_MAX ULONG_MAX USHRT_MAX
  syn keyword cConstant CHAR_MIN INT_MIN LONG_MIN SHRT_MIN
  syn keyword cConstant CHAR_MAX INT_MAX LONG_MAX SHRT_MAX
  syn keyword cConstant SCHAR_MIN SINT_MIN SLONG_MIN SSHRT_MIN
  syn keyword cConstant SCHAR_MAX SINT_MAX SLONG_MAX SSHRT_MAX
  if !exists("c_no_c99")
    syn keyword cConstant __func__
    syn keyword cConstant LLONG_MIN LLONG_MAX ULLONG_MAX
    syn keyword cConstant INT8_MIN INT16_MIN INT32_MIN INT64_MIN
    syn keyword cConstant INT8_MAX INT16_MAX INT32_MAX INT64_MAX
    syn keyword cConstant UINT8_MAX UINT16_MAX UINT32_MAX UINT64_MAX
    syn keyword cConstant INT_LEAST8_MIN INT_LEAST16_MIN INT_LEAST32_MIN INT_LEAST64_MIN
    syn keyword cConstant INT_LEAST8_MAX INT_LEAST16_MAX INT_LEAST32_MAX INT_LEAST64_MAX
    syn keyword cConstant UINT_LEAST8_MAX UINT_LEAST16_MAX UINT_LEAST32_MAX UINT_LEAST64_MAX
    syn keyword cConstant INT_FAST8_MIN INT_FAST16_MIN INT_FAST32_MIN INT_FAST64_MIN
    syn keyword cConstant INT_FAST8_MAX INT_FAST16_MAX INT_FAST32_MAX INT_FAST64_MAX
    syn keyword cConstant UINT_FAST8_MAX UINT_FAST16_MAX UINT_FAST32_MAX UINT_FAST64_MAX
    syn keyword cConstant INTPTR_MIN INTPTR_MAX UINTPTR_MAX
    syn keyword cConstant INTMAX_MIN INTMAX_MAX UINTMAX_MAX
    syn keyword cConstant PTRDIFF_MIN PTRDIFF_MAX SIG_ATOMIC_MIN SIG_ATOMIC_MAX
    syn keyword cConstant SIZE_MAX WCHAR_MIN WCHAR_MAX WINT_MIN WINT_MAX
  endif
  syn keyword cConstant FLT_RADIX FLT_ROUNDS
  syn keyword cConstant FLT_DIG FLT_MANT_DIG FLT_EPSILON
  syn keyword cConstant DBL_DIG DBL_MANT_DIG DBL_EPSILON
  syn keyword cConstant LDBL_DIG LDBL_MANT_DIG LDBL_EPSILON
  syn keyword cConstant FLT_MIN FLT_MAX FLT_MIN_EXP FLT_MAX_EXP
  syn keyword cConstant FLT_MIN_10_EXP FLT_MAX_10_EXP
  syn keyword cConstant DBL_MIN DBL_MAX DBL_MIN_EXP DBL_MAX_EXP
  syn keyword cConstant DBL_MIN_10_EXP DBL_MAX_10_EXP
  syn keyword cConstant LDBL_MIN LDBL_MAX LDBL_MIN_EXP LDBL_MAX_EXP
  syn keyword cConstant LDBL_MIN_10_EXP LDBL_MAX_10_EXP
  syn keyword cConstant HUGE_VAL CLOCKS_PER_SEC NULL
  syn keyword cConstant LC_ALL LC_COLLATE LC_CTYPE LC_MONETARY
  syn keyword cConstant LC_NUMERIC LC_TIME
  syn keyword cConstant SIG_DFL SIG_ERR SIG_IGN
  syn keyword cConstant SIGABRT SIGFPE SIGILL SIGHUP SIGINT SIGSEGV SIGTERM
  " Add POSIX signals as well...
  syn keyword cConstant SIGABRT SIGALRM SIGCHLD SIGCONT SIGFPE SIGHUP
  syn keyword cConstant SIGILL SIGINT SIGKILL SIGPIPE SIGQUIT SIGSEGV
  syn keyword cConstant SIGSTOP SIGTERM SIGTRAP SIGTSTP SIGTTIN SIGTTOU
  syn keyword cConstant SIGUSR1 SIGUSR2
  syn keyword cConstant _IOFBF _IOLBF _IONBF BUFSIZ EOF WEOF
  syn keyword cConstant FOPEN_MAX FILENAME_MAX L_tmpnam
  syn keyword cConstant SEEK_CUR SEEK_END SEEK_SET
  syn keyword cConstant TMP_MAX stderr stdin stdout
  syn keyword cConstant EXIT_FAILURE EXIT_SUCCESS RAND_MAX
  " Add POSIX errors as well
  syn keyword cConstant E2BIG EACCES EAGAIN EBADF EBADMSG EBUSY
  syn keyword cConstant ECANCELED ECHILD EDEADLK EDOM EEXIST EFAULT
  syn keyword cConstant EFBIG EILSEQ EINPROGRESS EINTR EINVAL EIO EISDIR
  syn keyword cConstant EMFILE EMLINK EMSGSIZE ENAMETOOLONG ENFILE ENODEV
  syn keyword cConstant ENOENT ENOEXEC ENOLCK ENOMEM ENOSPC ENOSYS
  syn keyword cConstant ENOTDIR ENOTEMPTY ENOTSUP ENOTTY ENXIO EPERM
  syn keyword cConstant EPIPE ERANGE EROFS ESPIPE ESRCH ETIMEDOUT EXDEV
  " math.h
  syn keyword cConstant M_E M_LOG2E M_LOG10E M_LN2 M_LN10 M_PI M_PI_2 M_PI_4
  syn keyword cConstant M_1_PI M_2_PI M_2_SQRTPI M_SQRT2 M_SQRT1_2
endif
if !exists("c_no_c99") " ISO C99
  syn keyword cConstant true false
endif

" Accept %: for # (C99)
syn region      cPreCondit      start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$"  keepend contains=cComment,cCommentL,cCppString,cCharacter,cCppParen,cParenError,cNumbers,cCommentError,cSpaceError
syn match	cPreCondit	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
if !exists("c_no_if0")
  if !exists("c_no_if0_fold")
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2 fold
  else
    syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
  endif
  syn region	cCppOut2	contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cSpaceError,cCppSkip
  syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cSpaceError,cCppSkip
endif
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
"syn match cLineSkip	"\\$"
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cErrInParen,cErrInBracket,cUserLabel,cSpecial,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cString,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cParen,cBracket,cMulti
syn region	cDefine		start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell
syn region	cPreProc	start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@cPreProcGroup,@Spell

" Highlight User Labels
syn cluster	cMultiGroup	contains=cIncluded,cSpecial,cCommentSkip,cCommentString,cComment2String,@cCommentGroup,cCommentStartError,cUserCont,cUserLabel,cBitField,cOctalZero,cCppOut,cCppOut2,cCppSkip,cFormat,cNumber,cFloat,cOctal,cOctalError,cNumbersCom,cCppParen,cCppBracket,cCppString
syn region	cMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@cMultiGroup,@Spell


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFI Labels - AMI TW 0xEuclid porting.{{{1
" " Vim syntax file
" Language:	UEFI in C 
" Author:	0xEuclid < 0xeuclid@gmail.com >
" Last Change:	$Date: 2013/5/2 pm 02:45:13
" $Revision: 0.1  $
" NOTE : Latter syntax has higher priority
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFI Constants{{{2
"--------------------------------------------------------
" EFIConst----match{{{3
syn match         EFIConst    "TRACE_\h*"
syn match         EFIConst    "\h*_TOK"
syn match         EFIConst    "BIT\d*"

" EFIConst----match
syn match 	EFIConst      "EFI_\h*_SIZE" 
syn match 	EFIConst      "UEFI_\h*" 
"syn match 	EFIConst      "BBS_\h*" 
" SMBIOS
syn match 	EFIConst      "EFI_SMBIOS_TYPE_\S*_INFORMATION"
syn match 	EFIConst      "EFI_SMBIOS_TYPE_\S*"
syn match 	EFIConst      "EFI_SMBIOS_OEM_\S*"
" DMI
syn match 	EFIConst      "DMI_\h*"
" EFI Scan code
syn match       EFIConst     "EFI_SCAN_\S*"
" PCH LPC Header define
syn match       EFIConst     "[A-Z]_PCH_[A-Z_0-9]*"
syn match       EFIConst     "HWM_[A-Z0-9_]*"
syn match       EFIConst     "SENSOR_SOURCE_MAPPING_SOFT\d*"
syn match       EFIConst     "DIAG_TOLERANCE_[A-Z0-9_]*"
syn match       EFIConst     "PCI_CL_[A-Z0-9_]*"
syn match       EFIConst     "PCI_[A-Z0-9_]*_OFFSET"
syn match       EFIConst     "[A-Z0-9_]*_SIG"
syn match       EFIConst     "SCAN_[A-Z0-9_]*"
syn match       EFIConst     "VARIABLE_ID_[A-Z0-9_]*"
syn match       EFIConst     "[A-Z0-9_]*_DEV[^A-Z_)]"
syn match       EFIConst     "[A-Z0-9_]*_BUS"
syn match       EFIConst     "EFI_D_[A-Z]*"
syn match       EFIConst     "EFI_MEMORY_[A-Z0-9]*"
syn match       EFIConst     "EFI_PERIPHERAL[A-Z0-9_]*"
syn match       EFIConst     "AMI_PEIM_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SOFTWARE_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_BL_PC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_DXE_BS_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_DXE_CORE_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_DXE_RT_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_EC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_PC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_PEIM_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_PEI_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_PS_PC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_RS_PC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_RT_PC_[A-Z0-9_]*"
syn match       EFIConst     "EFI_SW_SEC_PC[A-Z0-9_]*"
" Device Path
syn match       EFIConst     "[a-zA-Z0-9_]*_DP"
syn match       EFIConst     "[a-zA-Z0-9_]*_PATH_LENGTH"
" FV constant 
syn match       EFIConst     "EFI_FV2_[A-Z0-9_]*"
syn match       EFIConst     "EFI_FV_FILE_ATTRIB[A-Z0-9_]*"

"syn match       EFIConst     "EFI_PAGE_[A-Z0-9]*"
syn match       EFIConst     "DEBUG_PROPERTY_[A-Z_]*_ENABLED"
syn match       EFIConst     "EFI_PEI_PPI_DESCRIPTOR_[A-Z_]*"
syn match       EFIConst     "[A-Z_]*_OFFSET"
syn match       EFIConst     "[A-Z_]*_TIMEOUT"
syn match       EFIConst     "[A-Z_]*_CONTROLLER"
syn match       EFIConst     "ENUMERATE_[A-Z_]*"
syn match       EFIConst     "[A-Z_]*_RELEASE_VERSION"
syn match       EFIConst     "[A-Z_]*_OPCODE"
syn match       EFIConst     "[^a-zA-Z]g[a-zA-Z0-9]*Guid"
syn match       EFIConst     "Dell[a-zA-Z0-9]*Guid"
syn match       EFIConst     "\h*_YEAR"
syn match       EFIConst     "\h*_MONTH"
syn match       EFIConst     "\h*_DAY"
syn match       EFIConst     "\h*_HOUR"
syn match       EFIConst     "\h*_MINUTE"
syn match       EFIConst     "\h*_SECOND"
syn match       EFIConst     "\h*_INT"
syn match       EFIConst     "\h*_TODAY"
syn match       EFIConst     "\h*_NOW"
syn match       EFIConst     "[RSB]_\S*_TMR"
syn match       EFIConst     "[RSB]_\h*_EN"
syn match       EFIConst     "[A-Z0-9_]*_\h*_EN"
syn match       EFIConst     "[A-Z0-9_]*_\h*_ENABLE"
syn match       EFIConst     "[RSB]_\S*_CNT"
syn match       EFIConst     "[RSB]_\S*_STS"
syn match       EFIConst     "SYS_\S*_ADDR"
syn match       EFIConst     "[A-Z_0-9]*_PCI_ADDR"
syn match       EFIConst     "SYS_\S*_FN"
syn match       EFIConst     "\h*_PCI_\S*_ADDR"
syn match       EFIConst     "R_SATA_[A-Z_0-9]*"
syn match       EFIConst     "B_PCH_SMI_EN_[A-Z_0-9]*"
syn match       EFIConst     "B_PCH_SMI_STS[A-Z_0-9]*"
syn match       EFIConst     "B_PCH_TCO1_STS_[A-Z_0-9]*"
syn match       EFIConst     "B_PCH_TCO2_STS_[A-Z_0-9]*"
syn match       EFIConst     "B_PCH_TC[O12]_CNT[A-Z_0-9]*"
syn match       EFIConst     "PCI_\S*_NUMBER_PCH_SMBUS"
syn match       EFIConst     "SYS_PCIE_\d_DEVFUN"
syn match       EFIConst     "B_SB_HDA_COMMAND_[A-Z_0-9]*"
syn match       EFIConst     "[RB]_SB_RCRB_IO_TRAP_[A-Z_0-9]*"
syn match       EFIConst     "[RSB]_SB_RCRB_[A-Z_0-9]*"
syn match       EFIConst     "V_S\d\h*"
" SB.H
syn match       EFIConst     "LEGACY_[A-Z_0-9]*_MASTER"
syn match       EFIConst     "LEGACY_[A-Z_0-9]*_SLAVE"
syn match       EFIConst     "[A-Z0-9]*_FUN"
syn match       EFIConst     "[A-Z0-9]*_FUNC"
syn match       EFIConst     "[A-Z0-9]*_FUNC\d"
syn match       EFIConst     "[A-Z0-9]*_BUS_DEV_FUN"
syn match       EFIConst     "SB_REG_PIRQ_[A-H]"
syn match       EFIConst     "ACPI_IOREG_[A-Z_0-9]*"
syn match       EFIConst     "SATA_REG_[A-Z_0-9]*"
syn match       EFIConst     "SMBUS_REG_[A-Z_0-9]*"
syn match       EFIConst     "PCIBR_REG_[A-Z_0-9]*"
syn match       EFIConst     "THERMAL_REG_[A-Z_0-9]*"
syn match       EFIConst     "ICH_REG_[A-Z_0-9]*"
syn match       EFIConst     "LAN_REG_[A-Z_0-9]*"
syn match       EFIConst     "RCRB_MMIO_[A-Z_0-9]*"
syn match       EFIConst     "HST_STS_[A-Z_0-9]*"
syn match       EFIConst     "TCO_[A-Z_0-9]*"
syn match       EFIConst     "SMB_[A-Z_0-9]*"
syn match       EFIConst     "GP_[A-Z_0-9]*"
syn match       EFIConst     "R_RCRB_SPI_[A-Z_0-9]*"
syn match       EFIConst     "RCRB_IRQ[A-H0-9]"
syn match       EFIConst     "RCRB_PIRQ[A-H0-9]"
syn match       EFIConst     "[XE]HCI_REG_[A-Z_0-9]*"
syn match       EFIConst     "PCI_DEVICE_NUMBER_PCH_[A-Z_0-9]*"
syn match       EFIConst     "RTC_[A-Z_0-9]*_REG"
syn match       EFIConst     "RTC_[A-Z_0-9]*_INDEX"
syn match       EFIConst     "SB_REG_GEN\d_DEC"
syn match       EFIConst     "SB_REG_GEN_PMCON_\d"
syn match       EFIConst     "SB_REG_[A-Z0-9_]*"
syn match       EFIConst     "ME_REG_[A-Z0-9_]*"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_E"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_EN"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_SMI"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_INTERRUPT"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_STATUS"
syn match       EFIConst     "EHCI_[A-Z0-9_]*_STS"

" EFI_SMBIOS_TYPE_*
syn match       EFIConst     "EFI_SMBIOS_TYPE_[A-Z0-9_]*"

" }}}
"--------------------------------------------------------
" EFIConst----keyword{{{3
syn keyword	EFIConst      TRUE 
syn keyword	EFIConst      FALSE 
syn keyword	EFIConst      EFI_MEMORY_DESCRIPTOR_VERSION 
syn keyword	EFIConst      EFI_PAGE_SIZE 
syn keyword	EFIConst      NULL 
syn keyword	EFIConst      EFI_ERROR_BIT 
syn keyword	EFIConst      PI_ERROR_BIT 
syn keyword	EFIConst      EFI_SUCCESS 
syn keyword	EFIConst      EFI_LOAD_ERROR 
syn keyword	EFIConst      EFI_INVALID_PARAMETER 
syn keyword	EFIConst      EFI_UNSUPPORTED 
syn keyword	EFIConst      EFI_BAD_BUFFER_SIZE 
syn keyword	EFIConst      EFI_BUFFER_TOO_SMALL 
syn keyword	EFIConst      EFI_NOT_READY 
syn keyword	EFIConst      EFI_DEVICE_ERROR 
syn keyword	EFIConst      EFI_WRITE_PROTECTED 
syn keyword	EFIConst      EFI_OUT_OF_RESOURCES 
syn keyword	EFIConst      EFI_VOLUME_CORRUPTED 
syn keyword	EFIConst      EFI_VOLUME_FULL 
syn keyword	EFIConst      EFI_NO_MEDIA 
syn keyword	EFIConst      EFI_MEDIA_CHANGED 
syn keyword	EFIConst      EFI_NOT_FOUND 
syn keyword	EFIConst      EFI_ACCESS_DENIED 
syn keyword	EFIConst      EFI_NO_RESPONSE 
syn keyword	EFIConst      EFI_NO_MAPPING 
syn keyword	EFIConst      EFI_TIMEOUT 
syn keyword	EFIConst      EFI_NOT_STARTED 
syn keyword	EFIConst      EFI_ALREADY_STARTED 
syn keyword	EFIConst      EFI_ABORTED 
syn keyword	EFIConst      EFI_ICMP_ERROR 
syn keyword	EFIConst      EFI_TFTP_ERROR 
syn keyword	EFIConst      EFI_PROTOCOL_ERROR 
syn keyword	EFIConst      EFI_INCOMPATIBLE_VERSION 
syn keyword	EFIConst      EFI_SECURITY_VIOLATION 
syn keyword	EFIConst      EFI_CRC_ERROR 
syn keyword	EFIConst      EFI_NOT_AVAILABLE_YET 
syn keyword	EFIConst      EFI_UNLOAD_IMAGE 
syn keyword	EFIConst      EFI_END_OF_MEDIA 
syn keyword	EFIConst      EFI_END_OF_FILE 
syn keyword	EFIConst      EFI_INVALID_LANGUAGE 
syn keyword	EFIConst      EFI_NOT_AVAILABLE_YET 
syn keyword	EFIConst      EFI_UNLOAD_IMAGE 
syn keyword	EFIConst      EFI_DBE_EOF 
syn keyword	EFIConst      EFI_DBE_BOF 
syn keyword	EFIConst      EFI_WARN_UNKNOWN_GLYPH 
syn keyword	EFIConst      EFI_WARN_DELETE_FAILURE 
syn keyword	EFIConst      EFI_WARN_WRITE_FAILURE 
syn keyword	EFIConst      EFI_WARN_BUFFER_TOO_SMALL 
syn keyword	EFIConst      EFI_VARIABLE_NON_VOLATILE 
syn keyword	EFIConst      EFI_VARIABLE_BOOTSERVICE_ACCESS 
syn keyword	EFIConst      EFI_VARIABLE_RUNTIME_ACCESS 
syn keyword	EFIConst      EFI_VARIABLE_HARDWARE_ERROR_RECORD 
syn keyword	EFIConst      EFI_VARIABLE_AUTHENTICATED_WRITE_ACCESS 
syn keyword	EFIConst      TPL_APPLICATION 
syn keyword	EFIConst      TPL_CALLBACK 
syn keyword	EFIConst      TPL_NOTIFY 
syn keyword	EFIConst      TPL_HIGH_LEVEL 
syn keyword	EFIConst      EFI_TPL_APPLICATION 
syn keyword	EFIConst      EFI_TPL_CALLBACK 
syn keyword	EFIConst      EFI_TPL_NOTIFY 
syn keyword	EFIConst      EFI_TPL_HIGH_LEVEL 
syn keyword	EFIConst      EVT_TIMER 
syn keyword	EFIConst      EVT_RUNTIME 
syn keyword	EFIConst      EVT_RUNTIME_CONTEXT 
syn keyword	EFIConst      EVT_NOTIFY_WAIT 
syn keyword	EFIConst      EVT_NOTIFY_SIGNAL 
syn keyword	EFIConst      EVT_SIGNAL_EXIT_BOOT_SERVICES 
syn keyword	EFIConst      EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE 
syn keyword	EFIConst      EFI_EVENT_TIMER 
syn keyword	EFIConst      EFI_EVENT_RUNTIME 
syn keyword	EFIConst      EFI_EVENT_RUNTIME_CONTEXT 
syn keyword	EFIConst      EFI_EVENT_NOTIFY_WAIT 
syn keyword	EFIConst      EFI_EVENT_NOTIFY_SIGNAL 
syn keyword	EFIConst      EFI_EVENT_NOTIFY_SIGNAL_ALL 
syn keyword	EFIConst      EFI_EVENT_SIGNAL_EXIT_BOOT_SERVICES 
syn keyword	EFIConst      EFI_EVENT_SIGNAL_VIRTUAL_ADDRESS_CHANGE 
syn keyword	EFIConst      EFI_EVENT_SIGNAL_READY_TO_BOOT 
syn keyword	EFIConst      EFI_EVENT_SIGNAL_LEGACY_BOOT 
syn keyword	EFIConst      EFI_IMAGE_SUBSYSTEM_EFI_APPLICATION 
syn keyword	EFIConst      EFI_IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER 
syn keyword	EFIConst      EFI_IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER 
syn keyword	EFIConst      EFI_IMAGE_SUBSYSTEM_SAL_RUNTIME_DRIVER 
syn keyword	EFIConst      EFI_IMAGE_MACHINE_IA32 
syn keyword	EFIConst      EFI_IMAGE_MACHINE_IA64 
syn keyword	EFIConst      EFI_IMAGE_MACHINE_EBC 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_GET_PROTOCOL 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_TEST_PROTOCOL 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_BY_CHILD_CONTROLLER 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_BY_DRIVER 
syn keyword	EFIConst      EFI_OPEN_PROTOCOL_EXCLUSIVE 
syn keyword	EFIConst      EFI_EVENT_GROUP_EXIT_BOOT_SERVICES 
syn keyword	EFIConst      EFI_EVENT_GROUP_VIRTUAL_ADDRESS_CHANGE 
syn keyword	EFIConst      EFI_EVENT_GROUP_MEMORY_MAP_CHANGE 
syn keyword	EFIConst      EFI_EVENT_GROUP_READY_TO_BOOT 
syn keyword	EFIConst      EFI_BOOT_SERVICES_SIGNATURE 
syn keyword	EFIConst      EFI_BOOT_SERVICES_REVISION 
syn keyword	EFIConst      EFI_BOOT_SERVICES_REVISION 
syn keyword	EFIConst      EFI_TIME_ADJUST_DAYLIGHT 
syn keyword	EFIConst      EFI_TIME_IN_DAYLIGHT 
syn keyword	EFIConst      EFI_UNSPECIFIED_TIMEZONE 
syn keyword	EFIConst      EFI_OPTIONAL_PTR 
syn keyword	EFIConst      EFI_GLOBAL_VARIABLE 
syn keyword	EFIConst      EFI_STATUS_CODE_TYPE_MASK 
syn keyword	EFIConst      EFI_STATUS_CODE_SEVERITY_MASK 
syn keyword	EFIConst      EFI_STATUS_CODE_RESERVED_MASK 
syn keyword	EFIConst      EFI_PROGRESS_CODE 
syn keyword	EFIConst      EFI_ERROR_CODE 
syn keyword	EFIConst      EFI_DEBUG_CODE 
syn keyword	EFIConst      EFI_ERROR_MINOR 
syn keyword	EFIConst      EFI_ERROR_MAJOR 
syn keyword	EFIConst      EFI_ERROR_UNRECOVERED 
syn keyword	EFIConst      EFI_ERROR_UNCONTAINED 
syn keyword	EFIConst      EFI_STATUS_CODE_CLASS_MASK 
syn keyword	EFIConst      EFI_STATUS_CODE_SUBCLASS_MASK 
syn keyword	EFIConst      EFI_STATUS_CODE_OPERATION_MASK 
syn keyword	EFIConst      CAPSULE_FLAGS_PERSIST_ACROSS_RESET 
syn keyword	EFIConst      CAPSULE_FLAGS_POPULATE_SYSTEM_TABLE 
syn keyword	EFIConst      EFI_RUNTIME_SERVICES_SIGNATURE 
syn keyword	EFIConst      EFI_RUNTIME_SERVICES_REVISION 
syn keyword	EFIConst      EFI_RUNTIME_SERVICES_REVISION 
syn keyword	EFIConst      ACPI_20_TABLE_GUID 
syn keyword	EFIConst      ACPI_TABLE_GUID 
syn keyword	EFIConst      SAL_SYSTEM_TABLE_GUID 
syn keyword	EFIConst      SMBIOS_TABLE_GUID 
syn keyword	EFIConst      MPS_TABLE_GUID 
syn keyword	EFIConst      EFI_ACPI_TABLE_GUID 
syn keyword	EFIConst      ACPI_10_TABLE_GUID 
syn keyword	EFIConst      EFI_SYSTEM_TABLE_SIGNATURE 
syn keyword	EFIConst      EFI_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      EFI_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      EFI_2_10_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      EFI_2_00_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      EFI_1_10_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      EFI_1_02_SYSTEM_TABLE_REVISION 
syn keyword	EFIConst      BOOT_WITH_FULL_CONFIGURATION 
syn keyword	EFIConst      BOOT_WITH_MINIMAL_CONFIGURATION 
syn keyword	EFIConst      BOOT_ASSUMING_NO_CONFIGURATION_CHANGES 
syn keyword	EFIConst      BOOT_WITH_FULL_CONFIGURATION_PLUS_DIAGNOSTICS 
syn keyword	EFIConst      BOOT_WITH_DEFAULT_SETTINGS 
syn keyword	EFIConst      BOOT_ON_S4_RESUME 
syn keyword	EFIConst      BOOT_ON_S5_RESUME 
syn keyword	EFIConst      BOOT_ON_S2_RESUME 
syn keyword	EFIConst      BOOT_ON_S3_RESUME 
syn keyword	EFIConst      BOOT_ON_FLASH_UPDATE 
syn keyword	EFIConst      BOOT_IN_RECOVERY_MODE 
syn keyword	EFIConst      LOAD_OPTION_ACTIVE 
syn keyword	EFIConst      LOAD_OPTION_FORCE_RECONNECT 
syn keyword	EFIConst      LOAD_OPTION_HIDDEN 
syn keyword	EFIConst      LOAD_OPTION_CATEGORY 
syn keyword	EFIConst      LOAD_OPTION_CATEGORY_BOOT 
syn keyword	EFIConst      LOAD_OPTION_CATEGORY_APP 
syn keyword	EFIConst      EFI_BOOT_OPTION_SUPPORT_KEY 
syn keyword	EFIConst      EFI_BOOT_OPTION_SUPPORT_APP 
syn keyword	EFIConst      EFI_BOOT_OPTION_SUPPORT_COUNT 
syn keyword	EFIConst      EFI_REMOVABLE_MEDIA_FILE_NAME_IA32 
syn keyword	EFIConst      EFI_REMOVABLE_MEDIA_FILE_NAME_IA64 
syn keyword	EFIConst      EFI_REMOVABLE_MEDIA_FILE_NAME_X64 
syn keyword	EFIConst      EFI_REMOVABLE_MEDIA_FILE_NAME 
syn keyword	EFIConst      GUID_VARIABLE_DECLARATION 
syn keyword	EFIConst      EFI_FORWARD_DECLARATION 
" EHCI
syn keyword	EFIConst          EHCI_64BIT_CAP 
syn keyword	EFIConst          EHCI_ALL_LEGACY_SMI 
syn keyword	EFIConst          EHCI_ALL_SMI 
syn keyword	EFIConst          EHCI_ASP_CAP 
syn keyword	EFIConst          EHCI_ASYNCLISTADDR 
syn keyword	EFIConst          EHCI_ASYNC_ADVANCE_SMI 
syn keyword	EFIConst          EHCI_ASYNC_ADVANCE_SMI_STS 
syn keyword	EFIConst          EHCI_ASYNC_SCHED_ENABLE 
syn keyword	EFIConst          EHCI_ASYNC_SCHED_STATUS 
syn keyword	EFIConst          EHCI_CAP_ID 
syn keyword	EFIConst          EHCI_CONFIGFLAG 
syn keyword	EFIConst          EHCI_CONNECTSTATUSCHANGE 
syn keyword	EFIConst          EHCI_CTRLDSSEGMENT 
syn keyword	EFIConst          EHCI_CURRENTCONNECTSTATUS 
syn keyword	EFIConst          EHCI_DEBUG_N 
syn keyword	EFIConst          EHCI_DMINUSBIT 
syn keyword	EFIConst          EHCI_DPLUSBIT 
syn keyword	EFIConst          EHCI_EECP 
syn keyword	EFIConst          EHCI_ERROR_SMI 
syn keyword	EFIConst          EHCI_ERROR_SMI_STS 
syn keyword	EFIConst          EHCI_FLRINT_EN 
syn keyword	EFIConst          EHCI_FORCEPORTRESUME 
syn keyword	EFIConst          EHCI_FRAMELISTSIZE 
syn keyword	EFIConst          EHCI_FRAME_LIST_ROLLOVER 
syn keyword	EFIConst          EHCI_FRAME_LIST_ROLL_OVER_SMI 
syn keyword	EFIConst          EHCI_FRAME_LIST_ROLL_OVER_SMI_STS 
syn keyword	EFIConst          EHCI_FRINDEX 
syn keyword	EFIConst          EHCI_FRM1024 
syn keyword	EFIConst          EHCI_FRM256 
syn keyword	EFIConst          EHCI_FRM512 
syn keyword	EFIConst          EHCI_HCCPARAMS 
syn keyword	EFIConst          EHCI_HCHALTED 
syn keyword	EFIConst          EHCI_HCRESET 
syn keyword	EFIConst          EHCI_HCSPARAMS 
syn keyword	EFIConst          EHCI_HCSP_PORTROUTE 
syn keyword	EFIConst          EHCI_HC_BIOS 
syn keyword	EFIConst          EHCI_HC_OS 
syn keyword	EFIConst          EHCI_HOST_SYSTEM_ERROR 
syn keyword	EFIConst          EHCI_HOST_SYSTEM_ERROR_SMI 
syn keyword	EFIConst          EHCI_HSEINT_EN 
syn keyword	EFIConst          EHCI_IAAINT_EN 
syn keyword	EFIConst          EHCI_INTTHRESHOLD 
syn keyword	EFIConst          EHCI_INT_ASYNC_ADVANCE 
syn keyword	EFIConst          EHCI_INT_ASYNC_ADVANCE_ENABLE 
syn keyword	EFIConst          EHCI_IST 
syn keyword	EFIConst          EHCI_LEGACY_CTRL_STS_REG 
syn keyword	EFIConst          EHCI_LEGACY_REG 
syn keyword	EFIConst          EHCI_LINE_STATUS 
syn keyword	EFIConst          EHCI_NEXT_EECP 
syn keyword	EFIConst          EHCI_N_CC 
syn keyword	EFIConst          EHCI_N_PCC 
syn keyword	EFIConst          EHCI_N_PORTS 
syn keyword	EFIConst          EHCI_OVERCURRENTACTIVE 
syn keyword	EFIConst          EHCI_OVERCURRENTCAHGE 
syn keyword	EFIConst          EHCI_OWNERSHIP_CHANGE_SMI 
syn keyword	EFIConst          EHCI_OWNERSHIP_CHANGE_SMI_STS 
syn keyword	EFIConst          EHCI_PCDINT_EN 
syn keyword	EFIConst          EHCI_PCI_TRAP_SMI 
syn keyword	EFIConst          EHCI_PERIODICLISTBASE 
syn keyword	EFIConst          EHCI_PER_SCHED_ENABLE 
syn keyword	EFIConst          EHCI_PER_SCHED_STATUS 
syn keyword	EFIConst          EHCI_PFLFLAG 
syn keyword	EFIConst          EHCI_POINTER_MASK 
syn keyword	EFIConst          EHCI_PORTENABLE 
syn keyword	EFIConst          EHCI_PORTENABLESTATUSCHANGE 
syn keyword	EFIConst          EHCI_PORTOWNER 
syn keyword	EFIConst          EHCI_PORTPOWER 
syn keyword	EFIConst          EHCI_PORTRESET 
syn keyword	EFIConst          EHCI_PORTSC 
syn keyword	EFIConst          EHCI_PORT_CHANGE_DETECT 
syn keyword	EFIConst          EHCI_PORT_CHANGE_SMI 
syn keyword	EFIConst          EHCI_PORT_CHANGE_STS 
syn keyword	EFIConst          EHCI_PPC 
syn keyword	EFIConst          EHCI_PRR 
syn keyword	EFIConst          EHCI_P_INDICATOR 
syn keyword	EFIConst          EHCI_QUEUE_HEAD 
syn keyword	EFIConst          EHCI_RECLAIM 
syn keyword	EFIConst          EHCI_RUNSTOP 
syn keyword	EFIConst          EHCI_SMI 
syn keyword	EFIConst          EHCI_SMI_HOST_SYSTEM_ERROR 
syn keyword	EFIConst          EHCI_SMI_ON_BAR 
syn keyword	EFIConst          EHCI_SMI_ON_BAR_STS 
syn keyword	EFIConst          EHCI_SMI_PCI_COMMAND 
syn keyword	EFIConst          EHCI_SMI_PCI_COMMAND_STS 
syn keyword	EFIConst          EHCI_SMI_STS 
syn keyword	EFIConst          EHCI_SUSPEND 
syn keyword	EFIConst          EHCI_TERMINATE 
syn keyword	EFIConst          EHCI_USBCMD 
syn keyword	EFIConst          EHCI_USBERRINT_EN 
syn keyword	EFIConst          EHCI_USBINTR 
syn keyword	EFIConst          EHCI_USBINT_EN 
syn keyword	EFIConst          EHCI_USBSTS 
syn keyword	EFIConst          EHCI_USB_ERROR_INTERRUPT 
syn keyword	EFIConst          EHCI_USB_INTERRUPT 
syn keyword	EFIConst          EHCI_VERCAPLENGTH 
syn keyword	EFIConst          EHCI_WKCNNT_E 
syn keyword	EFIConst          EHCI_WKDSCNNT_E 
syn keyword	EFIConst          EHCI_WKOC_E 
syn keyword	EFIConst          MAX_EHCI_DATA_SIZE 
syn keyword	EFIConst          QH_CONTROL_ENDPOINT 
syn keyword	EFIConst          QH_DATA_TOGGLE 
syn keyword	EFIConst          QH_DATA_TOGGLE_CONTROL 
syn keyword	EFIConst          QH_ENDPOINT_SPEED 
syn keyword	EFIConst          QH_FULL_SPEED 
syn keyword	EFIConst          QH_HEAD_OF_LIST 
syn keyword	EFIConst          QH_HIGH_SPEED 
syn keyword	EFIConst          QH_IGNORE_QTD_DT 
syn keyword	EFIConst          QH_I_BIT 
syn keyword	EFIConst          QH_LOW_SPEED 
syn keyword	EFIConst          QH_MULT_SETTING 
syn keyword	EFIConst          QH_ONE_XFER 
syn keyword	EFIConst          QH_THREE_XFER 
syn keyword	EFIConst          QH_TWO_XFER 
syn keyword	EFIConst          QH_USE_QTD_DT 
syn keyword	EFIConst          QTD_ACTIVE 
syn keyword	EFIConst          QTD_BABBLE 
syn keyword	EFIConst          QTD_BUFFER_ERROR 
syn keyword	EFIConst          QTD_COMPLETE_SPLIT 
syn keyword	EFIConst          QTD_DATA0_TOGGLE 
syn keyword	EFIConst          QTD_DATA1_TOGGLE 
syn keyword	EFIConst          QTD_DATA_TOGGLE 
syn keyword	EFIConst          QTD_DIRECTION_PID 
syn keyword	EFIConst          QTD_DO_OUT 
syn keyword	EFIConst          QTD_DO_PING 
syn keyword	EFIConst          QTD_ERROR_COUNT 
syn keyword	EFIConst          QTD_HALTED 
syn keyword	EFIConst          QTD_IN_TOKEN 
syn keyword	EFIConst          QTD_IOC_BIT 
syn keyword	EFIConst          QTD_MISSED_UFRAME 
syn keyword	EFIConst          QTD_NO_ERRORS 
syn keyword	EFIConst          QTD_ONE_ERROR 
syn keyword	EFIConst          QTD_OUT_TOKEN 
syn keyword	EFIConst          QTD_PING_STATE 
syn keyword	EFIConst          QTD_SETUP_TOGGLE 
syn keyword	EFIConst          QTD_SETUP_TOKEN 
syn keyword	EFIConst          QTD_SPLIT_ERROR 
syn keyword	EFIConst          QTD_SPLIT_XSTATE 
syn keyword	EFIConst          QTD_START_SPLIT 
syn keyword	EFIConst          QTD_STATUS_FIELD 
syn keyword	EFIConst          QTD_STATUS_TOGGLE 
syn keyword	EFIConst          QTD_THREE_ERRORS 
syn keyword	EFIConst          QTD_TWO_ERRORS 
syn keyword	EFIConst          QTD_XACT_ERROR 
syn keyword	EFIConst          QTD_XFER_DATA_SIZE 
" XHCI
syn keyword	EFIConst          CRCR_RING_CYCLE_STATE 
syn keyword	EFIConst          EP_DESC_FLAG_TYPE_BITS 
syn keyword	EFIConst          EP_DESC_FLAG_TYPE_BULK 
syn keyword	EFIConst          EP_DESC_FLAG_TYPE_CONT 
syn keyword	EFIConst          EP_DESC_FLAG_TYPE_INT 
syn keyword	EFIConst          EP_DESC_FLAG_TYPE_ISOC 
syn keyword	EFIConst          MAX_CONTROL_DATA_SIZE 
syn keyword	EFIConst          PEI_RECOVERY_USB_XHCI_DEV_FROM_THIS 
syn keyword	EFIConst          PEI_XHCI_MAX_SLOTS 
syn keyword	EFIConst          RING_SIZE 
syn keyword	EFIConst          RING_SIZE 
syn keyword	EFIConst          TRBS_PER_SEGMENT 
syn keyword	EFIConst          TRBS_PER_SEGMENT 
syn keyword	EFIConst          XHCI_BOT_MAX_XFR_SIZE 
syn keyword	EFIConst          XHCI_BOT_TD_MAXSIZE 
syn keyword	EFIConst          XHCI_BULK_COMPLETE_TIMEOUT_MS 
syn keyword	EFIConst          XHCI_CMD_COMPLETE_TIMEOUT_MS 
syn keyword	EFIConst          XHCI_CTL_COMPLETE_TIMEOUT_MS 
syn keyword	EFIConst          XHCI_DEVICE_CONTEXT_ENTRIES 
syn keyword	EFIConst          XHCI_DEVSPEED_FULL 
syn keyword	EFIConst          XHCI_DEVSPEED_HIGH 
syn keyword	EFIConst          XHCI_DEVSPEED_LOW 
syn keyword	EFIConst          XHCI_DEVSPEED_SUPER 
syn keyword	EFIConst          XHCI_DEVSPEED_UNDEFINED 
syn keyword	EFIConst          XHCI_EPTYPE_BULK_IN 
syn keyword	EFIConst          XHCI_EPTYPE_BULK_OUT 
syn keyword	EFIConst          XHCI_EPTYPE_CTL 
syn keyword	EFIConst          XHCI_EPTYPE_INT_IN 
syn keyword	EFIConst          XHCI_EPTYPE_INT_OUT 
syn keyword	EFIConst          XHCI_EPTYPE_ISOCH_IN 
syn keyword	EFIConst          XHCI_EPTYPE_ISOCH_OUT 
syn keyword	EFIConst          XHCI_EPTYPE_NOT_VALID 
syn keyword	EFIConst          XHCI_EP_STATE_DISABLED 
syn keyword	EFIConst          XHCI_EP_STATE_ERROR 
syn keyword	EFIConst          XHCI_EP_STATE_HALTED 
syn keyword	EFIConst          XHCI_EP_STATE_RUNNING 
syn keyword	EFIConst          XHCI_EP_STATE_STOPPED 
syn keyword	EFIConst          XHCI_EP_TYPE_BLK_IN 
syn keyword	EFIConst          XHCI_EP_TYPE_BLK_OUT 
syn keyword	EFIConst          XHCI_EP_TYPE_CONTROL 
syn keyword	EFIConst          XHCI_EP_TYPE_INT_IN 
syn keyword	EFIConst          XHCI_EP_TYPE_INT_OUT 
syn keyword	EFIConst          XHCI_EP_TYPE_ISO_IN 
syn keyword	EFIConst          XHCI_EP_TYPE_ISO_OUT 
syn keyword	EFIConst          XHCI_EP_TYPE_NOTVALID 
syn keyword	EFIConst          XHCI_FIXED_DELAY_15MCS 
syn keyword	EFIConst          XHCI_FIXED_DELAY_MS 
syn keyword	EFIConst          XHCI_IMODI 
syn keyword	EFIConst          XHCI_INPUT_CONTEXT_ENTRIES 
syn keyword	EFIConst          XHCI_INT_COMPLETE_TIMEOUT_MS 
syn keyword	EFIConst          XHCI_PCI_ADDRESS 
syn keyword	EFIConst          XHCI_PCI_FLADJ 
syn keyword	EFIConst          XHCI_PCI_SBRN 
syn keyword	EFIConst          XHCI_PCS_CCS 
syn keyword	EFIConst          XHCI_PCS_CSC 
syn keyword	EFIConst          XHCI_PCS_OCA 
syn keyword	EFIConst          XHCI_PCS_PED 
syn keyword	EFIConst          XHCI_PCS_PP 
syn keyword	EFIConst          XHCI_PCS_PR 
syn keyword	EFIConst          XHCI_PCS_PRC 
syn keyword	EFIConst          XHCI_PORTSC_OFFSET 
syn keyword	EFIConst          XHCI_PORT_CONNECT 
syn keyword	EFIConst          XHCI_PORT_ENABLE 
syn keyword	EFIConst          XHCI_PORT_RESET 
syn keyword	EFIConst          XHCI_PORT_RESET_CHG 
syn keyword	EFIConst          XHCI_SLOT_STATE_ADDRESSED 
syn keyword	EFIConst          XHCI_SLOT_STATE_CONFIGURED 
syn keyword	EFIConst          XHCI_SLOT_STATE_DEFAULT 
syn keyword	EFIConst          XHCI_SLOT_STATE_DISABLED 
syn keyword	EFIConst          XHCI_STS_EVT_INTERRUPT 
syn keyword	EFIConst          XHCI_STS_HALTED 
syn keyword	EFIConst          XHCI_STS_HOSTSYSTEM_ERROR 
syn keyword	EFIConst          XHCI_STS_PCD 
syn keyword	EFIConst          XHCI_SWITCH2SS_DELAY_MS 
syn keyword	EFIConst          XHCI_TRB_BABBLE_ERROR 
syn keyword	EFIConst          XHCI_TRB_BANDWIDTHOVERRUN_ERROR 
syn keyword	EFIConst          XHCI_TRB_BANDWIDTH_ERROR 
syn keyword	EFIConst          XHCI_TRB_CMDRINGSTOPPED 
syn keyword	EFIConst          XHCI_TRB_COMMANDABORTED 
syn keyword	EFIConst          XHCI_TRB_CONTEXTSTATE_ERROR 
syn keyword	EFIConst          XHCI_TRB_CONTROLABORT_ERROR 
syn keyword	EFIConst          XHCI_TRB_DATABUF_ERROR 
syn keyword	EFIConst          XHCI_TRB_ENDPOINTNOTENABLED_ERROR 
syn keyword	EFIConst          XHCI_TRB_EVENTLOST_ERROR 
syn keyword	EFIConst          XHCI_TRB_EVENTRINGFULL_ERROR 
syn keyword	EFIConst          XHCI_TRB_EXECUTION_TIMEOUT_ERROR 
syn keyword	EFIConst          XHCI_TRB_INVALID 
syn keyword	EFIConst          XHCI_TRB_INVALIDSTREAMID_ERROR 
syn keyword	EFIConst          XHCI_TRB_INVALIDSTREAMTYPE_ERROR 
syn keyword	EFIConst          XHCI_TRB_ISOCHBUFOVERRUN 
syn keyword	EFIConst          XHCI_TRB_MISSEDSERVICE_ERROR 
syn keyword	EFIConst          XHCI_TRB_NOPINGRESPONSE_ERROR 
syn keyword	EFIConst          XHCI_TRB_OUTOFSLOTS_ERROR 
syn keyword	EFIConst          XHCI_TRB_PARAMETER_ERROR 
syn keyword	EFIConst          XHCI_TRB_RESOURCE_ERROR 
syn keyword	EFIConst          XHCI_TRB_RINGOVERRUN 
syn keyword	EFIConst          XHCI_TRB_RINGUNDERRUN 
syn keyword	EFIConst          XHCI_TRB_SECONDARYBANDWIDTH_ERROR 
syn keyword	EFIConst          XHCI_TRB_SHORTPACKET 
syn keyword	EFIConst          XHCI_TRB_SLOTNOTENABLED_ERROR 
syn keyword	EFIConst          XHCI_TRB_SPLITTRANSACTION_ERROR 
syn keyword	EFIConst          XHCI_TRB_STALL_ERROR 
syn keyword	EFIConst          XHCI_TRB_STOPPED 
syn keyword	EFIConst          XHCI_TRB_STOPPEDLENGTHINVALID 
syn keyword	EFIConst          XHCI_TRB_SUCCESS 
syn keyword	EFIConst          XHCI_TRB_TRANSACTION_ERROR 
syn keyword	EFIConst          XHCI_TRB_TRB_ERROR 
syn keyword	EFIConst          XHCI_TRB_UNDEFINED_ERROR 
syn keyword	EFIConst          XHCI_TRB_VFRINGFULL_ERROR 
syn keyword	EFIConst          XHCI_XFER_TYPE_DATA_IN 
syn keyword	EFIConst          XHCI_XFER_TYPE_DATA_OUT 
syn keyword	EFIConst          XHCI_XFER_TYPE_NO_DATA 
"--------------------------------------------------------
" EFIConst----keyword----from StatusCodes.h
syn keyword	EFIConst      AMI_BS_PC_CONFIG_RESET 
syn keyword	EFIConst      AMI_BS_PC_NVRAM_GC 
syn keyword	EFIConst      AMI_BS_PC_NVRAM_INIT 
syn keyword	EFIConst      AMI_CHIPSET_EC_BAD_BATTERY 
syn keyword	EFIConst      AMI_CHIPSET_EC_DXE_NB_ERROR 
syn keyword	EFIConst      AMI_CHIPSET_EC_DXE_SB_ERROR 
syn keyword	EFIConst      AMI_CHIPSET_EC_INTRUDER_DETECT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_HB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_NB2_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_NB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_NB_SMM_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_SB_DEVICES_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_SB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_SB_RT_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_DXE_SB_SMM_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_CAR_NB2_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_CAR_NB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_CAR_SB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_MEM_NB2_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_MEM_NB_INIT 
syn keyword	EFIConst      AMI_CHIPSET_PC_PEI_MEM_SB_INIT 
syn keyword	EFIConst      AMI_CU_HP_EC_DXE_CPU_ERROR 
syn keyword	EFIConst      AMI_CU_HP_PC_DXE_CPU_INIT 
syn keyword	EFIConst      AMI_DXE_BS_EC_BOOT_OPTION_FAILED 
syn keyword	EFIConst      AMI_DXE_BS_EC_BOOT_OPTION_LOAD_ERROR 
syn keyword	EFIConst      AMI_DXE_BS_EC_INVALID_IDE_PASSWORD 
syn keyword	EFIConst      AMI_DXE_BS_EC_INVALID_PASSWORD 
syn keyword	EFIConst      AMI_DXE_BS_PC_ACPI_INIT 
syn keyword	EFIConst      AMI_DXE_BS_PC_CSM_INIT 
syn keyword	EFIConst      AMI_DXE_CORE_EC_NO_ARCH 
syn keyword	EFIConst      AMI_DXE_CORE_PC_ARCH_READY 
syn keyword	EFIConst      AMI_PEI_CORE_EC_DXEIPL_NOT_FOUND 
syn keyword	EFIConst      AMI_PS_EC_MEMORY_INSTALLED_TWICE 
syn keyword	EFIConst      AMI_PS_EC_MEMORY_NOT_INSTALLED 
syn keyword	EFIConst      AMI_PS_EC_RESET_NOT_AVAILABLE 
syn keyword	EFIConst      AMI_PS_PC_RESET_SYSTEM 
syn keyword	EFIConst      AMI_STATUS_CODE_BEEP_CLASS 
syn keyword	EFIConst      AMI_STATUS_CODE_CLASS 
syn keyword	EFIConst      EFI_COMPUTING_UNIT 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_CACHE 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_CHIPSET 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_FIRMWARE_PROCESSOR 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_HOST_PROCESSOR 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_IO_PROCESSOR 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_MEMORY 
syn keyword	EFIConst      EFI_COMPUTING_UNIT_UNSPECIFIED 
syn keyword	EFIConst      EFI_DC_UNSPECIFIED 
syn match       EFIConst     "EFI_CU_[A-Z0-9_]*"
syn match       EFIConst     "EFI_IOB_[A-Z0-9_]*"
syn match       EFIConst     "EFI_IO_BUS[A-Z0-9_]*"
syn keyword	EFIConst      EFI_OEM_SPECIFIC 
syn keyword	EFIConst      EFI_P_EC_CONTROLLER_ERROR 
syn keyword	EFIConst      EFI_P_EC_DISABLED 
syn keyword	EFIConst      EFI_P_EC_INPUT_ERROR 
syn keyword	EFIConst      EFI_P_EC_INTERFACE_ERROR 
syn keyword	EFIConst      EFI_P_EC_NON_SPECIFIC 
syn keyword	EFIConst      EFI_P_EC_NOT_CONFIGURED 
syn keyword	EFIConst      EFI_P_EC_NOT_DETECTED 
syn keyword	EFIConst      EFI_P_EC_NOT_SUPPORTED 
syn keyword	EFIConst      EFI_P_EC_OUTPUT_ERROR 
syn keyword	EFIConst      EFI_P_EC_RESOURCE_CONFLICT 
syn keyword	EFIConst      EFI_P_KEYBOARD_EC_LOCKED 
syn keyword	EFIConst      EFI_P_KEYBOARD_EC_STUCK_KEY 
syn keyword	EFIConst      EFI_P_KEYBOARD_PC_CLEAR_BUFFER 
syn keyword	EFIConst      EFI_P_KEYBOARD_PC_SELF_TEST 
syn keyword	EFIConst      EFI_P_MOUSE_EC_LOCKED 
syn keyword	EFIConst      EFI_P_MOUSE_PC_SELF_TEST 
syn keyword	EFIConst      EFI_P_PC_DETECTED 
syn keyword	EFIConst      EFI_P_PC_DISABLE 
syn keyword	EFIConst      EFI_P_PC_ENABLE 
syn keyword	EFIConst      EFI_P_PC_INIT 
syn keyword	EFIConst      EFI_P_PC_PRESENCE_DETECT 
syn keyword	EFIConst      EFI_P_PC_RECONFIG 
syn keyword	EFIConst      EFI_P_PC_RESET 
syn keyword	EFIConst      EFI_P_SERIAL_PORT_PC_CLEAR_BUFFER 
syn keyword	EFIConst      EFI_SOFTWARE 
syn keyword	EFIConst      EFI_STATUS_CODE_DATA_TYPE_STRING_GUID 
syn keyword	EFIConst      EFI_STATUS_CODE_SPECIFIC_DATA_GUID 
syn keyword	EFIConst      EFI_SUBCLASS_SPECIFIC 
syn keyword	EFIConst      EFI_SW_AL_PC_ENTRY_POINT 
syn keyword	EFIConst      EFI_SW_AL_PC_RETURN_TO_LAST 
syn keyword	EFIConst      EFI_NATIVE_INTERFACE 

"--------------------------------------------------------
"}}}
"--------------------------------------------------------
" EFIConst----keyword---- {{{3
syn keyword	EFIConst      EFI_HOB_HANDOFF_TABLE_VERSION 
syn keyword	EFIConst      EFI_HOB_TYPE_CPU 
syn keyword	EFIConst      EFI_HOB_TYPE_CV 
syn keyword	EFIConst      EFI_HOB_TYPE_END_OF_HOB_LIST 
syn keyword	EFIConst      EFI_HOB_TYPE_FV 
syn keyword	EFIConst      EFI_HOB_TYPE_GUID_EXTENSION 
syn keyword	EFIConst      EFI_HOB_TYPE_HANDOFF 
syn keyword	EFIConst      EFI_HOB_TYPE_MEMORY_ALLOCATION 
syn keyword	EFIConst      EFI_HOB_TYPE_MEMORY_POOL 
syn keyword	EFIConst      EFI_HOB_TYPE_RESOURCE_DESCRIPTOR 
syn keyword	EFIConst      EFI_HOB_TYPE_UNUSED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_16_BIT_IO 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_32_BIT_IO 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_64_BIT_IO 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_ECC_RESERVED_1 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_ECC_RESERVED_2 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_EXECUTION_PROTECTED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_INITIALIZED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_MULTIPLE_BIT_ECC 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_PRESENT 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_READ_PROTECTED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_SINGLE_BIT_ECC 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_TESTED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_UNCACHED_EXPORTED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_WRITE_PROTECTED 
syn keyword	EFIConst      EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE 
syn keyword	EFIConst      EFI_RESOURCE_FIRMWARE_DEVICE 
syn keyword	EFIConst      EFI_RESOURCE_IO 
syn keyword	EFIConst      EFI_RESOURCE_IO_RESERVED 
syn keyword	EFIConst      EFI_RESOURCE_MAX_MEMORY_TYPE 
syn keyword	EFIConst      EFI_RESOURCE_MEMORY_MAPPED_IO 
syn keyword	EFIConst      EFI_RESOURCE_MEMORY_MAPPED_IO_PORT 
syn keyword	EFIConst      EFI_RESOURCE_MEMORY_RESERVED 
syn keyword	EFIConst      EFI_RESOURCE_SYSTEM_MEMORY 
syn keyword	EFIConst      PCIEBRS_REG_SVID ME_REG_SVID 
" }}}
"--------------------------------------------------------
" }}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFIType {{{2
"--------------------------------------------------------
" EFIType --- match{{{3
" ---Handle
syn match       EFIType     "\h*_HANDLE"
" ---Protocol
syn match       EFIType     "\h*_PROTOCOL"
syn match       EFIType     "EFI_\h*PROTOCOL"
syn match       EFIType     "EFI_\h*PROTOCOL_\h*"

" ---Event
syn match       EFIType     "\h*_EVENT"
" ---DATA
syn match       EFIType     "\h*_DATA[^A-Z_) ]*"
" ---Struct
"syn match       EFIType     ""
" ---TYPE
syn match       EFIType     "EFI_\h*_TYPE[^_]"
" ---Header
syn match       EFIType     "\h*_HDR"
" ---TPM Typedef
syn match       EFIType     "TPM_\h*"
" ---HOB
syn match	EFIType     "EFI_HOB\h*TYPE"
syn match	EFIType     "EFI_HOB\h*TYPE\h*"
"Plugin Setting
syn match	EFIType     "EFI_\h*_HOB\h*"
syn match	EFIUNDEF     "EFI\h*_HOB_"
" ---Point
syn match       EFIType     "\h*_POINT"
" ---Pointers
syn match       EFIType     "\h*_POINTERS"
" PEI
syn match       EFITYPE     "EFI_PEI[_a-zA-Z0-9]+"
"syn match       EFITYPE     "PEI_\h*"
syn match       EFITYPE     "EFI_PEIM_\h*"
syn match       EFIDefine   "PEI_SERVICES_\h*"
syn match       EFIDefine     "^(\S*_HOB"
syn match       EFIDefine     "^(\S*_HOB_\h*"
syn match	EFIType     "EFI_[A-Z_]*_PPI"
syn match	EFIType     "[A-Z_]*_PPI"
" bug
syn match       EFIDefine     "EFI_\h*_DESCRIPTOR_[a-zA-Z0-9_]*"
syn match	EFIType     "EFI_\h*_DESCRIPTOR"
syn match	EFIType     "EFI_\S*SIGNATURE"
syn match	EFIType     "EFI_\S*REVISION"
syn match	EFIType     "EFI_\S*SPACE"
syn match	EFIType     "EFI_\S*ATTRIBUTES"
syn match	EFIType     "EFI_\S*HEADER"
syn match	EFIType     "EFI_\S*HEADERS"
syn match	EFIType     "EFI_\S*MAP"
syn match	EFIType     "EFI_\S*DISPATCH"
syn match	EFIType     "EFI_\S*TRUST"
syn match	EFIType     "\h*_VOLUME"
syn match	EFIType     "\h*_VOLUME_\h*"
syn match	EFIType     "EFI_\S*SCHEDULE"
syn match	EFIType     "EFI_\S*SERVICES"
syn match	EFIType     "EFI_\S*SERVICES_\h*"
syn match	EFIType     "EFI_\S*TABLE"
syn match       EFIType     "EFI_\S*CONTEXT"
syn match       EFIType     "EFI_RESOURCE\S*TYPE"
syn match       EFIType     "EFI_\S*ENTRY\h*"
syn match       EFIType     "[A-Z_]*_ENTRY"
syn match       EFIType     "EFI_\h*_STRING"
syn match	EFIType     "EFI_\h*_HEADER"
" MAP
syn match       EFIType     "\h*MAP\s"
" SMBIOS
syn match       EFIType     "SMBIOS_\h*_INFO"
syn match       EFIType     "SMBIOS_\h*_HEADER"
syn match       EFIType     "SMBIOS_NVRAM_\h*"
" PCI
syn match       EFIType     "PCI_[A-Z0-9_]*_REG"
syn match       EFIType     "[A-Z0-9_]*_STRUCT"
syn match       EFIType     "[A-Z0-9_]*_STRUCTURE"
" Device Path
syn match       EFIType     "[A-Z0-9_v]*_DEVICE_PATH"
syn match       EFIType     "[a-zA-Z0-9_]*_TYPE"
" RTC
syn match       EFIType     "RTC_REG_[A-D]"
syn match       EFIType     "RTC_[A-Z]*_ALARM_REG"
" }}}
"--------------------------------------------------------
" EFIType---Keyword{{{3
syn keyword	EFIType     EFI_LBA 
syn keyword	EFIType     EFI_TPL 
syn keyword	EFIType     EFI_MAC_ADDRESS 
syn keyword	EFIType     EFI_IPv4_ADDRESS 
syn keyword	EFIType     EFI_IPv6_ADDRESS 
syn keyword	EFIType     EFI_IP_ADDRESS 
syn keyword	EFIType     EFI_ALLOCATE_TYPE 
syn keyword	EFIType     EFI_MEMORY_TYPE 
syn keyword	EFIType     EFI_PHYSICAL_ADDRESS 
syn keyword	EFIType     EFI_VIRTUAL_ADDRESS 
syn keyword	EFIType     EFI_MEMORY_DESCRIPTOR 
syn keyword	EFIType     PEI_CORE_INSTANCE 
syn keyword	EFIType     EFI_TABLE_HEADER 
syn keyword	EFIType     EFI_RAISE_TPL 
syn keyword	EFIType     EFI_RESTORE_TPL 
syn keyword	EFIType     EFI_ALLOCATE_PAGES 
syn keyword	EFIType     EFI_FREE_PAGES 
syn keyword	EFIType     EFI_GET_MEMORY_MAP 
syn keyword	EFIType     EFI_ALLOCATE_POOL 
syn keyword	EFIType     EFI_FREE_POOL 
syn keyword	EFIType     EFI_EVENT_NOTIFY 
syn keyword	EFIType     EFI_CREATE_EVENT 
syn keyword	EFIType     EFI_TIMER_DELAY 
syn keyword	EFIType     EFI_SET_TIMER 
syn keyword	EFIType     EFI_WAIT_FOR_EVENT 
syn keyword	EFIType     EFI_SIGNAL_EVENT 
syn keyword	EFIType     EFI_CLOSE_EVENT 
syn keyword	EFIType     EFI_CHECK_EVENT 
syn keyword	EFIType     EFI_INTERFACE_TYPE 
syn keyword	EFIType     EFI_INSTALL_PROTOCOL_INTERFACE 
syn keyword	EFIType     EFI_REINSTALL_PROTOCOL_INTERFACE 
syn keyword	EFIType     EFI_UNINSTALL_PROTOCOL_INTERFACE 
syn keyword	EFIType     EFI_HANDLE_PROTOCOL 
syn keyword	EFIType     EFI_REGISTER_PROTOCOL_NOTIFY 
syn keyword	EFIType     EFI_LOCATE_SEARCH_TYPE 
syn keyword	EFIType     EFI_LOCATE_HANDLE 
syn keyword	EFIType     EFI_DEVICE_PATH_PROTOCOL 
syn keyword	EFIType     EFI_LOCATE_DEVICE_PATH 
syn keyword	EFIType     EFI_INSTALL_CONFIGURATION_TABLE 
syn keyword	EFIType     EFI_IMAGE_LOAD 
syn keyword	EFIType     EFI_IMAGE_START 
syn keyword	EFIType     EFI_EXIT 
syn keyword	EFIType     EFI_IMAGE_UNLOAD 
syn keyword	EFIType     EFI_EXIT_BOOT_SERVICES 
syn keyword	EFIType     EFI_GET_NEXT_MONOTONIC_COUNT 
syn keyword	EFIType     EFI_STALL 
syn keyword	EFIType     EFI_SET_WATCHDOG_TIMER 
syn keyword	EFIType     EFI_CONNECT_CONTROLLER 
syn keyword	EFIType     EFI_DISCONNECT_CONTROLLER 
syn keyword	EFIType     EFI_OPEN_PROTOCOL 
syn keyword	EFIType     EFI_CLOSE_PROTOCOL 
syn keyword	EFIType     EFI_OPEN_PROTOCOL_INFORMATION_ENTRY 
syn keyword	EFIType     EFI_OPEN_PROTOCOL_INFORMATION 
syn keyword	EFIType     EFI_PROTOCOLS_PER_HANDLE 
syn keyword	EFIType     EFI_LOCATE_HANDLE_BUFFER 
syn keyword	EFIType     EFI_LOCATE_PROTOCOL 
syn keyword	EFIType     EFI_INSTALL_MULTIPLE_PROTOCOL_INTERFACES 
syn keyword	EFIType     EFI_UNINSTALL_MULTIPLE_PROTOCOL_INTERFACES 
syn keyword	EFIType     EFI_CALCULATE_CRC32 
syn keyword	EFIType     EFI_COPY_MEM 
syn keyword	EFIType     EFI_SET_MEM 
syn keyword	EFIType     EFI_CREATE_EVENT_EX 
syn keyword	EFIType     EFI_BOOT_SERVICES 
syn keyword	EFIType     EFI_TIME 
syn keyword	EFIType     EFI_TIME_CAPABILITIES 
syn keyword	EFIType     EFI_GET_TIME 
syn keyword	EFIType     EFI_SET_TIME 
syn keyword	EFIType     EFI_GET_WAKEUP_TIME 
syn keyword	EFIType     EFI_SET_WAKEUP_TIME 
syn keyword	EFIType     EFI_SET_VIRTUAL_ADDRESS_MAP 
syn keyword	EFIType     EFI_CONVERT_POINTER 
syn keyword	EFIType     EFI_GET_VARIABLE 
syn keyword	EFIType     EFI_GET_NEXT_VARIABLE_NAME 
syn keyword	EFIType     EFI_SET_VARIABLE 
syn keyword	EFIType     EFI_GET_NEXT_HIGH_MONO_COUNT 
syn keyword	EFIType     EFI_RESET_TYPE 
syn keyword	EFIType     EFI_RESET_SYSTEM 
syn keyword	EFIType     EFI_STATUS_CODE_TYPE 
syn keyword	EFIType     EFI_STATUS_CODE_VALUE 
syn keyword	EFIType     EFI_STATUS_CODE_DATA 
syn keyword	EFIType     EFI_REPORT_STATUS_CODE 
syn keyword	EFIType     EFI_CAPSULE_BLOCK_DESCRIPTOR 
syn keyword	EFIType     EFI_CAPSULE_HEADER 
syn keyword	EFIType     EFI_UPDATE_CAPSULE 
syn keyword	EFIType     EFI_QUERY_CAPSULE_CAPABILITIES 
syn keyword	EFIType     EFI_QUERY_VARIABLE_INFO 
syn keyword	EFIType     EFI_RUNTIME_SERVICES 
syn keyword	EFIType     EFI_CONFIGURATION_TABLE 
syn keyword	EFIType     EFI_SIMPLE_TEXT_INPUT_PROTOCOL 
syn keyword	EFIType     EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL 
syn keyword	EFIType     EFI_IMAGE_ENTRY_POINT 
syn keyword	EFIType     EFI_BOOT_MODE 
syn keyword	EFIType     EFI_LOAD_OPTION 
syn keyword	EFIType     HOT_KEY_EFI_KEY_DATA 
syn keyword	EFIType     EFI_KEY_OPTION
syn keyword	EFIType     NVRAM_VARIABLE
syn keyword	EFIType     IHANDLE
" ADDR
syn keyword	EFIType     ACPI_ADDR IO_ADDR MEM_ADDR PCIE_ADDR TCO_ADDR GPIO_ADDR
syn keyword	EFIType      PEI_EHCI_DEV 
syn keyword	EFIType     PCI_BUS_DEV_FUNCTION
" XHCI
syn keyword	EFIType          HCPARAMS 
syn keyword	EFIType          HCPARAMS1 
syn keyword	EFIType          HCPARAMS2 
syn keyword	EFIType          HCPARAMS3 
syn keyword	EFIType          PCI_BUS_DEV_FUNCTION 
syn keyword	EFIType          PCI_DEV_REGISTER_VALUE 
syn keyword	EFIType          PEI_XHCI_SLOTADDR_MAP 
syn keyword	EFIType          TRB_RING 
syn keyword	EFIType          TRB_TYPE 
syn keyword	EFIType          USB3_CONTROLLER 
syn keyword	EFIType          XHCI_ADDRESSDEV_CMD_TRB 
syn keyword	EFIType          XHCI_BANDWIDTHRQ_EVT_TRB 
syn keyword	EFIType          XHCI_CMDCOMPLETE_EVT_TRB 
syn keyword	EFIType          XHCI_CMD_TRB 
syn keyword	EFIType          XHCI_COMMON_CMD_TRB 
syn keyword	EFIType          XHCI_CRCR 
syn keyword	EFIType          XHCI_DATA_XFR_TRB 
syn keyword	EFIType          XHCI_DCBAA 
syn keyword	EFIType          XHCI_DEVICE_CONTEXT 
syn keyword	EFIType          XHCI_DEVNOTIFY_EVT_TRB 
syn keyword	EFIType          XHCI_DISABLESLOT_CMD_TRB 
syn keyword	EFIType          XHCI_DORBELL_EVT_TRB 
syn keyword	EFIType          XHCI_EP_CONTEXT 
syn keyword	EFIType          XHCI_ER_SEGMENT_ENTRY 
syn keyword	EFIType          XHCI_EVENT_TRB 
syn keyword	EFIType          XHCI_HC_CAP_REGS 
syn keyword	EFIType          XHCI_HC_EVT_TRB 
syn keyword	EFIType          XHCI_HC_OP_REGS 
syn keyword	EFIType          XHCI_HC_RT_REGS 
syn keyword	EFIType          XHCI_INPUT_CONTEXT 
syn keyword	EFIType          XHCI_INPUT_CONTROL_CONTEXT 
syn keyword	EFIType          XHCI_INTERRUPTER_REGS 
syn keyword	EFIType          XHCI_ISOCH_XFR_TRB 
syn keyword	EFIType          XHCI_LINK_TRB 
syn keyword	EFIType          XHCI_MFINDXWRAP_EVT_TRB 
syn keyword	EFIType          XHCI_NOOP_XFR_TRB 
syn keyword	EFIType          XHCI_NORMAL_XFR_TRB 
syn keyword	EFIType          XHCI_PORTSC 
syn keyword	EFIType          XHCI_PORTSTSCHG_EVT_TRB 
syn keyword	EFIType          XHCI_RESET_EP_CMD_TRB 
syn keyword	EFIType          XHCI_SETUP_XFR_TRB 
syn keyword	EFIType          XHCI_SET_TRPTR_CMD_TRB 
syn keyword	EFIType          XHCI_SLOT_CONTEXT 
syn keyword	EFIType          XHCI_STATUS_XFR_TRB 
syn keyword	EFIType          XHCI_TRANSFER_EVT_TRB 
syn keyword	EFIType          XHCI_TRB 
syn keyword	EFIType          XHCI_USBCMD 
syn keyword	EFIType          XHCI_USBSTS 
syn keyword	EFIType          XHCI_XFR_TRB 
syn keyword	EFIType          PROTOCOL_INTERFACE 
syn keyword	EFIType          EFI_SEC_PEI_HAND_OFF 


" }}}
"--------------------------------------------------------
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFIGUID {{{2
" EFIGUID --- match
syn match       EFIGUID     "\h*GUID[^A-Z_)]"
syn match       EFIGUID     "EFI_[A-Z0-9_]*_GUID[^)A-Z]*"
" }}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFIWarning {{{
syn keyword       EFIWarning    PEI_TRACE PCI_TRACE
syn keyword       EFIWarning    ASSERT TRACE ASSERT_IS_HANDLE
syn match         EFIWarnnig    "ASSERT\S*"
syn match         EFIWarnnig    "ASSERT\h*"
syn keyword	  EFIWarning    EFI_ERROR 
syn keyword	  EFIWarning    ASSERT_EFI_ERROR 
syn keyword	  EFIWarning    ASSERT_PEI_ERROR 
syn keyword	  EFIWarning    EFI_BREAKPOINT 
syn keyword	  EFIWarning    DEBUG_CODE DEBUG 
syn keyword	  EFIWarning    EFI_DEADLOOP CpuDeadLoop
syn keyword	  EFIWarning    DEBUG_DELL
syn keyword	  EFIWarning    PEI_DEBUG_CODE PEI_DEBUG
syn match         EFIWarnnig    "SETUP_DEBUG_\h*"
" }}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFISpecial"{{{
syn keyword     EFISpecial  EFI_STATUS 
syn keyword	EFISpecial     EFI_GUID 
syn keyword	EFISpecial     EFI_DRIVER_BINDING_PROTOCOL
syn keyword	EFISpecial     EFI_SYSTEM_TABLE 
syn match	EFISpecial     "[A-Z]*_SPECIFICATION_VERSION"
syn match	EFISpecial     "[A-Z]*_VERSION"
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFICommonType"{{{
syn keyword	EFICommonType     VOID 
syn keyword	EFICommonType     INTN 
syn keyword	EFICommonType     UINTN 
syn keyword	EFICommonType     INTN 
syn keyword	EFICommonType     UINTN 
syn keyword	EFICommonType     INT8 
syn keyword	EFICommonType     UINT8 
syn keyword	EFICommonType     INT16 
syn keyword	EFICommonType     UINT16 
syn keyword	EFICommonType     INT32 
syn keyword	EFICommonType     UINT32 
syn keyword	EFICommonType     INT64 
syn keyword	EFICommonType     UINT64 
syn keyword	EFICommonType     CHAR8 
syn keyword	EFICommonType     CHAR16 
syn keyword	EFICommonType     BOOLEAN 
syn keyword	EFICommonType     EFI_HANDLE 
syn keyword	EFICommonType     EFI_EVENT 
syn keyword	EFICommonType     VA_LIST 
syn keyword	EFICommonType     EFI_DEBUG_INFO 
syn keyword	EFICommonType     CONST 
syn keyword	EFICommonType     STATIC 
syn keyword	EFICommonType     VOLATILE 
syn keyword	EFICommonType     INIT_FUNCTION 


"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFIFunc : important EFI function needed to identified "{{{
syn keyword     EFIFunc     LocateHandle HandleProtocol LocateHandleBuffer OpenProtocol ProtocolPerHandle LocateProtocol
syn keyword     EFIFunc     InstallMultipleProtocolInterfaces 
syn keyword     EFIFunc     SetVariable GetVariable GetEfiConfigurationTable GetEfiVariable
" Macro function
syn keyword     EFIFunc     EFI_PROTOCOL_DEPENDENCY EFI_PROTOCOL_PRODUCER
syn keyword     EFIFunc     EFI_STRINGIZE EFI_PROTOCOL_DEFINITION EFI_GUID_DEFINITION EFI_PROTOCOL_CONSUMER EFI_ARCH_PROTOCOL_DEFINITION
syn keyword     EFIFunc     EFI_PPI_DEFINITION EFI_PPI_PRODUCER EFI_PPI_CONSUMER EFI_PPI_DEPENDENCY
syn keyword     EFIFunc     Status
syn keyword     EFIFunc     InitAmiLib InitializeLib
syn keyword     EFIFunc     EFI_GUID_STRING
syn keyword     EFIFunc     STRING_TOKEN
syn match       EFIFunc     "EFI_[A-Z_]*_ENTRY_POINT"
syn match       EFIFunc     "[SN]B_PCI_CFG_ADDRESS"
syn match       EFIFunc     "[SN]B_PCIE_CFG_ADDRESS"
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFITable"{{{
syn keyword     EFITable    gST gRT gBS gBds pST pRT pBS pRS gDS pDS pDXE
syn keyword     EFITable    ST RT BS Bds ST RT BS RS DS DS DXE SI SE
" DELL SMM
syn keyword     EFITable    gSmst gSmmRt gSmmServ gSMM
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFIModifier"{{{
syn keyword     EFIModifier IN OUT OPTIONAL EFIAPI EFI_BOOTSERVICE EFI_RUNTIMESERVICE EFI_BOOTSERVICE11 EFI_DXESERVICE
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syn keyword     EFIDefine     EFI_HOB_TYPE_RESOURCE_DESCRIPTOR
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EFI Constants with higher priority{{{2
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_NOTIFY_CALLBACK
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_NOTIFY_DISPATCH
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_NOTIFY_TYPES
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_PIC
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_PPI
syn keyword	EFIConst    EFI_PEI_PPI_DESCRIPTOR_TERMINATE_LIST
syn keyword	EFIConst    NULL_HANDLE
syn match       EFIConst     "[A-Z0-9_]*_SIGNATURE"
syn match       EFIConst     "EFI_SMBIOS_TYPE_[A-Z0-9_]*"
syn match       EFIConst     "CHASSIS_TYPE_[A-Z_]*"
syn match       EFIConst     "[A-Z_]*_SATAPORT_CNT"

"
" }}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Avoid matching foo::bar() in C++ by requiring that the next char is not ':'
syn cluster	cLabelGroup	contains=cUserLabel
syn match	cUserCont	display "^\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:$" contains=@cLabelGroup
syn match	cUserCont	display "^\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup
syn match	cUserCont	display ";\s*\I\i*\s*:[^:]"me=e-1 contains=@cLabelGroup

syn match	cUserLabel	display "\I\i*" contained

" Avoid recognizing most bitfields as labels
syn match	cBitField	display "^\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType
syn match	cBitField	display ";\s*\I\i*\s*:\s*[1-9]"me=e-1 contains=cType

if exists("c_minlines")
  let b:c_minlines = c_minlines
else
  if !exists("c_no_if0")
    let b:c_minlines = 50	" #if 0 constructs can be long
  else
    let b:c_minlines = 15	" mostly for () constructs
  endif
endif
if exists("c_curly_error")
  syn sync fromstart
else
  exec "syn sync ccomment cComment minlines=" . b:c_minlines
endif

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cFormat		cSpecial
hi def link cCppString		cString
hi def link cCommentL		cComment
hi def link cCommentStart	cComment
hi def link cLabel		Label
hi def link cUserLabel		Label
hi def link cConditional	Conditional
hi def link cRepeat		Repeat
hi def link cCharacter		Character
hi def link cSpecialCharacter	cSpecial
hi def link cNumber		Number
hi def link cOctal		Number
hi def link cOctalZero		PreProc	 " link this to Error if you want
hi def link cFloat		Float
hi def link cOctalError		cError
hi def link cParenError		cError
hi def link cErrInParen		cError
hi def link cErrInBracket	cError
hi def link cCommentError	cError
hi def link cCommentStartError	cError
hi def link cSpaceError		cError
hi def link cSpecialError	cError
hi def link cCurlyError		cError
hi def link cOperator		Operator
hi def link cStructure		Structure
hi def link cStorageClass	StorageClass
hi def link cInclude		Include
hi def link cPreProc		PreProc
hi def link cDefine		Macro
hi def link cIncluded		cString
hi def link cError		Error
hi def link cStatement		Statement
hi def link cPreCondit		PreCondit
hi def link cType		Type
hi def link cConstant		Constant
hi def link cCommentString	cString
hi def link cComment2String	cString
hi def link cCommentSkip	cComment
hi def link cString		String
hi def link cComment		Comment
hi def link cSpecial		SpecialChar
hi def link cTodo		Todo
hi def link cBadContinuation	Error
hi def link cCppSkip		cCppOut
hi def link cCppOut2		cCppOut
hi def link cCppOut		Comment

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 0xEuclid porting."{{{
" EFI porting
hi def link EFISpecial          operator
hi def link EFIFunc             Identifier
hi def link EFITable            Type
hi def link EFIType             Include
hi def link EFICommonType       Type
hi def link EFIModifier         Comment
hi def link EFIDefine           Special
"hi def link EFIConst            Constant
hi def link EFIConst            Delimiter 
hi def link EFIGUID             Delimiter
hi def link EFIWarning          error
"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let b:current_syntax = "c"

" vim: ts=8
" vim:fdm=marker
