// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PayoutCalculator } from "../../src/lib/PayoutCalculator.sol";
import { OddsType } from "../../src/constant/OddsType.sol";

contract PayoutCalculatorTest is Test {
    function test_convertFromDisplayForm_in_decimal_odds_with_case() public {
        uint256 payout;
        uint256 stake;

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Decimal, 120, 1_000_000);
        assertEq(payout, 1_200_000);
        assertEq(stake, 1_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Decimal, 220, 1_000_000);
        assertEq(payout, 2_200_000);
        assertEq(stake, 1_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Decimal, 300, 1_000_000);
        assertEq(payout, 3_000_000);
        assertEq(stake, 1_000_000);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_decimal_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, 101, 1_000_000_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Decimal, displayPrice, displayStake);
        assertEq(payout, (uint256(displayPrice) * displayStake) / 100);
        assertEq(stake, displayStake);
    }

    function test_convertFromDisplayForm_in_hongkong_odds_with_case() public {
        uint256 payout;
        uint256 stake;

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.HongKong, 98, 1_000_000);
        assertEq(payout, 1_980_000);
        assertEq(stake, 1_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.HongKong, 120, 1_000_000);
        assertEq(payout, 2_200_000);
        assertEq(stake, 1_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.HongKong, 320, 1_000_000);
        assertEq(payout, 4_200_000);
        assertEq(stake, 1_000_000);
    }

    /**
     * forge-config: default.fuzz.runs = 4095
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_hongkong_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, 1, 1_000_000_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.HongKong, displayPrice, displayStake);
        assertEq(payout, (uint256(displayPrice + 100) * displayStake) / 100);
        assertEq(stake, displayStake);
    }

    function test_convertFromDisplayForm_in_indo_odds_with_case() public {
        uint256 payout;
        uint256 stake;

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Indo, 126, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Indo, -111, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Indo, -199, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_positive_indo_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, 100, 1_000_000_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Indo, displayPrice, displayStake);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_negative_indo_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, -1_000_000_000, -100);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Indo, displayPrice, displayStake);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }

    function test_convertFromDisplayForm_in_malay_odds_with_case() public {
        uint256 payout;
        uint256 stake;

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Malay, 98, 1_000_000);
        assertEq(payout, 1_980_000);
        assertEq(stake, 1_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Malay, -30, 1_000_000);
        assertEq(payout, 1_300_000);
        assertEq(stake, 300_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Malay, -99, 1_000_000);
        assertEq(payout, 1_990_000);
        assertEq(stake, 990_000);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_positive_malay_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, 10, 300_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Malay, displayPrice, displayStake);
        assertEq(payout, (uint256(displayPrice + 100) * displayStake) / 100);
        assertEq(stake, displayStake);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_negative_malay_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, -100, 0);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.Malay, displayPrice, displayStake);
        assertEq(payout, (uint256(-displayPrice) * displayStake) / 100 + displayStake);
        assertEq(stake, (uint256(-displayPrice) * displayStake) / 100);
    }

    function test_convertFromDisplayForm_in_american_odds_with_case() public {
        uint256 payout;
        uint256 stake;

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.American, 12600, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.American, -11100, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.American, -19900, 1_000_000);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_positive_american_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, 10_000, 1_000_000_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.American, displayPrice, displayStake);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_convertFromDisplayForm_in_negative_american_odds_with_fuzz(
        int256 displayPrice,
        uint256 displayStake
    ) public {
        uint256 payout;
        uint256 stake;

        displayPrice = bound(displayPrice, -1_000_000, -10_000);
        displayStake = bound(displayStake, 10_000, 1_000_000_000);

        (payout, stake) = PayoutCalculator.covertFromDisplayForm(OddsType.American, displayPrice, displayStake);
        assertEq(payout, 0);
        assertEq(stake, 0);
    }
}
