import java.util.concurrent.Semaphore;

Semaphore allowMan = new Semaphore(0);
Semaphore mutex = new Semaphore(1);

20.times {
    Thread.start { // MAN
        mutex.acquire();
        allowMan.acquire();
        allowMan.acquire();
        System.out.println("1 Man")
        mutex.release();
    }
}

20.times {
    Thread.start { // WOMAN
        allowMan.release();
        System.out.println("1 Woman")
    }
}
 
 
        