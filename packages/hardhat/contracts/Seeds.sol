pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/**
  @title Seeds Access Voucher
  @author lourens.eth

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
  liability for users' actions when using this contract. 

  NB It is always your own responsibility to make sure you comply
  with tax (and any other) laws applicable to you and/or the entities
  you trade in.

  Note: When you sell tokens to a Harvestor contract the Harvestor makes
  a market for a price at 0.0069 ether. The contract will happily buy the
  tokens from you, but the intention is to sell these tokens if and when an
  opportunity arises for a profit.
 */

/******************************************************************
 *                            IMPORTS                             *
 ******************************************************************/
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

/******************************************************************
 *                         INTERFACES                             *
 ******************************************************************/
import "./interfaces/IHarvest0rFactory.sol";
import "./interfaces/ISeeds.sol";

contract Seeds is ISeeds, ERC721A, Ownable {

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
  /// The Havest0rFactory
  IHarvest0rFactory private factory;

  /// The strings required for SVG Generation
  string[3] internal svgParts = [
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
        '</text><text x="10" y="40" class="base">',
        '</text></svg>'
  ];

  /******************************************************************
   *                         SETUP                                  *
   ******************************************************************/

  /// @notice Initial set up of the `Seeds Access Voucher NFT` 
  constructor() ERC721A("Seeds Access Voucher", "SEEDS") {
    mintCost = 0.069 ether;
    maxMint = 5;
    maxSupply = 1000;
    
  }

  /// @inheritdoc ISeeds
  function setup(address harvestorFactory) external onlyOwner {
    factory = IHarvest0rFactory(harvestorFactory);
  }

  /******************************************************************
   *                         NFT FUNCTIONALITY                      *
   ******************************************************************/

  /// @inheritdoc	ISeeds
  function mint(uint256 quantity) external payable {
    if (msg.value < mintCost) {revert UnsufficientValue();}
    if (quantity > 5) {revert MaxMintExceeded();}

    // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
    _safeMint(msg.sender, quantity);
    fees += (msg.value / 10);

  }

  /// @inheritdoc	ERC721A
  function tokenURI(uint256 tokenId) public view override (ERC721A, IERC721A) returns (string memory json) {
    json = Base64.encode(bytes(string.concat(
          '{"name": "Seeds NFT", "description": "...as you sow...", "image": "data:image/svg+xml;base64,',
          Base64.encode(bytes(generateSVGofTokenById(tokenId))),
          '"}')));

        json = string.concat('data:application/json;base64,', json);
  }

  /// @inheritdoc	ISeeds
  function generateSVGofTokenById(uint256 tokenId) public view returns (string memory svg) {
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    svg = string.concat(svgParts[0], 'Charges: ', (uint256(unpackedData.extraData)).toString(), svgParts[1], svgParts[2]);
  }

  /******************************************************************
   *                         SPECIAL FUNCTIONS                      *
   ******************************************************************/

  /// @inheritdoc	ISeeds
  function useCharge(uint256 tokenId) external {
    if (!factory.isHarvestor(msg.sender)) {revert InvalidHarvestor();}
    if (tokenId >= _nextTokenId()) {revert NotExists();}
    if (viewCharge(tokenId) == 0) {revert NoCharge();}

    /// Consume a `SEEDS` NFT charge
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    _setExtraDataAt(tokenId, unpackedData.extraData - 1);

    (bool sent, ) = unpackedData.addr.call{value: mintCost / 10}("");

    if (!sent) {revert PaymentFailed();}

    emit ChargeUsed(tokenId);
  }

  /// @inheritdoc	ISeeds
  function recharge(uint256 tokenId) external payable {
    //  replenish an NFTs charges
    if (msg.value < mintCost) {revert UnsufficientValue();}

    _setExtraDataAt(tokenId, uint24(9));
    fees += (msg.value / 10);

    emit Recharged(tokenId);
  }

  /// @inheritdoc	ISeeds
  function viewCharge(uint256 tokenId) public view returns (uint24) {
    if (tokenId >= _nextTokenId()) {revert NotExists();}

    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    return unpackedData.extraData;
  }

  /******************************************************************
   *                         OWNER FUNCTIONS                        *
   ******************************************************************/

  /// @inheritdoc	ISeeds
  function withdrawFees(address target, uint256 value) external onlyOwner() returns (bool sent) {
    if (fees < value) {revert InvalidAmount();}

    fees -= value;
    (sent, ) = target.call{value: value}("");

    if (!sent) {revert PaymentFailed();}

    emit WithdrawFees(target, value);
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
        /// Fix for `OwnershipNotInitializedForExtraData` error
        _initializeOwnershipAt(startTokenId + i);
        /// Set the initial charges
        _setExtraDataAt(startTokenId + i, 9);
      }
    }
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
