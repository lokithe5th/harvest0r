pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISeeds.sol";

contract Harvest0r {
  using SafeERC20 for IERC20;
  address private seeds;
  address private token;

/*
  constructor(address seeds, address _token) payable {
    seedlings = seeds;
    token = _token;
  } */

  function init(address _seeds, address _token) external {
    seeds = _seeds;
    token = _token;
  }

  function sellToken(
    uint256 tokenId,
    uint256 value
  ) external {
    ISeeds gatekeeper = ISeeds(seeds);
    // require an NFT with an available charge
    require(msg.sender == gatekeeper.ownerOf(tokenId), "");
    require(gatekeeper.viewCharge(tokenId) > 0, "");

    gatekeeper.useCharge(tokenId);

    IERC20(token).safeTransferFrom(msg.sender, address(this), value);
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
