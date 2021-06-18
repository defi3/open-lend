/**
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  Reference: https://github.com/loomnetwork/cryptozombie-lessons/blob/master/en/5/06-erc721-6.md
 * 
 * 
 *  @ Author defi3
 * 
 * 
 *  Creation, 2021-05
 * 
 *  Main Update 1, 2021-06-12, simplification
 * 
 *  Main Update 2, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

abstract contract Ownable {
    address internal _owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable::_: only owner can call it");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }
    
    /**
     * terminate the contract and release any outstanding funds back to the contract owner.
     */
    function terminate() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}