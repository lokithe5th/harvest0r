pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "erc721a/contracts/IERC721A.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

interface ISeeds is IERC721A {

  function mint(uint256 quantity) external payable;

  function tokenURI(uint256 tokenId) external view override returns (string memory json);

  function generateSVGofTokenById(uint256 tokenId) external view returns (string memory svg);

  function useCharge(uint256 tokenId) external;

  function recharge(uint256 tokenId) external payable;

  function viewCharge(uint256 tokenId) external view returns (uint8);
}
