import { useRouter } from "next/router";
import Link from "next/link";

export default function AdviceFilePage() {
  const router = useRouter();
  const { adviceFileId } = router.query;

  // Demo-only stub data
  const auditPack = {
    notaryId: "NOTARY-DEMO"
  };

  return (
    <div style={{ padding: "2rem" }}>
      <h1>Advice File</h1>

      <p>
        <strong>Advice File ID:</strong> {adviceFileId}
      </p>

      <hr />

      <h2>Audit</h2>

      <p>
        This section presents immutable audit evidence captured at the time
        advice was issued.
      </p>

      {auditPack?.notaryId && (
        <div style={{ marginTop: "1rem" }}>
          <Link href={`/audit/notary/${auditPack.notaryId}`}>
            View Notary Proof
          </Link>
        </div>
      )}

      <p style={{ marginTop: "2rem", fontStyle: "italic" }}>
        TuringWealthOS does not provide financial advice. All advice decisions
        are made and authorised by licensed advisers.
      </p>
    </div>
  );
}
