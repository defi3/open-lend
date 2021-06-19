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
 *  Main Update 2, 2021-06-19, follow style of Ownable from OpenZeppelin
 * 
 */
pragma solidity ^0.8.0;

import "./Ownable.sol";

abstract contract Controllable is Ownable {
    address private _controller;
    
    event ControllershipTransferred(address indexed previousController, address indexed newController);

    /**
     * @dev The Controllable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() Ownable() {
    }

    /**
     * @return the address of the controller.
     */
    function controller() public view virtual returns(address) {
        return _controller;
    }
    
    function _isController() internal view returns(bool) {
        return _msgSender() == _controller;
    }
    

    modifier onlyController() {
        require(_isController(), "Controllable::_: only controller can call it");
        _;
    }
    
    modifier onlyOwnerOrController() {
        require(_isOwner() || _isController(), "Controllable::_: only owner or controller can call it");
        _;
    }
    
    
    /**
     * @dev Leaves the contract without controller. It will not be possible to call
     * `onlyController` functions anymore. Can only be called by the current controller.
     *
     * NOTE: Renouncing controllership will leave the contract without an controller,
     * thereby removing any functionality that is only available to the controller.
     */
    function renounceControllership() public virtual onlyOwner {
        _setController(address(0));
    }
    
    /**
     * @dev Transfers Controllership of the contract to a new account (`newController`).
     * Can only be called by the current controller.
     */
    function transferControllership(address newController) public virtual onlyOwner {
        require(newController != address(0), "Controllable: new controller is the zero address");
        
        _setController(newController);
    }
    
    function _setController(address newController) private {
        address oldController = _controller;
        
        _controller = newController;
        
        emit ControllershipTransferred(oldController, newController);
    }
}