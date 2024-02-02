# <h1 align="center"> Solidity Calldata Compression & Decompression </h1>

![Rust](https://github.com/coolcode/solidity-compression-decompression/actions/workflows/rust.yml/badge.svg)
![Node](https://github.com/coolcode/solidity-compression-decompression/actions/workflows/node.yml/badge.svg)
![Test](https://github.com/coolcode/solidity-compression-decompression/actions/workflows/test.yml/badge.svg)

Explore the world of Solidity calldata compression and decompression in this open-source project. This initiative aims to compare various compression methods, evaluating their effectiveness and performance.

## Getting Started

rust build

```sh
cd diff
cargo build --release
```

node.js build

```sh
cd js
pnpm install
pnpm compress 0xa9059cbb000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000de0b6b3a7640000
```

forge build and test

```sh
forge build
forge test
```

## References

- [1inch Compression](https://github.com/1inch/calldata-compressor)
- [ZeroKompressed](https://github.com/clabby/op-kompressor)