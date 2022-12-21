pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Harvest0r {
  using SafeERC20 for IERC20;
  address private seedlings;

  constructor(address seeds) payable {
    seedlings = seeds;
  }

  function sellToken(
    uint256 tokenID,
    address token,
    uint256 value
  ) external {
    // require an NFT with an available charge
    
    IERC20(token).safeTransferFrom(msg.sender, address(this), value);
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
