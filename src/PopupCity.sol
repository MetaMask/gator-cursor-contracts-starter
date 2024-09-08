// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import { Delegation } from "@delegator/src/utils/Types.sol";

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PopupCity is Ownable, ERC721Enumerable {
    uint256 public ticketPrice;
    uint256 public availableTickets;
    uint256 private _currentTokenId;

    event TicketPurchased(address owner, uint256 tokenId);
    event AvailableTicketsChanged(uint256 newAvailableTickets);

    constructor(
        address initialOwner,
        uint256 _ticketPrice,
        uint256 _availableTickets,
        string memory _ticketName,
        string memory _ticketSymbol
    ) Ownable(initialOwner) ERC721(_ticketName, _ticketSymbol) {
        ticketPrice = _ticketPrice;
        availableTickets = _availableTickets;
    }

    function buyTicket(Delegation calldata delegation, address ticketOwner) external onlyOwner {
        require(availableTickets > 0, "No tickets available");

        // Verify and use the delegation for payment
        require(executeDelegation(delegation), "Payment failed");

        availableTickets--;
        _currentTokenId++;
        uint256 newTokenId = _currentTokenId;
        _safeMint(ticketOwner, newTokenId);

        emit TicketPurchased(ticketOwner, newTokenId);
    }

    function setAvailableTickets(uint256 _availableTickets) external onlyOwner {
        availableTickets = _availableTickets;
        emit AvailableTicketsChanged(_availableTickets);
    }

    function executeDelegation(Delegation calldata delegation) internal returns (bool) {
        // Implement delegation execution logic for payment
        // This is a placeholder and should be replaced with actual execution
        return true;
    }

    // Override required function
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // Override required function
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
