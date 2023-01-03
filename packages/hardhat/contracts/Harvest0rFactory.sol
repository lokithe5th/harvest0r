pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/**
 __    __                                                      __       ______
/  |  /  |                                                    /  |     /      \
$$ |  $$ |  ______    ______   __     __  ______    _______  _$$ |_   /$$$$$$  |  ______
$$ |__$$ | /      \  /      \ /  \   /  |/      \  /       |/ $$   |  $$$  \$$ | /      \
$$    $$ | $$$$$$  |/$$$$$$  |$$  \ /$$//$$$$$$  |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |
$$$$$$$$ | /    $$ |$$ |  $$/  $$  /$$/ $$    $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$/
$$ |  $$ |/$$$$$$$ |$$ |        $$ $$/  $$$$$$$$/  $$$$$$  |  $$ |/  |$$ \$$$$ |$$ |
$$ |  $$ |$$    $$ |$$ |         $$$/   $$       |/     $$/   $$  $$/ $$   $$$/ $$ |
$$/   $$/  $$$$$$$/ $$/           $/     $$$$$$$/ $$$$$$$/     $$$$/   $$$$$$/  $$/


 ________                     __
/        |                   /  |
$$$$$$$$/______    _______  _$$ |_     ______    ______   __    __ 
$$ |__  /      \  /       |/ $$   |   /      \  /      \ /  |  /  |
$$    | $$$$$$  |/$$$$$$$/ $$$$$$/   /$$$$$$  |/$$$$$$  |$$ |  $$ |
$$$$$/  /    $$ |$$ |        $$ | __ $$ |  $$ |$$ |  $$/ $$ |  $$ |
$$ |   /$$$$$$$ |$$ \_____   $$ |/  |$$ \__$$ |$$ |      $$ \__$$ |
$$ |   $$    $$ |$$       |  $$  $$/ $$    $$/ $$ |      $$    $$ |
$$/     $$$$$$$/  $$$$$$$/    $$$$/   $$$$$$/  $$/        $$$$$$$ |
                                                         /  \__$$ |
                                                         $$    $$/
                                                          $$$$$$/

  The Harvest0r Factory is responsible for creating new `Harvest0r` contracts
  for token pairs.
 */

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IHarvest0r.sol";
import "./interfaces/IHarvest0rFactory.sol";

contract Harvest0rFactory is IHarvest0rFactory, Ownable {
  /******************************************************************
   *                            STORAGE                             *
   ******************************************************************/

  address private implementation;
  address private seeds;

  mapping(address => address) private fields;

  /******************************************************************
   *                         CONSTRUCTOR                            *
   ******************************************************************/

  constructor(address _implementation, address _seeds) payable {
    implementation = _implementation;
    seeds = _seeds;
  }

  /******************************************************************
   *                 FIELD-RELATED FUNCTIONALITY                    *
   ******************************************************************/

  function newField(address targetToken) external returns (address field) {
    if (fields[targetToken] != address(0)) {
      revert Exists();
    }

    field = Clones.clone(implementation);
    IHarvest0r(field).init(seeds, targetToken);

    fields[targetToken] = field;
  }

  function isField(address field) external view returns (bool) {
    return fields[field] != address(0) ? true : false;
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
