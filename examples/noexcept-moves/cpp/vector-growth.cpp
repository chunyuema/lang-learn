#include <iostream>
#include <vector>

struct Item {
    int id;

    explicit Item(int id) : id(id) {}
    Item(const Item& other) : id(other.id) {
        std::cout << "  copy " << id << '\n';
    }
    Item(Item&& other) : id(other.id) {
        std::cout << "  move " << id << '\n';
    }
};

int main() {
    std::vector<Item> items;
    for (int id = 0; id < 3; ++id) {
        std::cout << "push " << id << " (capacity " << items.capacity() << ")\n";
        items.emplace_back(id);
    }
}
