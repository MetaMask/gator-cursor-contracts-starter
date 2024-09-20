// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { CaveatEnforcer } from "@delegator/src/enforcers/CaveatEnforcer.sol";
import { ModeCode, Action } from "@delegator/src/utils/Types.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IDelegationManager } from "@delegator/src/interfaces/IDelegationManager.sol";

contract SafeNFTReceiptEnforcer is CaveatEnforcer {
    struct NFTReceiptTerms {
        address nftContract;
        address recipient;
        uint256 tokenId;
        bool enforceTokenId;
    }

    error NFTNotReceived(address recipient, address nftContract, uint256 tokenId);
    error InvalidDelegation();
    error InvalidTokenId(uint256 expected, uint256 actual);

    function beforeHook(
        bytes calldata _terms,
        bytes calldata _args,
        ModeCode _mode,
        bytes calldata _executionCalldata,
        bytes32 _delegationHash,
        address _delegator,
        address _redeemer
    ) external override {
        NFTReceiptTerms memory terms = abi.decode(_terms, (NFTReceiptTerms));
        (bytes memory nftDelegation, address delegationManager) = abi.decode(_args, (bytes, address));

        // Redeem the NFT delegation to transfer the NFT
        IDelegationManager manager = IDelegationManager(delegationManager);
        bytes[] memory permissionContexts = new bytes[](1);
        permissionContexts[0] = nftDelegation;

        ModeCode[] memory modes = new ModeCode[](1);
        modes[0] = ModeCode.wrap(1); // Simple single call

        bytes[] memory executionCallDatas = new bytes[](1);
        executionCallDatas[0] = abi.encodeWithSelector(
            IERC721(terms.nftContract).transferFrom.selector,
            _delegator,
            terms.recipient,
            terms.tokenId
        );

        if (terms.enforceTokenId) {
            // Decode the execution calldata to verify the tokenId
            (, , uint256 actualTokenId) = abi.decode(
                _executionCalldata[4:],
                (address, address, uint256)
            );
            if (actualTokenId != terms.tokenId) {
                revert InvalidTokenId(terms.tokenId, actualTokenId);
            }
        }

        try manager.redeemDelegations(permissionContexts, modes, executionCallDatas) {
            // NFT transfer successful
        } catch {
            revert InvalidDelegation();
        }
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
        if (terms.enforceTokenId) {
            if (nft.ownerOf(terms.tokenId) != terms.recipient) {
                revert NFTNotReceived(terms.recipient, terms.nftContract, terms.tokenId);
            }
        } else {
            if (nft.balanceOf(terms.recipient) == 0) {
                revert NFTNotReceived(terms.recipient, terms.nftContract, 0);
            }
        }
    }
}
