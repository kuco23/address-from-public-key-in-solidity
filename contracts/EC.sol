// SPDPLicense-Identifier: MIT
pragma solidity 0.8.11;

import "./BytesLib.sol";

contract EC {

    // Set parameters for secp256k1 curve.
    uint constant a = 0;
    uint constant b = 7;
    uint constant gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint constant gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint constant p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint constant n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    uint constant lowSmax = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;
    bytes constant CHARSET = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';

    /**
     * @dev Inverse of u in the field of modulo m.
     */
    function inverseMod(uint u, uint m) internal pure
        returns (uint)
    {
        if (u == 0 || u == m || m == 0)
            return 0;
        if (u > m)
            u = u % m;

        int t1;
        int t2 = 1;
        uint r1 = m;
        uint r2 = u;
        uint q;

        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int(q) * t2, r2, r1 - q * r2);
        }

        if (t1 < 0)
            return (m - uint(-t1));

        return uint(t1);
    }

    /**
     * @dev Transform affine coordinates into projective coordinates.
     */
    function toProjectivePoint(uint x0, uint y0) public pure
        returns (uint[3] memory P)
    {
        P[2] = addmod(0, 1, p);
        P[0] = mulmod(x0, P[2], p);
        P[1] = mulmod(y0, P[2], p);
    }

    /**
     * @dev Add two points in affine coordinates and return projective point.
     */
    function addAndReturnProjectivePoint(uint x1, uint y1, uint x2, uint y2) public pure
        returns (uint[3] memory P)
    {
        uint x;
        uint y;
        (x, y) = add(x1, y1, x2, y2);
        P = toProjectivePoint(x, y);
    }

    /**
     * @dev Transform from projective to affine coordinates. req
     */
    function toAffinePoint(uint x0, uint y0, uint z0) public pure
        returns (uint x1, uint y1)
    {
        uint z0Inv;
        z0Inv = inverseMod(z0, p);
        x1 = mulmod(x0, z0Inv, p);
        y1 = mulmod(y0, z0Inv, p);
    }

    /**
     * @dev Return the zero curve in projective coordinates.
     */
    function zeroProj() public pure
        returns (uint x, uint y, uint z)
    {
        return (0, 1, 0);
    }

    /**
     * @dev Return the zero curve in affine coordinates.
     */
    function zeroAffine() public pure
        returns (uint x, uint y)
    {
        return (0, 0);
    }

    /**
     * @dev Check if the curve is the zero curve.
     */
    function isZeroCurve(uint x0, uint y0) public pure
        returns (bool isZero)
    {
        if(x0 == 0 && y0 == 0) {
            return true;
        }
        return false;
    }

    /**
     * @dev Check if a point in affine coordinates is on the curve.
     */
    function isOnCurve(uint x, uint y) public pure
        returns (bool)
    {
        if (0 == x || x == p || 0 == y || y == p) {
            return false;
        }

        uint LHS = mulmod(y, y, p); // y^2
        uint RHS = mulmod(mulmod(x, x, p), x, p); // x^3

        if (a != 0) {
            RHS = addmod(RHS, mulmod(x, a, p), p); // x^3 + a*x
        }
        if (b != 0) {
            RHS = addmod(RHS, b, p); // x^3 + a*x + b
        }

        return LHS == RHS;
    }

    /**
     * @dev Double an elliptic curve point in projective coordinates. See
     * https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates
     */
    function twiceProj(uint x0, uint y0, uint z0) public pure
        returns (uint x1, uint y1, uint z1)
    {
        uint t;
        uint u;
        uint v;
        uint w;

        if(isZeroCurve(x0, y0)) {
            return zeroProj();
        }

        u = mulmod(y0, z0, p);
        u = mulmod(u, 2, p);

        v = mulmod(u, x0, p);
        v = mulmod(v, y0, p);
        v = mulmod(v, 2, p);

        x0 = mulmod(x0, x0, p);
        t = mulmod(x0, 3, p);

        z0 = mulmod(z0, z0, p);
        z0 = mulmod(z0, a, p);
        t = addmod(t, z0, p);

        w = mulmod(t, t, p);
        x0 = mulmod(2, v, p);
        w = addmod(w, p-x0, p);

        x0 = addmod(v, p-w, p);
        x0 = mulmod(t, x0, p);
        y0 = mulmod(y0, u, p);
        y0 = mulmod(y0, y0, p);
        y0 = mulmod(2, y0, p);
        y1 = addmod(x0, p-y0, p);

        x1 = mulmod(u, w, p);

        z1 = mulmod(u, u, p);
        z1 = mulmod(z1, u, p);
    }

    /**
     * @dev Add two elliptic curve points in projective coordinates. See
     * https://www.nayuki.io/page/elliptic-curve-point-addition-in-projective-coordinates
     */
    function addProj(uint x0, uint y0, uint z0, uint x1, uint y1, uint z1) public pure
        returns (uint x2, uint y2, uint z2)
    {
        uint t0;
        uint t1;
        uint u0;
        uint u1;

        if (isZeroCurve(x0, y0)) {
            return (x1, y1, z1);
        }
        else if (isZeroCurve(x1, y1)) {
            return (x0, y0, z0);
        }

        t0 = mulmod(y0, z1, p);
        t1 = mulmod(y1, z0, p);

        u0 = mulmod(x0, z1, p);
        u1 = mulmod(x1, z0, p);

        if (u0 == u1) {
            if (t0 == t1) {
                return twiceProj(x0, y0, z0);
            }
            else {
                return zeroProj();
            }
        }

        (x2, y2, z2) = addProj2(mulmod(z0, z1, p), u0, u1, t1, t0);
    }

    /**
     * @dev Helper function that splits addProj to avoid too many local variables.
     */
    function addProj2(uint v, uint u0, uint u1, uint t1, uint t0) private pure
        returns (uint x2, uint y2, uint z2)
    {
        uint u;
        uint u2;
        uint u3;
        uint w;
        uint t;

        t = addmod(t0, p-t1, p);
        u = addmod(u0, p-u1, p);
        u2 = mulmod(u, u, p);

        w = mulmod(t, t, p);
        w = mulmod(w, v, p);
        u1 = addmod(u1, u0, p);
        u1 = mulmod(u1, u2, p);
        w = addmod(w, p-u1, p);

        x2 = mulmod(u, w, p);

        u3 = mulmod(u2, u, p);
        u0 = mulmod(u0, u2, p);
        u0 = addmod(u0, p-w, p);
        t = mulmod(t, u0, p);
        t0 = mulmod(t0, u3, p);

        y2 = addmod(t, p-t0, p);

        z2 = mulmod(u3, v, p);
    }

    /**
     * @dev Add two elliptic curve points in affine coordinates.
     */
    function add(uint x0, uint y0, uint x1, uint y1) public pure
        returns (uint, uint)
    {
        uint z0;

        (x0, y0, z0) = addProj(x0, y0, 1, x1, y1, 1);

        return toAffinePoint(x0, y0, z0);
    }

    /**
     * @dev Double an elliptic curve point in affine coordinates.
     */
    function twice(uint x0, uint y0) public pure
        returns (uint, uint)
    {
        uint z0;

        (x0, y0, z0) = twiceProj(x0, y0, 1);

        return toAffinePoint(x0, y0, z0);
    }

    /**
     * @dev Multiply an elliptic curve point by a 2 power base (i.e., (2^exp)*P)).
     */
    function multiplyPowerBase2(uint x0, uint y0, uint exp) public pure
        returns (uint, uint)
    {
        uint base2X = x0;
        uint base2Y = y0;
        uint base2Z = 1;

        for(uint i = 0; i < exp; i++) {
            (base2X, base2Y, base2Z) = twiceProj(base2X, base2Y, base2Z);
        }

        return toAffinePoint(base2X, base2Y, base2Z);
    }

    /**
     * @dev Multiply an elliptic curve point by a scalar.
     */
    function multiplyScalar(uint x0, uint y0, uint scalar) public pure
        returns (uint x1, uint y1)
    {
        if(scalar == 0) {
            return zeroAffine();
        }
        else if (scalar == 1) {
            return (x0, y0);
        }
        else if (scalar == 2) {
            return twice(x0, y0);
        }

        uint base2X = x0;
        uint base2Y = y0;
        uint base2Z = 1;
        uint z1 = 1;
        x1 = x0;
        y1 = y0;

        if(scalar%2 == 0) {
            x1 = y1 = 0;
        }

        scalar = scalar >> 1;

        while(scalar > 0) {
            (base2X, base2Y, base2Z) = twiceProj(base2X, base2Y, base2Z);

            if(scalar%2 == 1) {
                (x1, y1, z1) = addProj(base2X, base2Y, base2Z, x1, y1, z1);
            }

            scalar = scalar >> 1;
        }

        return toAffinePoint(x1, y1, z1);
    }

    /**
     * @dev Multiply the curve's generator point by a scalar.
     */
    function multipleGeneratorByScalar(uint scalar) public pure
        returns (uint, uint)
    {
        return multiplyScalar(gx, gy, scalar);
    }

    ////////////////////////////////////////////////////////////////////////
    // Bech32 functions

    function negate(uint256 x) internal pure returns (uint256) {
        return x == 0 ? 0 : ~x + 1;
    }

    function polymod(uint256 pre) internal pure returns(uint) {

        uint256 chk = pre >> 25;
        chk = ((pre & 0x1ffffff) << 5)^(negate((chk >> 0) & 1) & 0x3b6a57b2) ^
    (negate((chk >> 1) & 1) & 0x26508e6d) ^
    (negate((chk >> 2) & 1) & 0x1ea119fa) ^
    (negate((chk >> 3) & 1) & 0x3d4233dd) ^
    (negate((chk >> 4) & 1) & 0x2a1462b3);
        return chk;

    }

    function prefixCheck(uint[] memory hrp) public pure returns (uint) {

        uint chk = 1;
        uint c;
        uint v;
        for (uint pm = 0; pm < hrp.length; ++pm) {
            c = hrp[pm];
            chk = polymod(chk) ^ (c >> 5);
        }

        chk = polymod(chk);

        for (uint pm = 0; pm < hrp.length; ++pm) {
            v = hrp[pm];
            chk = polymod(chk) ^ (v & 0x1f);
        }

        return chk;
    }

    function encode(bytes memory prefix, uint[] memory hrp, uint[] memory data) public pure returns (string memory) {

        uint256 chk = prefixCheck(hrp);
        bytes memory _add = '1';
        bytes memory result = abi.encodePacked(prefix, _add);

        for (uint pm = 0; pm < data.length; ++pm) {
            uint256 x = data[pm];
            chk = polymod(chk) ^ x;
            result = abi.encodePacked(result, CHARSET[x]);
        }

        for (uint i = 0; i < 6; ++i) {
            chk = polymod(chk);
        }
        chk ^= 1;

        for (uint i = 0; i < 6; ++i) {
            uint256 v = (chk >> ((5 - i) * 5)) & 0x1f;
            result = abi.encodePacked(result, CHARSET[v]);
        }
        bytes memory chainid = 'P-';
        string memory s = string(abi.encodePacked(chainid, result));

        return s;
    }

    function convert(uint[] memory data, uint inBits, uint outBits) public pure returns (uint[] memory) {
        uint value = 0;
        uint bits = 0;
        uint maxV = (1 << outBits) - 1;

        uint[] memory ret = new uint[](32);
        uint j = 0;
        for (uint i = 0; i < data.length; ++i) {
            value = (value << inBits) | data[i];
            bits += inBits;

            while (bits >= outBits) {
                bits -= outBits;
                ret[j] = (value >> bits) & maxV;
                j += 1;
            }
        }

        return ret;
    }

    function generalizedPolymod(uint256[] memory values) internal returns (uint256 chk) {
        chk = 1;
        for (uint256 i = 0; i < values.length; ++i) {
            uint256 top = chk >> 25;
            chk = ((chk & 0x1ffffff) << 5 ^ values[i]) ^
                (negate((chk >> 0) & 1) & 0x3b6a57b2) ^
                (negate((chk >> 1) & 1) & 0x26508e6d) ^
                (negate((chk >> 2) & 1) & 0x1ea119fa) ^
                (negate((chk >> 3) & 1) & 0x3d4233dd) ^
                (negate((chk >> 4) & 1) & 0x2a1462b3);
        }
    }

    function hrpExpand(bytes memory hrp) internal pure returns (uint256[] memory ret) {
        ret = new uint256[](hrp.length * 2 + 1);
        for (uint256 i = 0; i < hrp.length; ++i) {
            ret[i] = uint256(uint8(hrp[i]) >> 5);
        }
        ret[hrp.length] = 0;
        for (uint256 j = 0; j < hrp.length; ++j) {
            ret[hrp.length+1+j] = uint256(uint8(hrp[j]) & 31);
        }
        return ret;
    }

    function verifyChecksum(bytes memory hrp, uint256[] memory data) internal pure returns (bool) {
        uint256[] memory expandedHrp = hrpExpand(hrp);
        uint256[] memory joined = new uint256[](hrp.length + data.length);
        for (uint256 i = 0; i < hrp.length; ++i) {
            joined[i] = expandedHrp[i];
            joined[hrp.length+i] = data[i];
        }
        return generalizedPolymod(joined) == 1;
    }

    function decode(bytes memory bechBytes) internal pure returns (bytes memory, bool) {
        if (bechBytes.length > 90) return (new bytes(0), false);
        for (uint256 i = 0; i < bechBytes.length; i++) {
            uint8 digit = uint8(bechBytes[i]);
            if ((digit < 33 || digit > 126) || // wrong char
                (digit <= 65 && digit <= 90) // upper case
            ) return (new bytes(0), false);
        }
        (uint256 pos, bool found) = BytesLib.indexOf(bechBytes, '1');
        if (!found || pos == 0 || pos + 7 > bechBytes.length)
            return (new bytes(0), false);
        bytes memory hrp = BytesLib.slice(bechBytes, 0, pos);
        uint256[] memory data = new uint256[](bechBytes.length - pos - 1);
        for (uint256 i = pos + 1; i < bechBytes.length; ++i) {
            (uint256 d, bool foundd) = BytesLib.indexOf(CHARSET, bechBytes[i]);
            if (!foundd) return (new bytes(0), false);
            data[i] = d;
        }
        if (!verifyChecksum(hrp, data)) return (new bytes(0), false);
        return (BytesLib.slice(data, 0, data.length - 6), true);
    }


}
