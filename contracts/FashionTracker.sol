// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract FashionTracker is AccessControl {

//Contract status
    bool public contractIsActive;
//Contract owner
    address public contractOwner;
//Contract producer role
    bytes32 public constant PRODUCER_ROLE = keccak256("PRODUCER_ROLE");

// Contract Constructor
constructor() {
    contractOwner = msg.sender;
    contractIsActive = true;
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(PRODUCER_ROLE, msg.sender);
}

//Contract Modifiers

//Allow only when the contract is active
modifier onlyWhenActive() {
    require(contractIsActive, "Contract is not active");
    _;
}

//Allow only if caller has producer role
modifier onlyProducer() {
        require(hasRole(PRODUCER_ROLE, msg.sender), "Caller is not a producer");
        _;
    }
//Allow only if caller has owner role
modifier onlyOwner() {
        require(msg.sender == contractOwner, "Caller is not the contract owner");
        _;
    }

//Activate Contract
function activateContract() external onlyOwner {
    require (!contractIsActive, "Contract is already active");
        contractIsActive = true;
        emit ContractActivated();
    }
//Deactivate Contract    
function deactivateContract() external onlyOwner {
    require(contractIsActive, "Contract is already deactivated");
        contractIsActive = false;
        emit ContractDeactivated();
    }

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
    mapping(uint256 => Product) private products;
    mapping(uint256 => bool) private productExistsFlag;
    mapping(uint256 => bytes32) private productToTrackerMap;

//Modeling Trackers
    struct Tracker {
        bytes32 trackerId;
        string publicKey64; //Base64 representation of the tracker's public key
        uint256 registrationDate;
        bool isLinked;
    }

    bytes32[] trackerIds;
    mapping(bytes32 => Tracker) private trackers;
    mapping(bytes32 => bool) private trackerExistsFlag;
    mapping(bytes32 => uint256) private trackerToProductMap;

//Link Trackers to Products
function linkTracker (
    uint256 _productId,
    bytes32 _trackerId
) public onlyWhenActive onlyProducer {
    require (productExistsFlag[_productId], "This product does not exist");
    require(trackerExistsFlag[_trackerId], "This tracker does not exist");
    require(!products[_productId].isLinked, "This product is already linked to a tracker");
    require(!trackers[_trackerId].isLinked, "This tracker is already linked to a product");

    //Update isLinked variable on Product and Tracker
    products[_productId].isLinked = true;
    trackers[_trackerId].isLinked = true;

    //Update the Tracking Maps
    productToTrackerMap[_productId] = _trackerId;
    trackerToProductMap[_trackerId] = _productId;

    //Emit Device Linked Log
    emit Linked(_productId, _trackerId);
}

function unlinkTracker (
    uint256 _productId,
    bytes32 _trackerId
) public onlyWhenActive onlyProducer {
    require (productExistsFlag[_productId], "This product does not exist");
    require(trackerExistsFlag[_trackerId], "This tracker does not exist");
    require(products[_productId].isLinked, "This product is not linked to any tracker");
    require(trackers[_trackerId].isLinked, "This tracker is not linked to any product");

    //Update isLinked variable on Product and Tracker
    products[_productId].isLinked = false;
    trackers[_trackerId].isLinked = false;

    //Delete the entries in the Tracking Maps
    delete productToTrackerMap[_productId];
    delete trackerToProductMap[_trackerId];

    //Emit Device Unlinked Log
    emit Unlinked(_productId, _trackerId);
}

//Get Tracker <> Product Relation

function getProductTracker (uint256 _productId) public view onlyWhenActive onlyProducer returns (bytes32) {
    require (productExistsFlag[_productId], "This product does not exist");
    return productToTrackerMap[_productId];
}

function getTrackerProduct (bytes32 _trackerId) public view onlyWhenActive onlyProducer returns (uint256) {
    require (trackerExistsFlag[_trackerId], "This tracker does not exist");
    return trackerToProductMap[_trackerId];
}

//Key Events
    event ProductCreated(uint256 indexed productId, string productName);
    event ProductUpdated(uint256 indexed productId, Product updatedProduct);
    event ProductDeleted(uint256 indexed productId);

    event TrackerCreated(bytes32 indexed trackerId, string publicKey64);
    event TrackerUpdated(bytes32 indexed trackerId, Tracker updatedTracker);
    event TrackerDeleted(bytes32 trackerId);

    event Linked(uint256 indexed productId, bytes32 indexed trackerId);
    event Unlinked(uint256 indexed productId, bytes32 indexed trackerId);

    //Contract Status Change Event
    event ContractActivated();
    event ContractDeactivated();

//Useful Functions

    // function productExists(uint256 _productId) public view returns (bool) {
    //     bool exists = false;
    //     if (productExistsFlag[_productId]) {
    //         exists = true;
    //     }
    //     return exists;
    // }

    function countProducts() public view onlyOwner onlyWhenActive returns (uint256) {
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
    string memory _additionalInfo) external onlyWhenActive onlyProducer {
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

function getProduct(uint256 _productId) external view onlyWhenActive onlyProducer returns (Product memory) {
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
) internal onlyWhenActive {
    Product storage toUpdate = products[_productId];
    if (_updatedProductInfo.updateProductName) toUpdate.productName = _updatedProductInfo.newProductName;
    if (_updatedProductInfo.updateProductCategory) toUpdate.productCategory = _updatedProductInfo.newProductCategory;
    if (_updatedProductInfo.updateProductPrice) toUpdate.productPrice = _updatedProductInfo.newProductPrice;
    if (_updatedProductInfo.updateProductColor) toUpdate.productColor = _updatedProductInfo.newProductColor;
    if (_updatedProductInfo.updateProductMaterial) toUpdate.productMaterial = _updatedProductInfo.newProductMaterial;
    //Emit event to show the changes made to the product
    emit ProductUpdated(toUpdate.productId, toUpdate);
}

function updateProduct(
    uint256 _productId,
    bool _updateProductName, string memory _newProductName,
    bool _updateProductCategory, string memory _newProductCategory,
    bool _updateProductPrice, uint32 _newProductPrice,
    bool _updateProductColor, string memory _newProductColor,
    bool _updateProductMaterial, string memory _newProductMaterial) external onlyWhenActive onlyProducer {
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

function deleteProduct(uint256 _productId) external onlyWhenActive onlyProducer {
    require(productExistsFlag[_productId], "Product doesn't exist");

    //Unlink product, in case linked
    if (products[_productId].isLinked) {
        unlinkTracker(_productId, productToTrackerMap[_productId]);
    }

    delete products[_productId];
    //Remove the productExistsFlag mapping for the deleted product
    productExistsFlag[_productId] = false;
    //Remove the product from the productIds array
    //Exception for single element array
    if (productIds.length == 1) {
        productIds.pop();
    } else {
        for (uint256 i = 0; i < productIds.length; i++) {
            if (productIds[i] == _productId) {
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }
    }

    //Emit event to say the product was deleted
    emit ProductDeleted(_productId);
}

//Tracker Functions

function countTrackers () public view onlyWhenActive onlyProducer returns (uint256) {
    return trackerIds.length;
}

//Create Tracker
function createTracker (
    bytes32 _trackerId,
    string memory _publicKey64
) external onlyWhenActive onlyProducer {
    require (!trackerExistsFlag[_trackerId], "Tracker already exists");
    trackers[_trackerId] = Tracker({
        trackerId : _trackerId,
        publicKey64 : _publicKey64,
        registrationDate : block.timestamp,
        isLinked : false
    });
    //Add new tracker to the trackerIds array
    trackerIds.push(bytes32(_trackerId));
    //Add new tracker to the trackerExistsFlag mapping
    trackerExistsFlag[_trackerId] = true;
    //Emit event saying the tracker was created
    emit TrackerCreated(_trackerId, _publicKey64);
}

//Search Tracker by trackerId
function getTracker (bytes32 _trackerId) external view onlyWhenActive onlyProducer returns (Tracker memory) {
    require (trackerExistsFlag[_trackerId], "Tracker does not exist");
    return trackers[_trackerId];
}

//Delete Tracker
function deleteTracker (bytes32 _trackerId) external onlyWhenActive onlyProducer {
    require (trackerExistsFlag[_trackerId], "Tracker does not exist");

    //Unlink tracker, in case linked
    if (trackers[_trackerId].isLinked) {
        unlinkTracker(trackerToProductMap[_trackerId], _trackerId);
    }

    delete trackers[_trackerId];
    //Remove the trackerExistsFlag mapping for the deleted tracker
    trackerExistsFlag[_trackerId] = false;
    //Remove the tracker from the trackerIds array
    //Exception for single element array
    if (trackerIds.length == 1) {
        trackerIds.pop();
    } else {
        for (uint256 i = 0; i < trackerIds.length; i++) {
            if (trackerIds[i] == _trackerId) {
                trackerIds[i] = trackerIds[trackerIds.length - 1];
                trackerIds.pop();
                break;
            }
        }
    }

    //Emit event to say the tracker was deleted
    emit TrackerDeleted(_trackerId);
}

//Update Tracker
function updateTracker (
    bytes32 _trackerId,
    string memory _newPublicKey64
) external onlyWhenActive onlyProducer {
    require (trackerExistsFlag[_trackerId], "Tracker does not exist");
    trackers[_trackerId].publicKey64 = _newPublicKey64;
    //Emit event to show the changes made to the tracker
    emit TrackerUpdated(_trackerId, trackers[_trackerId]);
}

}