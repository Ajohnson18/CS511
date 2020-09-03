public class Barrier {

    int threads = 0;
    final static int N = 3;
    
    public synchronized void synch() {
        
        if(threads<N) {
            threads++;
            while(threads < N) {
                wait() // use Objects wait-set
            }    
            
            notifyAll()
        }
    }

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