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
	K_TOKEN, 
	K_ELINK, 
	K_PATH, 
	K_IODEVICE,
	K_MODULE, 
	K_IRQLINK,
	K_PCIDEVICE
} sdlKind;

/*
*   DATA DEFINITIONS
*/
static kindOption sdlKinds [] = {
	{ TRUE, 't', "token",  "tokens" },
	{ TRUE, 'e', "elink", "elinks" },
	{ TRUE, 'p', "path", "paths" },
	{ TRUE, 'i', "I/O device", "I/O devices" } ,
	{ TRUE, 'm', "module", "modules" },
	{ TRUE, 'q', "IRQ link", "IRQ links" },
	{ TRUE, 'd', "PCI device", "PCI Devices" },
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


static void findSdlTags (void)
{
    vString *name = vStringNew() ;
	const unsigned char *line;

	sdlKind kindNow = K_UNDEFINED ;

	while ((line = fileReadLine ()) != NULL)
	{
		const unsigned char *cp = line;

		skipWhitespace (&cp);

		if (canMatch (&cp, "TOKEN"))
		{
		    kindNow = K_TOKEN ;
            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (isspace ((int) *cp)) ++cp;
            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }
		}
		else if (canMatch (&cp, "ELINK"))
		{
		    kindNow = K_ELINK ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }
		}
		else if (canMatch (&cp, "PATH"))
		{
		    kindNow = K_PATH ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

		}
		else if (canMatch (&cp, "MODULE"))
		{
		    kindNow = K_MODULE ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

		}
		else if (canMatch (&cp, "IRQLINK"))
		{
		    kindNow = K_IRQLINK ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

		}
		else if (canMatch (&cp, "IODEVICE"))
		{
		    kindNow = K_IODEVICE ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Name")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

		}
		else if (canMatch (&cp, "PCIDEVICE"))
		{
		    kindNow = K_PCIDEVICE ;

            do{
                cp = fileReadLine() ;
                while (isspace ((int) *cp)) ++cp;
            
            }while(!canMatch(&cp,"Title")) ;

            cp+=4 ;

            while (*cp != '\0')
            {
                vStringPut (name, (int) *cp);
                ++cp;
            }

		}

        vStringTerminate (name);
        makeSimpleTag (name, sdlKinds, kindNow);
        vStringClear (name);

		while (*cp != '\0')
		{
			/* FIXME: we don't cope with here documents,
			* or regular expression literals, or ... you get the idea.
			* Hopefully, the restriction above that insists on seeing
			* definitions at the starts of lines should keep us out of
			* mischief.
			*/
			if (isspace (*cp))
			{
				++cp;
			}
			//else if (*cp == '#')
			//{
				/* FIXME: this is wrong, but there *probably* won't be a
				* definition after an interpolated string (where # doesn't
				* mean 'comment').
				*/
			//	break;
			//}
			else if (*cp == '"')
			{
				/* Skip string literals.
				 * FIXME: should cope with escapes and interpolation.
				 */
				do {
					++cp;
				} while (*cp != 0 && *cp != '"');
			}
			else if (*cp != '\0')
			{
				do
					++cp;
				while (isalnum (*cp) || *cp == '_');
			}
		}
	}
}

extern parserDefinition* SdlParser (void)
{
	static const char *const extensions [] = { "sdl", "SDL", NULL };
	parserDefinition* def = parserNew ("Sdl");
	def->kinds      = sdlKinds;
	def->kindCount  = KIND_COUNT (sdlKinds);
	def->extensions = extensions;
	def->parser     = findSdlTags;
	return def;
}

/* vi:set tabstop=4 shiftwidth=4: */
