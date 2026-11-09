# Language Learning by Comparison

Small, runnable programs for learning how programming languages express the same ideas differently. Examples are organized by **concept first** so implementations can be compared side by side.

## Quick start

List the available examples:

```sh
./run list
```

Run one example or every example:

```sh
./run error-hierarchies
./run all
```

These commands show the programs' actual output so you can compare it directly with the source. To run automated output and compiler-diagnostic assertions instead, use:

```sh
./run check
```

The runner builds in temporary directories where practical. Rust's Cargo output is written to `target/`, which is ignored by Git.

## Repository layout

```text
.
├── run                         # Repository-level example runner
└── examples/
    ├── error-hierarchies/      # C++ exceptions/expected vs Rust Result/panic
    │   ├── cpp/
    │   └── rust/
    ├── ownership-and-borrowing/
    │   └── rust/self-address/  # Moving and borrowing `self`
    └── thread-lifetime/
        └── cpp/                # Joinable thread destruction
```

Each topic owns its sources and any topic-specific run or test harness. Cross-language examples live in sibling language directories within the same topic.

## Examples

### Error hierarchies

The [Notion notes](https://app.notion.com/p/413e5d67dda680928e80e372f34c7a98) compare how C++ and Rust preserve error details as a failure moves through a program.

| Source | What it demonstrates |
| --- | --- |
| `examples/error-hierarchies/cpp/exceptions.cpp` | Handler order, slicing when catching by value, and `throw;` versus `throw e;`. |
| `examples/error-hierarchies/cpp/expected.cpp` | Manual propagation with `std::expected` and nested `std::variant` types. |
| `examples/error-hierarchies/rust/result.rs` | Nested errors, exhaustive matching, and propagation through `?` and `From`. |
| `examples/error-hierarchies/rust/panic.rs` | Catching an unwinding panic and inspecting its payload. |

This example requires Clang with C++23 `<expected>` support and `rustc`. The fetches are simulated. Run `./run error-hierarchies` to see the successful programs side by side. Run `./run check` to also verify the intentionally triggered C++ handler-order warning and Rust E0277 diagnostic.

### Ownership and borrowing

The Rust self-address example prints stack and heap addresses before and after borrowing or moving a value. Exact addresses vary on every run; compare the relationships between them.

### Thread lifetime

The C++ example demonstrates why destroying a joinable `std::thread` calls `std::terminate`, including when another exception is already unwinding the stack. Its abnormal exit is intentional and counted as a successful observation by the harness.

## Adding an example

1. Create `examples/<concept>/<language>/` and keep all files for the concept together.
2. Add a small `run.sh` when the example needs compilation flags, expected-output checks, or an intentionally failing command.
3. Register a stable ID in the root `run` script and document the concept here.

Prefer examples that are focused, deterministic where possible, and explicit about whether compilation or runtime failure is intentional.
