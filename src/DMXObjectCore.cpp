#include "DMXObjectCore.h"

//#include "pthread.h"
#include "unistd.h"

#include <string>

#include <functional>
#include <thread>

extern "C" {
#import "ftd2xx.h"
}

struct DMXImplementation {
    FT_HANDLE dmxPointer = 0;
    FT_STATUS ftdiPortStatus = 0;

    // device info
    FT_DEVICE ftDevice = 0;
    LPDWORD ftDeviceID = 0;
    PCHAR ftSerialNumber = 0;
    PCHAR ftDeviceDescription = 0;

    //thread:
//    pthread_t dThread;
    bool threadOn;
    int threadAction;

    //static void* thread(void*);
    void timerAction();
    std::function<void(void)> getThread();

    std::thread* _thread = 0;//(getThread());

    unsigned char* _data = 0;
    DMXObjectCore* _object = 0;

    // ---
    DMXImplementation()
    {
        //pthread_create(&dThread, NULL, getThread(), NULL);
       // _thread = std::thread(getThread());
        _thread = new std::thread(getThread());
    }

    ~DMXImplementation()
    {
//        pthread_join(dThread, NULL);
//        pthread_exit(NULL);
        _thread->join();
        delete _thread;
    }
};

// =======
// thread

//void* DMXImplementation::thread(void*)

std::function<void(void)> DMXImplementation::getThread(){ return [&]() {
    while (true) {

        if (threadAction == 1) {
            if (_object->extraDebug)
                _object->log.msg(">connect\n");
            threadAction = 0;
            _object->connect();
        }

        if (threadAction == 2) {
            if (_object->extraDebug)
                _object->log.msg(">disconnect\n");
            threadAction = 0;
            _object->disconnect();
        }

        if (threadAction == 3) {
            //post(">restart");
            threadOn = 0;

            _object->disconnect();
            threadAction = 0;

            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            usleep(10000);

            threadAction = 1;
            //});
        }

        if (threadOn)
            timerAction();

        usleep(25000);
        //[NSThread sleepForTimeInterval:1 / 50 * NSEC_PER_SEC];
    }
}; };

void DMXImplementation::timerAction()
{

    DWORD bytesWrittenOrRead;
    unsigned char start;

    start = 0;

    DWORD s1 = 1;

    //todo packet size
    DWORD s2_init = 512;
    DWORD s2 = 512;

    FT_STATUS qftdiPortStatus;
    qftdiPortStatus = -1;

    if (dmxPointer) {

        FT_SetBreakOff(dmxPointer);
        qftdiPortStatus = FT_Write((dmxPointer), &start, s1, &bytesWrittenOrRead);

        int fuse = 10;
        while (s2 && fuse) {
            qftdiPortStatus = FT_Write((dmxPointer), _data + (s2_init - s2), s2, &bytesWrittenOrRead);
            s2 -= bytesWrittenOrRead;
            fuse--;
        }

        FT_SetBreakOn(dmxPointer);
        qftdiPortStatus = FT_Purge(dmxPointer, FT_PURGE_RX | FT_PURGE_TX);
    }

    if (qftdiPortStatus != FT_OK) {
        // todo
        if (_object->extraDebug)
            _object->log.errorMsg(">timer error");
    }
}

// ---

DMXObjectCore::DMXObjectCore()
{
    for (int i = 0; i < 512; i++)
        _data[i] = 0;

    _impl = new DMXImplementation();
    _impl->_data = _data;
    _impl->_object = this;
}

DMXObjectCore::~DMXObjectCore()
{
    delete _impl;
}

// =====

void DMXObjectCore::connect()
{
    // connect section 1 - open device

    if (extraDebug)
        log.msg(" *** connect 1");

    DWORD numDevs = (DWORD)deviceCount();

    if ((numDevs > 0) && (_impl->dmxPointer == NULL)) {

        char Buffer[64] = "FT232R USB UART";

        if (extraDebug)
            log.msg("dmx485: connecting to device: " + std::to_string(_deviceNumber));

        std::string portDescription = deviceNameAt(_deviceNumber);

        const char* nBuffer = portDescription.c_str();
        FT_ListDevices(&_deviceNumber, &nBuffer, FT_LIST_BY_INDEX | FT_OPEN_BY_DESCRIPTION);

        if (extraDebug)
            log.msg("port name: " + portDescription);

        if (_impl->dmxPointer == NULL) {

            log.msg("dmx485: connecting...");

            FT_HANDLE tdmxPointer = NULL;
            int idx = _deviceNumber;

            FT_STATUS cftdiPortStatus;

            cftdiPortStatus = FT_Open(idx, &tdmxPointer);
            log.msg("open");

            if (_impl->ftdiPortStatus != FT_OK) {
                log.errorMsg("dmx485: electronics error: Can't open USB device: " + std::to_string((int)_impl->ftdiPortStatus));
                _impl->dmxPointer = 0;
                return;
            }

            _impl->ftdiPortStatus = FT_SetBitMode(tdmxPointer, 0x00, 0);
            if (_impl->ftdiPortStatus != FT_OK) {
                log.errorMsg("dmx485: electronics error: Can't set bit bang mode");
                _impl->dmxPointer = 0;
                return;
            }

            // reset etc.
            _impl->ftdiPortStatus = FT_ResetDevice(tdmxPointer);
            _impl->ftdiPortStatus = FT_Purge(tdmxPointer, FT_PURGE_RX | FT_PURGE_TX);
            _impl->ftdiPortStatus = FT_SetBaudRate(tdmxPointer, 250000);

            if (_impl->ftdiPortStatus != FT_OK) {
                log.errorMsg("dmx485: electronics error: Can't set baud rate");
                _impl->dmxPointer = 0;
                return;
            }

            // settings
            _impl->ftdiPortStatus = FT_SetTimeouts(tdmxPointer, 1000, 1000);
            _impl->ftdiPortStatus = FT_SetDataCharacteristics(tdmxPointer, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE); // 8N1
            _impl->ftdiPortStatus = FT_SetFlowControl(tdmxPointer, FT_FLOW_NONE, 0, 0);
            FT_ClrRts(tdmxPointer);

            _impl->ftdiPortStatus = FT_SetLatencyTimer(tdmxPointer, 2);
            if (_impl->ftdiPortStatus != FT_OK) {
                log.errorMsg("dmx485: electronics error: Can't set latency timer");
                _impl->dmxPointer = 0;
                return;
            }

            FT_W32_EscapeCommFunction(tdmxPointer, CLRRTS);

            FT_GetDeviceInfo(tdmxPointer, &_impl->ftDevice, _impl->ftDeviceID, _impl->ftSerialNumber, _impl->ftDeviceDescription, NULL);

            log.msg("dmx485: ok"); //object_ this->mClass,

            _impl->dmxPointer = tdmxPointer;

            usleep(10000);

            if (extraDebug)
                log.msg("setting timer");
            if (extraDebug)
                log.msg("result " + std::to_string((long)_impl->dmxPointer));

            _impl->threadOn = true;

            return;

        } else {
            log.msg("dmx485: USB device is not connected");
            _impl->dmxPointer = 0;
            return;
        }

    } else {
        log.errorMsg("dmx485: no USB device found");
        _impl->dmxPointer = 0;
        return;
    }
}

void DMXObjectCore::disconnect()
{
    {
        _impl->threadOn = false;

        FT_HANDLE cPointer = _impl->dmxPointer;

        if (cPointer != NULL) {
            _impl->ftdiPortStatus = FT_Close(cPointer);
        } else {
            _impl->ftdiPortStatus = FT_OK;
        }

        if (_impl->ftdiPortStatus != FT_OK) {
            log.errorMsg("dmx485: error disconnecting: " + std::to_string(_impl->ftdiPortStatus));

        } else {
            _impl->dmxPointer = 0;
            log.msg("dmx485: disconnected");
        }
    }
}

// =====

size_t DMXObjectCore::deviceCount()
{
    DWORD numDevs = 0;
    FT_STATUS iftdiPortStatus = FT_ListDevices(&numDevs, NULL, FT_LIST_NUMBER_ONLY);

    //TODO: move to object
    if (iftdiPortStatus != FT_OK) {
        log.errorMsg("dmx485: unable to list devices");
        return -1;
    } else {
        log.msg("devices: " + std::to_string(numDevs));
        return numDevs;
    }
}

std::string DMXObjectCore::deviceNameAt(size_t idx)
{
    char* buffer = (char*)malloc(64);
    FT_ListDevices((PVOID)idx, buffer, FT_LIST_BY_INDEX); //|FT_OPEN_BY_DESCRIPTION\

    std::string ret = std::string(buffer);
    log.msg("device name: " + ret);

    return ret;
}

void DMXObjectCore::setDeviceNumber(size_t index)
{
    _deviceNumber = index;
}

//

void DMXObjectCore::setEnabled(bool value)
{
    if (value) {
        if (_impl->dmxPointer == 0) {
            _impl->threadAction = 1;
        }
        log.msg("dmx485: starting...");
    } else {
        log.msg("dmx485: stopping...");
        _impl->threadAction = 2;
    }
}

void DMXObjectCore::refresh()
{
    log.msg("dmx485: refreshing...");
    _impl->threadAction = 3;
}

// =====
// setters

void DMXObjectCore::setChannel(unsigned int channel, unsigned char value)
{
    if ((channel < 512)) {
        _data[channel] = value;
    }
}

void DMXObjectCore::setAutoConnect(bool value)
{
    _autoConnect = value;
}
