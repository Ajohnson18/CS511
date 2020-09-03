import java.util.concurrent.Semaphore;

Semaphore mutex = new Semaphore(0);

Semaphore mutex2 = new Semaphore(0);

Semaphore mutex3 = new Semaphore(0);

Semaphore mutex4 = new Semaphore(0);

Semaphore mutex5 = new Semaphore(0);

Thread.start {
    println("R");
    mutex2.release();
    mutex.acquire();
    println("OK");
    mutex3.release();
}

Thread.start {
    mutex2.acquire();
    println("I");
    mutex4.release();
    mutex3.acquire();
    println("OK");
    mutex5.release();

}

Thread.start {
    mutex4.acquire();
    println("O");
    mutex.release();
    mutex5.acquire();
    println("OK");
}

return;
