import java.util.concurrent.Semaphore;


forks = [new Semaphore(1), new Semaphore(1), new Semaphore(1), new Semaphore(1), new Semaphore(1)]

Semaphore allowedToEat = new Semaphore(4);

5.times {
    Thread.start { //Philosphers
        while (true) {
            //think
            allowedToEat.acquire();
            forks[it].acquire();
            forks[(it+1) % 5].acquire();
            println "Ph %it is eating";
            //eat
            forks[it].release();
            forks[(it+1) % 5].release();
            allowedToEat.release();
        }
    }
}