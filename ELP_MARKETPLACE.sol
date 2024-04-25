// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ELP_Marketplace is ReentrancyGuard
{
    enum status{live,cancelled,bought}

    address ELP; //The address of the $ELPs contract
    
    struct Listing
    {
        address seller;
        uint256 quantity;
        uint256 totalPrice;
        status listingStatus;
    }

    //mapping(uint256 => Listing) public listings;
    Listing[] public listings;
    mapping(address => uint256) public totalPointsListedByUser;

    event ListingCreated(uint256 indexed id, address seller, uint256 quantity, uint256 totalPrice);
    event ListingCancelled(uint256 indexed id, address seller);
    event TradeExecuted(uint256 indexed id, address buyer, uint256 quantity, uint256 totalPrice);


    constructor(address _ELP)
    {
        ELP=_ELP;
    }

    //approval must be asked for

    function createListing(uint256 quantity, uint256 totalPrice) external
    {
        require(quantity > 0 && totalPrice > 0, "Error - MARKETPLACE.sol - Function:createListing - Invalid listing parameters");
        require(IERC20(ELP).balanceOf(msg.sender)>=quantity, "Error - MARKETPLACE.sol - Function:createListing - You are trying to list more tokens than you have");
        require(totalPointsListedByUser[msg.sender]<=IERC20(ELP).balanceOf(msg.sender), "Error - MARKETPLACE.sol - Function:createListing - You do not have enough points to list this");

        listings.push(Listing(msg.sender, quantity, totalPrice, status.live));
        totalPointsListedByUser[msg.sender]+=quantity;
        
        emit ListingCreated(listings.length-1, msg.sender, quantity, totalPrice);
    }

    function cancelListing(uint256 id) external
    {
        require (msg.sender==listings[id].seller,"Error - MARKETPLACE.sol - Function:cancelListing - You are not the owner of this listing");
        require (listings[id].listingStatus==status.live,"Error - MARKETPLACE.sol - Function:cancelListing - You can not cancel this listing");

        listings[id].listingStatus=status.cancelled;
        totalPointsListedByUser[msg.sender]-=listings[id].quantity;

        emit ListingCancelled(id,msg.sender);
    }

    function buyListing(uint256 id) external payable nonReentrant
    {
        require(listings[id].listingStatus==status.live, "Error - MARKETPLACE.sol - Function:buyListing - Listing is not live");
        require(msg.value == listings[id].totalPrice, "Error - MARKETPLACE.sol - Function:buyListing - Incorrect payment amount");
        require(IERC20(ELP).allowance(listings[id].seller,address(this))>=listings[id].quantity,"Error - MARKETPLACE.sol - Function:buyListing - Seller denied the the contract spending approval");
        require(IERC20(ELP).balanceOf(listings[id].seller)>=listings[id].quantity,"Error - MARKETPLACE.sol - Function:buyListing - Seller does not have enough balance to complete the sale");

        IERC20(ELP).transferFrom(listings[id].seller, msg.sender, listings[id].quantity);

        payable(listings[id].seller).transfer(msg.value);

        listings[id].listingStatus = status.bought;
        totalPointsListedByUser[listings[id].seller]-=listings[id].quantity;

        emit TradeExecuted(id, msg.sender, listings[id].quantity, msg.value);
    }

    function getListings() public view returns (Listing[] memory)
    {
        return listings;
    }

}
