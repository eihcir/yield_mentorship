// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@yield-protocol/utils-v2/contracts/token/IERC20.sol";
import "./AMMCore.sol";

/// @title AMMRouter
/// @author devtooligan.eth
/// @notice Simple Automated Market Maker - Router contract. An excercise for the Yield mentorship program
/// @dev Uses AMMCore
contract AMMRouter {
    AMMCore public core;
    address public owner;

    modifier isInitialized() {
        require(core.k() > 0, "Not initialized");
        _;
    }

    constructor(AMMCore _core) {
        owner = msg.sender;
        core = _core;
    }

    // @notice Use this function to initialize k and add liquidity
    // @dev Can only be used once
    // @param wadX The amount of tokenX to add
    // @param wadY The amount of tokenY to add
    function init(uint256 wadX, uint256 wadY) external {
        require(msg.sender == owner, "Unauthorized");
        require(core.k() == 0, "Already initialized");
        require(wadX > 0 && wadY > 0, "Invalid amounts");
        IERC20 tokenX;
        uint256 reserveX;
        (tokenX, reserveX) = core.x();
        IERC20 tokenY;
        uint256 reserveY;
        (tokenY, reserveY) = core.y();
        tokenX.transferFrom(owner, address(core), wadX);
        tokenY.transferFrom(owner, address(core), wadY);
        core._init(msg.sender);
    }

    // @notice Use this function to add liquidity in the correct ratio, receive LP tokens
    // @param wadX The amount of tokenX to add
    // @param wadY The amount of tokenY to add
    function mint(uint256 wadX, uint256 wadY) external isInitialized {
        require(wadX > 0 && wadY > 0, "Invalid amounts");
        IERC20 tokenX;
        uint256 reserveX;
        (tokenX, reserveX) = core.x();
        IERC20 tokenY;
        uint256 reserveY;
        (tokenY, reserveY) = core.y();
        require((reserveX / reserveY) == (wadX / wadY), "Invalid amounts");

        tokenX.transferFrom(msg.sender, address(core), wadX);
        tokenY.transferFrom(msg.sender, address(core), wadY);
        core._mintLP(msg.sender);
    }

    // @notice Use this function to remove liquidity and get back tokens
    // @param wad The amount of LP tokens to burn
    function burn(uint256 wad) external isInitialized {
        require(wad > 0, "Invalid amount");
        require(core.balanceOf(msg.sender) >= wad, "Insufficent balance");
        core._burnLP(msg.sender, wad);
    }

    // @notice Use this function to sell an exact amount of tokenX for the going rate of tokenY
    // @param wad The amount of tokenX to sell
    function sellX(uint256 wad) external isInitialized {
        require(wad > 0, "Invalid amount");
        IERC20 tokenX;
        uint256 reserveX;
        (tokenX, reserveX) = core.x();
        tokenX.transferFrom(msg.sender, address(core), wad);
        core._swapX(msg.sender);
    }

    // @notice Use this function to sell an exact amount of tokenY for the going rate of tokenX
    // @param wad The amount of tokenY to sell
    function sellY(uint256 wad) external isInitialized {
        require(wad > 0, "Invalid amount");
        IERC20 tokenY;
        uint256 reserveY;
        (tokenY, reserveY) = core.y();
        tokenY.transferFrom(msg.sender, address(core), wad);
        core._swapY(msg.sender);
    }
}