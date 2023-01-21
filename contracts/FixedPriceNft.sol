// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract FixedPriceNFT {
    address public contractOwner;
    mapping(address => mapping(uint256 => bool)) public nftOwners;
    mapping(uint256 => address) public nftToOwner;
    mapping(uint256 => uint256) public nftPrices;
    mapping(uint256 => bool) public nftListings;
    uint256 public marketplaceFee;
    address public royaltyBeneficiary;

    constructor() public {
        contractOwner = msg.sender;
    }

    function setMarketplaceFee(uint256 _fee) public {
        require(msg.sender == contractOwner);
        marketplaceFee = _fee;
    }

    function setRoyaltyBeneficiary(address _beneficiary) public {
        require(msg.sender == contractOwner);
        royaltyBeneficiary = _beneficiary;
    }

    function listNFT(uint256 _tokenId, uint256 _price) public {
        require(nftOwners[msg.sender][_tokenId]);
        require(!nftListings[_tokenId]);
        nftListings[_tokenId] = true;
        nftPrices[_tokenId] = _price;
        nftToOwner[_tokenId] = msg.sender;
    }

    function cancelListing(uint256 _tokenId) public {
        require(nftListings[_tokenId]);
        require(nftToOwner[_tokenId] == msg.sender);
        delete nftListings[_tokenId];
        delete nftPrices[_tokenId];
        delete nftToOwner[_tokenId];
    }

    function purchaseNFT(uint256 _tokenId) public payable {
        require(nftListings[_tokenId]);
        require(msg.value >= nftPrices[_tokenId]);
        address seller = nftToOwner[_tokenId];
        uint256 price = nftPrices[_tokenId];
        require(nftOwners[seller][_tokenId]);
        nftOwners[seller][_tokenId] = false;
        nftOwners[msg.sender][_tokenId] = true;
        seller.transfer(price);
        if (royaltyBeneficiary != address(0)) {
            royaltyBeneficiary.transfer(price * marketplaceFee / 100);
        }
      
    }
