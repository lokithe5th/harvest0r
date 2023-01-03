pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/**
  __  __     ______     ______     __   __   ______     ______     ______   ______
/\ \_\ \   /\  __ \   /\  == \   /\ \ / /  /\  ___\   /\  ___\   /\__  _\ /\  == \
\ \  __ \  \ \  __ \  \ \  __<   \ \ \'/   \ \  __\   \ \___  \  \/_/\ \/ \ \  __<
 \ \_\ \_\  \ \_\ \_\  \ \_\ \_\  \ \__|    \ \_____\  \/\_____\    \ \_\  \ \_\ \_\
  \/_/\/_/   \/_/\/_/   \/_/ /_/   \/_/      \/_____/   \/_____/     \/_/   \/_/ /_/

  The Harvest0r is a market-making contract that allows holders of
  a `Seeds Access Voucher` NFT to sell their tokens to the Harvest0r
  for 0.0069 ether.

  Each Harvest0r contract only creates a market for one token.

  Sellers must own a `Seeds Access Voucher` and the act of selling a token
  will consume one charge of the `SEEDS` NFT.

  Note the sold tokens are not recoverable by sellers and the contract creator
  intends to sell these tokens at a profit should the opportubnity arise.

  Harvest at your own risk!

 */

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISeeds.sol";

contract Harvest0r is Ownable {
  using SafeERC20 for IERC20;

  /******************************************************************
   *                           STORAGE                              *
   ******************************************************************/

  /// The address for the `Seeds Access Voucher` NFT
  address private seeds;
  /// The token to be harvested
  IERC20 private token;

  /******************************************************************
   *                         INITIALIZE                             *
   ******************************************************************/

  /// @notice Initializes the `Harvest0r` field for the specified token
  /// @param _seeds The address for the `SEEDS` NFT
  /// @param _token The target token to be harvested
  function init(address _seeds, address _token) external {
    seeds = _seeds;
    token = IERC20(_token);
  }

  /******************************************************************
   *                    HARVEST0R FUNCTIONALITY                     *
   ******************************************************************/

  /// @notice Allows a user to sell a token for 
  /// @dev The `Havest0r` makes a market and buys a token for `buyAmount`
  /// @param tokenId The target `tokenId` which loses a charge
  /// @param value The amount of `token` to sell for `buyAmount`
  function sellToken(
    uint256 tokenId,
    uint256 value
  ) external {
    ISeeds gatekeeper = ISeeds(seeds);
    // require an NFT with an available charge
    require(msg.sender == gatekeeper.ownerOf(tokenId), "");
    require(gatekeeper.viewCharge(tokenId) > 0, "");

    gatekeeper.useCharge(tokenId);

    token.safeTransferFrom(msg.sender, address(this), value);
  }

  /******************************************************************
   *                      OWNER FUNCTIONS                           *
   ******************************************************************/

  /// @notice Transfers the bought tokens to `target`
  /// @param target The address to which to transfer the tokens
  /// @param value The amount of tokens to transfer to `target`
  function transferToken(address target, uint256 value) external onlyOwner() {
    token.safeTransfer(target, value);
  }
}
