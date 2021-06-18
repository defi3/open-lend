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
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

interface IController {
    function collateralFactor() external view returns (uint);
    function setCollateralFactor(uint factor) external;
    
    function liquidationFactor() external view returns (uint);
    function setLiquidationFactor(uint factor) external;
    
    function addMarket(address market) external;
    function removeMarket(address market) external returns (bool);
    function size() external view returns (uint);
    function marketOf(address token) external view returns (address);
    function include(address market_) external returns (bool);

    function accountValues(address account) external view returns (uint supplyValue, uint borrowValue);
    function accountHealth(address account) external view returns (bool status, uint index);
}
