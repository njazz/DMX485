//
//  dm2xx.h
//
//
//  Created by Alex Nadzharov on 04/02/17.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//

//  Pd version

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


extern "C" {
  #import "ftd2xx.h"
}

#include <stdio.h>
#include <string>

#include "m_pd.h"

#include "pthread.h"

class dm2xx;

static dm2xx* dm2xx_obj;

class dm2xx {
private:
    FT_HANDLE dmxPointer;

    FT_STATUS ftdiPortStatus;

    //int tempV;

    unsigned char dmx_data[512];

    unsigned char deviceNumber;

    // device info
    FT_DEVICE ftDevice;
    LPDWORD ftDeviceID;
    PCHAR ftSerialNumber;
    PCHAR ftDeviceDescription;

    BOOL autoConnect;

    //thread:
    pthread_t dThread;
    bool threadOn;
    int threadAction;

    dm2xx();
    dm2xx(dm2xx const&);
    void operator=(dm2xx const&);

    // main actions

    void connect();
    void disconnect();

    // thread

    static void* thread(void*);
    void timer_action();

public:
    static dm2xx& instance();

    t_object* mClass;

    // basic

    int getDeviceCount();

    void getDeviceNameForIndex(long int index, char* Buffer);

    void select_device(unsigned char index);

    void enable();

    void disable();
    void refresh();

    // setters

    void set_channel(unsigned int channel, unsigned char value);
    void set_auto_connect(bool yesorno);
};
