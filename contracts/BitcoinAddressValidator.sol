// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";
import "./Base58.sol";

// according to chatGPT:
// we do not support P2SH addresses as sending to P2SH address with the wrong
// underlying script hash will likely be rejected by the miners during block
// validation. Thus we would need to verify correctness of the script, which
// is probably not feasible in solidity.

contract BitcoinAddressValidator is Base58 {
    bytes constant BTC_ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    function _validateP2PKH(string memory _bitcoinAddress) external pure returns (bool) {
        bytes memory bitcoinAddress = bytes(_bitcoinAddress);
        if (bitcoinAddress.length != 34 || bitcoinAddress[0] != '1') return false;
        (bytes memory decoded, bool ok) = decode(bitcoinAddress, BTC_ALPHABET);
        // decoded is always length 25, as it is result of ripemd160
        return (ok && decoded.length == 25) ? checkChecksum(decoded) : false;
    }

    function _validateBech32(string memory _bitcoinAddress) external pure returns (bool) {
        
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


    ////////////////////////////////////////////////////////////////////
    // Bech32



}