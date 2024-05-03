// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Template is ERC20 
{
    address public owner; //The owner (the company that has the points)
    address public distributor; // The (off-chain -> on-chain) points distributor
    uint256 allPoints; //10**18 for points (a very big number that points issued by a company won't exceed)
    uint8 decimal;
    uint256 public orderingFee; // The fee of redeeming off-chain points into on-chain points. (in Wei)

    event paidForTransferring(address user);
    event transferred(address user,uint256 value);

    error UserHasNoPoints(address user);
    error DidNotPayOrderingFee(uint256 AttemptedToTransferByUser,uint256 _orderingFee);

    constructor(
        address _owner,
        address _distributor, 
        uint256 _allPoints,
        uint8 _decimal,
        uint256 _orderingFee,
        string memory _pointName,
        string memory _pointSymbol
    ) ERC20(_pointName,_pointSymbol)
    {
        owner=_owner;
        distributor=_distributor;
        allPoints=_allPoints;
        decimal=_decimal;
        orderingFee=_orderingFee;

        _mint(owner,allPoints*(10**uint256(decimals())));
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner,"onlyOwner");
        _;
    }
    modifier onlyDistributor()
    {
        require(msg.sender == distributor,"onlyDistributor");
        _;
    }

    function decimals() public view override returns (uint8)
    {
        return decimal;
    }

    function transferTokensByDistributor(address user, uint256 value) onlyDistributor public
    {
        if (value<=0)
        {
            revert UserHasNoPoints(msg.sender);
        }

        transferFrom(owner,user,value);

        emit transferred(user,value);
    }

    function OrderYourTokens() payable public
    {
        if (msg.value!=orderingFee)
        {
            revert DidNotPayOrderingFee(msg.value,orderingFee);
        }
        
        emit paidForTransferring(msg.sender);
    }

    function withdrawOrderingFees() onlyDistributor public
    {
        payable(distributor).transfer(address(this).balance);
    }
}
