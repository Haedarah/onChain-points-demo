// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EIGEN is ERC20
{
    address public owner;
    uint256 constant public maxSupply=21000000;
    
    constructor() ERC20("EigenLayerTokens","EIGEN")
    {
        owner=msg.sender;
        _mint(owner,maxSupply*(10**uint256(decimals())));
    }

}