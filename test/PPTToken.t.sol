// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

import "forge-std/Test.sol";
import "../src/PPTToken.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PPTTokenTest is Test {
    PPTToken token;

    function setUp() public {
        token = new PPTToken(1000);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1000 * 1e18);
    }

    function testBalanceOfDeployer() public view {
        assertEq(token.balanceOf(address(this)), 1000 * 1e18);
    }

    function testMaxSupplyConstant() public view {
        assertEq(token.MAX_SUPPLY(), 1e9 * 1e18);
    }

    function testTransfer() public {
        address recipient = address(0x123);
        uint256 amount = 10 * 1e18;

        token.transfer(recipient, amount);
        assertEq(token.balanceOf(recipient), amount);
    }

    function testOwnerCanMintWholeTokens() public {
        address recipient = address(0x456);
        token.mint(recipient, 1);
        assertEq(token.balanceOf(recipient), 1e18);
    }

    function testNonOwnerCannotMint() public {
        vm.prank(address(0x999));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x999)));
        token.mint(address(0x456), 1);
    }

    function testMintToZeroAddressReverts() public {
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InvalidReceiver.selector, address(0)));
        token.mint(address(0), 1);
    }

    function testMintExceedingMaxSupplyReverts() public {
        uint256 wholeTokensOverCap = token.MAX_SUPPLY() / 1e18 - 999 + 1;
        vm.expectRevert(PPTToken.MaxSupplyExceeded.selector);
        token.mint(address(0x456), wholeTokensOverCap);
    }

    function testConstructorExceedingMaxSupplyReverts() public {
        vm.expectRevert(PPTToken.MaxSupplyExceeded.selector);
        new PPTToken(1e9 + 1);
    }
}
