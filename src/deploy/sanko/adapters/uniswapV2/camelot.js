const { deployAdapter, addresses } = require('../../../utils')
const { factory } = addresses.sanko.camelot

const networkName = 'sanko'
const contractName = 'CamelotAdapter'
const tags = [ 'camelot', 'camelot_v2' ]
const name = contractName
const gasEstimate = 238_412
const args = [ name, factory, gasEstimate ]

module.exports = deployAdapter(networkName, tags, contractName, contractName, args)