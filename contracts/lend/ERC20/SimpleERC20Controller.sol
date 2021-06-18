/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Controller.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-06, change it to abstract contract
 * 
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 *  Main Update 3, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./ERC20Controller.sol";
import "./SimpleERC20Market.sol";

contract SimpleERC20Controller is ERC20Controller() {

    constructor() {
    }
    
    function _accountValues(address account) internal view override returns (uint supplyValue, uint borrowValue) {
        for (uint k = 0; k < _markets.length; k++) {
            SimpleERC20Market market = SimpleERC20Market(_markets[k]);
            uint price = _prices[_markets[k]];
            
            supplyValue += market.supplyOf(account) * price;
            borrowValue += market.borrowBy(account) * price;
        }
    }
}

