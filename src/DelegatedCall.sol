// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@erc7579/lib/ModeLib.sol";
import "@erc7579/lib/ExecutionLib.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @notice This library provides a convenient way to call delegation managers
 * as demonstrated in PopupCity.sol.
 * 
 * It simplifies the process of redeeming delegations by encapsulating the
 * complex call structure required by the ERC-7710 standard. This allows
 * contracts like PopupCity to easily execute delegated calls, such as
 * transferring tokens or minting NFTs, based on user-provided delegations.
 * 
 * Usage example from PopupCity.sol:
 * DelegatedCall.call(
 *     contexts[i],
 *     address(fundingToken),
 *     0,
 *     abi.encodeWithSelector(IERC20.transferFrom.selector, recipients[i], address(this), closingPrice)
 * );
 * 
 * This approach enhances flexibility and security by leveraging the
 * delegation framework for complex operations like closing a sale or
 * transferring ownership.
 */


struct DelegatedContext {
    address delegationManager;
    bytes permissionContext;
}

library DelegatedCall {
    using ModeLib for ModeCode;
    using Address for address;

    function call(
        DelegatedContext memory context,
        address target,
        uint256 value,
        bytes memory data
    ) internal returns (bytes memory) {
        bytes[] memory permissionContexts = new bytes[](1);
        permissionContexts[0] = context.permissionContext;

        bytes[] memory executionCallDatas = new bytes[](1);
        executionCallDatas[0] = ExecutionLib.encodeSingle(target, value, data);

        ModeCode[] memory encodedModes = new ModeCode[](1);
        encodedModes[0] = ModeLib.encodeSimpleSingle();

        return context.delegationManager.functionCall(
            abi.encodeWithSelector(
                bytes4(keccak256("redeemDelegations(bytes[],uint8[],bytes[])")),
                permissionContexts,
                encodedModes,
                executionCallDatas
            )
        );
    }
}