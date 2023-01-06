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

  Access to one sale consumes one charge of a SEEDS token's charges.
  The Harvest0r contract will make a market and buy your tokens for 
  0.0069 ether. 

  The NFT's charges can be replenished.

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

contract MockSeeds is ERC721A, Ownable {

  /******************************************************************
   *                         LIBRARIES                              *
   ******************************************************************/
  using Strings for uint256;

  /******************************************************************
   *                          EVENTS                                *
   ******************************************************************/

  /// The `tokenId` has been recharged
  event Recharged(uint256 indexed tokenId);
  /// Charge used
  event ChargeUsed(uint256 indexed tokenId);
  /// Accumulated fees withdrawn
  event WithdrawFees(address indexed to, uint256 indexed amount);

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

  mapping(uint256 => uint24) private charges;
  /******************************************************************
   *                         CONSTRUCTOR                            *
   ******************************************************************/

  /// @notice Initial set up of the `Seeds Access Voucher NFT` 
  constructor() ERC721A("Seeds Access Voucher", "SEEDS") {
    mintCost = 0.069 ether;
    maxMint = 5;
    maxSupply = 1000;
  }

  /******************************************************************
   *                         NFT FUNCTIONALITY                      *
   ******************************************************************/

  function mint(uint256 quantity) external payable {
    // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
    _safeMint(msg.sender, quantity);
  }

  /******************************************************************
   *                         SPECIAL FUNCTIONS                      *
   ******************************************************************/

  function useCharge(uint256 tokenId) external {
    charges[tokenId]--;
    emit ChargeUsed(tokenId);
  }

  function recharge(uint256 tokenId) external payable {

  }

  function viewCharge(uint256 tokenId) public view returns (uint24) {
    return charges[tokenId];
  }

    /// @inheritdoc ERC721A
  function _afterTokenTransfers(
      address from,
      address to,
      uint256 startTokenId,
      uint256 quantity
  ) internal override {
    if (from == address(0)) {
       for (uint8 i; i < quantity; i++) {
        charges[startTokenId + i] = 9;
      }
    }
  }

  /******************************************************************
   *                         OWNER FUNCTIONS                        *
   ******************************************************************/

  function withdrawFees(address target, uint256 value) external onlyOwner() returns (bool sent) {
    return sent;
  }

  /******************************************************************
   *                       VIEW FUNCTIONS                           *
   ******************************************************************/

  /// @notice Returns the accumulated fees
  /// @return uint256 The amount of ether accumulated
  function viewFees() external view returns (uint256) {
    return fees;
  }
}
