pragma solidity 0.8.17;
//SPDX-License-Identifier: MIT

interface IHarvest0rFactory {

  error Exists();

  function newField(address targetToken) external returns (address field);

  function isField(address field) external view returns (bool);
}
