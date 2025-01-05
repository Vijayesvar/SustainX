const axios = require("axios");
const { BITSCRUNCH_API_KEY, BITSCRUNCH_API_BASE_URL } = require("../Utils/constants");

/**
 * BitsCrunch API Integration Service
 */
const bitsCrunchService = {
  /**
   * Validate NFT metadata using BitsCrunch API
   * @param {string} tokenId - The ID of the token to validate
   * @param {string} contractAddress - The contract address of the NFT
   * @returns {Promise<Object>} - Response from the BitsCrunch API
   */
  validateNFT: async (tokenId, contractAddress) => {
    try {
      const response = await axios.post(
        `${BITSCRUNCH_API_BASE_URL}/validate-nft`,
        {
          tokenId,
          contractAddress,
        },
        {
          headers: {
            Authorization: `Bearer ${BITSCRUNCH_API_KEY}`,
            "Content-Type": "application/json",
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error validating NFT with BitsCrunch API:", error);
      throw error.response?.data || error.message;
    }
  },

  /**
   * Get analytics for a specific NFT
   * @param {string} tokenId - The ID of the token
   * @param {string} contractAddress - The contract address of the NFT
   * @returns {Promise<Object>} - NFT analytics from BitsCrunch API
   */
  getNFTAnalytics: async (tokenId, contractAddress) => {
    try {
      const response = await axios.get(
        `${BITSCRUNCH_API_BASE_URL}/nft-analytics`,
        {
          params: { tokenId, contractAddress },
          headers: {
            Authorization: `Bearer ${BITSCRUNCH_API_KEY}`,
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error("Error fetching NFT analytics from BitsCrunch API:", error);
      throw error.response?.data || error.message;
    }
  },
};

module.exports = bitsCrunchService;
