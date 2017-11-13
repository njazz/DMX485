//
//  dm2xx.h
//
//
//  Created by Alex Nadzharov on 04/02/17.
//  Copyright (c) 2014 Alex Nadzharov. All rights reserved.
//

//  Max version

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



#include "dmxObject.h"

//static dm2xx* dm2xx_obj;

#include "unistd.h"

dm2xx::dm2xx()
{
    deviceNumber = 0;

    ftDeviceID = NULL;
    ftSerialNumber = NULL;
    ftDeviceDescription = NULL;

    for (int i = 0; i < 512; i++)
        dmx_data[i] = 0;

    dmxPointer = 0;

    pthread_create(&this->dThread, NULL, &dm2xx::thread, NULL);
}
dm2xx::dm2xx(dm2xx const&){};
void dm2xx::operator=(dm2xx const&){};

void dm2xx::connect()
{
    // connect section 1 - open device

    post(" *** connect 1");

    DWORD numDevs = this->getDeviceCount();

    if ((numDevs > 0) && (dmxPointer == NULL)) {
        char Buffer[64] = "FT232R USB UART";
        post("dmx485: connecting to device: %i", deviceNumber);

        //[self getDeviceNameForIndex:deviceNumber toString:(char *)&Buffer];    //sort of

        this->getDeviceNameForIndex(deviceNumber, Buffer);
        FT_ListDevices(&deviceNumber, Buffer, FT_LIST_BY_INDEX | FT_OPEN_BY_DESCRIPTION);

        std::string portDescription = Buffer; //[NSString stringWithCString:Buffer encoding:NSASCIIStringEncoding];
        post("port name: %s", portDescription.c_str());
        //post(this->mClass, [[NSString stringWithFormat:@"port name: %s",portDescription] charValue]);

        //if ((portDescription == "FT232R USB UART") && (dmxPointer == NULL))
        if (dmxPointer == NULL) {

            post( "dmx485: connecting...");

            FT_HANDLE tdmxPointer = NULL;
            int idx = deviceNumber;

            //post("device idx p %i %lu %li", idx, &tdmxPointer, tdmxPointer);

            FT_STATUS cftdiPortStatus;

            cftdiPortStatus = FT_Open(idx, &tdmxPointer);
            post("open");

            if (ftdiPortStatus != FT_OK) {
                error("Electronics error: Can't open USB device: %d", (int)ftdiPortStatus);
                dmxPointer = 0;
                return;
            }

            ftdiPortStatus = FT_SetBitMode(tdmxPointer, 0x00, 0);
            if (ftdiPortStatus != FT_OK) {
                error("Electronics error: Can't set bit bang mode");
                dmxPointer = 0;
                return;
            }

            // reset etc.
            ftdiPortStatus = FT_ResetDevice(tdmxPointer);
            ftdiPortStatus = FT_Purge(tdmxPointer, FT_PURGE_RX | FT_PURGE_TX);
            ftdiPortStatus = FT_SetBaudRate(tdmxPointer, 250000);

            if (ftdiPortStatus != FT_OK) {
                error("Electronics error: Can't set baud rate");
                dmxPointer = 0;
                return;
            }

            // settings
            ftdiPortStatus = FT_SetTimeouts(tdmxPointer, 1000, 1000);
            ftdiPortStatus = FT_SetDataCharacteristics(tdmxPointer, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N1
            ftdiPortStatus = FT_SetFlowControl(tdmxPointer, FT_FLOW_NONE, 0, 0);
            FT_ClrRts(tdmxPointer);

            ftdiPortStatus = FT_SetLatencyTimer(tdmxPointer, 2);
            if (ftdiPortStatus != FT_OK) {
                error("Electronics error: Can't set latency timer");
                dmxPointer = 0;
                return;
            }

            FT_W32_EscapeCommFunction(tdmxPointer, CLRRTS);

            FT_GetDeviceInfo(tdmxPointer, &ftDevice, ftDeviceID, ftSerialNumber, ftDeviceDescription, NULL);

            post( "dmx485: ok");

            dmxPointer = tdmxPointer;

            usleep(10000);
            post("setting timer");

            post("result %li", dmxPointer);

            this->threadOn = true;

            return;

        } else {
            //            object_error(this->mClass, "dmx485: USB device is not connected");
            printf("dmx485: USB device is not connected");
            dmxPointer = 0;
            return;
        }

    } else {
        error( "dmx485: no USB device found");
        //printf("dmx485: no USB device found");
        dmxPointer = 0;
        return;
    }

    // section 2
    //if (dmxPointer > 0)

    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    //});

    //);
}

void dm2xx::disconnect()
{
    {
        this->threadOn = false;

        FT_HANDLE cPointer = this->dmxPointer;

        if (cPointer != NULL) {
            ftdiPortStatus = FT_Close(cPointer);
        } else {
            ftdiPortStatus = FT_OK;
        }

        if (ftdiPortStatus != FT_OK) {
            //printf("error disconnecting: %u", ftdiPortStatus);
            error( "dmx485: error disconnecting: %u", ftdiPortStatus);

        } else {
            this->dmxPointer = 0;
            post( "dmx485: disconnected");
        }
    }
    //);
}

#pragma mark thread

void* dm2xx::thread(void*)
{
    while (true) {

        if (dm2xx_obj->threadAction == 1) {
            post(">connect\n");
            dm2xx_obj->threadAction = 0;
            dm2xx_obj->connect();
        }

        if (dm2xx_obj->threadAction == 2) {
            post(">disconnect\n");
            dm2xx_obj->threadAction = 0;
            dm2xx_obj->disconnect();
        }

        if (dm2xx_obj->threadAction == 3) {
            //post(">restart");
            dm2xx_obj->threadOn = 0;

            dm2xx_obj->disconnect();
            dm2xx_obj->threadAction = 0;

            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            usleep(10000);

            dm2xx_obj->threadAction = 1;
            //});
        }

        if (dm2xx_obj->threadOn)
            dm2xx_obj->timer_action();

        usleep(10000);
        //[NSThread sleepForTimeInterval:1 / 50 * NSEC_PER_SEC];
    }
}

void dm2xx::timer_action()
{
    //FT_HANDLE qDmxPointer = this->dmxPointer; //[self get_dmx_pointer];

    //if ((qDmxPointer > 0))
    //post(">timer");

    DWORD bytesWrittenOrRead;
    unsigned char start;

    start = 0;

    DWORD s1 = 1;

    //todo packet size
    DWORD s2_init = 512;
    DWORD s2 = 512;

    FT_STATUS qftdiPortStatus;

    qftdiPortStatus = -1;

    if (this->dmxPointer) {

        FT_SetBreakOff(this->dmxPointer);
        qftdiPortStatus = FT_Write((this->dmxPointer), &start, s1, &bytesWrittenOrRead);
        
        int fuse = 10;
        while (s2 && fuse)
        {
            qftdiPortStatus = FT_Write((this->dmxPointer), &dmx_data+(s2_init-s2), s2, &bytesWrittenOrRead);
            s2 -= bytesWrittenOrRead;
            fuse --;
        }

        FT_SetBreakOn(this->dmxPointer);
        qftdiPortStatus = FT_Purge(this->dmxPointer, FT_PURGE_RX | FT_PURGE_TX);
    }

    if (qftdiPortStatus != FT_OK) {
        // todo
        error(">timer error");
    }
}

#pragma mark public

dm2xx& dm2xx::instance()
{
    static dm2xx instance;

    dm2xx_obj = &instance;

    return instance;
}

t_object* mClass;

#pragma mark basic

int dm2xx::getDeviceCount()
{

    DWORD numDevs = 0;
    FT_STATUS iftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);

    //TODO: move to object
    if (iftdiPortStatus != FT_OK) {
        //error("dmx485 error: Unable to list devices");

        error("dmx485: unable to list devices");

        return -1;
    } else {
        post("devices: %i", numDevs);
        return numDevs;
    }
}

void dm2xx::getDeviceNameForIndex(long int index, char* Buffer)
{
    //char * tempBuffer = malloc(64);

    FT_ListDevices((PVOID)index, Buffer, FT_LIST_BY_INDEX); //|FT_OPEN_BY_DESCRIPTION

    post("device name: %s", Buffer);

    //Buffer = tempBuffer;
}

void dm2xx::select_device(unsigned char index)
{
    this->deviceNumber = index;
}

void dm2xx::enable()

{
    post("starting USB DMX");

    if (this->dmxPointer == 0) {

        this->threadAction = 1;
    }
}

void dm2xx::disable()

{
    this->threadAction = 2;

    post("stopping USB DMX");
}

void dm2xx::refresh()
{
    post("--refresh");

    this->threadAction = 3;
}

#pragma mark setters

void dm2xx::set_channel(unsigned int channel, unsigned char value)
{

    if ((channel < 513)) {
        this->dmx_data[channel] = value;
    }
}

void dm2xx::set_auto_connect(bool yesorno)
{
    this->autoConnect = yesorno;
}
