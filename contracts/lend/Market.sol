/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference 1: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  Reference 2: https://blog.openzeppelin.com/onward-with-ethereum-smart-contract-security-97a827e47702/
 * 
 *  @Authoer defi3
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-05-31, change getCash() to balance()
 * 
 *  Main Update 2, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 3, 2021-06-06, add owner(), totalSupply(), totalBorrow()
 * 
 *  Main Update 4, 2021-06-06, improve naming convention
 * 
 *  Main Update 5, 2021-06-12, use Controllable
 * 
 *  Main Update 6, 2021-06-12, add Market for inheritance
 * 
 *  Main Update 7, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./IMarket.sol";
import "../utils/Controllable.sol";

abstract contract Market is IMarket, Controllable {
    address internal _token;
    uint internal _totalSupply;
    uint internal _totalBorrow;
    

    constructor(address token_) Controllable() {
        // require(IERC20(token_).totalSupply() >= 0);
        
        _token = token_;
    }

 
    function token() external view override returns (address) {
        return _token;
    }
    
    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }
    
    function totalBorrow() external view override returns (uint) {
        return _totalBorrow;
    }
}