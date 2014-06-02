
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
void dmx_list(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);
void dmx_refresh(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv);

//handle
void *dmx485_class;


//

dm2xx *dmx1;

int C74_EXPORT main(void)
{	
	t_class *c;
	
	c = class_new("DMX485", (method)dmx_new, (method)dmx_free, (long)sizeof(t_dmx485),
				  0L /* leave NULL!! */, A_GIMME, 0);
	
    
    class_addmethod(c, (method)dmx_list,				"list",			A_GIMME, 0);
    class_addmethod(c, (method)dmx_refresh,				"refresh",			A_GIMME, 0);
	
	CLASS_METHOD_ATTR_PARSE(c, "identify", "undocumented", gensym("long"), 0, "1");

	CLASS_ATTR_SYM(c, "name", 0, t_dmx485, name);
	
	class_register(CLASS_BOX, c);
	dmx485_class = c;
    
    //
    
    dmx1 = [[dm2xx alloc] init];
    dmx1.mClass = dmx485_class;
    
    
    
    [dmx1 dmx_enable:YES];
    
    
    object_post(dmx485_class, "DMX485: loaded");
    

	return 0;
}



void dmx_free(t_dmx485 *x)
{
	;
    
    [dmx1 dmx_enable:NO];
}



void dmx_list(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{

    
    [dmx1 dmx_set_channel:atom_getlong(argv) value:atom_getlong(argv+1)];
    
}



void dmx_refresh(t_dmx485 *x, t_symbol *s, long argc, t_atom *argv)
{

    object_post(dmx485_class, "DMX485: refreshing...");
    
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
