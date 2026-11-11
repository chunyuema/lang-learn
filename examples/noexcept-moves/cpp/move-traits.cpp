#include <iostream>
#include <string>
#include <type_traits>
#include <utility>

struct Written {
    std::string name;
    Written(Written&& other) : name(std::move(other.name)) {}
};

struct Promised {
    std::string name;
    Promised(Promised&& other) noexcept : name(std::move(other.name)) {}
};

struct Defaulted {
    std::string name;
    Defaulted(Defaulted&&) = default;
};

struct Implicit {
    std::string name;
};

struct Holder {
    std::string name;
    Written member;
};

int main() {
    std::cout << std::boolalpha;
    std::cout << "Written   " << std::is_nothrow_move_constructible_v<Written> << '\n';
    std::cout << "Promised  " << std::is_nothrow_move_constructible_v<Promised> << '\n';
    std::cout << "Defaulted " << std::is_nothrow_move_constructible_v<Defaulted> << '\n';
    std::cout << "Implicit  " << std::is_nothrow_move_constructible_v<Implicit> << '\n';
    std::cout << "Holder    " << std::is_nothrow_move_constructible_v<Holder> << '\n';
}
