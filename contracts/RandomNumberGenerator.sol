pragma solidity ^0.8.0;

// SPDX-License-Identifier: AGPL-3.0-only
// Author: https://github.com/ankurdaharwal

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./Lottery.sol";

/// @title Random Number Generator
/// @author Ankur Daharwal (https://github.com/ankurdaharwal)
/// @notice Generates a random number based on the ChainLink VRF consumer implementation (https://docs.chain.link/docs/get-a-random-number/)
/// @dev Inherits VRFConsumerBase (ChainLink VRF)

// Reference ChainLink VRF: https://docs.chain.link/docs/get-a-random-number/

contract RandomNumberGenerator is VRFConsumerBase {

    address requester;
    bytes32 keyHash;
    uint256 fee;

    constructor()
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ) {
            keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; 
            fee = 0.1 * 10 ** 18; // 0.1 LINK
    }

    /// @dev Fulfills a verifiable random number request and overrides the VRFConsumerBase parent contract function `fulfillRandomness`
    /// @param _requestId Unique request identifier
    /// @param _randomness Verifiable random number
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        Lottery(requester).numberDrawn(_requestId, _randomness);
    }
    
    /// @dev Requests a new verifiable random number
    /// @return requestId
    /// @param requestId Returns the unique requested random number identifier
    function request() public returns(bytes32 requestId) {
        require(keyHash != bytes32(0), "Must have valid key hash");
        requester = msg.sender;
        return requestRandomness(keyHash, fee);
    }
}

