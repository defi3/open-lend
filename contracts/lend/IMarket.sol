// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMarket {
    function getToken() external view returns (address);
    function supplyOf(address account) external view returns (uint);
    function borrowBy(address account) external view returns (uint);
    function updatedSupplyOf(address account) external view returns (uint);
    function updatedBorrowBy(address account) external view returns (uint);
    function accrueInterest() external;
    function transferTo(address sender, address receiver, uint amount) external;
}

