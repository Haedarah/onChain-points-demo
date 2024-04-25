// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AIRDROP is ReentrancyGuard
{
    address public constant ELP_tokenContract=0xAf6811D31E359A45EbbC72B4873fB43257B1a6b3;
    address public constant EIGEN_tokenContract=0x8c76c1a8daEB698c742b48f6FA8BBDb8CE4f751a;
    address public owner; //same as EIGEN_TOKEN owner (Makes sense as they are the same company)
    uint256 ELP;
    uint256 EIGEN;

    event TokensExchanged(address indexed user, uint256 ELPs, uint256 EIGENs);

    constructor(uint256 _ELP, uint256 _EIGEN)
    {
        ELP=_ELP;
        EIGEN=_EIGEN;
        owner = msg.sender;
        //Setting the ratio of ELP:EIGEN as 5:1
    }


    //user will need to approve this contract of spending "ELPs"
    function exchangeTokens(uint256 ELPs) external nonReentrant
    {
        require(ELPs > 0, "Error - AIRDROP.sol - Function:exchangeTokens - ELPs must be greater than 0");
        require(msg.sender!=owner,"Error - AIRDROP.sol - Function:exchangeTokens - Owner can not call this function");
        uint256 EIGENs = ELPs*EIGEN/ELP;

        IERC20(ELP_tokenContract).transferFrom(msg.sender,owner,ELPs);
        IERC20(EIGEN_tokenContract).transferFrom(owner,msg.sender,EIGENs);

        emit TokensExchanged(msg.sender, ELPs, EIGENs);
    }

}
