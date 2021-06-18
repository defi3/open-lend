/**
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  Reference: https://jeancvllr.medium.com/solidity-tutorial-all-about-modifiers-a86cf81c14cb
 * 
 * 
 *  @Authoer defi3
 * 
 * 
 *  Creation, 2021-06
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
import "./Minimal.sol";
import "./Maximal.sol";

pragma solidity ^0.8.0;

abstract contract Extremal is Minimal, Maximal {

    constructor(uint256 min_, uint256 max_) Minimal(min_) Maximal(max_) {
    }
    
    modifier extremum(uint256 amount) {
        require(amount > _min, "Minimal::_: not enough amount to call it");
        require(amount < _max, "Maximal::_: too much amount to call it");
        // require((amount > _min) && (amount < _max), "Extremal::_: not enough amount or too much amount to call it");
        _;
    }
}