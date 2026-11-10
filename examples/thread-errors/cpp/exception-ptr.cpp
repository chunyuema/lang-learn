#include <exception>
#include <iostream>
#include <stdexcept>
#include <thread>

void parse_config() {
    std::cout << "worker: parsing\n";
    throw std::runtime_error("bad input on line 3");
}

int main() {
    std::exception_ptr error;
    std::thread worker([&error] {
        try {
            parse_config();
        } catch (...) {
            error = std::current_exception();
            std::cout << "worker: stored it\n";
        }
    });

    worker.join();
    std::cout << "main: joined, error is " << (error ? "set" : "empty") << '\n';
    try {
        if (error) {
            std::rethrow_exception(error);
        }
    } catch (const std::runtime_error& caught) {
        std::cout << "main: caught " << caught.what() << '\n';
    }
    std::cout << "main: done\n";
}
