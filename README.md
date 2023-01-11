# Harvest0r 🚜🚜🚜

Harvestors allow users to take advantage of tax-loss harvesting by making a market
for a specified token and buying it at a constant price of `0.0069` ether.  

A user can create a market for any token they wish to harvest by using the `Harvest0rFactory`

The HARVEST0R projects consists of `Harvest0r.sol`, `Seeds.sol` and the `Harvest0rFactory.sol` contracts.  

To access Harvestors you need a `Seeds Access Voucher` NFT with enough charge.

The flow to use a `Harvest0r` is:
1. Obtain a `Seeds Access Voucher` NFT
2. Navigate to the `Harvest0rFactory` and either deploy a `Harvest0r` for the token you want to harvest, or find the `Harvest0r` address if already deployed.
3. Access the `sellToken` functionality of the `Harvest0r`-token pair. You will receive a constant `0.0069 ether` per sale. This consumes one charge of the `SEEDS` NFT.
4. Should the charges become depleted you can replenish the NFT's charges by calling `recharge` on the `SEEDS` NFT contract, this costs `0.069 ether` for 9 charges.  


## IMPORTANT
1. Tax-loss harvesting is legal in certain jurisdictions, but **it is ALWAYS the user's responsibility to be aware of the tax and legal consequences of any action they take, especially on the blockchain where transactions are not private and do not disappear**. Do not interact with the contracts if you intend to use it in an illegal manner. Always assume all addresses used at least once as doxxed. The creator cannot accept responsibility for your actions.

2. The tokens sold to the Harvestors do not return to the users. The owners can sell these tokens at a later stage should it become profitable. This is part of the business model.

## Harvest0rFactory  

`HarvestorFactory.sol` allows users to deploy Harvestors for specific tokens using `newHarvestor`.

A user can use `findHarvestor(token)` to find the appropriate Harvestor-Token pair.

## Seeds Access Voucher  

The Seeds Access Voucher NFTs (SEEDS) are required to allow access to Harvestor Contracts.

Only 1000 of these vouchers can be minted, at a price of 0.069 eth. Max 5 per wallet.

As evidenced in the code, in effect only 10% of the minting price goes to the creators.

The Seeds NFTs hold 9 charges, which grants access to the `sellToken` functionality of the Harvest0r 9 times.

Once depleted the NFT can be recharged through the `recharge` function of the `Seeds.sol` contract.

This project was created as part of the BuidlGuidl and is built on Scaffold-eth

# 🏗 Scaffold-ETH

> everything you need to build on Ethereum! 🚀

🧪 Quickly experiment with Solidity using a frontend that adapts to your smart contract:

![image](https://user-images.githubusercontent.com/2653167/124158108-c14ca380-da56-11eb-967e-69cde37ca8eb.png)


# 🏄‍♂️ Quick Start

Prerequisites: [Node (v18 LTS)](https://nodejs.org/en/download/) plus [Yarn (v1.x)](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

🚨 If you are using a version < v18 you will need to remove `openssl-legacy-provider` from the `start` script in `package.json`

> clone/fork 🏗 scaffold-eth:

```bash
git clone https://github.com/scaffold-eth/scaffold-eth.git
```

> install and start your 👷‍ Hardhat chain:

```bash
cd scaffold-eth
yarn install
yarn chain
```

> in a second terminal window, start your 📱 frontend:

```bash
cd scaffold-eth
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
cd scaffold-eth
yarn deploy
```
# 🏃💨 Speedrun Ethereum
Register as a builder [here](https://speedrunethereum.com) and start on some of the challenges and build a portfolio.

# 💬 Support Chat

Join the telegram [support chat 💬](https://t.me/joinchat/KByvmRe5wkR-8F_zz6AjpA) to ask questions and find others building with 🏗 scaffold-eth!

---

🙏 Please check out our [Gitcoin grant](https://gitcoin.co/grants/2851/scaffold-eth) too!

### Automated with Gitpod

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/scaffold-eth/scaffold-eth)
