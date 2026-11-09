#include <iostream>
#include <stdexcept>

struct AppError : std::runtime_error {
    using std::runtime_error::runtime_error;
    virtual const char* kind() const { return "AppError"; }
};

struct NetworkError : AppError {
    using AppError::AppError;
    const char* kind() const override { return "NetworkError"; }
};

struct TimeoutError : NetworkError {
    using NetworkError::NetworkError;
    const char* kind() const override { return "TimeoutError"; }
};

void fetch() {
    throw TimeoutError("server took too long");
}

void compare_handler_order() {
    try {
        fetch();
    } catch (const AppError& e) { // Intentionally shadows both derived handlers.
        std::cout << "base first: " << e.kind() << " reached AppError handler\n";
    } catch (const NetworkError&) {
        std::cout << "base first: NetworkError handler\n";
    } catch (const TimeoutError&) {
        std::cout << "base first: TimeoutError handler\n";
    }

    try {
        fetch();
    } catch (const TimeoutError&) {
        std::cout << "leaf first: TimeoutError handler\n";
    } catch (const NetworkError&) {
        std::cout << "leaf first: NetworkError handler\n";
    } catch (const AppError&) {
        std::cout << "leaf first: AppError handler\n";
    }
}

void compare_catch_parameters() {
    try {
        fetch();
    } catch (const AppError& e) {
        std::cout << "by reference: " << e.kind() << ", " << e.what() << '\n';
    }

    try {
        fetch();
    } catch (AppError e) { // Intentionally slices the derived exception.
        std::cout << "by value: " << e.kind() << ", " << e.what() << '\n';
    }
}

void middle(bool bare_rethrow) {
    try {
        fetch();
    } catch (const AppError& e) {
        std::cout << "  middle saw: " << e.kind() << '\n';
        if (bare_rethrow) {
            throw;
        }
        throw e; // Constructs a new exception of type AppError.
    }
}

void top(bool bare_rethrow) {
    try {
        middle(bare_rethrow);
    } catch (const TimeoutError& e) {
        std::cout << "  top: retry (" << e.kind() << ")\n";
    } catch (const AppError& e) {
        std::cout << "  top: give up (" << e.kind() << ")\n";
    }
}

int main() {
    compare_handler_order();
    compare_catch_parameters();
    std::cout << "throw;\n";
    top(true);
    std::cout << "throw e;\n";
    top(false);
}
