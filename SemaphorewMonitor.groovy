monitor Semaphore {

    private int permits;
    Contition availablePermits;
    
    Semaphore(int init) {
        permits = init;
    }
    
    acquire() {
        while (permits == 0) {
            availablePermits.wait();
        }
        permits--;
    }
    
    release() {
        permits++;
        availablePermits.signal();
    }
}