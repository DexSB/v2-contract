// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { OddsType } from "../constant/OddsType.sol";

struct Ticket {
    uint16 betType;
    address payoutAddress;
    uint256 payout;
    address customer;
    uint256 stake;
    address token;
    bool isExist;
    uint256 version;
    bytes betDetail;
}

struct PlaceSingleBetDto {
    uint256 transId;
    uint16 sportType;
    uint256 eventId;
    uint16 betType;
    bytes32 keyHash;
    uint256 liveHomeScore;
    uint256 liveAwayScore;
    OddsType oddsType;
    int256 displayPrice;
    uint256 displayStake;
    address customer;
    address payoutAddress;
    address token;
    uint256 hdp1;
    uint256 hdp2;
    uint8 resource1;
    uint8 resource2;
}

struct SingleBetTicket {
    uint256 transId;
    uint256 eventId;
    bytes32 keyHash;
    uint256 liveHomeScore;
    uint256 liveAwayScore;
    uint256 hdp1;
    uint256 hdp2;
    uint16 sportType;
    uint8 resource1;
    uint8 resource2;
}

struct PlaceOutrightBetDto {
    uint256 transId;
    uint256 leagueId;
    uint256 teamId;
    OddsType oddsType;
    int256 displayPrice;
    uint256 displayStake;
    address customer;
    address payoutAddress;
    address token;
}

struct OutrightBetTicket {
    uint256 leagueId;
    uint256 teamId;
}

struct ProcessRequestDto {
    int256 displayPrice;
    uint256 displayStake;
}

struct ProcessResponseDto {
    uint256 payout;
    uint256 stake;
}
