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

contract MockFactory {
  mapping(address => address) private harvestors;


  function newHarvestor(address targetToken) external returns (address harvestor) {
    harvestors[targetToken] = harvestor;
  }

  function isHarvestor(address target) external view returns (bool) {
    return harvestors[target] != address(0) ? true : false;
  }
}