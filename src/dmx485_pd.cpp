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

#include "dmxObject_pd.h"
#include "stdlib.h"

#include <sstream>

#define dmxVersionString "dmx485: version 0.7 beta [pd]"

////////////////////////// object struct
typedef struct _dmx485 {
    t_object ob;
    t_atom val;
    t_symbol* name;
    t_outlet* out;
    t_outlet* out2;

} t_dmx485;

t_atom out_list[3];

//1
void* dmx_new(t_symbol* s, long argc, t_atom* argv);
void dmx_free(t_dmx485* x);

//2
void dmx_message(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);
void dmx_frame(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);

void dmx_refresh(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);
void dmx_print(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);

void dmx_connect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);
void dmx_select_device(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);
void dmx_auto_connect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);
void dmx_disconnect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);

void dmx_version(t_dmx485* x, t_symbol* s, long argc, t_atom* argv);

//handle
void* dmx485_class;

//
dm2xx* dmx1;

static unsigned long int instance_counter;

#pragma mark -

long int atom_getlong(t_atom* atom)
{
    return (long int)atom_getfloat(atom);
}

t_symbol* atom_getsym(t_atom* atom)
{
    return atom_getsymbol(atom);
}

void atom_setlong(t_atom* atom, long int value)
{
    if (!atom)
        return;

    atom->a_type = A_FLOAT;
    atom->a_w.w_float = (float)value;
}

void atom_setsym(t_atom* atom, t_symbol* symbol)
{
    if (!atom)
        return;

    atom->a_type = A_SYMBOL;
    atom->a_w.w_symbol = symbol;
}

t_symbol* symbol_unique()
{
    std::stringstream str;
    std::string name;

    str << instance_counter;
    str >> name;

    instance_counter++;

    return gensym(name.c_str());
}

#pragma mark -

void dmx_message(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    dmx1->set_channel(atom_getlong(argv), atom_getlong(argv + 1));
}

void dmx_frame(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    for (int i = 0; i < argc; i++) {
        dmx1->set_channel(i, atom_getlong(argv + i));
    }
}

void dmx_refresh(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    post("dmx485: refreshing...");
    dmx1->refresh();
}

void dmx_print(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{

    int n = dmx1->getDeviceCount();

    outlet_anything(x->out, gensym("clear"), 0, NULL);

    for (int i = 0; i < n; i++)

    {
        char* Buffer = (char*)malloc(64);
        dmx1->getDeviceNameForIndex(i, Buffer);

        post("dev idx: %i", i);

        atom_setlong(out_list + 0, 1);
        atom_setsym(out_list + 1, gensym(Buffer));

        outlet_anything(x->out, gensym("insert"), 2, out_list);
    }
}

void dmx_connect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    dmx1->enable();
}

void dmx_select_device(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    long dev = -1;

    if (argc > 0) {
        dev = atom_getlong(argv);
    }

    if ((dev < 0) || (dev > (dmx1->getDeviceCount() - 1))) {
        printf("devc %li %i", dev, dmx1->getDeviceCount() - 1);
        error("dmx485: wrong device index!");
    } else {
        dmx1->select_device(dev);
    }
}

void dmx_auto_connect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    long con = -1;

    if (argc > 0) {
        con = atom_getlong(argv);
    }

    if (con >= 0) {
        dmx1->set_auto_connect(con > 0);
        post((con > 0) ? "dmx485: auto reconnect enabled" : "dmx485: auto reconnect disabled");
    }
}

void dmx_disconnect(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    dmx1->disable();
}

void dmx_version(t_dmx485* x, t_symbol* s, long argc, t_atom* argv)
{
    post(dmxVersionString);
}

#pragma mark main

void* dmx_new(t_symbol* s, long argc, t_atom* argv)
{
    t_dmx485* x = NULL;

    if ((x = (t_dmx485*)pd_new((t_class*)dmx485_class))) {
        x->name = gensym("");

        if (argc && argv) {
            x->name = atom_getsym(argv);
        }

        if (!x->name || x->name == gensym(""))
            x->name = symbol_unique();

        atom_setlong(&x->val, 0);

        x->out = outlet_new((t_object*)x, NULL);
        x->out2 = outlet_new((t_object*)x, NULL);
    }

    dmx1->enable();

    return (x);
}

void dmx_free(t_dmx485* x)
{
    dmx1->disable();
}

extern "C" {

void dmx485_setup(void)
{
    t_class* c;

    post("dmx485: loading...");

    c = class_new(gensym("dmx485"), (t_newmethod)dmx_new, (t_method)dmx_free, (long)sizeof(t_dmx485),
        0L, A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_message, gensym("list"), A_GIMME, 0);
    class_addmethod(c, (t_method)dmx_frame, gensym("frame"), A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_refresh, gensym("refresh"), A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_print, gensym("print"), A_GIMME, 0);
    class_addmethod(c, (t_method)dmx_version, gensym("version"), A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_connect, gensym("connect"), A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_select_device, gensym("device"), A_GIMME, 0);
    class_addmethod(c, (t_method)dmx_auto_connect, gensym("auto_connect"), A_GIMME, 0);

    class_addmethod(c, (t_method)dmx_disconnect, gensym("disconnect"), A_GIMME, 0);

    //class_addmethod(c, (t_method)dmx_get_info,			"getinfo",		A_GIMME, 0);

    // CLASS_METHOD_ATTR_PARSE(c, "identify", "undocumented", gensym("long"), 0, "1");
    // CLASS_ATTR_SYM(c, "name", 0, t_dmx485, name);

    // class_register(CLASS_BOX, c);
    dmx485_class = c;

    dmx1 = &dm2xx::instance();
    dmx1->mClass = (t_object*)dmx485_class;

    // printf("dmx485 msg");

    post("dmx485: loaded");

    //dmx1->set_auto_connect(true);

    //return 0;
}
}
