// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./temp.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract MonetPointFactory
{
    struct Point
    {
        address pointContractAddress;
        string name;
        string symbol;
    }

    address public FactoryOwner;
    Point[] createdPoints;

    event PointCreated(address indexed owner, address pointAddress, string name, string symbol);

    constructor()
    {
        FactoryOwner=msg.sender;
    }

    modifier onlyOwner()
    {
        require(msg.sender==FactoryOwner);
        _;
    }

    function createPoint
    (
        address _owner,
        address _distributor,
        uint256 _allPoints,
        uint8 _decimalDigits,
        uint256 _orderingFee,
        string memory _pointName,
        string memory _pointSymbol
    ) onlyOwner external returns(address)
    {
        Template point = new Template(
            _owner,
            _distributor,
            _allPoints,
            _decimalDigits,
            _orderingFee,
            _pointName,
            _pointSymbol
        );
        
        createdPoints.push(Point(address(point),IERC20Metadata(address(point)).name(),IERC20Metadata(address(point)).symbol()));

        emit PointCreated(msg.sender, address(point), IERC20Metadata(address(point)).name(),IERC20Metadata(address(point)).symbol());
        
        return address(point);
    }

    function getPoints() public view returns (Point[] memory)
    {
        return createdPoints;
    }
}
