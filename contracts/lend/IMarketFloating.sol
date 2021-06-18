/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  Support Floating Interest Rate
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

interface IMarketFloating {
    function utilizationRate(uint balance_, uint totalBorrow_, uint reserve_) external pure returns (uint);
    function borrowRate(uint balance_, uint totalBorrow_, uint reserve_) external view returns (uint);
    function supplyRate(uint balance_, uint totalBorrow_, uint reserve_) external view returns (uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
    function blockNumber() external view returns (uint);
}

