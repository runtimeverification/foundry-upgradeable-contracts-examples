# Exploring Upgradeable Contracts With Foundry

This repo contains a Foundry project that illustrates the basic implementation
techniques that are used when implementing upgradeable contracts.

## Getting Started

First, you need to install Foundry. To do so, follow the instructions
[here](https://book.getfoundry.sh/getting-started/installation).

Then cloning the repository and running all tests is as simple as
```sh
git clone https://github.com/runtimeverification/foundry-upgradeable-contracts-examples.git
forge test
```

By default, `forge test` will run all tests. To only run the tests of a single
test contract, you can use `--match-contract`:
```sh
forge test --match-contract StorageTest
```

Also, log messages emitted by `console.log()` will not be shown by default. To
see them, you need to increase the verbosity with `-vvv`:
```sh
forge test --match-contract DelegateCallTest -vvv
```

## Repository Contents

All code can be found in the `test/` directory. It contains the following test
contracts:
- [`StorageTest`](test/Storage.t.sol): Shows how we can manually load the value stored in a specific slot
- [`DelegateCallTest`](test/DelegateCall.t.sol): Demonstrates the use of `delegatecall`
- [`FallbackTest`](test/Fallback.t.sol): Demonstrates the use of fallback functions
- [`FaultyProxyTest`](test/FaultyProxy.t.sol): Shows what can go wrong when trying to implement a proxy
- [`ProxyTest`](test/Proxy.t.sol): Shows a working proxy implementation


---

**DISCLAIMER:** The files in this repository are toy examples only meant to
illustrate how upgradeable contracts work. The code is not intended to be used in production.
Runtime Verification will not be held accountable should you do otherwise.
