pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

/// @title Harvest0rFactory Interface
/// @author lourens.eth

interface IHarvest0rFactory {

  /******************************************************************
   *                            ERRORS                              *
   ******************************************************************/

  /// The Harvestor contract for this token exists
  error Exists();

  /******************************************************************
   *                 HARVST0R-RELATED FUNCTIONALITY                 *
   ******************************************************************/

  /// @notice Sets up the Harvestor Factory
  /// @param implementation The address of the MasterCopy for Harvestors
  /// @param seeds The address for the `Seeds Access Voucher` NFTs
  function setup(address implementation, address seeds) external;

  /// @notice Deploys a `Harvest0r` contract for the target token
  /// @param targetToken The token address for the new Harvestor
  /// @return harvestor The address for the newly deployed `Harvest0r`
  function newHarvestor(address targetToken) external returns (address harvestor);

  /// @notice Checks if a contract is a `Harvest0r`
  /// @param target The address of the Harvestor being inspected
  /// @return bool The result of the Harvestor check
  function isHarvestor(address target) external view returns (bool);

  /// @notice Returns the implementation address
  /// @return address The address of the master copy (implementation contract)
  function viewImplementation() external view returns (address);

  /// @notice Returns the harvestor for a given token address
  /// @param token The token address
  /// @return address The address of the Harvestor for this token
  function findHarvestor(address token) external view returns (address);

}
