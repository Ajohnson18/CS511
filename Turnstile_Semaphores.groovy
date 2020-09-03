import java.util.concurrent.Semaphore;

int c = 0;

Semaphore mutex = new Semaphore(1);

def P = Thread.start {
    50.times {
        mutex.acquire();
        c++;
        mutex.release();
    }
}

def Q = Thread.start {
    50.times {
        mutex.acquire();
        c++;
        mutex.release();
    }
}

P.join()
Q.join();
println c
 
 
        