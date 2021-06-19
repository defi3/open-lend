/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 *  No interest
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-06, inherit Market
 * 
 *  Main Update 2, 2021-06-06, improve naming convention
 * 
 *  Main Update 3, 2021-06-12, move condtions from _supply() to supply(), _borrow() to borrow(), _redeem() to redeem(), _payBorrow() to payBorrow()
 * 
 *  Main Update 4, 2021-06-13, add Extremal
 * 
 *  Main Update 5, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "./ERC20Market.sol";
import "./ERC20Controller.sol";
import "../../token/ERC20/IERC20.sol";

contract SimpleERC20Market is ERC20Market {
    mapping (address => uint) internal _supplies;
    mapping (address => uint) internal _borrows;


    constructor(address token_, uint256 min_, uint256 max_) ERC20Market(token_, min_, max_) {
    }


    function supplyOf(address account) external view override returns (uint) {
        return _supplies[account];
    }
    
    function borrowBy(address account) external view override returns (uint) {
        return _borrows[account];
    }


    function _supply(address supplier, uint amount) internal override {
        _supplies[supplier] += amount;
    }

    function _redeem(address supplier, uint amount) internal override {
        require(_supplies[supplier] >= amount);

        _supplies[supplier] -= amount;
        
        ERC20Controller ctr = ERC20Controller(controller());
        
        bool status;
        uint health;
        
        (status, health) = ctr.accountHealth(supplier);
        
        require(status);
    }

    function _borrow(address borrower, uint amount) internal override {
        ERC20Controller ctr = ERC20Controller(controller()); 
        
        bool status;
        uint liquidity;
        
        (status, liquidity) = ctr.accountLiquidity(borrower, address(this), amount);

        require(status, "SimpleERC20Market::_borrow: Not enough account liquidity");

        _borrows[borrower] += amount;
    }

    function _payBorrow(address payer, address borrower, uint amount) internal override returns (uint paid, uint additional_) {
        require(_borrows[borrower] > 0);
        
        uint additional;
        
        if (amount > _borrows[borrower]) {
            additional = amount - _borrows[borrower];
            amount = _borrows[borrower];
        }

        _borrows[borrower] -= amount;
        
        if (additional > 0)
            _supply(payer, additional);
            
        return (amount, additional);
    }
    
    
    function liquidateBorrow(address borrower, uint amount, address collateral) public override extremum(amount) {
        require(borrower != msg.sender);
        
        require(IERC20(_token).balanceOf(msg.sender) >= amount);
        
        ERC20Controller ctr = ERC20Controller(controller());
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = _payBorrow(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, collateral, collateralAmount);
    }
}

