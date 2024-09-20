// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@erc7579/lib/ModeLib.sol";
import "@erc7579/lib/ExecutionLib.sol";
import "@openzeppelin/contracts/utils/Address.sol";

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