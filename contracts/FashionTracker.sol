// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FashionTracker is AccessControl {

//Modeling Products
    struct Product {
        address productOwner;
        uint256 productId;
        uint256 trackerId;
        string productName;
        string productCategory;
        uint32 productPrice;
        string productSize;
        string productColor;
        string productMaterial;
        string additionalInfo;
    }

//Modeling Trackers

}