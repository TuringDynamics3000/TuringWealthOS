import { useRouter } from "next/router";
import useSWR from "swr";
import NotaryViewer from "../../../components/audit/NotaryViewer";

const fetcher = (url) => fetch(url).then((r) => r.json());

export default function NotaryPage() {
  const router = useRouter();
  const { notaryId } = router.query;

  const { data, error } = useSWR(
    notaryId ? `/api/notary/${notaryId}` : null,
    fetcher
  );

  if (error) return <div>Notary record not found.</div>;
  if (!data) return <div>Loading notary record…</div>;

  return <NotaryViewer record={data} />;
}
