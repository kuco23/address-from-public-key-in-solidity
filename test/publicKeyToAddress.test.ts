import { expect } from "chai"
import { PublicKeyToAddressInstance } from "../typechain-truffle";
import * as util from "../scripts/publicKeyToAddress";
import { privateKeyToAvalancheAddress } from "../scripts/privateKeyToAddress";

const PublicKeyToAddress = artifacts.require("PublicKeyToAddress");

describe("Tests for address derivation from public key", async () => {
  let publicKeyToAddress: PublicKeyToAddressInstance;

  beforeEach(async() => {
    publicKeyToAddress = await PublicKeyToAddress.new();
  });

  it("Should correctly derive ethereum address from public key", async () => {
    for (let i = 0; i < 100; i++) {
      const privateKey = util.randomPrivateKey();
      const [x, y] = util.privateKeyToPublicKey(privateKey);
      const ethereumAddress = util.publicKeyToEthereumAddress(x, y);
      const publicKeyEncodings = [
        util.encodePublicKey(x, y, false),
        util.encodePublicKey(x, y, true),
        Buffer.concat([x, y])
      ];
      for (const publicKeyEncoding of publicKeyEncodings) {
        const resp = await publicKeyToAddress.publicKeyToEthereumAddress(publicKeyEncoding);
        expect(resp.toLowerCase()).to.equal(`0x${ethereumAddress.toString('hex')}`);
      }
    }
  });

  it("should correctly derive avalanche address from public key", async () => {
    for (let i = 0; i < 100; i++) {
      const privateKey = util.randomPrivateKey();
      const [x, y] = util.privateKeyToPublicKey(privateKey);
      const avalancheAddress = util.publicKeyToAvalancheAddress(x, y);
      const publicKeyEncodings = [
        util.encodePublicKey(x, y, false),
        util.encodePublicKey(x, y, true),
        Buffer.concat([x, y])
      ];
      for (const publicKeyEncoding of publicKeyEncodings) {
        const resp = await publicKeyToAddress.publicKeyToAvalancheAddress(publicKeyEncoding);
        expect(resp).to.equal(`0x${avalancheAddress.toString('hex')}`);
      }
    }
  });

  it("should correctly derive avalanche address string from public key", async () => {
    let prefix = "fuji";
    let hrp: Array<number> = []; //array of unicode of prefix
    for (var i=0; i<prefix.length; i++) {
      hrp[i] = prefix.charCodeAt(i);
    }
    for (let i = 0; i < 100; i++) {
      const privateKey = util.randomPrivateKey();
      const [x, y] = util.privateKeyToPublicKey(privateKey);
      const encodedPublicKey = util.encodePublicKey(x, y, false);
      const resp = await publicKeyToAddress.publicKeyToAvalancheAddressString(encodedPublicKey, prefix, hrp);
      expect(resp).to.equal(privateKeyToAvalancheAddress(privateKey.toString('hex'), "fuji"));
    }
  });
});