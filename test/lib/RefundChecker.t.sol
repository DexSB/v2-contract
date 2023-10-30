// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { RefundChecker } from "../../src/lib/RefundChecker.sol";
import { BetType } from "../../src/constant/BetType.sol";
import { ResultStatus } from "../../src/constant/Status.sol";

contract RefundCheckerTest is Test {
    /**
     * Supported bet type list
     * FTHandicap = 1
     * FTOddEven = 2
     * FTOverUnder = 3
     * FT1x2 = 5
     * HTHandicap = 7
     * HTOverUnder = 8
     * HTOddEven = 12
     * HT1x2 = 15
     * FTMoneyline = 20
     * HTMoneyline = 21
     * FTGameHandicap = 153
     * FTCorrectScore = 413
     * QuarterHandicap = 609
     * QuarterOverUnder = 610
     * QuarterOddEven = 611
     * QuarterMoneyline = 612
     * MatchHandicap = 701
     * MatchPointHandicap = 704
     * MatchPointOverUnder = 705
     * MatchPointOddEven = 706
     * MapXMoneyline = 9001
     * CorrectMapScore = 9008
     */

    function test_getIsRefund_with_refund() public {
        uint16 betType;

        betType = uint16(BetType.FTHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FTOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FTOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FT1x2);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.HTHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.HTOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.HTOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.HT1x2);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FTMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.HTMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FTGameHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.FTCorrectScore);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.MatchHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.MatchPointHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.MatchPointOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.MatchPointOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.MapXMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
        betType = uint16(BetType.CorrectMapScore);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Refund, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.Abandoned1H, 1));
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ1, 1));
    }

    function test_getIsRefund_with_AbandonedQuater2() public {
        uint16 betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 1));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 1));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 1));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 1));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 2));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 2));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 2));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 2));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 3));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 3));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 3));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 3));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 4));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 4));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 4));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ2, 4));
    }

    function test_getIsRefund_with_AbandonedQuater3() public {
        uint16 betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 1));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 1));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 1));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 1));

        betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 2));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 2));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 2));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 2));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 3));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 3));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 3));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 3));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
    }


    function test_getIsRefund_with_AbandonedQuater4() public {
        uint16 betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 1));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 1));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 1));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 1));

        betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 2));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 2));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 2));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 2));

        betType = uint16(BetType.QuarterHandicap);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 3));
        betType = uint16(BetType.QuarterOverUnder);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 3));
        betType = uint16(BetType.QuarterOddEven);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 3));
        betType = uint16(BetType.QuarterMoneyline);
        assertFalse(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ4, 3));

        betType = uint16(BetType.QuarterHandicap);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterOverUnder);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterOddEven);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
        betType = uint16(BetType.QuarterMoneyline);
        assertTrue(RefundChecker.getIsRefund(betType, ResultStatus.AbandonedQ3, 4));
    }
}