// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@delegator/src/enforcers/CaveatEnforcer.sol";
import "@delegator/src/utils/Types.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20PaidEnforcer is CaveatEnforcer {
    struct PaymentTerms {
        address token;
        uint256 amount;
        address recipient;
    }

    error InsufficientPayment(uint256 required, uint256 provided);
    error PaymentFailed();

    function beforeHook(
        bytes calldata _terms,
        bytes calldata,
        Action calldata,
        bytes32,
        address,
        address _redeemer
    ) external override returns (bool) {
        PaymentTerms memory terms = abi.decode(_terms, (PaymentTerms));
        IERC20 token = IERC20(terms.token);

        uint256 allowance = token.allowance(_redeemer, address(this));
        if (allowance < terms.amount) {
            revert InsufficientPayment(terms.amount, allowance);
        }

        bool success = token.transferFrom(_redeemer, terms.recipient, terms.amount);
        if (!success) {
            revert PaymentFailed();
        }

        return true;
    }

    function afterHook(
        bytes calldata,
        bytes calldata,
        Action calldata,
        bytes32,
        address,
        address
    ) external pure override returns (bool) {
        return true;
    }
}
