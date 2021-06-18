/**  
 *  SPDX-License-Identifier: MIT
 * 
 * 
 *  Reference: https://github.com/raineorshine/solidity-by-example/blob/master/remove-from-array.sol
 * 
 * 
 *  @Author defi3
 * 
 * 
 *  Creation, 2021-06
 * 
 *  Main Update 1, 2021-06-17, migrate to ^0.8.0
 * 
 */
pragma solidity ^0.8.0;

library AddressArray {
    function find(address[] storage arr, address a) internal view returns(uint) {
        uint i = 0;
        
        while (arr[i] != a) {
            i++;
            
            if (i >= arr.length)
                break;
        }
        
        return i;
    }
    
    function include(address[] storage arr, address a) internal view returns(bool) {
        return find(arr, a) < arr.length;
    }
    
    function removeByIndex(address[] storage arr, uint i) internal {
        uint len = arr.length;
        
        while (i < len - 1) {
            arr[i] = arr[i+1];
            i++;
        }
        
        arr.pop();
    }
    
    function removeByValue(address[] storage arr, address a) internal {
        uint i = find(arr, a);
        
        require(i < arr.length, "AddressArray::removeByValue: not found");
        
        removeByIndex(arr, i);
    }
}