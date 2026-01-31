public class Box {
    // a rectangle representing a bounding box of a shape
    // Shape @ shape;
    float x_left, x_right, y_bottom, y_top;
}

public class PosEvent {
    0 => static int LEFT_EDGE;
    1 => static int RIGHT_EDGE;

    float x;
    int type;
    Box @box;

    fun int lessThan(PosEvent @other) { return this.x < other.x; }
}

public class BinaryHeap {
    1000 => static int MAX;
    PosEvent @data[MAX]; // Internal storage for the heap
    0 => int size;

    // array manipulation
    fun void _push_back(PosEvent @value) { value @=> data[size++]; }

    fun void _pop_back() {
        if (size <= 0) {
            <<< "_pop_back an empty heap!" >>>;
            me.exit();
        }
        size--;
    }

    fun void _swap(PosEvent @a, PosEvent @b) {
        PosEvent c;
        a.x => c.x;
        a.type => c.type;
        a.box @=> c.box;

        b.x => a.x;
        b.type => a.type;
        b.box @=> a.box;

        c.x => b.x;
        c.type => b.type;
        c.box @=> b.box;
    }

    // Insert an element into the heap
    fun void push(PosEvent @value) {
        _push_back(value);   // Add the new value at the end
        heapifyUp(size - 1); // Fix the heap property upwards
        // <<< top().x >>>;
    }

    // Remove the maximum element from the heap
    fun void pop() {
        if (size == 0)
            return;

        _swap(data[0], data[size - 1]); // Swap the root with the last element
        _pop_back();                    // Remove the last element
        heapifyDown(0);                 // Fix the heap property downwards
    }

    // Get the maximum element in the heap
    fun PosEvent @top() {
        if (size == 0) {
            <<< "Heap is empty" >>>;
            me.exit();
        }
        return data[0];
    }

    // Check if the heap is empty
    fun int empty() { return size == 0; }


    // Heapify up to restore the heap property
    fun void heapifyUp(int index) {
        while (index > 0) {
            (index - 1) / 2 => int parent;
            if (data[parent].lessThan(data[index]))
                break; // Heap property is satisfied

            _swap(data[index], data[parent]);
            parent => index;
        }
    }

    // Heapify down to restore the heap property
    fun void heapifyDown(int index) {
        while (index < size) {
            2 * index + 1 => int left;
            2 * index + 2 => int right;
            index => int largest;

            if (left < size && data[left].lessThan(data[largest])) {
                left => largest;
            }
            if (right < size && data[right].lessThan(data[largest])) {
                right => largest;
            }

            if (largest == index)
                break;

            _swap(data[index], data[largest]);
            largest => index;
        }
    }
}


// test =======================================================================

BinaryHeap heap;

for (int i; i < 10; ++i) {
    PosEvent tmp;
    Math.random2(1, 100) => tmp.x;
    <<< tmp.x >>>;
    heap.push(tmp);
}
<<< "=====================" >>>;

for (int i; i < 10; ++i) {
    <<< heap.top().x >>>;
    heap.pop();
}
