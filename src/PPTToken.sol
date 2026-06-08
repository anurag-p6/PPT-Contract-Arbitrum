// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PPTToken is ERC20, Ownable {
    /**
     * @param initialSupply Initial supply in whole tokens (e.g. 1000 = 1000 PPT)
     */
    constructor(uint256 initialSupply) ERC20("Park Pro Token", "PPT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /**
     * @param to Recipient address
     * @param amount Number of whole tokens to mint (e.g. 1 = 1 PPT)
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount * 10 ** decimals());
    }
}
