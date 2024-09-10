// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EventTickets is ERC721, Ownable {
    uint256 public constant MAX_TICKETS = 1000;
    uint256 public ticketPrice;
    uint256 public ticketsMinted;

    constructor(string memory name, string memory symbol, uint256 _ticketPrice) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        ticketPrice = _ticketPrice;
    }

    // Mint a ticket for a specific address
    // Recommended delegation: Use AllowedCalldataEnforcer to restrict who can receive tickets
    // Combined with ERC20TransferAmountEnforcer to ensure proper payment
    function mintTicket(address to) external onlyOwner {
        require(ticketsMinted < MAX_TICKETS, "All tickets have been minted");
        uint256 newTokenId = ticketsMinted + 1;
        _safeMint(to, newTokenId);
        ticketsMinted++;
    }

    // Update ticket price
    // Recommended delegation: Use ValueLteEnforcer to limit the maximum price
    function setTicketPrice(uint256 _newPrice) external onlyOwner {
        ticketPrice = _newPrice;
    }

    // Withdraw funds from ticket sales
    // Recommended delegation: Use ERC20TransferAmountEnforcer to limit withdrawal amounts
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    // Allow contract to receive ETH
    receive() external payable {}
}
