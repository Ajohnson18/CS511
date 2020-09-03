public class Barrier {

    int threads = 0;
    final static int N = 3;
    boolean door1 = false
    boolean door2 = true
    Lock l = new ReentrantLock();
    Condition cdoor1 = new l.newCondition();
    Condition cdoor2 = new l.newCondition();
    
    synch() {
        l.lock();

            while(door1) {
                cdoor1.wait() 
            }    
            
            threads++;
            if(threads == N) {
                door1 = true;
                door2 = false;
                cdoor2.signalAll()
            }
            
            while(door2) {
                cdoor2.wait()
            }
            
            threads--;
            if (threads == N) {
                door1 = false;
                door2 = true;
                cdoor1.signalAll()
            }
    }
    finally
     {l.unlock();}

}

Barrier barrier = new Barrier();

Thread.start {
    println "a"
    barrier.synch()
    println "1"
}
Thread.start {
    println "b"
    barrier.synch()
    println "2"
}
Thread.start {
    println "c"
    barrier.synch()
    println "3"
}

return;