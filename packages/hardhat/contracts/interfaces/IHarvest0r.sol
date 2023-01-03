pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

interface IHarvest0r {

  function init(address _seeds, address _token) external;

  function sellToken(uint256 tokenId, uint256 value) external;

}
