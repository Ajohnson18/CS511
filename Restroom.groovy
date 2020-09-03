import java.util.concurrent.Semaphore;

int n = 10;

Semaphore toiletsInUse = new Semaphore(n);
Semaphore restrictOther = new Semaphore(1);

10.times {
Thread.start { //Man


        restrictOther.acquire();
        toiletsInUse.acquire();
        
        n--;
        System.out.println("men");
        n++;
        
        toiletsInUse.release();
        
        if(n == 10) restrictOther.release();
    
}
}

10.times {
Thread.start { //Woman
    
        restrictOther.acquire();
        toiletsInUse.acquire();
        
        n--;
        System.out.println("women");
        n++;
        
        toiletsInUse.release();
  
        if(n == 10) restrictOther.release();
    
}

}