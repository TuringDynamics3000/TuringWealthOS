type Props = {
  record: {
    notaryId: string;
    merkleRoot: string;
    timestampUtc: string;
    gitCommit: string;
  };
};

export default function NotaryViewer({ record }: Props) {
  return (
    <div style={{ padding: "2rem" }}>
      <h1>Notary Record — Immutable Audit Proof</h1>

      <p>
        This view presents cryptographic proof that an audit pack has not changed
        since notarisation.
      </p>

      <h3>Cryptographic Anchors</h3>
      <ul>
        <li><strong>Merkle Root:</strong> {record.merkleRoot}</li>
        <li><strong>Timestamp (UTC):</strong> {record.timestampUtc}</li>
        <li><strong>Git Commit:</strong> {record.gitCommit}</li>
      </ul>

      <p style={{ marginTop: "2rem", fontStyle: "italic" }}>
        TuringWealthOS does not provide financial advice. All advice decisions are
        made and authorised by licensed advisers. This proof demonstrates that
        the audit record has not been altered since the time shown above.
      </p>
    </div>
  );
}
