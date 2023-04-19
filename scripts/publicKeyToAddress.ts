import * as crypto from 'crypto';
import { sha256, keccak, ripemd160 } from 'ethereumjs-util';
import { bech32 } from "bech32"
import * as elliptic from "elliptic"

import BN from "bn.js";

const EC: typeof elliptic.ec = elliptic.ec;
const ec: elliptic.ec = new EC("secp256k1");

export function randomPrivateKey() {
  return crypto.randomBytes(32);
}

export function privateKeyToPublicKey(privateKey: Buffer): Buffer[] {
  const keyPair = ec.keyFromPrivate(privateKey).getPublic();
  const x = keyPair.getX().toBuffer(undefined, 32);
  const y = keyPair.getY().toBuffer(undefined, 32);
  return [x, y];
}

export function compressPublicKey(x: Buffer, y: Buffer): Buffer {
  const prefix = ((new BN(y)).isEven()) ? 0x02 : 0x03;
  return Buffer.concat([Buffer.from([prefix]), x]);
}

export function encodePublicKey(x: Buffer, y: Buffer, compress: boolean): Buffer {
  return (compress) ? compressPublicKey(x, y) : Buffer.concat([Buffer.from([0x04]), x, y]);
}

export function publicKeyToEthereumAddress(x: Buffer, y: Buffer) {
  return keccak(Buffer.concat([x, y])).slice(-20);
}

export function publicKeyToAvalancheAddress(x: Buffer, y: Buffer) {
  const compressed = compressPublicKey(x, y);
  return ripemd160(sha256(compressed), false);
}

export function ethereumAddressToString(address: Buffer) {
    return `0x${address.toString('hex')}`
}

export function avalancheAddressToString(hrp: string, chainId: string, address: Buffer) {
  return `${chainId}-${bech32.encode(hrp, bech32.toWords(address))}`;
}