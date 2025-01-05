// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SustainabilityMetrics is Ownable {
    using SafeMath for uint256;

    // Mapping to track recycled products for each brand
    mapping(address => uint256) public brandRecycledCount;
    // Mapping to track total rewards issued
    mapping(address => uint256) public brandTotalRewards;
    // Mapping to track the total carbon footprint reduction for each brand
    mapping(address => uint256) public brandCarbonReduction;

    // Event emitted when a recycling event occurs and metrics are updated
    event RecyclingEvent(address indexed user, address indexed brand, uint256 carbonReduction, uint256 rewardAmount);

    // Recycling reward and carbon reduction rate (for simplicity, assuming fixed values for now)
    uint256 public carbonReductionPerRecycling = 10; // Example: 10 kg of carbon reduced per recycled product
    uint256 public rewardPerRecycling = 100; // Example: 100 tokens issued per recycling event

    /**
     * @notice Constructor to initialize the contract with the reward token and reward rate
     * @param initialOwner The address of the initial owner (usually msg.sender)
     */
    constructor(address initialOwner) Ownable(initialOwner) {
        transferOwnership(initialOwner); // Ensure the initial owner is set
    }

    // Function to record a recycling event for a specific brand
    function recordRecyclingEvent(address user, address brand) external onlyOwner {
        // Update the brand's recycled product count
        brandRecycledCount[brand] = brandRecycledCount[brand].add(1);
        
        // Update the total rewards issued for the brand
        brandTotalRewards[brand] = brandTotalRewards[brand].add(rewardPerRecycling);
        
        // Update the brand's carbon reduction (for simplicity, assuming a fixed reduction per product)
        brandCarbonReduction[brand] = brandCarbonReduction[brand].add(carbonReductionPerRecycling);

        // Emit event
        emit RecyclingEvent(user, brand, carbonReductionPerRecycling, rewardPerRecycling);
    }

    // Function to get the total recycled count for a brand
    function getRecycledProductCount(address brand) external view returns (uint256) {
        return brandRecycledCount[brand];
    }

    // Function to get the total rewards issued for a brand
    function getTotalRewards(address brand) external view returns (uint256) {
        return brandTotalRewards[brand];
    }

    // Function to get the total carbon reduction for a brand
    function getTotalCarbonReduction(address brand) external view returns (uint256) {
        return brandCarbonReduction[brand];
    }

    // Function to update the reward rate (for flexibility)
    function updateRewardRate(uint256 newRewardRate) external onlyOwner {
        rewardPerRecycling = newRewardRate;
    }

    // Function to update the carbon reduction rate
    function updateCarbonReductionRate(uint256 newCarbonReduction) external onlyOwner {
        carbonReductionPerRecycling = newCarbonReduction;
    }

    // Function to get sustainability metrics for a specific brand
    function getSustainabilityMetrics(address brand) external view returns (uint256 recycledCount, uint256 totalRewards, uint256 totalCarbonReduction) {
        recycledCount = brandRecycledCount[brand];
        totalRewards = brandTotalRewards[brand];
        totalCarbonReduction = brandCarbonReduction[brand];
    }
}
