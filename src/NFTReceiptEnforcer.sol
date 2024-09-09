// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CaveatEnforcer } from "@delegator/src/enforcers/CaveatEnforcer.sol";
import { Action } from "@delegator/src/utils/Types.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTReceiptEnforcer is CaveatEnforcer {
    struct NFTReceipt {
        address nftContract;
        uint256 tokenId;
        address intendedRecipient;
    }

    error NFTNotReceived(address account, address nftContract, uint256 tokenId);
    error UnauthorizedRecipient(address actual, address intended);

    function beforeHook(
        bytes calldata _terms,
        bytes calldata,
        Action calldata,
        bytes32,
        address,
        address _redeemer
    ) external view override returns (bool) {
        NFTReceipt memory receipt = abi.decode(_terms, (NFTReceipt));
        if (_redeemer != receipt.intendedRecipient) {
            revert UnauthorizedRecipient(_redeemer, receipt.intendedRecipient);
        }
        return true;
    }

    function afterHook(
        bytes calldata _terms,
        bytes calldata,
        Action calldata,
        bytes32,
        address,
        address _redeemer
    ) external view override returns (bool) {
        NFTReceipt memory receipt = abi.decode(_terms, (NFTReceipt));
        
        IERC721 nft = IERC721(receipt.nftContract);
        if (nft.ownerOf(receipt.tokenId) != _redeemer) {
            revert NFTNotReceived(_redeemer, receipt.nftContract, receipt.tokenId);
        }

        return true;
    }
}

