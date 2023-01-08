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
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./interfaces/ISeeds.sol";
import "./interfaces/IHarvest0r.sol";

contract Harvest0r is IHarvest0r, Ownable, Initializable {
  using SafeERC20 for IERC20;

  /******************************************************************
   *                            EVENTS                              *
   ******************************************************************/
  event Sale(address indexed from, uint256 indexed amount);
  event TokensTransferred(address indexed to, uint256 indexed amount);

  /******************************************************************
   *                           STORAGE                              *
   ******************************************************************/

  /// The `Seeds Access Voucher` NFT
  ISeeds private seeds;
  /// The token to be harvested
  IERC20 private token;

  /******************************************************************
   *                         INITIALIZE                             *
   ******************************************************************/

  /// @inheritdoc IHarvest0r
  function init(
    address _seeds,
    address _token,
    address newOwner
  ) external initializer() {
    seeds = ISeeds(_seeds);
    token = IERC20(_token);
    _transferOwnership(newOwner);
  }

  /******************************************************************
   *                    HARVEST0R FUNCTIONALITY                     *
   ******************************************************************/

  /// @inheritdoc IHarvest0r
  function sellToken(
    uint256 tokenId,
    uint256 value
  ) external {
    // require an NFT with an available charge
    if (msg.sender != seeds.ownerOf(tokenId)) {revert NotOwner();}
    if (seeds.viewCharge(tokenId) == 0) {revert UnsufficientCharge();}

    seeds.useCharge(tokenId);

    token.safeTransferFrom(msg.sender, address(this), value);

    emit Sale(msg.sender, value);
  }

  /******************************************************************
   *                      OWNER FUNCTIONS                           *
   ******************************************************************/

  /// @inheritdoc IHarvest0r
  function transferToken(address target, uint256 value) external onlyOwner() {
    token.safeTransfer(target, value);

    emit TokensTransferred(target, value);
  }

  /******************************************************************
   *                       VIEW FUNCTIONS                           *
   ******************************************************************/
  function viewToken() external view returns (address) {
    return address(token);
  }

}
