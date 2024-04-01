// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ELP_Marketplace is ReentrancyGuard
{
    address constant ELP= 0xb14A59F98a2E1F0C8567EA628FB1D94f00509D03; 

    struct Listing
    {
        address seller;
        uint256 quantity;
        uint256 totalPrice;
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public listingCount;

    event ListingCreated(uint256 indexed id, address seller, uint256 quantity, uint256 totalPrice);
    event TradeExecuted(uint256 indexed id, address buyer, uint256 quantity, uint256 totalPrice);

    function createListing(uint256 quantity, uint256 totalPrice) external
    {
        require(quantity > 0 && totalPrice > 0, "Error - MARKETPLACE.sol - Function:createListing - Invalid listing parameters");
        uint256 id = listingCount++;
        listings[id] = Listing(msg.sender, quantity, totalPrice, true);
        emit ListingCreated(id, msg.sender, quantity, totalPrice);
    }

    function buyListing(uint256 id) external payable nonReentrant
    {
        require(listings[id].isActive, "Error - MARKETPLACE.sol - Function:buyListing - Listing is inactive");
        require(msg.value == listings[id].totalPrice, "Error - MARKETPLACE.sol - Function:buyListing - Incorrect payment amount");
        require(IERC20(ELP).allowance(listings[id].seller,address(this))>=listings[id].quantity,"Error - MARKETPLACE.sol - Function:buyListing - Seller denied the the contract's spending approval");
        require(IERC20(ELP).balanceOf(listings[id].seller)>=listings[id].quantity,"Error - MARKETPLACE.sol - Function:buyListing - Seller doesn't have enough balance any more!");

        IERC20(ELP).transferFrom(listings[id].seller, msg.sender, listings[id].quantity);

        payable(listings[id].seller).transfer(msg.value);

        listings[id].isActive = false;

        emit TradeExecuted(id, msg.sender, listings[id].quantity, msg.value);
    }
}



//This attempt's contract is: 0x796E47cD6fF1CAE55E47174D7e2a8FD1e2ADB632