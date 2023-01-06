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

  /// The address of the `Harvest0r` implementation
  address private harvestorMaster;
  /// The address of the `Seeds Access Voucher` NFT
  address private seedsNft;
  /// Mapping of token address to `Harvest0r` contract
  mapping(address => address) private tokenHarvestors;
  /// Mapping containing harvestor addresses
  mapping(address => bool) private harvestors;

  /******************************************************************
   *                         CONSTRUCTOR                            *
   ******************************************************************/

  /// @param implementation The address of the MasterCopy for Harvestors
  /// @param seeds The address for the `Seeds Access Voucher` NFTs
  constructor(address implementation, address seeds) payable {
    harvestorMaster = implementation;
    seedsNft = seeds;
  }

  /******************************************************************
   *                 HARVST0R-RELATED FUNCTIONALITY                 *
   ******************************************************************/

  /// @inheritdoc IHarvest0rFactory
  function newHarvestor(address targetToken) external returns (address harvestor) {
    if (tokenHarvestors[targetToken] != address(0)) {
      revert Exists();
    }

    harvestor = Clones.clone(harvestorMaster);
    IHarvest0r(harvestor).init(seedsNft, targetToken);

    tokenHarvestors[targetToken] = harvestor;
    harvestors[harvestor] = true;
  }

  /// @inheritdoc IHarvest0rFactory
  function isHarvestor(address target) external view returns (bool) {
    return harvestors[target];
  }
}
