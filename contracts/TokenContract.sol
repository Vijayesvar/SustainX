// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenContract is ERC20, Ownable {

    // Token details will be inherited from ERC20 and not defined manually
    // These variables are automatically defined by the ERC20 contract.
    
    uint256 public initialSupply = 1000000 * (10 ** uint256(decimals())); // 1 million tokens

    // Mapping to track rewards for users
    mapping(address => uint256) public rewards;

    // Event to log minting action
    event TokensMinted(address indexed to, uint256 amount);

    /**
     * @notice Constructor for initializing the token contract
     * @param initialOwner The address of the initial owner (usually deployer's address)
     */
    constructor(address initialOwner) ERC20("SustainabilityToken", "SUS") {
        transferOwnership(initialOwner);
    }
    

    /**
     * @notice Mint new tokens to an address (only owner can mint)
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);  // Mint the specified amount to the 'to' address
        emit TokensMinted(to, amount);  // Emit an event for transparency
    }

    /**
     * @notice Burn tokens from an address (only owner can burn)
     * @param from The address to burn tokens from
     * @param amount The amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);  // Burn the specified amount from the 'from' address
    }

    /**
     * @notice Reward a user with tokens for an eco-friendly action (like recycling)
     * @param user The address of the user to reward
     * @param amount The amount of tokens to reward the user
     */
    function rewardUser(address user, uint256 amount) external onlyOwner {
        _mint(user, amount);  // Mint tokens to the user's address
        rewards[user] = rewards[user] + amount;  // Update the rewards mapping for the user
    }

    /**
     * @notice Transfer tokens from one address to another (inherits from ERC20)
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return success Returns true if the transfer was successful
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        return super.transfer(to, amount);  // Transfer the tokens using ERC20's built-in function
    }

    /**
     * @notice Get the balance of tokens for a given address
     * @param account The address to check the balance for
     * @return balance The token balance of the given address
     */
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);  // Return the balance using ERC20's built-in function
    }

    /**
     * @notice Approve another address to spend tokens on your behalf
     * @param spender The address allowed to spend the tokens
     * @param amount The amount of tokens that can be spent
     * @return success Returns true if the approval was successful
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        return super.approve(spender, amount);  // Approve spending using ERC20's built-in function
    }

    /**
     * @notice Transfer tokens on behalf of another address
     * @param from The address to transfer tokens from
     * @param to The address to transfer tokens to
     * @param amount The amount of tokens to transfer
     * @return success Returns true if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        return super.transferFrom(from, to, amount);  // Transfer using ERC20's built-in function
    }
}
