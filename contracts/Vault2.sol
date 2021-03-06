// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@yield-protocol/utils-v2/contracts/token/ERC20.sol";
import "@yield-protocol/utils-v2/contracts/token/IERC20.sol";

// @title NewVault
// @dev Standard vault for single ERC-20 token type - part of an excercise for the Yield mentorship
// Issues TooliganVaultToken ERC20 tokens for deposits
contract Vault2 is ERC20("TooliganVaultToken", "TVT", 18) {
    //@notice This vault only accepts one type of token which is passed in at deploy
    IERC20 public _token;

    event Deposit(uint256 wad);
    event Withdraw(uint256 wad);

    constructor(IERC20 token) {
        _token = token;
    }

    // @notice Function to deposit funds into the vault by means of
    // transfering in tokens and minting TVT to the depositor
    // @param wad Amount being deposited
    function deposit(uint256 wad) external {
        _mint(msg.sender, wad);
        _token.transferFrom(msg.sender, address(this), wad);
        emit Deposit(wad);
    }

    // @notice Function to withdraw funds from the vault by means of
    // transfering in TVT tokens and burning them, then transferring out
    // the ERC20 tokens
    // @param wad Amount being withdrawn
    function withdraw(uint256 wad) external {
        _burn(msg.sender, wad);
        _token.approve(msg.sender, wad);
        _token.transfer(msg.sender, wad);
        emit Withdraw(wad);
    }
}
