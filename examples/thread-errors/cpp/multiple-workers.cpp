#include <exception>
#include <iostream>
#include <stdexcept>
#include <thread>
#include <vector>

void work(int id) {
    if (id == 0) throw std::runtime_error("worker 0: disk full");
    if (id == 2) throw std::invalid_argument("worker 2: bad flag");
}

int main() {
    std::vector<std::exception_ptr> errors(3);
    std::vector<std::thread> workers;
    for (int id = 0; id < 3; ++id) {
        workers.emplace_back([id, &errors] {
            try {
                work(id);
            } catch (...) {
                errors[id] = std::current_exception();
            }
        });
    }
    for (auto& worker : workers) worker.join();

    for (int id = 0; id < 3; ++id) {
        if (!errors[id]) {
            std::cout << id << ": ok\n";
            continue;
        }
        try {
            std::rethrow_exception(errors[id]);
        } catch (const std::invalid_argument& error) {
            std::cout << id << ": invalid_argument: " << error.what() << '\n';
        } catch (const std::exception& error) {
            std::cout << id << ": exception: " << error.what() << '\n';
        }
    }
}
