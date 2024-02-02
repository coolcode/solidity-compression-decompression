import { describe, expect, it } from "vitest"
import { compress } from "../src/compressor"

describe("compressor", () => {
  describe("compress test", () => {
    it("compress success", async () => {
      const r = await compress("123456")
      expect(r.compressedData).to.eq("0x42123456")
    })
  })
})
