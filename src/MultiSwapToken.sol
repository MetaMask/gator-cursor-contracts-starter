// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DelegatedCall.sol";

contract MultiSwapToken is ERC20, Ownable {
    address[] public acceptedCurrencies;

    constructor(string memory name, string memory symbol, address[] memory _acceptedCurrencies) 
        ERC20(name, symbol) 
        Ownable(msg.sender)
    {
        acceptedCurrencies = _acceptedCurrencies;
    }
    struct TokenSwap {
        bytes permissionContext;
        address delegationManager;
        address offerCurrency;
        uint256 amount;
    }

    // Recommended delegation: Allow trusted parties to call this function with specific limits
    function swapBatch(TokenSwap[] calldata swaps) public {
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < swaps.length; i++) {
            require(isAcceptedCurrency(swaps[i].offerCurrency), "Currency not accepted");

            DelegatedContext memory context = DelegatedContext({
                delegationManager: swaps[i].delegationManager,
                permissionContext: swaps[i].permissionContext
            });

            DelegatedCall.call(
                context,
                swaps[i].offerCurrency,
                0,
                abi.encodeWithSelector(IERC20.transferFrom.selector, msg.sender, address(this), swaps[i].amount)
            );

            totalAmount += swaps[i].amount;
        }

        _mint(msg.sender, totalAmount);
    }

    function isAcceptedCurrency(address currency) internal view returns (bool) {
        for (uint256 i = 0; i < acceptedCurrencies.length; i++) {
            if (acceptedCurrencies[i] == currency) {
                return true;
            }
        }
        return false;
    }
    // Recommended delegation: Allow trusted parties to update the list of accepted currencies
    function setAcceptedCurrencies(address[] memory _acceptedCurrencies) public onlyOwner {
        acceptedCurrencies = _acceptedCurrencies;
    }

    // Helper function to get the list of accepted currencies
    function getAcceptedCurrencies() public view returns (address[] memory) {
        return acceptedCurrencies;
    }
}
