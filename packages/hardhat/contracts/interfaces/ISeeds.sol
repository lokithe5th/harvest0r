pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

import "erc721a/contracts/IERC721A.sol";

interface ISeeds is IERC721A {

  /// The calling contract is not a Harvest0r
  error InvalidHarvestor();
  /// Mint quantity exceeded
  error MaxMintExceeded();
  /// The `msg.value` is too low
  error UnsufficientValue();
  /// The payment for tokens has failed
  error PaymentFailed();
  /// Invalid amount to withdraw
  error InvalidAmount();
  /// Target token does not exist
  error NotExists();
  /// The target token doesn't have enough charge left
  error NoCharge();

  /******************************************************************
   *                         NFT FUNCTIONALITY                      *
   ******************************************************************/

  /// @notice Mints a `Seeds Access Voucher` to the `msg.sender`
  /// @dev `msg.value` must be greater than `mintCost`
  /// @dev `quantity` must be less than or equal to `maxMint`
  /// @param quantity Number of `SEEDS` to mint to msg.sender
  function mint(uint256 quantity) external payable;

  /// @notice Generates an SVG graphic for a given `tokenId`
  /// @param tokenId The target `tokenId`
  /// @return svg The SVG image corresponding to the given `tokenId`
  function generateSVGofTokenById(uint256 tokenId) external view returns (string memory svg);

  /******************************************************************
   *                         SPECIAL FUNCTIONS                      *
   ******************************************************************/

  /// @notice Allows an `Field` contract to use a `SEEDS` charge
  /// @dev Consuming a charge decrements the target `tokenId` charge
  /// @param tokenId The target `tokenId`
  function useCharge(uint256 tokenId) external;

  /// @notice Replenishes a target `SEEDS` NFT's charges
  /// @dev `msg.value` must equal or exceed `mintCost`
  /// @param tokenId The target `tokenId`
  function recharge(uint256 tokenId) external payable;

  /// @notice Returns the number of available charges for a given `tokenId` 
  /// @dev The `charges` are stored using the 24 available `extraData` bits
  /// @param tokenId The target `tokenId`
  /// @return uint24 The amount of charges available for a given `tokenId`
  function viewCharge(uint256 tokenId) external view returns (uint24);

  /******************************************************************
   *                         OWNER FUNCTIONS                        *
   ******************************************************************/

  /// @notice Allows `owner` to withdraw accumulated fees
  /// @param target The account where ether must be withdrawn to
  /// @param value The amount of ether to transfer
  function withdrawFees(address target, uint256 value) external returns (bool sent);
}
