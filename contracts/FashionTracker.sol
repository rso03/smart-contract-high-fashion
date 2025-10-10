// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FashionTracker is AccessControl {

//Modeling Products
    struct Product {
        address productOwner;
        uint256 productId;
        bool isLinked;
        string productName;
        string productCategory;
        uint32 productPrice;
        string productSize;
        string productColor;
        string productMaterial;
        string additionalInfo;
    }

    uint256[] productIds;
    mapping(uint256 => Product) public products;
    mapping(uint256 => bool) public productExistsFlag;
    mapping(uint256 => bytes32) public productToTrackerMap;

//Modeling Trackers
    struct Tracker {
        bytes32 trackerId;
        string publicKey64; //Base64 representation of the tracker's public key
        uint256 registrationDate;
        bool isLinked;
    }

    uint256[] trackerIds;
    mapping(uint256 => Tracker) public trackers;
    mapping(uint256 => bool) public trackerExistsFlag;
    mapping(bytes32 => uint256) public trackerToProductMap;

//Modeling Events
    event ProductCreated(uint256 indexed productId, string productName);
    event TrackerCreated(bytes32 indexed trackerId, string publicKey64);
    event Linked(uint256 indexed productId, bytes32 indexed trackerId);
//Contract Status Change Event
//    event ContractStatusChange(bool contractStatus status);

//Useful Functions

    function productExists(uint256 _productId) public view returns (bool) {
        bool exists = false;
        if (productExistsFlag[_productId]) {
            exists = true;
        }
        return exists;
    }

    function countProducts() public view returns (uint256) {
        return productIds.length;
    }

//Product Functions

function createProduct(
    uint256 _productId,
    string memory _productName,
    string memory _productCategory,
    uint32 _productPrice,
    string memory _productSize,
    string memory _productColor,
    string memory _productMaterial,
    string memory _additionalInfo) external {
    require(!productExistsFlag[_productId], "Product already exists");

    products[_productId] = Product({
        productOwner : msg.sender,
        productId : _productId,
        isLinked : false,
        productName : _productName,
        productCategory : _productCategory,
        productPrice : _productPrice,
        productSize : _productSize,
        productColor : _productColor,
        productMaterial : _productMaterial,
        additionalInfo : _additionalInfo
    });

    //Add new product to the productIds array
    productIds.push(_productId);
    //Add new product to the productExistsFlag mapping
    productExistsFlag[_productId] = true;
    //Emit event saying the product was created
    emit ProductCreated(_productId, _productName);

}

function getProduct(uint256 _productId) external view returns (Product memory) {
    require(productExistsFlag[_productId], "Product doesn't exist");
    return products[_productId];
}

//Temporary Structure to make Product Update Function easier

struct ProductUpdate {
    bool updateProductName;
    string newProductName;
    bool updateProductCategory;
    string newProductCategory;
    bool updateProductPrice;
    uint32 newProductPrice;
    bool updateProductColor;
    string newProductColor;
    bool updateProductMaterial;
    string newProductMaterial;
}

function internalUpdateProduct(
    uint256 _productId,
    ProductUpdate memory _updatedProductInfo
) internal {
    Product storage toUpdate = products[_productId];
    if (_updatedProductInfo.updateProductName) toUpdate.productName = _updatedProductInfo.newProductName;
    if (_updatedProductInfo.updateProductCategory) toUpdate.productCategory = _updatedProductInfo.newProductCategory;
    if (_updatedProductInfo.updateProductPrice) toUpdate.productPrice = _updatedProductInfo.newProductPrice;
    if (_updatedProductInfo.updateProductColor) toUpdate.productColor = _updatedProductInfo.newProductColor;
    if (_updatedProductInfo.updateProductMaterial) toUpdate.productMaterial = _updatedProductInfo.newProductMaterial;  
}

function updateProduct(
    uint256 _productId,
    bool _updateProductName, string memory _newProductName,
    bool _updateProductCategory, string memory _newProductCategory,
    bool _updateProductPrice, uint32 _newProductPrice,
    bool _updateProductColor, string memory _newProductColor,
    bool _updateProductMaterial, string memory _newProductMaterial) external {
    require(productExistsFlag[_productId], "Product doesn't exist");
    require(products[_productId].productOwner == msg.sender, "You are not the product owner.");

    ProductUpdate memory updatedProductInfo = ProductUpdate({
        updateProductName: _updateProductName,
        newProductName: _newProductName,
        updateProductCategory: _updateProductCategory,
        newProductCategory: _newProductCategory,
        updateProductPrice: _updateProductPrice,
        newProductPrice: _newProductPrice,
        updateProductColor: _updateProductColor,
        newProductColor: _newProductColor,
        updateProductMaterial: _updateProductMaterial,
        newProductMaterial: _newProductMaterial
    });

//Call internal function to update the product accordingly
    internalUpdateProduct(_productId, updatedProductInfo);
}

function deleteProduct(uint256 _productId) external {
    require(productExistsFlag[_productId], "Product doesn't exist");
    delete products[_productId];
}

}