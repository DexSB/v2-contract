// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { EnumerableSet } from "../EnumerableSet.sol";
import { BytesEventResultV1 } from "../../model/EventResult.sol";

library BytesEventMapV1 {
    using EnumerableSet for EnumerableSet.UintSet;

    struct EventResultMap {
        EnumerableSet.UintSet _keys;
        mapping(uint256 => bytes) _values;
    }

    function set(
        EventResultMap storage map,
        uint256 key,
        BytesEventResultV1 memory value
    ) internal returns (bool) {
        map._values[key] = abi.encode(value);
        return map._keys.add(key);
    }

    function remove(
        EventResultMap storage map,
        uint256 key
    ) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function contains(
        EventResultMap storage map,
        uint256 key
    ) internal view returns (bool) {
        return map._keys.contains(key);
    }

    function length(
        EventResultMap storage map
    ) internal view returns (uint256) {
        return map._keys.length();
    }

    function at(
        EventResultMap storage map,
        uint256 index
    ) internal view returns (uint256, BytesEventResultV1 memory) {
        uint256 key = map._keys.at(index);
        return (
            key,
            abi.decode(
                map._values[key],
                (BytesEventResultV1)
            )
        );
    }

    function tryGet(
        EventResultMap storage map,
        uint256 key
    ) internal view returns (bool, BytesEventResultV1 memory result) {
        bytes memory value = map._values[key];
        if (keccak256(value) == keccak256(bytes(""))) {
            return (contains(map, key), result);
        } else {
            return (
                true,
                abi.decode(
                    map._values[key],
                    (BytesEventResultV1)
                )
            );
        }
    }
}
