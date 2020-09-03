monitor threeWaySequencer {

    condition firstc, secondc, thirdc;
    int state;
    
    first() {
        while (state != 0) {
            firstc.wait()
        }
        state = 1
        secondc.signal()
    }
    
    second() {
        while (state != 1) {
            secondc.wait() 
        }
        state = 2
        thirdc.signal()
    }
    
    third() {
        while (state != 2) {
            thirdc.wait()
        }
        state = 0
        firstc.signal()
    }

}