// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";
import "./Base58.sol";

contract RippleAddressValidator is Base58 {
    bytes constant XRP_ALPHABET = "rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz";

    function validateRipple(string memory _rippleAddress) external pure returns (bool) {
        bytes memory rippleAddress = bytes(_rippleAddress);
        if (rippleAddress.length < 25 || rippleAddress.length > 35 || rippleAddress[0] != 'r') {
            return false;
        }
        (bytes memory decoded, bool ok) = decode(rippleAddress, XRP_ALPHABET);
        return ok ? checkChecksum(decoded) : false;
    }

    function checkChecksum(bytes memory _payload) internal pure returns (bool) {
        bytes memory checksum = BytesLib.slice(_payload, _payload.length - 4, 4);
        bytes memory accountID = BytesLib.slice(_payload, 0, _payload.length - 4);
        bytes memory accountChecksum = sha256Checksum(accountID);
        return BytesLib.equal(accountChecksum, checksum);
    }

    function sha256Checksum(bytes memory _payload) internal pure returns (bytes memory) {
        bytes memory dSha256 = abi.encodePacked(sha256(abi.encodePacked(sha256(_payload))));
        return BytesLib.slice(dSha256, 0, 4);
    }

}