// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {
    ResultStatus,
    MapStatus
} from "../../constant/Status.sol";
import { EventResultV3 } from "../../model/EventResult.sol";
import { BetType } from "../../constant/BetType.sol";
import { SportType } from "../../constant/SportType.sol";

library EventHandlerV3 {
    function getScore(
        uint256 sportType,
        uint16 betType,
        uint8 resource1,
        bytes memory resultBytes
    ) internal pure returns (uint256 homeScore, uint256 awayScore) {
        EventResultV3 memory result = abi.decode(
            resultBytes,
            (EventResultV3)
        );

        if (
            betType == BetType.FTHandicap ||
            betType == BetType.FTOddEven ||
            betType == BetType.FTOverUnder ||
            betType == BetType.FT1x2 ||
            betType == BetType.FTMoneyline ||
            betType == BetType.FTCorrectScore ||
            betType == BetType.FTGameHandicap ||
            betType == BetType.CorrectMapScore ||
            betType == BetType.MatchHandicap ||
            betType == BetType.MatchPointHandicap ||
            betType == BetType.MatchPointOverUnder ||
            betType == BetType.MatchPointOddEven
        )
        {
            if (sportType == SportType.Tennis || sportType == SportType.Badminton) {
                if (
                    betType == BetType.FTGameHandicap ||
                    betType == BetType.FTOddEven ||
                    betType == BetType.FTOverUnder ||
                    betType == BetType.MatchPointHandicap ||
                    betType == BetType.MatchPointOverUnder ||
                    betType == BetType.MatchPointOddEven
                ) {
                    homeScore = uint256(result.gameScore.homeScore);
                    awayScore = uint256(result.gameScore.awayScore);
                    return (homeScore, awayScore);
                }
            }

            homeScore = uint256(result.fullTimeScore.homeScore);
            awayScore = uint256(result.fullTimeScore.awayScore);
            return (homeScore, awayScore);
        }

        if (
            betType == BetType.HTHandicap ||
            betType == BetType.HTOverUnder ||
            betType == BetType.HTOddEven ||
            betType == BetType.HT1x2 ||
            betType == BetType.HTMoneyline
        )
        {
            homeScore = uint256(result.halfTimeScore.homeScore);
            awayScore = uint256(result.halfTimeScore.awayScore);
            return (homeScore, awayScore);
        }

        if (
            betType == BetType.QuarterHandicap ||
            betType == BetType.QuarterOverUnder ||
            betType == BetType.QuarterOddEven ||
            betType == BetType.QuarterMoneyline
        )
        {
            homeScore = uint256(result.sessionScores[resource1 - 1].homeScore);
            awayScore = uint256(result.sessionScores[resource1 - 1].awayScore);
            return (homeScore, awayScore);
        }

        if (betType == BetType.MapXMoneyline)
        {
            homeScore = uint256(result.mapScores[resource1 - 1].homeScore);
            awayScore = uint256(result.mapScores[resource1 - 1].awayScore);
            return (homeScore, awayScore);
        }
    }

    function getEventStatus(
        bytes memory resultBytes,
        uint16 betType,
        uint8 resource1
    ) internal pure returns (ResultStatus) {
        EventResultV3 memory result = abi.decode(
            resultBytes,
            (EventResultV3)
        );

        if (betType == BetType.MapXMoneyline) {
            MapStatus mapStatus = result.mapScores[resource1 - 1].status;
            if (mapStatus == MapStatus.Completed) {
                return ResultStatus.Completed;
            }
            if (mapStatus == MapStatus.Refund) {
                return ResultStatus.Refund;
            }
        }
        return result.status;
    }

    function getResultHash(
        uint256 sportType,
        uint16 betType,
        uint8 resource1,
        bytes memory resultBytes
    ) internal pure returns (bytes32) {
        (uint256 homeScore, uint256 awayScore) = getScore(sportType, betType, resource1, resultBytes);
        return keccak256(abi.encode(abi.encodePacked(
            Strings.toString(homeScore),
            ":",
            Strings.toString(awayScore)))
        );
    }

    function getEventId(
        bytes memory resultBytes
    ) internal pure returns (uint256) {
        EventResultV3 memory result = abi.decode(
            resultBytes,
            (EventResultV3)
        );

        return result.eventId;
    }
}
