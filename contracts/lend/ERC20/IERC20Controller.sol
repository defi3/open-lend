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
 *  Main Update 1, 2021-06-06, add owner(), marketOf(), priceOf()
 * 
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 *  Main Update 3, 2021-06-12, add IController
 * 
 *  Main Update 4, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "../IController.sol";

interface IERC20Controller is IController{
    function setPrice(address market, uint price) external;
    function priceOf(address market) external view returns (uint);

    function accountLiquidity(address account, address market, uint amount) external view returns (bool status, uint liquidity_);
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, address collateral) external returns (uint collateralAmount);
}

