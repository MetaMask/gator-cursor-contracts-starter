// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DelegatedCall.sol";

contract PopupCity is ERC721, Ownable {
    uint256 public fundingTarget;
    IERC20 public fundingToken;
    uint256 private _tokenIdCounter;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _fundingTarget,
        address _fundingToken
    ) ERC721(name, symbol) Ownable(msg.sender) {
        fundingTarget = _fundingTarget;
        fundingToken = IERC20(_fundingToken);
    }

    // This function should be called by the owner when the funding target is reached
    // Recommended delegation: Allow trusted party to call this function when funding goal is met
    // Recommended delegation: Bidders would ideally wrap their offers with a caveat that enforces the ticket receipt
    // (For extra user-side-enforced safety)
    function closeSale(uint256 closingPrice, DelegatedContext[] calldata contexts, address[] calldata recipients) public onlyOwner {
        require(contexts.length == recipients.length, "Arrays length mismatch");
        uint256 totalFunds = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            DelegatedCall.call(
                contexts[i],
                address(fundingToken),
                0,
                abi.encodeWithSelector(IERC20.transferFrom.selector, recipients[i], address(this), closingPrice)
            );
            _safeMint(recipients[i], _tokenIdCounter);
            _tokenIdCounter++;
            totalFunds += closingPrice;
        }

        require(totalFunds >= fundingTarget, "Total funds are less than the funding target");
        require(fundingToken.transfer(owner(), totalFunds), "Transfer to owner failed");
    }

    // Helper function to check current funding status
    function currentFunding() public view returns (uint256) {
        return fundingToken.balanceOf(address(this));
    }

    // Function to update funding target if needed
    // Recommended delegation: Allow trusted advisors to adjust target based on market conditions
    function updateFundingTarget(uint256 newTarget) public onlyOwner {
        fundingTarget = newTarget;
    }

    // Function to withdraw funds after sale closure
    // Recommended delegation: Allow financial team to manage funds post-sale
    function withdrawFunds(address to, uint256 amount) public onlyOwner {
        require(fundingToken.transfer(to, amount), "Transfer failed");
    }
}
