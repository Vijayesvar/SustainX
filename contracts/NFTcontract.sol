// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title NFTContract for Circular Economy
/// @dev Extends OpenZeppelin ERC721 with metadata updates and lifecycle tracking
contract NFTContract is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    /// @notice Counter for tracking token IDs
    Counters.Counter private _tokenIdCounter;

    /// @notice Event emitted when metadata is updated
    event MetadataUpdated(uint256 indexed tokenId, string newMetadataURI);

    /// @notice Event emitted for lifecycle events
    event LifecycleEvent(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        string eventType,
        uint256 timestamp
    );

    /// @dev Mapping to store product lifecycle data
    mapping(uint256 => string[]) private _lifecycleEvents;

    /// @notice Constructor to initialize the NFT contract
    /// @param name Name of the NFT collection
    /// @param symbol Symbol of the NFT collection
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    transferOwnership(msg.sender); // Set the owner as the deployer or any other desired logic
	}

    /**
     * @notice Mint a new NFT with metadata
     * @param to Address of the recipient
     * @param metadataURI URI pointing to the metadata (e.g., IPFS link)
     * @return tokenId The ID of the newly minted token
     */
    function mintNFT(address to, string memory metadataURI) external onlyOwner returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, metadataURI);

        emit LifecycleEvent(tokenId, address(0), to, "Minted", block.timestamp);
        return tokenId;
    }

    /**
     * @notice Update the metadata of an existing NFT
     * @dev Can only be called by the owner of the contract or token owner
     * @param tokenId The ID of the token to update
     * @param newMetadataURI New metadata URI
     */
    function updateMetadata(uint256 tokenId, string memory newMetadataURI) external {
        address owner = ownerOf(tokenId);
        require(owner == _msgSender() || isApprovedForAll(owner, _msgSender()), "Caller is not owner nor approved");
        _setTokenURI(tokenId, newMetadataURI);

        emit MetadataUpdated(tokenId, newMetadataURI);
    }

    /**
     * @notice Log a lifecycle event for a specific token
     * @dev Records an event type such as resale, donation, or recycling
     * @param tokenId The ID of the token
     * @param to The address involved in the event
     * @param eventType Description of the lifecycle event
     */
    function logLifecycleEvent(
        uint256 tokenId,
        address to,
        string memory eventType
    ) external {
        address owner = ownerOf(tokenId);
        require(owner == _msgSender() || isApprovedForAll(owner, _msgSender()), "Caller is not owner nor approved");
        require(to != address(0), "Invalid address");

        string memory eventDetail = string(abi.encodePacked(
            "From: ", _addressToString(owner),
            ", To: ", _addressToString(to),
            ", Event: ", eventType,
            ", Timestamp: ", _uintToString(block.timestamp)
        ));

        _lifecycleEvents[tokenId].push(eventDetail);

        emit LifecycleEvent(tokenId, owner, to, eventType, block.timestamp);
    }

    /**
     * @notice Retrieve lifecycle events of an NFT
     * @param tokenId The ID of the token
     * @return List of lifecycle events
     */
    function getLifecycleEvents(uint256 tokenId) external view returns (string[] memory) {
        return _lifecycleEvents[tokenId];
    }

    /**
     * @dev Utility function to convert address to string
     */
    function _addressToString(address _addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);

        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    /**
     * @dev Utility function to convert uint256 to string
     */
    function _uintToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_value % 10)));
            _value /= 10;
        }
        return string(buffer);
    }
}
