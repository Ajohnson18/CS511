import java.util.concurrent.Semaphore;

Semaphore station0 = new Semaphore(1);
Semaphore station1 = new Semaphore(1);
Semaphore station2 = new Semaphore(1);
permToProcess = [new Semaphore(0), new Semaphore(0), new Semaphore(0)]

100.times {
    Thread.start {
        // got to station 0
        station0.acquire();
        permToProcess0.release();
        permToProcess0.acquire()

        // move on to station 1
        station1.acquire();
        station0.release();
        permToProcess1.release();
        permToProcess1.acquire()
        
        // move on to station 2
        station2.acquire();
        station1.release();
        permToProcess2.release();
        permToProcess2.acquire()
    }
}

3.times {
    Thread.machine { // machine at station i
        while(true) {
            permToProcess[it].acquire();
            // process car when available
            permToProcess[it].release();
        }
    }
}