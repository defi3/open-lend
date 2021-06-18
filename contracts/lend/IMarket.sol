/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/MarketInterface.sol
 * 
 *  @Authoer defi3
 * 
 *  Support ERC20, ERC721
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 *  Main Update 2, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

interface IMarket {
    function token() external view returns (address);
    function totalSupply() external view returns (uint);
    function totalBorrow() external view returns (uint);
    function balance() external view returns (uint);
}