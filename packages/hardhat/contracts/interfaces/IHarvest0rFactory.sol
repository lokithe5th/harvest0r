pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

interface IHarvest0rFactory {

  /******************************************************************
   *                            ERRORS                              *
   ******************************************************************/

  /// The Harvestor contract for this token exists
  //error Exists();

  /******************************************************************
   *                 HARVST0R-RELATED FUNCTIONALITY                 *
   ******************************************************************/

  /// @notice Deploys a `Harvest0r` contract for the target token
  /// @param targetToken The token address for the new Harvestor
  /// @return harvestor The address for the newly deployed `Harvest0r`
  function newHarvestor(address targetToken) external returns (address harvestor);

  /// @notice Checks if a contract is a `Harvest0r`
  /// @param target The address of the Harvestor being inspected
  /// @return bool The result of the Harvestor check
  function isHarvestor(address target) external view returns (bool);
}
