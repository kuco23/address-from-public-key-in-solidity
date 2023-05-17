// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";
import "./Base58.sol";

contract AddressValidator is Base58 {

    function sha256Checksum(bytes memory _payload) internal pure returns (bytes memory) {
        bytes memory dSha256 = abi.encodePacked(sha256(abi.encodePacked(sha256(_payload))));
        return BytesLib.slice(dSha256, 0, 4);
    }

    function validateRipple(string memory _rippleAddress) external pure returns (bool) {
        bytes memory rippleAddress = bytes(_rippleAddress);
        if (rippleAddress.length < 25 || rippleAddress.length > 35 || rippleAddress[0] != bytes1("r")) {
            return false;
        }
        bytes memory decoded = decode(rippleAddress);
        bytes memory checksum = BytesLib.slice(decoded, decoded.length - 4, 4);
        bytes memory accountID = BytesLib.slice(decoded, 0, decoded.length - 4);
        bytes memory accountChecksum = sha256Checksum(accountID);
        return BytesLib.equal(accountChecksum, checksum);
    }
}