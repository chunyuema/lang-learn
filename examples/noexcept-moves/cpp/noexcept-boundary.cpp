#include <iostream>
#include <stdexcept>

void risky() noexcept {
    // noexcept is a promise that no exception will escape this function.
    // Throwing is still syntactically allowed, but because this exception is
    // not caught inside risky(), the runtime calls std::terminate.
    std::cout << "risky: about to throw" << std::endl;
    throw std::runtime_error("boom");
}

int main() {
    try {
        risky();
    } catch (const std::exception& error) {
        // This handler cannot catch the exception from risky(): termination
        // happens as soon as it tries to cross the noexcept boundary.
        std::cout << "caught: " << error.what() << '\n';
    }
    // This line is also unreachable after risky() violates its promise.
    std::cout << "main: still running\n";
}
