// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RecyclingRewards is Ownable {
    using SafeMath for uint256;

    // ERC20 token for rewards
    IERC20 public rewardToken;

    // Mapping to track recycled products and the rewards issued
    mapping(uint256 => bool) public recycledProducts;
    mapping(address => uint256) public userRewards;

    // Recycling reward rate (reward per recycled product)
    uint256 public rewardPerRecycling;

    // Event emitted when a product is recycled and rewards are issued
    event ProductRecycled(address indexed user, uint256 indexed tokenId, uint256 rewardAmount);

    /**
     * @notice Constructor to initialize the contract with the reward token and reward rate
     * @param _rewardToken Address of the ERC20 reward token contract
     * @param _rewardPerRecycling The amount of reward given per recycled product
     * @param initialOwner The address of the initial owner (msg.sender)
     */
    constructor(address _rewardToken, uint256 _rewardPerRecycling, address initialOwner) Ownable(initialOwner) {
        rewardToken = IERC20(_rewardToken);
        rewardPerRecycling = _rewardPerRecycling;
    }

    /**
     * @notice Recycle a product and earn rewards
     * @param tokenId The ID of the product NFT that is being recycled
     * @param nftContract The address of the NFT contract representing the product
     */
    function recycleProduct(uint256 tokenId, address nftContract) external {
        IERC721 nft = IERC721(nftContract);

        // Ensure the product is owned by the caller and hasn't been recycled already
        require(nft.ownerOf(tokenId) == msg.sender, "You must own the product to recycle it");
        require(!recycledProducts[tokenId], "This product has already been recycled");

        // Mark the product as recycled
        recycledProducts[tokenId] = true;

        // Issue rewards to the user (transfer reward tokens)
        userRewards[msg.sender] = userRewards[msg.sender].add(rewardPerRecycling);
        rewardToken.transfer(msg.sender, rewardPerRecycling);

        emit ProductRecycled(msg.sender, tokenId, rewardPerRecycling);
    }

    /**
     * @notice Update the reward rate for recycling products
     * @param newRewardRate The new amount of reward given per recycled product
     */
    function updateRewardRate(uint256 newRewardRate) external onlyOwner {
        rewardPerRecycling = newRewardRate;
    }

    /**
     * @notice Withdraw the rewards accumulated by a user
     */
    function withdrawRewards() external {
        uint256 amount = userRewards[msg.sender];
        require(amount > 0, "No rewards available");

        // Reset user rewards and transfer the tokens
        userRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, amount);
    }

    /**
     * @notice Get the current reward rate for recycling
     * @return The reward rate per recycled product
     */
    function getRewardRate() external view returns (uint256) {
        return rewardPerRecycling;
    }

    /**
     * @notice Get the accumulated rewards for a user
     * @param user The address of the user
     * @return The total accumulated rewards for the user
     */
    function getUserRewards(address user) external view returns (uint256) {
        return userRewards[user];
    }
}
