# Calldata Compression & Decompression on Rust 

A simple rust binary for differential testing the Solidity implementations of various decoding schemes as well as encoding data. To be used as an FFI sidecar in `op-kompressor`'s test suite.

```sh
cargo run --bin diff -- --in-bytes a9059cbb000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000de0b6b3a7640000 --mode zero-kompress 
```

or

```sh
target/debug/diff --in-bytes a9059cbb000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000de0b6b3a7640000 --mode zero-kompress 
```
