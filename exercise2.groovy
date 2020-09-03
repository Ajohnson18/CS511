Semaphore buttons = new Semphore(2);
Semaphore mutex = new Semaphore(1);

200.times {
   Thread.start { // client

          buttons.acquire();
          // grab coffee
	  buttons.release();
         // consume

   }
}


10.times {
  Thread.start { // employee

         // make sure no clients are using the machine
         mutex.acquire();
	 buttons.acquire();
	 buttons.acquire();
	 mutex.release();
        // refill coffee
	buttons.release();
	buttons.release();
  }
}
