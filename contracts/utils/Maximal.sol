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
pragma solidity ^0.8.0;

abstract contract Maximal {
    uint256 internal _max;

    constructor(uint256 max_) {
        _max = max_;
    }

    function max() public view returns(uint256) {
        return _max;
    }

    modifier maximum(uint256 amount) {
        require(amount < _max, "Maximal::_: too much amount to call it");
        _;
    }
}