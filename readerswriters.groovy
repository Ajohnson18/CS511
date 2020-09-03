//Readers/writers

Semaphore resource = new Semphore(1);
int numR = 0;
Semaphore entryProtocol = new Semaphore(1);

Thread.start { // W

    entryProtocol.acquire();
    resource.acquire();
    entryProtocol.release();
    //write to sharedRes   
    resourse.release();

}

Thread.start { //R

    entryProtocol.acquire()
    mutexR.acquire();
    numR++;
    if(numR == 1) {
        resource.acquire();
    }
    mutexR.release();
    entryProtocol.release()
    
    //read from sharedRes
    mutexR.acquire();
    numR--;
    if(numR == 0) {
        resourse.release();
    }
    mutexR.release();
}