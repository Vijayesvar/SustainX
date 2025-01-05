// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Marketplace Contract for the Circular Economy Platform
contract MarketplaceContract is Ownable {
    using SafeMath for uint256;

    /// @notice Fee in percentage for marketplace (e.g., 3% fee)
    uint256 public platformFeePercent;

    /// @notice Event emitted when a new listing is created
    event ProductListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    
    /// @notice Event emitted when a product is sold
    event ProductSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);

    /// @notice Event emitted when a listing is canceled
    event ListingCanceled(uint256 indexed tokenId, address indexed seller);

    /// @notice Structure to store product listings
    struct Listing {
        address seller;
        uint256 price;
        bool isActive;
    }

    /// @notice Mapping to store product listings by token ID
    mapping(uint256 => Listing) public listings;

    /**
     * @notice Constructor to initialize the contract with the marketplace fee
     * @param fee The marketplace fee percentage (e.g., 3 for 3%)
     * @param initialOwner The address of the initial owner (msg.sender)
     */
    constructor(uint256 fee, address initialOwner) Ownable(initialOwner) {
        require(fee <= 100, "Fee cannot be more than 100%");
        platformFeePercent = fee;
    }

    /**
     * @notice List a product for sale in the marketplace
     * @param tokenId The ID of the product NFT
     * @param price The price at which the product is listed
     */
    function listProduct(uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than 0");
        IERC721 nftContract = IERC721(address(this));
        address tokenOwner = nftContract.ownerOf(tokenId);

        require(msg.sender == tokenOwner, "You must own the NFT to list it");
        require(nftContract.isApprovedForAll(tokenOwner, address(this)), "Marketplace must be approved to transfer the NFT");

        // Mark the product as listed
        listings[tokenId] = Listing({
            seller: tokenOwner,
            price: price,
            isActive: true
        });

        emit ProductListed(tokenId, tokenOwner, price);
    }

    /**
     * @notice Buy a product listed for sale
     * @param tokenId The ID of the product NFT to buy
     */
    function buyProduct(uint256 tokenId) external payable {
        Listing storage listing = listings[tokenId];

        require(listing.isActive, "Product is not for sale");
        require(msg.value == listing.price, "Incorrect payment amount");

        uint256 feeAmount = listing.price.mul(platformFeePercent).div(100);
        uint256 sellerAmount = listing.price.sub(feeAmount);

        // Transfer the NFT to the buyer
        IERC721(address(this)).safeTransferFrom(listing.seller, msg.sender, tokenId);

        // Pay the seller minus the platform fee
        payable(listing.seller).transfer(sellerAmount);
        // Pay the platform fee
        payable(owner()).transfer(feeAmount);

        // Mark the product as no longer for sale
        listing.isActive = false;

        emit ProductSold(tokenId, listing.seller, msg.sender, listing.price);
    }

    /**
     * @notice Cancel a product listing
     * @param tokenId The ID of the product NFT to cancel the listing
     */
    function cancelListing(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];

        require(listing.isActive, "Product is not listed");
        require(msg.sender == listing.seller, "You are not the seller");

        // Mark the product as no longer listed
        listing.isActive = false;

        emit ListingCanceled(tokenId, msg.sender);
    }

    /**
     * @notice Update the platform fee percentage
     * @param newFee The new marketplace fee percentage
     */
    function updatePlatformFee(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee cannot be more than 100%");
        platformFeePercent = newFee;
    }

    /**
     * @notice Retrieve the listing details of a product
     * @param tokenId The ID of the product NFT
     * @return seller The address of the seller
     * @return price The price at which the product is listed
     * @return isActive Whether the product is still listed for sale
     */
    function getListing(uint256 tokenId) external view returns (address seller, uint256 price, bool isActive) {
        Listing storage listing = listings[tokenId];
        return (listing.seller, listing.price, listing.isActive);
    }
}
