import request from "@/utils/request";

export interface ContentReport {
  id: number;
  postId: number;
  postTitle: string;
  postAuthorName: string;
  reporterId: number;
  reporterName: string;
  reason: string;
  status: string;
  reviewedBy: number;
  reviewerName: string;
  reviewedAt: string;
  createdAt: string;
}

export function getReportList(params: {
  page: number;
  size: number;
  status?: string;
}) {
  return request<any, { records: ContentReport[]; total: number }>({
    url: "/system/report/list",
    method: "get",
    params,
  });
}

export function handleReport(
  id: number,
  action: "IGNORE" | "DELETE_POST",
  reason?: string,
) {
  return request<any, void>({
    url: `/system/report/${id}/handle`,
    method: "post",
    params: { action, reason },
  });
}
