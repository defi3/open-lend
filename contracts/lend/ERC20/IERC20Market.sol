/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 *  
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-06, add events
 * 
 *  Main Update 2, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 *  Main Update 3, 2021-06-17, migrate to ^0.8.0
 * 
 *  Main Update 4, 2021-06-18, add setPrice() and price()
 * 
 */
pragma solidity ^0.8.0;

import "../IMarket.sol";

interface IERC20Market is IMarket {
    event Supply(address user, uint amount);
    event Redeem(address user, uint amount);
    event Borrow(address user, uint amount);
    event PayBorrow(address user, uint amount);
    
    event LiquidateBorrow(address borrower, uint amount, address liquidator, address collateral, uint collateralAmount);
    
    function setPrice(uint256 price_) external;
    function price() external view returns (uint256);
    
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    
    function borrow(uint amount) external;
    function supply(uint amount) external;
    function redeem(uint amount) external;
    function payBorrow(uint amount) external;
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external;
    function redeemFor(address from, address to, uint amount) external;
}

