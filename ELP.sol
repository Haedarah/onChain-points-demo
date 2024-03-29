// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ELP is ERC20 
{
    address public ownerAndDistributor;
    uint256 allTokens=10**18;

    event paidForTransferring(address user);
    event transferred(address user,uint256 value);

    constructor() ERC20("EigenLayerPoints","ELP")
    {
        ownerAndDistributor=msg.sender;
        _mint(ownerAndDistributor,allTokens*(10**uint256(decimals())));
    }

    modifier onlyDistributor()
    {
        require(msg.sender == ownerAndDistributor, "Error - ELP.sol - Modifier:onlyDistributor - onlyDistributor function");
        _;
    }

    function decimals() public pure override returns (uint8)
    {
        return 4;
    }

    function transferTokensByDistributor(address user, uint256 value) onlyDistributor public
    {
        require(value>0,"Error - ELP.sol - Function:transferTokensByDistributor - User has no points!");

        transfer(user,value);

        emit transferred(user,value);
    }

    function OrderYourTokens() payable public
    {
        require(msg.value==0.1 ether,"Error - ELP.sol - Function:OrderYourTokens - User Didn't pay conversion fee");
        
        emit paidForTransferring(msg.sender);
    }

    function withdrawOrderingFees() onlyDistributor() public
    {
        payable(ownerAndDistributor).transfer(address(this).balance);
    }
}