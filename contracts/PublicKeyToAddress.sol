// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";
import "./EC.sol";

contract PublicKeyToAddress is EC {

    function publicKeyToEthereumAddress(uint[2] memory publicKey) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(publicKey));
        return address(uint160(uint256(hash)));
    }

    function publicKeyToAvalancheAddress(
        uint[2] memory publicKey, string memory prefix, uint[] memory hrp
    )
        public pure
        returns (string memory)
    {
        bytes memory compressedPublicKey = compressPublicKey(publicKey[0], publicKey[1]);
        bytes32 sha = sha256(abi.encodePacked(compressedPublicKey));
        bytes20 ripesha = ripemd160(abi.encodePacked(sha));
        uint[] memory rp = new uint[](20);
        for(uint i=0;i<20;i++) {
            rp[i] = uint(uint8(ripesha[i]));
        }
        bytes memory pre = bytes(prefix);
        return encode(pre, hrp, convert(rp, 8, 5));
    }

    function compressPublicKey(uint256 x, uint256 y) public pure returns (bytes memory) {
        return BytesLib.concat(publicKeyBytePrefix(y % 2 == 0), abi.encodePacked(bytes32(x)));
    }

    function decompressPublicKey(
        bytes memory compressedPublicKey
    )
        public pure
        returns (uint[2] memory publicKey)
    {
        require(compressedPublicKey.length == 33, "Invalid compressed public key length");
        bytes1 prefix = compressedPublicKey[0];
        uint256 x = uint256(BytesLib.toBytes32(compressedPublicKey, 1));
        // Tonelli–Shanks algorithm for calculating square root modulo prime of x^3 + 7
        uint256 y = powmod(mulmod(x, mulmod(x, x, p), p) + 7, (p + 1) / 4, p);
        publicKey[0] = x;
        publicKey[1] = (prefix == bytes1(0x02)) ?
            ((y % 2 == 0) ? y : p - y) :
            ((y % 2 == 0) ? p - y : y);
        return publicKey;
    }

    function publicKeyBytePrefix(bool evenY) internal pure returns (bytes memory) {
        // convert byte1 to bytes
        return abi.encodePacked(evenY ? bytes1(0x02) : bytes1(0x03));
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