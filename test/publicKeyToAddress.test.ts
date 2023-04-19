import { expect } from "chai"
import { PublicKeyToAddressInstance } from "../typechain-truffle";
import * as util from "../scripts/publicKeyToAddress";

const PublicKeyToAddress = artifacts.require("PublicKeyToAddress");

describe("Tests for address derivation from public key", async () => {
  let publicKeyToAddress: PublicKeyToAddressInstance;

  beforeEach(async() => {
    publicKeyToAddress = await PublicKeyToAddress.new();
  });

  // assumes that input address is encoded with prefix 0x04
  it("Should correctly derive ethereum address from public key", async () => {
    for (let i = 0; i < 1000; i++) {
      const privateKey = util.randomPrivateKey();
      const [x, y] = util.privateKeyToPublicKey(privateKey);
      const encodedPublicKey = util.encodePublicKey(x, y, false);
      const resp = await publicKeyToAddress.publicKeyToEthereumAddress(encodedPublicKey);
      const ethereumAddress = util.publicKeyToEthereumAddress(x, y);
      expect(resp.toLowerCase()).to.equal(`0x${ethereumAddress.toString('hex')}`);
    }
  });

  // assumes that input address is encoded with prefix 0x04
  it.only("should correctly derive avalanche address from public key", async () => {
    for (let i = 0; i < 100; i++) {
      const privateKey = util.randomPrivateKey();
      const [x, y] = util.privateKeyToPublicKey(privateKey);
      const encodedPublicKey = util.encodePublicKey(x, y, false);
      const resp = await publicKeyToAddress.publicKeyToAvalancheAddress(encodedPublicKey);
      const avalancheAddress = util.publicKeyToAvalancheAddress(x, y);
      expect(resp).to.equal(`0x${avalancheAddress.toString('hex')}`);
    }
  });

  it("should correctly derive avalanche address string from public key", async () => {
    let prefix = "fuji";
    let hrp: Array<number> = []; //array of unicode of prefix
    for (var i=0; i<prefix.length; i++) {
      hrp[i] = prefix.charCodeAt(i);
    }
    /* for (let i = 0; i < 100; i++) {
      const privateKey = randomPrivateKey();
      const publicKey = Buffer.from(privateKeyToKeypair(privateKey).getPublic(true, 'hex'), 'hex');
      const resp = await publicKeyToAddress.publicKeyToAvalancheAddressString(publicKey, prefix, hrp);
      expect(resp).to.equal(privateKeyToAvalancheAddress(privateKey, "fuji"));
    } */
  });
});