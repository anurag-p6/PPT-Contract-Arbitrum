# PPT–USDC pool on Arbitrum Sepolia

This creates a Uniswap v3 pool for Park Pro Token (PPT) against test USDC on Arbitrum Sepolia. The starting price is **0.01 USDC per PPT**. The pool deposits **1,000 PPT** and **10 USDC** in a full-range position with a **1%** fee.

Use a separate test wallet. Do not use a key that holds mainnet funds, and do not commit `.env`.

The Uniswap website does not list Arbitrum Sepolia. After the script succeeds, the pool is visible on the Sepolia explorer, not on [app.uniswap.org](https://app.uniswap.org).

## What you need

- [Foundry](https://getfoundry.sh/)
- A test wallet private key
- An Arbitrum Sepolia RPC URL. A public one is `https://sepolia-rollup.arbitrum.io/rpc`

MetaMask network:

| Field | Value |
| --- | --- |
| Network | Arbitrum Sepolia |
| RPC | `https://sepolia-rollup.arbitrum.io/rpc` |
| Chain ID | `421614` |
| Symbol | ETH |
| Explorer | `https://sepolia.arbiscan.io` |

Contracts the script calls:

| Contract | Address |
| --- | --- |
| Test USDC (6 decimals) | `0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d` |
| Uniswap v3 position manager | `0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65` |
| Uniswap v3 factory | `0x248AB79Bbb9bC29bB72f7Cd42F17e054Fc40188e` |

## 1. Configure the project

```bash
cp .env.example .env
```

Set these in `.env`:

```bash
ARBITRUM_SEPOLIA_RPC=https://sepolia-rollup.arbitrum.io/rpc
PRIVATE_KEY=your_test_wallet_private_key
```

Load them in the shell before every `forge` command below:

```bash
set -a && source .env && set +a
```

## 2. Get test ETH

The wallet needs a little ETH for gas. Request it from the [Alchemy Arbitrum Sepolia faucet](https://www.alchemy.com/faucets/arbitrum-sepolia).

## 3. Deploy PPT

`script/DeployPPTToken.s.sol` mints **200,000 PPT** to the deployer. That is enough for the 1,000 PPT deposit.

```bash
forge script script/DeployPPTToken.s.sol:DeployPPTToken \
  --rpc-url arbitrum-sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

Copy the `PPTToken deployed at:` address from the log.

Open `script/CreatePPTUSDCPool.s.sol` and replace the `PPT` constant with that address. Leave the USDC address as it is. The script always sends PPT first and USDC second. The new PPT address must be lower than the USDC address (`0x75fa...`). The reference PPT address already is.

## 4. Get test USDC

Request Arbitrum Sepolia USDC from the [Circle faucet](https://faucet.circle.com/) to the **same wallet** that holds the PPT. One claim is 20 USDC. The script needs **10 USDC**.

Import the test USDC address in the wallet if the balance does not show up. It has 6 decimals.

## 5. Create the pool

```bash
forge script script/CreatePPTUSDCPool.s.sol:CreatePPTUSDCPool \
  --rpc-url arbitrum-sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

The script does four things:

1. Approves 1,000 PPT to the position manager.
2. Approves 10 USDC to the position manager.
3. Creates the PPT–USDC 1% pool and sets the price to 0.01 USDC per PPT.
4. Adds a full-range position. The broadcasting wallet receives the liquidity NFT.

A successful run ends with `ONCHAIN EXECUTION COMPLETE & SUCCESSFUL` and prints:

- `Pool`
- `Position NFT`
- `PPT deposited`
- `USDC deposited`
- `Position owner`

`insufficient PPT` means that wallet holds less than 1,000 PPT. `insufficient USDC` means it holds less than 10 test USDC.

## 6. Check the result

Open the pool address on [sepolia.arbiscan.io](https://sepolia.arbiscan.io). Under **Read Contract**:

- `token0()` returns the PPT address and `token1()` returns the USDC address
- `fee` is `10000` (1%)
- `liquidity` is non-zero

The position NFT is token id `Position NFT` on the position manager:

`https://sepolia.arbiscan.io/nft/0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65/<token-id>`

That NFT is the liquidity. The wallet that holds it can withdraw the position.

## Reference deployment

This repository already has one finished testnet pool. It is an example. Deploy a new PPT token for a new run, because that supply belongs to the original deployer.

| Item | Value |
| --- | --- |
| PPT | `0x38c505EE3FDf02C0A041B08611aDB2F1d92DF410` |
| Pool | `0x78ddbaba2b828bf7fdbced46ade0c8034d23039d` |
| Position NFT | `3801` |
| Position owner | `0x225Fd0b9D011C8BBffd0f0c6f854Cd23b99B6aF7` |
| Pool explorer | [sepolia.arbiscan.io/address/0x78ddbaba2b828bf7fdbced46ade0c8034d23039d](https://sepolia.arbiscan.io/address/0x78ddbaba2b828bf7fdbced46ade0c8034d23039d) |
