pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Seeds is ERC721A {
  uint256 private mintCost;

  constructor() ERC721A("Seeds", "SEEDS") {
    mintCost = 0.069 ether;
  }

  function mint(uint256 quantity) external payable {
      // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
      _mint(msg.sender, quantity);
  }

}
