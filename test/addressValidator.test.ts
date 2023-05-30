import { expect } from "chai";
import { RippleAddressValidatorInstance } from "../typechain-truffle/contracts/RippleAddressValidator";
import { BitcoinAddressValidatorInstance } from "../typechain-truffle/contracts/BitcoinAddressValidator";
import { randomXrpAddress, randomBase58Address, randomAddress } from "./lib/addressGenerator";
const cryptoAddressValidator = require("@swyftx/api-crypto-address-validator");

function randint(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

function replaceAt(data: string, index: number, replacement: string) {
  return data.substring(0, index) + replacement + data.substring(index + replacement.length);
}

const xrpB58 = 'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz';
const btcB58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

const RippleAddressValidator = artifacts.require("RippleAddressValidator");
const BitcoinAddressValidator = artifacts.require("BitcoinAddressValidator");


describe("Tests for crypto address validation", () => {
  let bitcoinValidator: BitcoinAddressValidatorInstance;
  let rippleValidator: RippleAddressValidatorInstance;

  beforeEach(async () => {
    rippleValidator = await RippleAddressValidator.new();
    bitcoinValidator = await BitcoinAddressValidator.new();
  });

  describe("ripple address validation", () => {

    it("should fuzz test valid addresses", async () => {
      const ncases = 100;
      for (let i = 0; i < ncases; i++) {
        const address = randomXrpAddress();
        const isValidSol = await rippleValidator.validateRipple(address);
        const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
        expect(isValidSol).to.equal(isValidJs);
      }
    });

    it("should fuzz test invalid addresses", async () => {
      const ncases = 100;
      for (let i = 0; i < ncases; i++) {
        const address = randomBase58Address();
        const isValidSol = await rippleValidator.validateRipple(address);
        const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
        expect(isValidSol).to.equal(isValidJs);
      }
    });

    it("should fuzz test tempered addresses", async () => {
      const ncases = 100;
      for (let i = 0; i < ncases; i++) {
        const address = randomXrpAddress();
        const tempered = replaceAt(address, randint(0, address.length - 1), xrpB58[randint(0, xrpB58.length - 1)]);
        const isValidSol = await rippleValidator.validateRipple(tempered);
        const isValidJs = await cryptoAddressValidator.validate(tempered, "XRP");
        expect(isValidSol).to.equal(isValidJs);
      }
    });

    it("should fuzz test non-base58 addresses", async () => {
      const ncases = 10;
      for (let i = 0; i < ncases; i++) {
        const address = randomAddress();
        const isValidSol = await rippleValidator.validateRipple(address);
        const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
        expect(isValidSol).to.equal(isValidJs);
      }
    });

  });

  describe("bitcoin address validation", () => {

    it.only("should test valid P2PKH addresses", async () => {
      const genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
      const isValidSol = await bitcoinValidator._validateP2PKH(genesisAddress);
      expect(isValidSol).to.be.true;
    });

  });
});