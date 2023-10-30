// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { ResultStatus } from "../constant/Status.sol";
import { BetType } from "../constant/BetType.sol";

library RefundChecker {
    enum BetTypeCategory {
        Undefined,
        Quarter1,
        Quarter2,
        HalfTime,
        Quarter3,
        Quarter4,
        FullTime,
        Map
    }

    function getIsRefund(
        uint16 betType,
        ResultStatus status,
        uint8 resource1
    ) internal pure returns (bool) {
        // these ResultStatus should refund all tickets
        if (
            status == ResultStatus.Refund ||
            status == ResultStatus.Abandoned1H ||
            status == ResultStatus.AbandonedQ1
        )
        {
            return true;
        }

        // get the ticket target period 
        BetTypeCategory betTypeCategory = getBetTypeCategory(betType, resource1);
        // check if the target period should be refund
        if (status == ResultStatus.Abandoned2H) {
            return betTypeCategory > BetTypeCategory.HalfTime;
        } else if (status == ResultStatus.AbandonedQ2) {
            return betTypeCategory > BetTypeCategory.Quarter1;
        } else if (status == ResultStatus.AbandonedQ3) {
            return betTypeCategory > BetTypeCategory.HalfTime;
        } else if (status == ResultStatus.AbandonedQ4) {
            return betTypeCategory > BetTypeCategory.Quarter3;
        }

        return false;
    }

    function getBetTypeCategory(
        uint16 betType,
        uint8 resource1
    ) internal pure returns (BetTypeCategory) {
        
        if (
            betType == BetType.FTHandicap ||
            betType == BetType.FTOddEven ||
            betType == BetType.FTOverUnder ||
            betType == BetType.FT1x2 ||
            betType == BetType.FTMoneyline ||
            betType == BetType.FTGameHandicap ||
            betType == BetType.FTCorrectScore ||
            betType == BetType.CorrectMapScore ||
            betType == BetType.MatchHandicap ||
            betType == BetType.MatchPointHandicap ||
            betType == BetType.MatchPointOverUnder ||
            betType == BetType.MatchPointOddEven
        )
        {
            return BetTypeCategory.FullTime;
        } else if (
            betType == BetType.HTHandicap ||
            betType == BetType.HTOverUnder ||
            betType == BetType.HTOddEven ||
            betType == BetType.HT1x2 ||
            betType == BetType.HTMoneyline
        )
        {
            return BetTypeCategory.HalfTime;
        } else if (
            betType == BetType.QuarterHandicap ||
            betType == BetType.QuarterOverUnder ||
            betType == BetType.QuarterOddEven ||
            betType == BetType.QuarterMoneyline
        )
        {
            if (resource1 == 1) {
                return BetTypeCategory.Quarter1;
            } else if (resource1 == 2) {
                return BetTypeCategory.Quarter2;
            } else if (resource1 == 3) {
                return BetTypeCategory.Quarter3;
            } else if (resource1 == 4) {
                return BetTypeCategory.Quarter4;
            }
        } else if (
            betType == BetType.MapXMoneyline
        ) {
            return BetTypeCategory.Map;
        }

        revert("CustomErrors: this bet type is not supported yet");
    }
}