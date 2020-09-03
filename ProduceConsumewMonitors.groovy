// Producer Consumer of buffer size n

monitor Producers_Consumers {

    private Object[] buffer=null;
    private int size = 0;
    private int start,end = 0;
    ConditionVariable empty;
    
    void produce(Object o) {
        if (size == N) {
            empty.wait();
        }
        buffer[start] = o;
        start = (start+1) % N;
        size++;
        full.signal();
    }
    
    Object consume() {
        if (size == 0) {
            full.wait();
        }    
        Object temp = buffer;
        buffer[end] = null;
        end = (end+1) % N;
        size--;
        empty.signal();
        return temp;
    }
}
    