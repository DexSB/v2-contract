// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { OutrightTeamStatus } from "../constant/Status.sol";

struct BytesOutrightResultV1 {
    uint256 version;
    bytes resultBytes;
}

struct OutrightEventV1 {
    uint16 sportType;
    uint256 leagueId;
    Outright[] outrights;
    uint16 deadHeat;
}

struct Outright {
    uint256 teamId;
    OutrightTeamStatus status;
}
