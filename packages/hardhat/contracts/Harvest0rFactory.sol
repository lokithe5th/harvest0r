pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IHarvest0r.sol";

contract Harvest0rFactory is Ownable{
  address private implementation;
  address private seeds;

  mapping(address => bool) private fields;

  constructor(address _implementation, address _seeds) payable {
    implementation = _implementation;
    seeds = _seeds;
  }

  function newField(address targetToken) external returns (address field) {
    field = Clones.clone(implementation);
    fields[field] = true;
    IHarvest0r(field).init(seeds, targetToken);
  }

  function isField(address field) external view returns (bool) {
    return fields[field];
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
