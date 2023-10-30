// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { OutrightTeamStatus } from "../../constant/Status.sol";
import { OutrightEventV1 } from "../../model/OutrightResult.sol";

library OutrightHandlerV1 {
    function getOutrightResult(
        uint256 teamId,
        bytes memory resultBytes
    ) internal pure returns (OutrightTeamStatus, uint256) {
        OutrightEventV1 memory result = abi.decode(
            resultBytes,
            (OutrightEventV1)
        );

        for (uint256 i; i < result.outrights.length; i++) {
            if (teamId == result.outrights[i].teamId) {
                return (result.outrights[i].status, result.deadHeat);
            }
        }
        return (OutrightTeamStatus.Lost, result.deadHeat);
    }

    function getLeagueId(
        bytes memory resultBytes
    ) internal pure returns (uint256) {
        OutrightEventV1 memory result = abi.decode(
            resultBytes,
            (OutrightEventV1)
        );

        return result.leagueId;
    }
}
