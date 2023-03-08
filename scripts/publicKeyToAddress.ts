import * as crypto from 'crypto';
import { sha256, keccak, ripemd160 } from 'ethereumjs-util';
import { bech32 } from "bech32"
import * as elliptic from "elliptic"

const EC: typeof elliptic.ec = elliptic.ec
const ec: elliptic.ec = new EC("secp256k1")

export function generatePrivateKey() {
  const privateKey = crypto.randomBytes(32);
  return privateKey.toString('hex');
}

export function privateKeyToPublicKeypair(prvk: string) {
  const _keypair = ec.keyFromPrivate(prvk).getPublic()
  return [_keypair.getX().toString(), _keypair.getY().toString()]
}

export function privateKeyToPublicKey(prvk: string) {
  return ec.keyFromPrivate(prvk).getPublic()
}

export function privateKeyToKeypair(prvk: string) {
  return ec.keyFromPrivate(prvk)
}

export const compressPublicKey = (pubKeyUncompressed: string): string => {
  return (parseInt(pubKeyUncompressed.slice(130, 132), 16) % 2 === 0 ? '02' : '03') + pubKeyUncompressed.slice(2, 66);
}

function publicKeyToEthereumAddress(pubk: Buffer) {
  if (pubk.length != 64) throw new Error("need uncompressed public key without type flag")
  return keccak(pubk).slice(-20)
}

function publicKeyToAvalancheAddress(pubk: Buffer) {
  if (pubk.length != 33) throw new Error("need compressed public key")
  return ripemd160(sha256(pubk), false)
}

const avalancheAddressToString = (hrp: string, chainid: string, bytes: Buffer) =>
  `${chainid}-${bech32.encode(hrp, bech32.toWords(bytes))}`

export function publicKeyToEthereumAddressString(pubk: elliptic.curve.base.BasePoint) {
    const ethPubk = Buffer.from(pubk.encode('hex', false).padStart(66, "0"), "hex").slice(1)
    return publicKeyToEthereumAddress(ethPubk).toString('hex')
}

export function publicKeyToAvalancheAddressString(
    hrp: string, chainid: string, pubk: elliptic.curve.base.BasePoint
) {
    const avaPubk = Buffer.from(pubk.encode('hex', true).padStart(66, "0"), "hex")
    const avaAddr = publicKeyToAvalancheAddress(avaPubk)
    return avalancheAddressToString(hrp, chainid, avaAddr)
}