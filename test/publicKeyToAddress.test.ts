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
  let publicKeyToAddress: PublicKeyToAddressInstance;

  beforeEach(async() => {
    publicKeyToAddress = await PublicKeyToAddress.new();
  });

  it("Should correctly derive ethereum address from public key", async () => {
    for (let i = 0; i < 100; i++) {
      const privateKey = generatePrivateKey();
      const publicKey = Buffer.from(privateKeyToKeypair(privateKey).getPublic(true, 'hex'), 'hex');
      const resp = await publicKeyToAddress.publicKeyToEthereumAddress(publicKey);
      expect(resp.toLowerCase()).to.equal(privateKeyToEthereumAddress(privateKey));
    }
  });

  it("should correctly derive avalanche address from public key", async () => {
    let prefix = "fuji";
    let hrp: Array<number> = []; //array of unicode of prefix
    for (var i=0; i<prefix.length; i++) {
      hrp[i] = prefix.charCodeAt(i);
    }
    for (let i = 0; i < 100; i++) {
      const privateKey = generatePrivateKey();
      const publicKey = Buffer.from(privateKeyToKeypair(privateKey).getPublic(true, 'hex'), 'hex');
      const resp = await publicKeyToAddress.publicKeyToAvalancheAddressString(publicKey, prefix, hrp);
      expect(resp).to.equal(privateKeyToAvalancheAddress(privateKey, "fuji"));
    }
  });
});