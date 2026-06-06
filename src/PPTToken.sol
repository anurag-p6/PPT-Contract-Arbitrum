// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PPTToken is ERC20, Ownable {
    // Custom errors
    error Unauthorized();
    error MedInvoiceAlreadySet();
    error ZeroAddress();
    error OnlyMedInvoiceContract();

    // State variables
    address public medInvoiceContract;

    //Event
    event MedInvoiceContractSet(address newMedInvoiceContract);

    /**
     * @dev Constructor
     * @param initialSupply The initial supply of the token
     */
    constructor(uint256 initialSupply) ERC20("Park Pro Token", "PPT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    /**
     * @dev Mint tokens
     * @notice Only the medInvoiceContract can call this function
     * @param to The address to mint tokens to
     * @param amount The amount in raw token units (smallest unit, e.g. 1e18 = 1 PPT)
     */
    function mint(address to, uint256 amount) public {
        if (msg.sender != medInvoiceContract) {
            revert Unauthorized();
        }
        _mint(to, amount);
    }

    /**
     * @dev Set the medInvoiceContract
     * @notice Only the owner can call this function
     * @param _medInvoiceContract The address of the medInvoiceContract
     */
    function setMedInvoiceContract(address _medInvoiceContract) external onlyOwner {
        if (_medInvoiceContract == address(0)) {
            revert ZeroAddress();
        }
        if (medInvoiceContract != address(0)) {
            revert MedInvoiceAlreadySet();
        }
        medInvoiceContract = _medInvoiceContract;
        emit MedInvoiceContractSet(_medInvoiceContract);
    }

    /**
     * @dev Get the medInvoiceContract
     * @return The medInvoiceContract address
     */
    function getMedInvoiceContract() external view returns (address) {
        return medInvoiceContract;
    }
}
