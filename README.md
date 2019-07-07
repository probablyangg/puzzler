# Puzzler :game_die:

A simple Ethereum based decentralized application demonstrating usage of ERC-721 tokens.

## Description

<!-- ![Puzzler](./puzzler.png) -->
<p align = center><img src="./puzzler.png" center></p>

- Answering questions would increment the level for the user.
- Each puzzle solved mints an ERC-721 token (PZLR), which is owned by the smart contract. Called 'Spiro' in the game.
- Each Spiro is representative of: 
  - creator 
  - level at which it was created
- Each user can own a single Spiro that represents the current level of the user in the game.
- User has an option to sell that spiro
  - would reset his/her level to 0
- Available spiros with level strictly greater than user's level are displayed in the left. These spiros can be bought to level up. 
- Total number of questions is the number of questions available in the database - currently a .json file
  - can also be seen as the "max level reachable"
- Contract is currently deployed on Ropsten Testnet

## Usage

- **0 PZLR** or the **0th Spiro** is the initial token - basically, nothing can be done with it. Think of it as a null/starting token
  - the 0th question generates 0th spiro
- Each user can own only a single spiro
- Answering a question 
  - correctly
    - increments your level
    - generates a spiro with your address as the creator and your level
  - incorrectly
    - generates an alert on the page
- User can buy one of the spiros owned by the contract - to level up.
- User can sell his/her owned token - would change level and spiro to 0.

## Running Locally

Clone this repo to your local machine and install the dependencies:

```bash
git clone https://github.com/nglglhtr/puzzler.git
cd puzzler
npm i
```
Serve the application

```bash
npm run dev
```
Switch to Ropsten Testnet on Metamask

## Built With

* [Solidity](https://solidity.readthedocs.io/en/v0.5.3/) - v0.5.3 (compiled on Remix IDE, solc `v0.5.3+commit.10d17f24.Emscripten.clang`)
* [Vue.js](https://vuejs.org/) 
* [Metamask](https://metamask.io/)
* [web3.js](https://github.com/ethereum/web3.js/)


(Contract Address: [0x989da6d8a9358d7de3859cf3a15303e9c673cf55](https://ropsten.etherscan.io/token/0x989da6d8a9358d7de3859cf3a15303e9c673cf55))