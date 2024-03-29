// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AIRDROP is ReentrancyGuard
{
    address constant ELP=0x63709E505857e230AF10DeF0E8FCaDA2b563FBfc;
    address constant EIGEN=0x4e890A72CBD3a78500Cd8c44Aa13f48Cdd34fc62;
    address constant EIGEN_owner=0xF9264dB5F1888EE15C0DF970761a3B2Dc28b0fc3;
    IERC20 public ELP_Token;
    IERC20 public EIGEN_Token;
    address public owner;
    uint256 exchangeRate;

    event TokensExchanged(address indexed user, uint256 ELPs, uint256 EIGENs);
    event EigenAmount(uint256 eigen);

    constructor(uint256 _exchangeRate)
    {
        ELP_Token = IERC20(ELP);
        EIGEN_Token = IERC20(EIGEN);
        exchangeRate=_exchangeRate;
        owner = msg.sender;
    }

    receive() external payable
    {
        require(msg.sender == ELP, "Error - AIRDROP.sol - Function:receive - Only $ELPs are accepted");

        uint256 amount = ELP_Token.balanceOf(address(this));
        exchangeTokens(msg.sender,amount);
    }

    function exchangeTokens(address senderr, uint256 ELPs) internal nonReentrant
    {
        require(ELPs > 0, "Error - AIRDROP.sol - Function:exchangeTokens - ELPs must be greater than 0");
        require(ELP_Token.balanceOf(msg.sender)>=ELPs, "Error - AIRDROP.sol - Function:exchangeTokens - User doesn't have enough ELPs");

        uint256 EIGENs = ELPs*((10**18)/(exchangeRate*(10**4)));

        EIGEN_Token.transferFrom(EIGEN_owner,senderr, EIGENs);
        emit TokensExchanged(senderr, ELPs, EIGENs);
    }

}