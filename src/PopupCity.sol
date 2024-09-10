// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PopupCity is ERC721, Ownable {
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 1000;

    constructor() ERC721("PopupCity", "POP") Ownable(msg.sender) {}

    // Mint function for ticket creation
    // Recommended delegation: AllowedMethodsEnforcer to restrict to this function
    // Additional enforcer: LimitedCallsEnforcer to limit number of tickets per invitee
    function mint(address to) public onlyOwner {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    // Function to check ticket validity
    function isValidTicket(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    // Owner can set base URI for metadata
    // Recommended delegation: AllowedMethodsEnforcer to restrict to this function
    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    // Internal function to set base URI
    function _setBaseURI(string memory baseURI) internal {
        _baseURI = baseURI;
    }

    // Override base URI function
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURI;
    }

    string private _baseURI;
}

