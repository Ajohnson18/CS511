import java.util.concurrent.Semaphore;

Semaphore cleanOveralls = new Semaphore(10);
Semaphore dirtyOveralls = new Semaphore(0);

100.times {
    Thread.start { //Worker
    
        cleanOveralls.acquire();
        
        //works
        
        dirtyOveralls.release();
    
    }
}

20.times {
    Thread.start { // Machine
        while (true) {
            
            dirtyOveralls.acquire();
            
            //Clean
            
            cleanOveralls.release();
            
            
        }
    }
}