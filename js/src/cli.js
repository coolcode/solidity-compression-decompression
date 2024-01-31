const yargs = require("yargs")
const { hideBin } = require("yargs/helpers")
const { compress } = require("./compressor")
const { trim0x } = require("./common")

const TITLE = "cli"
const VERSION = "0.1.0"

// node src/cli.js compress -d 123456 --log debug
const CompressCommand = {
  command: "compress",
  alias: "c",
  describe: "",
  builder: (yargs) =>
    yargs
      .default("data", "")
      .default("log", "info")
      .options({
        data: {
          type: "string",
          description: "data bytes",
          alias: "d",
        },
        log: {
          type: "string",
          description: "log type",
          choices: ["debug", "warn", "info", "error"],
        },
      })
      .version(false),
  handler: async (args) => {
    const data = args.data
    if (!data) {
      console.error("'data' required")
    }
    const r = await compress(data)
    if (args.log === "debug") {
      console.debug("r:", r)
    }
    console.info(trim0x(r.compressedData))
  },
}

try {
  yargs(hideBin(process.argv))
    .scriptName(TITLE)
    .command([CompressCommand])
    .version("v", VERSION)
    .demandCommand()
    .strict()
    .help("h")
    .fail((msg, err, yargs) => {
      if (msg && !msg.includes("Not enough non-option arguments") && !msg.includes("Unknown arguments")) {
        console.error(`Error: ${msg}`)
      }
      console.info("")
      yargs.showHelp()
      console.info("")
      if (err) {
        console.error(err.toString())
      }
      process.exit(1)
    }).argv
} catch (error) {
  console.error(`Error: ${error.message}`)
}
