pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

interface Harvest0rFactory {
  function newField(address targetToken) external returns (address field);

  function isField(address field) external view;
}
