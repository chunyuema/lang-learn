#include <iostream>
#include <stdexcept>
#include <thread>

void parse_config() {
    std::cout << "worker: parsing\n" << std::flush;
    throw std::runtime_error("bad input on line 3");
}

int main() {
    try {
        std::thread worker(parse_config);
        worker.join();
        std::cout << "main: joined\n";
    } catch (const std::exception& error) {
        std::cout << "main: caught " << error.what() << '\n';
    }
    std::cout << "main: done\n";
}
