import { expect } from "chai"
import { PublicKeyToAddressInstance } from "../typechain-truffle";
import {
  privateKeyToPublicKeypair, generatePrivateKey, privateKeyToKeypair
} from "../scripts/publicKeyToAddress";
import {
  privateKeyToAvalancheAddress, privateKeyToEthereumAddress
} from "../scripts/privateKeyToAddress";

const PublicKeyToAddress = artifacts.require("PublicKeyToAddress");

describe("Tests for address derivation from public key", async () => {
  let publicKeyToAddress: PublicKeyToAddressInstance

  beforeEach(async() => {
    publicKeyToAddress = await PublicKeyToAddress.new()
  })

  it("Should correctly derive ethereum address from public key", async () => {
    for (let i = 0; i < 100; i++) {
      const privateKey = generatePrivateKey();
      const ethAddress = privateKeyToEthereumAddress(privateKey)
      const pubpair = privateKeyToPublicKeypair(privateKey)
      const resp = await publicKeyToAddress.publicKeyToEthereumAddress(pubpair)
      expect(resp.toLowerCase()).to.equal(ethAddress)
    }
  })

  it("should correctly derive avalanche address from public key", async () => {
    let prefix = "fuji"
    let hrp: Array<number> = [] //array of unicode of prefix
    for (var i=0; i<prefix.length; i++) {
      hrp[i] = prefix.charCodeAt(i)
    }
    for (let i = 0; i < 100; i++) {
      const privateKey = generatePrivateKey()
      const avaAddress = privateKeyToAvalancheAddress(privateKey, "fuji")
      const pubpair = privateKeyToPublicKeypair(privateKey)
      const resp = await publicKeyToAddress.publicKeyToAvalancheAddress(pubpair, prefix, hrp)
      expect(resp).to.equal(avaAddress)
    }
  })

  it("should test the public key compression", async () => {
    const privateKey = "8944ff161a80575ff14b2216fd7c19edc085f2d4a3c00a923ffc77ce64d6ffa7"
    const pubpair = privateKeyToPublicKeypair(privateKey)
    const keypair = privateKeyToKeypair(privateKey)
    const publicKey = Buffer.from(keypair.getPublic(true, 'hex').padStart(66, '0'), 'hex')
    const resp = await publicKeyToAddress.compressPublicKey(pubpair[0], pubpair[1])
    expect(resp).to.equal(`0x${publicKey.toString('hex')}`)
  })
})