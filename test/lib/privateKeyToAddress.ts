import { Avalanche, Buffer, BinTools } from 'avalanche'
import { PlatformVMAPI, KeyChain as PVMKeyChain } from 'avalanche/dist/apis/platformvm'
import { PrivateKeyPrefix } from 'avalanche/dist/utils'

const bintools = BinTools.getInstance()

function hexToCB58(hex: string) {
    return bintools.bufferToB58(bintools.addChecksum(Buffer.from(hex, 'hex')))
}

export function privateKeyToEthereumAddress(privateKey: string) {
    return web3.eth.accounts.privateKeyToAccount(privateKey).address.toLowerCase()
}

export function privateKeyToAvalancheAddress(privateKey: string, hrp: string) {
    const avalanche = new Avalanche(undefined, undefined, undefined, undefined, undefined, undefined, hrp)
    const pchain: PlatformVMAPI = avalanche.PChain()
    const pKeychain: PVMKeyChain = pchain.keyChain()
    const privateKeyCB59 = hexToCB58(privateKey)
    pKeychain.importKey(`${PrivateKeyPrefix}${privateKeyCB59}`)
    return pchain.keyChain().getAddressStrings()[0]
}