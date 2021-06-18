/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 2, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 3, 2021-06-06, improve naming convention
 * 
 *  Main Update 4, 2021-06-12, use Ownable
 * 
 *  Main Update 5, 2021-06-12, add Controller for inheritance
 * 
 *  Main Update 6, 2021-06-12, use AddressArray, remove _markets and rename _marketList to _markets
 * 
 *  Main Update 7, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./IController.sol";
import "./IMarket.sol";
import "../utils/Ownable.sol";
import "../utils/AddressArray.sol";

abstract contract Controller is IController, Ownable {
    using AddressArray for address[];
    
    // uint public constant MANTISSA = 1e6;
    
    uint internal _collateralFactor;
    uint internal _liquidationFactor;

    mapping (address => address) internal _tokenToMarket;
    address[] internal _markets;


    constructor() Ownable() {
    }


    modifier onlyMarket() {
        require(_markets.include(msg.sender), "Controller::_: only market can call it");
        _;
    }
    
    
    function collateralFactor() external view override returns (uint) {
        return _collateralFactor;
    }
    
    function setCollateralFactor(uint factor) external override onlyOwner {
        _collateralFactor = factor;
    }

    function liquidationFactor() external view override returns (uint) {
        return _liquidationFactor;
    }
    
    function setLiquidationFactor(uint factor) external override onlyOwner {
        _liquidationFactor = factor;
    }
    

    function addMarket(address market) external override onlyOwner {
        address token = IMarket(market).token();
        
        require(_tokenToMarket[token] == address(0));
        
        _tokenToMarket[token] = market;
        _markets.push(market);
    }
    
    function removeMarket(address market_) external override onlyOwner returns (bool status) {
        IMarket market = IMarket(market_);
        
        require(market.balance() == 0);
        require(market.totalSupply() == 0);
        require(market.totalBorrow() == 0);
        
        address token = market.token();
        
        require(_tokenToMarket[token] != address(0));
        
        
        delete _tokenToMarket[token];
        _markets.removeByValue(market_);
        
        return true;
    }
    
    function size() external view override returns (uint) {
      return _markets.length;
    }
    
    function marketOf(address token) external view override returns (address) {
        return _tokenToMarket[token];
    }
    
    function include(address market_) external view override returns (bool included) {
        return _markets.include(market_);
    }
}