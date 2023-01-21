// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT_Auction is ERC721 {
    address public owner;
    mapping (address => mapping (uint256 => uint256)) public royalties;
    mapping (address => mapping (uint256 => bool)) public sold;
    mapping (uint256 => bool) public nftListing;
    mapping (uint256 => address) public highestBidder;
    mapping (uint256 => uint256) public highestBid;
    mapping (uint256 => uint) public bidEnd;
    uint256 public maxRoyaltyPercentage;

    constructor() ERC721("NFT_Auction", "NFTA") public {
        owner = msg.sender;
        maxRoyaltyPercentage = 20;
    }

    function listForSale(uint256 tokenId, uint256 initialBid, uint256 royaltyPercentage, uint bidDuration) public {
        require(msg.sender == ownerOf(tokenId), "Only the owner can list this NFT for sale");
        require(!nftListing[tokenId], "This NFT is already listed for sale");
        require(royaltyPercentage <= maxRoyaltyPercentage, "The maximum allowed royalty percentage is 20%");

        nftListing[tokenId] = true;
        highestBid[tokenId] = initialBid;
        highestBidder[tokenId] = msg.sender;
        bidEnd[tokenId] = now + bidDuration;
        royalties[msg.sender][tokenId] = (initialBid * royaltyPercentage) / 100;
    }

    function cancelSell(uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "Only the owner can cancel the sale of this NFT");
        require(nftListing[tokenId], "This NFT is not currently listed for sale");

        nftListing[tokenId] = false;
        delete royalties[msg.sender][tokenId];
        delete highestBid[tokenId];
        delete highestBidder[tokenId];
        delete bidEnd[tokenId];
    }

    function bid(uint256 tokenId, uint256 bidAmount) public payable {
        require(nftListing[tokenId], "This NFT is not currently listed for sale");
        require(bidAmount > highestBid[tokenId], "Bid amount must be higher than the current highest bid");
        require(now <= bidEnd[tokenId], "The bidding period for this NFT has ended");
        require(msg.value >= bidAmount, "The sent value is not enough to complete the bid");

        address previousBidder = highestBidder[tokenId];
        if (previousBidder != msg.sender) {
            if (previousBidder != address(0)) {
                previousBidder.transfer(highestBid[tokenId]);
            }
        }
        highestBid[tokenId] = bidAmount;
        highestBidder[tokenId] = msg.sender;
    }
}
