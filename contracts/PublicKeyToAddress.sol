// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";
import "./EC.sol";

contract PublicKeyToAddress is EC {

    function publicKeyToAvalancheAddressString(
        bytes calldata publicKey, string memory prefix, uint[]memory hrp
    )
        public pure
        returns (string memory)
    {
        bytes20 avalancheAddress = publicKeyToAvalancheAddress(publicKey);
        uint[] memory rp = new uint[](20);
        for(uint i=0;i<20;i++) {
            rp[i] = uint(uint8(avalancheAddress[i]));
        }
        bytes memory pre = bytes(prefix);
        return encode(pre, hrp, convert(rp, 8, 5));
    }

    function publicKeyToEthereumAddress(
        bytes calldata publicKey
    )
        public pure
        returns (bytes20)
    {
        (uint256 x, uint256 y) = extractPublicKeyPair(publicKey);
        uint256[2] memory publicKeyPair = [x, y];
        bytes32 hash = keccak256(abi.encodePacked(publicKeyPair));
        return bytes20(uint160(uint256(hash)));
    }

    function publicKeyToAvalancheAddress(
        bytes calldata publicKey
    )
        public pure
        returns (bytes20)
    {
        bytes memory compressedPublicKey = publicKey;
        if (publicKey[0] == bytes1(0x04)) {
            (uint256 x, uint256 y) = extractPublicKeyPair(publicKey);
            compressedPublicKey = compressPublicKey(x, y);
        }
        bytes32 sha = sha256(abi.encodePacked(compressedPublicKey));
        return ripemd160(abi.encodePacked(sha));
    }

    function extractPublicKeyPair(
        bytes calldata encodedPublicKey
    )
        internal pure
        returns (uint256, uint256)
    {
        bytes1 prefix = encodedPublicKey[0];
        if (prefix == bytes1(0x04)) {
            return (
                uint256(BytesLib.toBytes32(encodedPublicKey, 1)),
                uint256(BytesLib.toBytes32(encodedPublicKey, 33)));
        } else {
            uint256 x = uint256(BytesLib.toBytes32(encodedPublicKey, 1));
            // Tonelli–Shanks algorithm for calculating square root modulo prime of x^3 + 7
            uint256 y = powmod(mulmod(x, mulmod(x, x, p), p) + 7, (p + 1) / 4, p);
            if (prefix == bytes1(0x02)) {
                return (x, (y % 2 == 0) ? y : p - y);
            } else if (prefix == bytes1(0x03)) {
                return (x, (y % 2 == 0) ? p - y : y);
            } else {
                revert("Invalid public key prefix");
            }
        }
    }

    function compressPublicKey(uint256 x, uint256 y) internal pure returns (bytes memory) {
        return BytesLib.concat(compressedPublicKeyBytePrefix(y % 2 == 0), abi.encodePacked(bytes32(x)));
    }

    function compressedPublicKeyBytePrefix(bool evenY) internal pure returns (bytes memory) {
        return abi.encodePacked(evenY ? bytes1(0x02) : bytes1(0x03));
    }

    function uncompressedPublicKeyBytePrefix() internal pure returns (bytes memory) {
        return abi.encodePacked(bytes1(0x04));
    }

    function powmod(uint256 x, uint256 n, uint256 p) private pure returns (uint256) {
        uint256 result = 1;
        while (n > 0) {
            if (n & 1 == 1) {
                result = mulmod(result, x, p);
            }
            x = mulmod(x, x, p);
            n >>= 1;
        }
        return result;
    }
}