
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MacroExecutor is Ownable {
    struct Action {
        address target;
        uint256 value;
        bytes data;
    }

    // Execute a sequence of actions (macro)
    // Only the owner can call this function, but can share the ability to widen the solver network.
    // Recommended delegation: Use AllowedCalldataEnforcer to restrict the actions that can be executed
    // and combine with other enforcers like ERC20BalanceGteEnforcer to ensure proper outcome
    function executeMacro(Action[] calldata actions) external onlyOwner {
        for (uint i = 0; i < actions.length; i++) {
            (bool success, ) = actions[i].target.call{value: actions[i].value}(actions[i].data);
            require(success, "Action execution failed");
        }
    }

    // Allow the contract to receive ETH
    receive() external payable {}

    // Allow the owner to withdraw any tokens accidentally sent to this contract
    // Recommended delegation: Use ERC20TransferAmountEnforcer to limit withdrawal amounts
    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }

    // Allow the owner to withdraw any ETH in the contract
    // Recommended delegation: Use ValueLteEnforcer to limit withdrawal amounts
    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }

    // Allow the owner to withdraw any ERC721 tokens accidentally sent to this contract
    // Recommended delegation: Use NFTOwnershipEnforcer to ensure the delegatee owns the NFT
    function withdraw721(address nftContract, uint256 tokenId, address to) external onlyOwner {
        IERC721(nftContract).transferFrom(address(this), to, tokenId);
    }

    // Allow the owner to withdraw any ERC1155 tokens accidentally sent to this contract
    // Recommended delegation: Use a custom BalanceEnforcer for ERC1155 tokens
    function withdraw1155(address nftContract, uint256 id, uint256 amount, address to) external onlyOwner {
        IERC1155(nftContract).safeTransferFrom(address(this), to, id, amount, "");
    }
}

