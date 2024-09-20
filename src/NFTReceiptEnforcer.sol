// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CaveatEnforcer } from "@delegator/src/enforcers/CaveatEnforcer.sol";
import { ModeCode } from "@delegator/src/utils/Types.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTReceiptEnforcer is CaveatEnforcer {
    struct NFTReceiptTerms {
        address nftContract;
        address recipient;
        uint256 tokenId;
    }

    error NFTNotReceived(address recipient, address nftContract, uint256 tokenId);

    function beforeHook(
        bytes calldata,
        bytes calldata,
        ModeCode,
        bytes calldata,
        bytes32,
        address,
        address
    ) external pure override {
        // No pre-execution checks needed
    }

    function afterHook(
        bytes calldata _terms,
        bytes calldata,
        ModeCode,
        bytes calldata,
        bytes32,
        address,
        address
    ) external view override {
        NFTReceiptTerms memory terms = abi.decode(_terms, (NFTReceiptTerms));
        
        IERC721 nft = IERC721(terms.nftContract);
        if (nft.ownerOf(terms.tokenId) != terms.recipient) {
            revert NFTNotReceived(terms.recipient, terms.nftContract, terms.tokenId);
        }
    }
}
