import fs from "fs";
import path from "path";

export default function handler(req, res) {
  const { notaryId } = req.query;

  const repoRoot = process.cwd();
  const notaryDir = path.join(repoRoot, "audit_notary", notaryId);

  if (!fs.existsSync(notaryDir)) {
    return res.status(404).json({ error: "Notary record not found" });
  }

  const read = (f) =>
    fs.existsSync(path.join(notaryDir, f))
      ? fs.readFileSync(path.join(notaryDir, f), "utf8").trim()
      : null;

  res.status(200).json({
    notaryId,
    merkleRoot: read("merkle_root.txt"),
    timestampUtc: read("timestamp_utc.txt"),
    gitCommit: read("git_anchor.txt"),
  });
}
