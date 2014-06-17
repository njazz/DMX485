//
//  dmx485 Max object
//
//  Created by Alex Nadzharov on 29/05/14.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.

#include "ext.h"							// standard Max include, always required
#include "ext_obex.h"						// required for new style Max object

#import "dm2xx.h"

////////////////////////// object struct
typedef struct _dmx485
{
	t_object	ob;
	t_atom		val;
	t_symbol	*name;
	void		*out;
} t_dmx485;

//1
void *dmx_new(t_symbol *s, long argc, t_atom *argv);
void dmx_free(t_dmx485 *x);

//2
void dmx_message(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);
void dmx_refresh(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);
void dmx_print(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);

void dmx_connect(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);
void dmx_disconnect(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);


//handle
void *dmx485_class;


//

dm2xx *dmx1;

int C74_EXPORT main(void)
{	
	t_class *c;
	
	c = class_new("dmx485", (method)dmx_new, (method)dmx_free, (long)sizeof(t_dmx485),
				  0L , A_GIMME, 0);
	
    
    class_addmethod(c, (method)dmx_message,				"list",			A_GIMME, 0);
    class_addmethod(c, (method)dmx_refresh,				"refresh",			A_GIMME, 0);
	
    class_addmethod(c, (method)dmx_print,				"print",			A_GIMME, 0);

    class_addmethod(c, (method)dmx_connect,				"connect",			A_GIMME, 0);
    class_addmethod(c, (method)dmx_disconnect,			"disconnect",		A_GIMME, 0);
	
    
	CLASS_METHOD_ATTR_PARSE(c, "identify", "undocumented", gensym("long"), 0, "1");

	CLASS_ATTR_SYM(c, "name", 0, t_dmx485, name);
	
	class_register(CLASS_BOX, c);
	dmx485_class = c;
    
    //
    
    dmx1 = [[dm2xx alloc] init];
    dmx1.mClass = dmx485_class;
    
    
    
    [dmx1 dmx_enable:YES];
    
    
    object_post(dmx485_class, "dmx485: loaded");
    

	return 0;
}



void dmx_free(t_dmx485 *x)
{
	;
    
    [dmx1 dmx_enable:NO];
}



void dmx_message(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{

    
    [dmx1 dmx_set_channel:atom_getlong(argv) value:atom_getlong(argv+1)];
    
}



void dmx_refresh(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{

    object_post(dmx485_class, "dmx485: refreshing...");
    
    [dmx1 dmx_enable:NO];
    [dmx1 dmx_enable:YES];
}



void *dmx_new(t_symbol *s, long argc, t_atom *argv)
{
	t_dmx485 *x = NULL;
    
	if ((x = (t_dmx485 *)object_alloc(dmx485_class))) {
		x->name = gensym("");
		if (argc && argv) {
			x->name = atom_getsym(argv);
		}
		if (!x->name || x->name == gensym(""))
			x->name = symbol_unique();
		
		atom_setlong(&x->val, 0);
		x->out = outlet_new(x, NULL);
	}
    
    [dmx1 dmx_enable:YES];
    
    
    
	return (x);
}

void dmx_print(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{

    int n = [dmx1 getDeviceCount];
    
    for (int i=0;i<n;i++)
        
    {
        char Buffer[64];
        [dmx1 getDeviceNameForIndex:i toString:Buffer];
        
        outlet_anything(x->out, gensym(Buffer), 0, NULL);
    }
    //outlet_anything(x->out, gensym(<#const char *s#>), 0, NULL)
    
}

void dmx_connect(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{
    
    [dmx1 connect];

}

void dmx_disconnect(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{
    
    [dmx1 disconnect];
    
}
