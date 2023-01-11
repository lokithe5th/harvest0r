pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/** 
  @title Harvest0rFactory
  @author lourens.eth
  @notice The Harvest0r Factory is responsible for creating new `Harvest0r`-token pairs.
          Harvest0rs allow holders of an access token to access a market for tokens.

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
 */

/******************************************************************
 *                            IMPORTS                             *
 ******************************************************************/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/******************************************************************
 *                        INTERFACES                              *
 ******************************************************************/

import "./interfaces/IHarvest0r.sol";
import "./interfaces/IHarvest0rFactory.sol";

contract Harvest0rFactory is IHarvest0rFactory, Ownable {
  /******************************************************************
   *                            EVENTS                              *
   ******************************************************************/
  
  /// A new Token-Harvestor has bee been deployed
  event HarvestorDeployed(address indexed token, address indexed harvestor);

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
   *                         Set up                                 *
   ******************************************************************/

  /// @inheritdoc IHarvest0rFactory
  function setup(address implementation, address seeds) external {
    harvestorMaster = implementation;
    seedsNft = seeds;
  }

  /******************************************************************
   *                 HARVEST0R-RELATED FUNCTIONALITY                *
   ******************************************************************/

  /// @inheritdoc IHarvest0rFactory
  function newHarvestor(address targetToken) external returns (address harvestor) {
    if (tokenHarvestors[targetToken] != address(0)) {revert Exists();}

    harvestor = Clones.clone(harvestorMaster);
    IHarvest0r(harvestor).init(seedsNft, targetToken, owner());

    tokenHarvestors[targetToken] = harvestor;
    harvestors[harvestor] = true;

    emit HarvestorDeployed(targetToken, harvestor);
  }

  /// @inheritdoc IHarvest0rFactory
  function isHarvestor(address target) external view returns (bool) {
    return harvestors[target];
  }

  /******************************************************************
   *                       VIEW FUNCTIONS                           *
   ******************************************************************/

  /// @inheritdoc IHarvest0rFactory
  function viewImplementation() external view returns (address) {
    return harvestorMaster;
  }

  /// @inheritdoc IHarvest0rFactory
  function findHarvestor(address token) external view returns (address) {
    return tokenHarvestors[token];
  }
}
