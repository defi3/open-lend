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

abstract contract Minimal {
    uint256 internal _min;

    constructor(uint256 min_) {
        _min = min_;
    }

    function min() public view returns(uint256) {
        return _min;
    }

    modifier minimum(uint256 amount) {
        require(amount > _min, "Minimal::_: not enough amount to call it");
        _;
    }
}