// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Park Pro Token (PPT)
/// @notice ERC-20 token with a capped supply. Owner should be a multisig in production.
contract PPTToken is ERC20, Ownable {
    uint256 private constant TOKEN_UNIT = 1e18;
    uint256 public constant MAX_SUPPLY = 1e9 * TOKEN_UNIT;

    error MaxSupplyExceeded();

    /**
     * @param initialSupply Initial supply in whole tokens (e.g. 1000 = 1000 PPT)
     */
    constructor(uint256 initialSupply) ERC20("Park Pro Token", "PPT") Ownable(msg.sender) {
        uint256 supply = initialSupply * TOKEN_UNIT;
        if (supply > MAX_SUPPLY) revert MaxSupplyExceeded();
        _mint(msg.sender, supply);
    }

    /**
     * @param to Recipient address
     * @param amount Number of whole tokens to mint (e.g. 1 = 1 PPT)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        uint256 mintAmount = amount * TOKEN_UNIT;
        if (totalSupply() + mintAmount > MAX_SUPPLY) revert MaxSupplyExceeded();
        _mint(to, mintAmount);
    }
}
