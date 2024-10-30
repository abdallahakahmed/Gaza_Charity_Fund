## Gaza Charity Fund Smart Contract
<h3>This project is a Solidity-based smart contract for a crowdsourced charity fund. The contract enables users to donate Ether to a fund and restricts withdrawals to specific pre-approved addresses, based on defined conditions. The contract is designed for transparency, ease of access, and security, allowing for conditional withdrawal functionality.</h3>

## Project Structure

* Donate.sol: The main contract file that defines the donation and withdrawal functionalities.
* DonorTest.sol: A testing file that uses Foundry to simulate donation and withdrawal scenarios.

## Features
* Donation Mechanism: Users can send Ether to the charity fund using the donate function, with a minimum donation amount requirement.
* Authorized Withdrawals: Only specific pre-approved addresses (e.g., the fund owner) can withdraw funds from the contract.
* Condition Verification: Withdrawals are permitted only when certain conditions are met (e.g., reaching a target donation amount).
* Error Handling: Custom error messages are thrown when users attempt unauthorized actions or transactions fail.

### Setup and Installation

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
