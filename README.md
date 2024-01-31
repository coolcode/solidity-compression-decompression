# <h1 align="center"> Solidity Compression & Decompression </h1>

![Rust CI](https://github.com/coolcode/solidity-compression-decompression/actions/workflows/rust.yml/badge.svg)
![Test CI](https://github.com/coolcode/solidity-compression-decompression/actions/workflows/test.yml/badge.svg)

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
pnpm test 0xa9059cbb000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000de0b6b3a7640000
```

forge build and test

```sh
forge build
forge test
```


## Refs

- [1inch Compression](https://github.com/1inch/calldata-compressor)
- [ZeroKompressed](https://github.com/clabby/op-kompressor)