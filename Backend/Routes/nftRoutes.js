const express = require("express");
const bitsCrunchService = require("../Integrations/bitsCrunch");
const router = express.Router();

/**
 * Validate NFT Metadata
 */
router.post("/validate-nft", async (req, res) => {
  const { tokenId, contractAddress } = req.body;

  try {
    const validationResult = await bitsCrunchService.validateNFT(tokenId, contractAddress);
    res.status(200).json({
      success: true,
      data: validationResult,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to validate NFT metadata",
      error,
    });
  }
});

/**
 * Get NFT Analytics
 */
router.get("/nft-analytics", async (req, res) => {
  const { tokenId, contractAddress } = req.query;

  try {
    const analytics = await bitsCrunchService.getNFTAnalytics(tokenId, contractAddress);
    res.status(200).json({
      success: true,
      data: analytics,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch NFT analytics",
      error,
    });
  }
});

module.exports = router;
