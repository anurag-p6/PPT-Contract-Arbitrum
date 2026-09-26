// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface INonfungiblePositionManager {
    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)
        external
        payable
        returns (address pool);

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
}

/// @notice Creates the Arbitrum Sepolia PPT/USDC 1% pool and adds a full-range position.
/// @dev Does not deploy PPT. The broadcaster must already hold the PPT and test USDC.
contract CreatePPTUSDCPool is Script {
    address internal constant PPT = 0x38c505EE3FDf02C0A041B08611aDB2F1d92DF410;
    address internal constant USDC = 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;
    address internal constant POSITION_MANAGER = 0x6b2937Bde17889EDCf8fbD8dE31C3C2a70Bc4d65;

    uint24 internal constant FEE = 10_000;
    int24 internal constant TICK_LOWER = -887_200;
    int24 internal constant TICK_UPPER = 887_200;

    // 1,000 PPT and 10 USDC. The starting price stays 0.01 USDC per PPT.
    uint256 internal constant AMOUNT_PPT = 1_000 ether;
    uint256 internal constant AMOUNT_USDC = 10 * 1e6;

    function run() external {
        address lp = msg.sender;
        require(PPT < USDC, "token order");
        require(IERC20(PPT).balanceOf(lp) >= AMOUNT_PPT, "insufficient PPT");
        require(IERC20(USDC).balanceOf(lp) >= AMOUNT_USDC, "insufficient USDC");

        // sqrtPriceX96 = 2^96 / 1e7, which is 0.01 USDC (6 decimals) per 1 PPT (18 decimals).
        uint160 sqrtPriceX96 = uint160((uint256(1) << 96) / 1e7);

        vm.startBroadcast();

        require(IERC20(PPT).approve(POSITION_MANAGER, AMOUNT_PPT), "PPT approve failed");
        require(IERC20(USDC).approve(POSITION_MANAGER, AMOUNT_USDC), "USDC approve failed");

        address pool = INonfungiblePositionManager(POSITION_MANAGER)
            .createAndInitializePoolIfNecessary(PPT, USDC, FEE, sqrtPriceX96);

        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = INonfungiblePositionManager(
            POSITION_MANAGER
        ).mint(
            INonfungiblePositionManager.MintParams({
                token0: PPT,
                token1: USDC,
                fee: FEE,
                tickLower: TICK_LOWER,
                tickUpper: TICK_UPPER,
                amount0Desired: AMOUNT_PPT,
                amount1Desired: AMOUNT_USDC,
                amount0Min: 0,
                amount1Min: 0,
                recipient: lp,
                deadline: block.timestamp + 30 minutes
            })
        );

        vm.stopBroadcast();

        console.log("Pool:", pool);
        console.log("Position NFT:", tokenId);
        console.log("Liquidity:", liquidity);
        console.log("PPT deposited:", amount0);
        console.log("USDC deposited:", amount1);
        console.log("Position owner:", lp);
    }
}
