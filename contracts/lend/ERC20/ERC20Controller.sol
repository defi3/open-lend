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
 *  Main Update 4, 2021-06-12, add Controller for inheritance
 * 
 *  Main Update 5, 2021-06-17, migrate to ^0.8.0
 * 
 *  Main Update 6, 2021-06-18, move price to ERC20Market
 * 
 */
pragma solidity ^0.8.0;

import "../Controller.sol";
import "./IERC20Controller.sol";
import "./ERC20Market.sol";

abstract contract ERC20Controller is Controller, IERC20Controller {
    using AddressArray for address[];
    
    uint public constant MANTISSA = 1e6;


    constructor() Controller() {
    }
    
    
    // for testing and UI
    function accountValues(address account) public view override returns (uint supplyValue, uint borrowValue) {
        return _accountValues(account);
    }
    
    function _accountValues(address account) internal view virtual returns (uint supplyValue, uint borrowValue);

   
    // called by _borrow() in Market 
    function accountLiquidity(address account, address market, uint amount) external view override returns (bool status, uint liquidity_) {
        uint liquidity = _accountLiquidity(account);
        
        return (liquidity >= ERC20Market(market).price() * amount * 2, liquidity);
    }
    
    function _accountLiquidity(address account) internal view returns (uint) {
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(account);

        borrowValue = borrowValue * (_collateralFactor + MANTISSA);
        borrowValue = borrowValue / MANTISSA;

        if (borrowValue < supplyValue)
            liquidity = supplyValue - borrowValue;

        return liquidity;
    }
    
    
    function accountHealth(address account) external view override returns (bool status, uint index) {
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(account);

        return (supplyValue >= borrowValue * (MANTISSA + _collateralFactor) / MANTISSA, calculateHealthIndex(supplyValue, borrowValue));
    }
    
    function calculateHealthIndex(uint supplyValue, uint borrowValue) internal view returns (uint) {
        if (supplyValue == 0 || borrowValue == 0)
            return 0;

        borrowValue = borrowValue * (_liquidationFactor + MANTISSA);
        borrowValue = borrowValue / MANTISSA;
        
        return supplyValue * MANTISSA / borrowValue;
    }
    
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external override onlyMarket returns (uint collateralAmount)  {
        uint price = ERC20Market(msg.sender).price();        
        require(price > 0);

        uint collateralPrice = ERC20Market(collateral).price();     
        require(collateralPrice > 0);
        
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = _accountValues(borrower);
        require(borrowValue > 0);
        
        uint healthIndex = calculateHealthIndex(supplyValue, borrowValue);
        
        require(healthIndex <= MANTISSA);
        
        uint liquidationValue = amount * price;
        uint liquidationPercentage = liquidationValue * MANTISSA / borrowValue;
        uint collateralValue = supplyValue * liquidationPercentage / MANTISSA;
        
        collateralAmount = collateralValue / collateralPrice;
        
        ERC20Market(collateral).redeemFor(borrower, liquidator, collateralAmount);
    }
}

