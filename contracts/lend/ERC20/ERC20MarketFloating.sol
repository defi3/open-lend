/**
 *  SPDX-License-Identifier: MIT
 * 
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/contracts/Market.sol
 * 
 *  @Authoer defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-02, add getCurrentBlockNumber()
 * 
 *  Main Update 2, 2021-06-05, update accrueInterest()
 * 
 *  Main Update 3, 2021-06-06, inherit Market
 * 
 *  Main Update 4, 2021-06-06, improve naming convention
 * 
 *  Main Update 5, 2021-06-12, move condtions from _supply() to supply(), _borrow() to borrow(), _redeem() to redeem(), _payBorrow() to payBorrow()
 * 
 *  Main Update 6, 2021-06-13, add Extremal
 * 
 *  Main Update 7, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

import "../IMarketFloating.sol";
import "./ERC20Market.sol";
import "./ERC20Controller.sol";
import "../../token/ERC20/IERC20.sol";

contract ERC20MarketFloating is ERC20Market, IMarketFloating {
    uint public constant FACTOR = 1e6;
    
    struct SupplySnapshot {
        uint supply;
        uint interestIndex;
    }

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint internal _supplyIndex;
    uint internal _borrowIndex;
    uint internal _baseBorrowRate;
    
    uint internal _utilizationRateFraction;
    
    uint internal _accrualBlockNumber;
    uint internal _blocksPerYear;

    mapping (address => SupplySnapshot) internal _supplies;
    mapping (address => BorrowSnapshot) internal _borrows;


    constructor(address token_, uint256 min_, uint256 max_, uint baseBorrowAnnualRate_, uint blocksPerYear_, uint utilizationRateFraction_) ERC20Market(token_, min_, max_) {
        _borrowIndex = FACTOR;
        _supplyIndex = FACTOR;
        _blocksPerYear = blocksPerYear_;
        _baseBorrowRate = baseBorrowAnnualRate_ / blocksPerYear_;
        _accrualBlockNumber = block.number;
        _utilizationRateFraction = utilizationRateFraction_ / blocksPerYear_;
    }
    
    
    function supplyIndex() external view returns (uint) {
        return _supplyIndex;
    }
    
    function borrowIndex() external view returns (uint) {
        return _borrowIndex;
    }
    
    function baseBorrowRate() external view returns (uint) {
        return _baseBorrowRate;
    }
    
    
    function supplyOf(address account) external view override returns (uint) {
        return _supplies[account].supply;
    }

    function borrowBy(address account) external view override returns (uint) {
        return _borrows[account].principal;
    }


    function utilizationRate(uint balance_, uint totalBorrow_, uint reserve_) public pure override returns (uint) {
        if (totalBorrow_ == 0)
            return 0;

        return totalBorrow_ * FACTOR / (balance_ + totalBorrow_ -  reserve_);
    }

    function borrowRate(uint balance_, uint totalBorrow_, uint reserve_) public view override returns (uint) {
        uint ur = utilizationRate(balance_, totalBorrow_, reserve_);

        return ur * _utilizationRateFraction / FACTOR + _baseBorrowRate;
    }

    function supplyRate(uint balance_, uint totalBorrow_, uint reserve_) public view override returns (uint) {
        uint borrowRate__ = borrowRate(balance_, totalBorrow_, reserve_);

        return utilizationRate(balance_, totalBorrow_, reserve_) * borrowRate__ / FACTOR;
    }

    function borrowRatePerBlock() public view override returns (uint) {
        return borrowRate(balance(), _totalBorrow, 0);
    }

    function supplyRatePerBlock() public view override returns (uint) {
        return supplyRate(balance(), _totalBorrow, 0);
    }
    

    function updatedBorrowBy(address account) public view override returns (uint) {
        BorrowSnapshot storage snapshot = _borrows[account];

        if (snapshot.principal == 0)
            return 0;

        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return snapshot.principal * newBorrowIndex / snapshot.interestIndex;
    }

    function updatedSupplyOf(address account) public view override returns (uint) {
        SupplySnapshot storage snapshot = _supplies[account];

        if (snapshot.supply == 0)
            return 0;

        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return snapshot.supply * newSupplyIndex / snapshot.interestIndex;
    }

    function _supply(address supplier, uint amount) internal override {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].supply += amount;
        _supplies[supplier].interestIndex = _supplyIndex;
    }

    function _redeem(address supplier, uint amount) internal override {
        accrueInterest();

        SupplySnapshot storage supplySnapshot = _supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        _supplies[supplier].interestIndex = _supplyIndex;

        require(supplySnapshot.supply >= amount);

        supplySnapshot.supply -= amount;
        
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.accountHealth(supplier);
        
        require(status);
    }

    function _borrow(address borrower, uint amount) internal override {
        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = _borrows[borrower];

        if (borrowSnapshot.principal > 0) {
            uint interest = borrowSnapshot.principal * _borrowIndex / borrowSnapshot.interestIndex - borrowSnapshot.principal;

            borrowSnapshot.principal += interest;
            borrowSnapshot.interestIndex = _borrowIndex;
        }
        
        ERC20Controller ctr = ERC20Controller(_controller);
        
        bool status;
        uint value;
        
        (status, value) = ctr.accountLiquidity(borrower, address(this), amount);

        require(status, "Not enough account liquidity");

        borrowSnapshot.principal += amount;
        borrowSnapshot.interestIndex = _borrowIndex;
    }
    
    
    function blockNumber() external view override returns (uint) {
        return block.number;
    }
    
    function accrualBlockNumber() external view returns (uint) {
        return _accrualBlockNumber;
    }

    function accrueInterest() public override {
        uint currentBlockNumber = block.number;
        
        if (currentBlockNumber > _accrualBlockNumber) {
            (_totalBorrow, _borrowIndex) = calculateBorrowDataAtBlock(currentBlockNumber);
            (_totalSupply, _supplyIndex) = calculateSupplyDataAtBlock(currentBlockNumber);

            _accrualBlockNumber = currentBlockNumber;
        }
    }

    function calculateBorrowDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalBorrows, uint newBorrowIndex) {
        if (_totalBorrow == 0)
            return (_totalBorrow, _borrowIndex);

        uint blockDelta = newBlockNumber - _accrualBlockNumber;

        uint simpleInterestFactor = borrowRatePerBlock() * blockDelta;
        uint interestAccumulated = simpleInterestFactor * _totalBorrow / FACTOR;

        newBorrowIndex = simpleInterestFactor * _borrowIndex / FACTOR + _borrowIndex;
        newTotalBorrows = interestAccumulated + _totalBorrow;
    }

    function calculateSupplyDataAtBlock(uint newBlockNumber) internal view returns (uint newTotalSupply, uint newSupplyIndex) {
        if (_totalSupply == 0)
            return (_totalSupply, _supplyIndex);

        uint blockDelta = newBlockNumber - _accrualBlockNumber;

        uint simpleInterestFactor = supplyRatePerBlock() * blockDelta;
        uint interestAccumulated = simpleInterestFactor * _totalSupply / FACTOR;

        newSupplyIndex = simpleInterestFactor * _supplyIndex / FACTOR + _supplyIndex;
        newTotalSupply = interestAccumulated + _totalSupply;
    }

    function getUpdatedTotalBorrows() internal view returns (uint) {
        uint newTotalBorrows;
        uint newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return newTotalBorrows;
    }

    function getUpdatedTotalSupply() internal view returns (uint) {
        uint newTotalSupply;
        uint newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return newTotalSupply;
    }

    function _payBorrow(address payer, address borrower, uint amount) internal override returns (uint paid, uint additional_) {
        accrueInterest();

        BorrowSnapshot storage snapshot = _borrows[borrower];

        require(snapshot.principal > 0);

        uint interest = snapshot.principal * _borrowIndex / snapshot.interestIndex - snapshot.principal;

        snapshot.principal = snapshot.principal + interest;
        snapshot.interestIndex = _borrowIndex;

        uint additional;

        if (snapshot.principal < amount) {
            additional = amount - snapshot.principal;
            amount = snapshot.principal;
        }

        snapshot.principal -= amount;

        if (additional > 0)
            _supply(payer, additional);
            
        return (amount, additional);
    }
    
    
    function liquidateBorrow(address borrower, uint amount, address collateral) external override extremum(amount) {
        require(borrower != msg.sender);
        
        ERC20MarketFloating collateralMarket = ERC20MarketFloating(collateral);
        
        accrueInterest();
        collateralMarket.accrueInterest();

        uint debt = updatedBorrowBy(borrower);
        
        require(debt >= amount);
        
        require(IERC20(_token).balanceOf(msg.sender) >= amount);
        
        ERC20Controller ctr = ERC20Controller(_controller);
        uint collateralAmount = ctr.liquidateCollateral(borrower, msg.sender, amount, collateral);

        uint paid;
        uint additional;

        (paid, additional) = _payBorrow(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
}

