pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Seeds is ERC721A {
  using Strings for uint256;
  uint256 private mintCost;
  address private harvest0r;

  string[3] internal svgParts = [
        '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 400"><style>.base { fill: white; font-family: monospace; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',
        '</text><text x="10" y="40" class="base">',
        '</text></svg>'
  ];

  mapping(uint256 => uint8) private charges;

  constructor(address harvestor) ERC721A("Seeds", "SEEDS") {
    mintCost = 0.069 ether;
    harvest0r = harvestor;
  }

  function mint(uint256 quantity) external payable {
      // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`.
      _mint(msg.sender, quantity);

      _setExtraDataAt(_nextTokenId() - 1, 9);
      charges[_nextTokenId() - 1] = 9;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory json) {
    json = Base64.encode(bytes(string(abi.encodePacked(
          '{"name": "Seeds NFT", "description": "...as you sow...", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(generateSVGofTokenById(tokenId))), '"}'))));

        json = string(abi.encodePacked('data:application/json;base64,', json));
  }

  function generateSVGofTokenById(uint256 tokenId) public view returns (string memory svg) {
    svg = string(abi.encodePacked(svgParts[0], 'Charges: ', (uint256(charges[tokenId])).toString(), svgParts[1], svgParts[2]));
  }

  function useCharge(uint256 tokenId) external {
    require(msg.sender == harvest0r, "Only harvestor");
    //  consume an NFTs charge
    TokenOwnership memory unpackedData = _ownershipAt(tokenId);
    _setExtraDataAt(tokenId, unpackedData.extraData - 1);
  }

  function recharge(uint256 tokenId) external payable {
    //  replenish an NFTs charges
    require(msg.value == mintCost, "cost not covered");
    charges[tokenId] = 9;
  }

  function viewCharge(uint256 tokenId) public view returns (uint8) {
    return charges[tokenId];
  }
}
