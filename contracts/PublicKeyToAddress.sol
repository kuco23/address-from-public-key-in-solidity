// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "hardhat/console.sol";
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
        return BytesLib.concat(getPublicKeyBytePrefix(y % 2 == 0), abi.encodePacked(bytes32(x)));
    }

    function getPublicKeyBytePrefix(bool evenY) internal pure returns (bytes memory prefix) {
        prefix = new bytes(1);
        bytes1 bytes1Prefix = evenY ? bytes1(0x02) : bytes1(0x03);
        assembly {
            mstore(add(prefix, 32), bytes1Prefix)
        }
        return prefix;
    }
}