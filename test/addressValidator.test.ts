import { expect } from "chai";
import { AddressValidatorInstance } from "../typechain-truffle/contracts/AddressValidator";
import { randomXrpAddress, randomBase58Address, randomAddress } from "./lib/addressGenerator";
const cryptoAddressValidator = require("@swyftx/api-crypto-address-validator");

function randint(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1) + min);
}

function replaceAt(data: string, index: number, replacement: string) {
  return data.substring(0, index) + replacement + data.substring(index + replacement.length);
}

const xrpB58 = 'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz';

const AddressValidator = artifacts.require("AddressValidator");

describe("Tests for crypto address validation", () => {
  let addressValidator: AddressValidatorInstance;

  beforeEach(async () => {
    addressValidator = await AddressValidator.new();
  });

  it("should fuzz test ripple address validation with valid addresses", async () => {
    const ncases = 1000;
    for (let i = 0; i < ncases; i++) {
      const address = randomXrpAddress();
      const isValidSol = await addressValidator.validateRipple(address);
      const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
      expect(isValidSol).to.equal(isValidJs);
    }
  });

  it("should fuzz test ripple address validation with invalid addresses", async () => {
    const ncases = 1000;
    for (let i = 0; i < ncases; i++) {
      const address = randomBase58Address();
      const isValidSol = await addressValidator.validateRipple(address);
      const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
      expect(isValidSol).to.equal(isValidJs);
    }
  });

  it("should fuzz test ripple address validation with tempered addresses", async () => {
    const ncases = 1000;
    for (let i = 0; i < ncases; i++) {
      const address = randomXrpAddress();
      const tempered = replaceAt(address, randint(0, address.length - 1), xrpB58[randint(0, xrpB58.length - 1)]);
      const isValidSol = await addressValidator.validateRipple(tempered);
      const isValidJs = await cryptoAddressValidator.validate(tempered, "XRP");
      expect(isValidSol).to.equal(isValidJs);
    }
  });

  it("should fuzz test ripple address validation with non-base58 addresses", async () => {
    const ncases = 1000;
    for (let i = 0; i < ncases; i++) {
      const address = randomAddress();
      const isValidSol = await addressValidator.validateRipple(address);
      const isValidJs = await cryptoAddressValidator.validate(address, "XRP");
      expect(isValidSol).to.equal(isValidJs);
    }
  });
});