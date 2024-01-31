const trim0x = (text) => {
  return text && text.length > 2 && text.indexOf("0x") === 0 ? text.substring(2) : text
}

module.exports = { trim0x }
