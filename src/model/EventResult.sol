// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {
    ResultStatus,
    MapStatus
} from "../constant/Status.sol";

struct BytesEventResultV1 {
    uint256 version;
    bytes resultBytes;
}

struct EventResultV1 {
    uint256 eventId;
    uint256 homeId;
    uint256 awayId;
    ResultStatus status;
    Score fullTimeScore;
    Score halfTimeScore;
    Score overTimeScore;
    Score[] sessionScores;
}

struct Score {
    uint256 homeScore;
    uint256 awayScore;
}

struct EventResultV2 {
    uint256 eventId;
    uint256 homeId;
    uint256 awayId;
    ResultStatus status;
    Score fullTimeScore;
    Score halfTimeScore;
    Score overTimeScore;
    Score[] sessionScores;
    Score gameScore;
}

struct MapScore {
    uint256 homeScore;
    uint256 awayScore;
    MapStatus status;
}

struct EventResultV3 {
    uint256 eventId;
    uint256 homeId;
    uint256 awayId;
    ResultStatus status;
    Score fullTimeScore;
    Score halfTimeScore;
    Score overTimeScore;
    Score[] sessionScores;
    Score gameScore;
    MapScore[] mapScores;
}
