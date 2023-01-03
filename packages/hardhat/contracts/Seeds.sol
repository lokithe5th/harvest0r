pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/**
   .-'''-.     .-''-.      .-''-.   ______        .-'''-.
  / _     \  .'_ _   \   .'_ _   \ |    _ `''.   / _     \
 (`' )/`--' / ( ` )   ' / ( ` )   '| _ | ) _  \ (`' )/`--'
(_ o _).   . (_ o _)  |. (_ o _)  ||( ''_'  ) |(_ o _).
 (_,_). '. |  (_,_)___||  (_,_)___|| . (_) `. | (_,_). '.
.---.  \  :'  \   .---.'  \   .---.|(_    ._) '.---.  \  :
\    `-'  | \  `-'    / \  `-'    /|  (_.\.' / \    `-'  |
 \       /   \       /   \       / |       .'   \       /
  `-...-'     `'-..-'     `'-..-'  '-----'`      `-...-'

  The Seeds Access Voucher NFTs allow holders to sell their tokens
  to Harvest0r contracts to allow tax-loss harvesting for
  tokens which have legitimately lost their value.

  Disclaimer: Every user must ensure they adhere to the tax laws of
  their local jurisdiction. The creator of this contract cannot accept
  liability for users' actions when using this piece of software. 

  NB It is always your own responsibility to make sure you comply
  with tax (and any other) laws applicable to you and/or the entities
  you trade in.

  Note: When you sell tokens to a Harvestor contract the Harvestor makes
  a market for a price at 0.0069 ether. The contract will happily buy the
  tokens from you, but the intention is to sell these tokens if and when an
  opportunity arises for a profit.
 */

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "./interfaces/IHarvest0rFactory.sol";
import "./interfaces/ISeeds.sol";

contract Seeds is ISeeds, ERC721A, Ownable {

  /******************************************************************
   *                         LIBRARIES                              *
   ******************************************************************/
  using Strings for uint256;

  /******************************************************************
   *                         STORAGE                                *
   ******************************************************************/

  /// The cost to mint an Seed NFT
  uint256 private mintCost;
  /// The maximum number of mints per transaction
  uint256 private maxMint;
  /// The maximum number of `SEEDS`
  uint256 private maxSupply;
  /// The amount of accumulated fees
  uint256 private fees;
  /// The Havest0rFactory
  IHarvest0rFactory private factory;

  /// The strings required for SVG Generation
  string[3] internal svgParts = [
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
        '</text><text x="10" y="40" class="base">',
        '</text></svg>'
  ];

  /******************************************************************
   *                         CONSTRUCTOR                            *
   ******************************************************************/

  /// @notice Initial set up of the `Seeds Access Voucher NFT` 
  /// @param harvestor Address of the Harvestor Factory
  constructor(address harvestor) ERC721A("Seeds Access Voucher", "SEEDS") {
    mintCost = 0.069 ether;
    maxMint = 5;
    maxSupply = 1000;
    factory = IHarvest0rFactory(harvestor);
  }

  /******************************************************************
   *                         NFT FUNCTIONALITY                      *
   ******************************************************************/

  /// @inheritdoc	ISeeds
  function mint(uint256 quantity) external payable {
    if (msg.value < mintCost) {
      revert UnsufficientValue();
    }
    // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
    _mint(msg.sender, quantity);
    _setExtraDataAt(_nextTokenId() - 1, 9);
    fees += (msg.value / 10);
  }

  /// @inheritdoc	ERC721A
  function tokenURI(uint256 tokenId) public view override (ERC721A, IERC721A) returns (string memory json) {
    json = Base64.encode(bytes(string(abi.encodePacked(
          '{"name": "Seeds NFT", "description": "...as you sow...", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(generateSVGofTokenById(tokenId))), '"}'))));

        json = string(abi.encodePacked('data:application/json;base64,', json));
  }

  /// @inheritdoc	ISeeds
  function generateSVGofTokenById(uint256 tokenId) public view returns (string memory svg) {
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    svg = string(abi.encodePacked(svgParts[0], 'Charges: ', (uint256(unpackedData.extraData)).toString(), svgParts[1], svgParts[2]));
  }

  /******************************************************************
   *                         SPECIAL FUNCTIONS                      *
   ******************************************************************/

  /// @inheritdoc	ISeeds
  function useCharge(uint256 tokenId) external {
    if (!factory.isField(msg.sender)) {
      revert InvalidHarvestor();
    }

    /// Consume a `SEEDS` NFT charge
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    _setExtraDataAt(tokenId, unpackedData.extraData - 1);

    (bool sent, ) = unpackedData.addr.call{value: mintCost / 10}("");

    if (!sent) {
      revert PaymentFailed();
    }

  }

  /// @inheritdoc	ISeeds
  function recharge(uint256 tokenId) external payable {
    //  replenish an NFTs charges
    if (msg.value < mintCost) {
      revert UnsufficientValue();
    }
    require(msg.value == mintCost, "cost not covered");
    _setExtraDataAt(tokenId, uint24(9));
    fees += (msg.value / 10);
    //charges[tokenId] = 9;
  }

  /// @inheritdoc	ISeeds
  function viewCharge(uint256 tokenId) public view returns (uint24) {
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    return unpackedData.extraData;
  }

  /// @inheritdoc	ISeeds
  function withdrawFees(address target, uint256 value) external onlyOwner() returns (bool sent) {
    if (fees < value) {
      revert InvalidAmount();
    }

    fees -= value;
    (sent, ) = target.call{value: value}("");

    if (!sent) {
      revert PaymentFailed();
    }
  }
}
