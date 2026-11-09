#include <iostream>
#include <thread>
#include <vector>
#include <exception>
using std::cout; using std::endl;

void task1() {
    cout << "Task 1 is running." << endl;
}

void program() {
    try {
        std::thread t1(task1);
        std::vector<int> data{0,1,2};
        data.at(4); // out of range
        t1.join();
    } catch (std::exception &ex) {
        cout << "Some error occurred!" << endl;
    }
}

void good_program() {
    std::thread t1(task1);
    try {
        std::vector<int> data{0,1,2};
        data.at(4); // out of range
        t1.join();
    } catch (std::exception &ex) {
        cout << "Some error occurred!" << endl;
    }
}

int main() {
    try {
        program();
        // good_program();
    } catch (...) {
        cout << "An error occurred" << endl;
    }
}