import java.util.concurrent.Semaphore;

Semaphore permToLoad = new Semaphore(0);
Semaphore doneLoading = new Semaphore(0);

Semaphore trainsOnTrack = [new Semaphore(1), new Semaphore(1)];

Random r = new Random();

Thread.start { // passenger train
    
    int dir = r.nextInt(2); // random number between 0 and 1

    trainsOnTrack[dir].acquire();
    
    // Load passengers
    
    trainsOnTrack[dir].release();
}

Thread.start { // freight train

    trainsOnTrack[0].acquire();
    trainsOnTrack[1].acquire();
    // Load Freight
    permToLoad.release();
    doneLoading.acquire();
    
    trainsOnTrack[0].release();
    trainsOnTrack[1].release();

}

Thread.start { // Loading machine
    while(true) {
        permToLoad.acquire();
        // load
        doneLoading.release();
    }
}