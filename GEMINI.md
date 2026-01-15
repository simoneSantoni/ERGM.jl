# GEMINI.md - ERGM.jl

## Project Overview

This project is a Julia implementation of Exponential Random Graph Models (ERGMs), inspired by the popular `ergm` R package. ERGMs are a class of statistical models used for analyzing network data.

The project is structured as a Julia package and utilizes several key libraries from the Julia ecosystem:
-   **`Graphs.jl`**: For the underlying graph data structures and algorithms.
-   **`DataFrames.jl`**: For managing vertex attributes.
-   **`Documenter.jl`**: For generating documentation.
-   **`Test.jl`**: For running the test suite.

The core of the package is a Metropolis-Hastings MCMC (Markov Chain Monte Carlo) sampler used to simulate networks from a given ERGM and, eventually, to fit model parameters to observed network data. The implementation is modular, with clear separation between the graph representation, the model terms (network statistics), the MCMC logic, and the user-facing API.

## Building and Running

### Installation and Environment

To work with this project, you'll need to have Julia installed.

1.  **Open the Julia REPL:**
    ```bash
    julia
    ```

2.  **Enter the package manager:**
    Press `]` in the REPL.

3.  **Activate the project environment:**
    This will install the correct versions of all dependencies as specified in `Project.toml` and `Manifest.toml`.
    ```julia
    (@v1.10) pkg> activate .
    ```

4.  **Instantiate the environment:**
    ```julia
    (ERGM) pkg> instantiate
    ```

### Running Tests

The test suite uses the standard `Test.jl` library. To run the tests, make sure you have activated the project environment as described above, then run:

```julia
using Pkg
Pkg.test("ERGM")
```

Alternatively, you can run the `test/runtests.jl` file directly from the Julia REPL.

### Building Documentation

The documentation is built using `Documenter.jl`. To generate the HTML documentation:

1.  Navigate to the `docs/` directory in your terminal.
2.  Run the `make.jl` script with Julia:
    ```bash
    julia make.jl
    ```
The generated documentation will be in the `docs/build/` directory.

## Development Conventions

*   **Code Style**: The code follows standard Julia conventions. It is organized into modules and files with specific purposes (`mcmc.jl`, `model_terms.jl`, `change_stats.jl`, etc.).
*   **Documentation**: Functions are documented using docstrings, which are used to generate the official documentation.
*   **Testing**: Tests are located in the `test/` directory and use `@testset` to group related tests. The tests also serve as a good source of examples for how to use the package's functionality.
*   **Dependencies**: Project dependencies are managed through the `Project.toml` file.
*   **User Interface**: The main user-facing functions are intended to be in `src/ui.jl`, providing a high-level API for users. The `fit` function is the primary entry point for model fitting and returns a `MCMCResult` struct containing simulation statistics.
