#include <expected>
#include <iostream>
#include <string>
#include <utility>
#include <variant>

struct Timeout { int ms; };
struct Refused {};
using NetworkError = std::variant<Timeout, Refused>;

struct Missing { std::string file; };
using ConfigError = std::variant<Missing>;
using AppError = std::variant<NetworkError, ConfigError>;

enum class Scenario { success, timeout, refused, missing_config };

std::expected<std::string, NetworkError> fetch(Scenario scenario) {
    if (scenario == Scenario::timeout) {
        return std::unexpected(NetworkError{Timeout{1500}});
    }
    if (scenario == Scenario::refused) {
        return std::unexpected(NetworkError{Refused{}});
    }
    return "response";
}

std::expected<std::string, AppError> handle(Scenario scenario) {
    if (scenario == Scenario::missing_config) {
        return std::unexpected(AppError{ConfigError{Missing{"app.toml"}}});
    }

    auto body = fetch(scenario);
    if (!body) {
        return std::unexpected(AppError{std::move(body).error()});
    }
    return *std::move(body);
}

void report(const std::expected<std::string, AppError>& result) {
    if (result) {
        std::cout << "got " << *result << '\n';
        return;
    }

    if (const auto* network = std::get_if<NetworkError>(&result.error())) {
        if (const auto* timeout = std::get_if<Timeout>(network)) {
            std::cout << "retry after " << timeout->ms << " ms\n";
        } else {
            std::cout << "give up: connection refused\n";
        }
        return;
    }

    const auto& config = std::get<ConfigError>(result.error());
    std::cout << "give up: missing " << std::get<Missing>(config).file << '\n';
}

int main() {
    report(handle(Scenario::success));
    report(handle(Scenario::timeout));
    report(handle(Scenario::refused));
    report(handle(Scenario::missing_config));
}
