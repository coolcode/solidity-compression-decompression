const ethers = require("ethers")

const trim0x = (text) => {
  return text && text.length > 2 ? text.substring(2) : ""
}

const ether = (text) => {
  return ethers.parseEther(text)
}

module.exports = { trim0x, ether }
