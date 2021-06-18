/**
 *  SPDX-License-Identifier: MIT
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

import "./Ownable.sol";

abstract contract Controllable is Ownable {
    address internal _controller;

    /**
     * @dev The Controllable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() Ownable() {
    }

    /**
     * @return the address of the controller.
     */
    function controller() public view returns(address) {
        return _controller;
    }
    
    function setController(address controller_) external onlyOwner {
        _controller = controller_;
    }

    modifier onlyController() {
        require(isController(), "Controllable::_: only controller can call it");
        _;
    }
    
    modifier onlyOwnerOrController() {
        require((msg.sender == _owner) || (msg.sender == _controller), "Controllable::_: only owner or controller can call it");
        _;
    }

    function isController() public view returns(bool) {
        return msg.sender == _controller;
    }
}