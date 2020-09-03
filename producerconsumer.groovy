final int N = 100;
buffer = [0] * N;

Semaphore permToConsume = new Semaphore(0);
Semaphore permToProduce = new Semaphore(N);

Semaphore mutexP = new Semaphore(1);
Semaphore mutexC = new Semaphore(1);

100.times {
    Thread.start { //producer
        while (true) {
            permToProduce.acquire();
            mutexP.acquire();
            buffer[start] = produce();
            start = (start + 1) % N;
            mutexP.release();
            permToConsume.release();
        }
    }
}

100.times {
    Thread.start { //consumer
        while (true) {
            permToConsume.acquire();
            mutexC.acquire();
            consume(buffer[end]);
            end = (end + 1) % N;
            mutexC.release();
            permToProduce.release();

        }
    }
}