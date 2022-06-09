class Queue {
  Node first;
  Node last;
  int l;

  Queue() {
    this.first = null;
    l = 0;
  }

  void push(String val) {
    Node n = new Node(val);
    if (this.first == null) {
      this.first = n;
    } else {
      n.next = this.first;
      this.first = n;
    }
    this.l++;
  }

  String pop() {
    String value = this.first.getValue();
    this.first = this.first.next;
    return value;
  }

  void enQueue(String val) {
    Node n = new Node(val);
    Node tempN = this.last;
    while(tempN.prev != null){
      tempN = tempN.prev;
    }
    tempN.next = n;
    n.prev = tempN;
  }

  void dequeue() {
    Node n = this.first;
    while (n.next != null) {
      n = n.next;
    }
    //remove the node from the train
    n.prev.next = null;
    n.prev = null;
  }


  void traverse() {
    Node node = this.first;
    while (node != null) {
      println(node.getValue());
      node = node.next;
    }
  }
}

class Node {
  String value;
  Node next;
  Node prev;
  Node (String val) {
    this.value = val;
    this.next = null;
  }

  String getValue() {
    return this.value;
  }
}
