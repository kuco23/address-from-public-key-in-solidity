# Ethereum Honeypot

The honeypot attack tries to fool a person into thinking a funded contract is vulnerable to reentrancy.
This is done by publishing a contract that makes external calls to a malicious contract with a deceivably implemented interface.
An example of this is the contract `contracts/Pool.sol`. The honeypot attack is implemented in `test/pool.test.ts`.