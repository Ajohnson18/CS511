monitor Buffer {
     // Data fields
     private LinkedList data = new LinkedList ();
     condition nonEmpty, writeEnabled;
     boolean writeDisabled=false;
     
     public Object read() {
         while (data.isEmpty()) {
	       nonEmpty.wait();
	 }
	 Object ret_val = data.getLast();
	 data.removeLast();
	 return ret_val;
     }


      public void write(Object o) {
           while (writeDisabled) {
	          writeEnabled.wait()
           }
           data.addFirst(o);
           nonEmpty.signalAll();
     }

     public disableWrite() {
           writeDisabled=true;
      }
      
      public enableWrite() {
           writeDisabled=false;
	   writeEnabled.signalAll();
      }
}

