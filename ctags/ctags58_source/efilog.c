/*
*   Copyright (c) 2013 Shengwei Hsu  <ShengweiHsu@ami.com.tw>
*
*   This source code is released for free distribution under the terms of the
*   GNU General Public License.
*
*   This module contains functions for generating tags for  AMI SDL(System Description Language)
*   files.
*/

/*
*   INCLUDE FILES
*/
#include "general.h"  /* must always come first */

#include <string.h>

#include "entry.h"
#include "parse.h"
#include "read.h"
#include "vstring.h"

/*
*   DATA DECLARATIONS
*/
typedef enum {
	K_UNDEFINED = -1, 
	K_ERROR, 
	K_ENTRY, 
} sdlKind;

/*
*   DATA DEFINITIONS
*/
static kindOption efilogKinds [] = {
	{ TRUE, 'x', "error",  "errors" },
	{ TRUE, 'e', "entry", "entrys" },
};

/*
*   FUNCTION DEFINITIONS
*/
/*
* Attempts to advance 's' past 'literal'.
* Returns TRUE if it did, FALSE (and leaves 's' where
* it was) otherwise.
*/
static boolean canMatch (const unsigned char** s, const char* literal)
{
	const int literal_length = strlen (literal);
	const unsigned char next_char = *(*s + literal_length);
	if (strncmp ((const char*) *s, literal, literal_length) != 0)
	{
	    return FALSE;
	}
	/* Additionally check that we're at the end of a token. */
	if ( ! (next_char == 0 || isspace (next_char) || next_char == '('))
	{
	    return FALSE;
	}
	*s += literal_length;
	return TRUE;
}

/* Advances 'cp' over leading whitespace. */
static void skipWhitespace (const unsigned char** cp)
{
	while (isspace (**cp))
	{
	    ++*cp;
	}
}


static void findEfilogTags (void)
{
    vString *name = vStringNew() ;
	const unsigned char *line;
	const unsigned char *statusStart = "[==== Status Code Available ====]";
    const unsigned char *DXE = "[==== DXE phase start ====]" ;
    const unsigned char *bbsTbl = "[==== BBS Table ====]" ;
	sdlKind kindNow = K_UNDEFINED ; 
    
    
    while ((line = fileReadLine ()) != NULL) {
		const unsigned char *cp = line;

		skipWhitespace (&cp);

		if (canMatch (&cp, "ERROR:"))
		{
		    kindNow = K_ERROR ;

            cp+=1 ;

            while (isspace ((int) *cp)) ++cp;
            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }
        }
        else if( canMatch(&cp, "DXE IPL Entry"))
        {
            kindNow = K_ENTRY ;
            cp = line ;
            while ( *cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }
        }
        else if( canMatch(&cp, "DXE Status Code Available"))
        {

            kindNow = K_ENTRY ;
            cp = DXE ;
            while ( *cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

        }
        vStringTerminate (name);
        makeSimpleTag (name, efilogKinds, kindNow);
        vStringClear (name);

		while (*cp != '\0')
		{

		    if (canMatch (&cp, ".Entry"))
            {
                kindNow = K_ENTRY ;

                cp = line ;

                while ( *cp != '\0')
                {
		            if (canMatch (&cp, ".Entry")) ; // Skip ".Entry"
                    vStringPut (name, (int) *cp);
                    ++cp;
                }
                vStringTerminate (name);
                makeSimpleTag (name, efilogKinds, kindNow);
                vStringClear (name);

                break ;
            }else if(canMatch( &cp, "Status Code Available")){

                kindNow = K_ENTRY ;
                cp = statusStart ;

                while ( *cp != '\0')
                {
                    vStringPut (name, (int) *cp);
                    ++cp;
                }
                vStringTerminate (name);
                makeSimpleTag (name, efilogKinds, kindNow);
                vStringClear (name);

                break ;
            }
            else if( canMatch(&cp, "BDS"))
            {

                kindNow = K_ENTRY ;
                
                cp = line ;
                while ( *cp != '\0')
                {
                    vStringPut (name, (int) *cp);
                    ++cp;
                }
                vStringTerminate (name);
                makeSimpleTag (name, efilogKinds, kindNow);
                vStringClear (name);

                break ;
            }
            else if( canMatch(&cp, "BBS_TABLE"))
            {
                kindNow = K_ENTRY ;
                cp = bbsTbl;
                while ( *cp != '\0')
                {
                    vStringPut (name, (int) *cp);
                    ++cp;
                }
                vStringTerminate (name);
                makeSimpleTag (name, efilogKinds, kindNow);
                vStringClear (name);

                break ;
            }


            ++cp ;
		}
	}
}

extern parserDefinition* EfilogParser (void)
{
	static const char *const extensions [] = { "efilog", "EFILOG", NULL };
	parserDefinition* def = parserNew ("efilog");
	def->kinds      = efilogKinds;
	def->kindCount  = KIND_COUNT (efilogKinds);
	def->extensions = extensions;
	def->parser     = findEfilogTags;
	return def;
}

/* vi:set tabstop=4 shiftwidth=4: */
