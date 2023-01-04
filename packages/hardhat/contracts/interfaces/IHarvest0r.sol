pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

interface IHarvest0r {

  /******************************************************************
   *                            ERRORS                              *
   ******************************************************************/
  /// The caller does not own the target `SEEDS` NFT
  error NotOwner();
  /// `SEEDS[tokenId`] does not have enough charges
  error UnsufficientCharge();

  /******************************************************************
   *                         INITIALIZE                             *
   ******************************************************************/

  /// @notice Initializes the `Harvest0r` field for the specified token
  /// @param _seeds The address for the `SEEDS` NFT
  /// @param _token The target token to be harvested
  function init(address _seeds, address _token) external;

  /******************************************************************
   *                    HARVEST0R FUNCTIONALITY                     *
   ******************************************************************/

  /// @notice Allows a user to sell a token for 
  /// @dev The `Havest0r` makes a market and buys a token for `buyAmount`
  /// @param tokenId The target `tokenId` which loses a charge
  /// @param value The amount of `token` to sell for `buyAmount`
  function sellToken(uint256 tokenId, uint256 value) external;

  /// @notice Transfers the bought tokens to `target`
  /// @param target The address to which to transfer the tokens
  /// @param value The amount of tokens to transfer to `target`
  function transferToken(address target, uint256 value) external;
}
