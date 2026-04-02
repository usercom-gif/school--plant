import request from "@/utils/request";

export interface PlantAbnormality {
  id: number;
  plantId?: number;
  plantName?: string;
  location?: string;
  reporterId: number;
  reporterName: string;
  reporterContact: string;
  maintainerId?: number;
  abnormalityType: string;
  description: string;
  imageUrls: string; // JSON string
  suggestedSolution?: string;
  status: "PENDING" | "ASSIGNED" | "RESOLVED" | "UNRESOLVED";
  assignedAt?: string;
  resolutionDescription?: string;
  resolutionImageUrls?: string; // JSON string
  materialsUsed?: string;
  effectEvaluation?: string;
  resolvedAt?: string;
  createdAt: string;
}

export interface ReportAbnormalityParams {
  plantId?: number;
  type: string;
  desc?: string;
  location?: string;
  reporterName: string;
  reporterContact: string;
  images?: File[];
}

export interface AbnormalityQueryParams {
  page?: number;
  size?: number;
  status?: string;
  type?: string;
  description?: string;
  maintainerId?: number;
  reporterId?: number;
}

export function reportAbnormality(data: ReportAbnormalityParams) {
  const formData = new FormData();
  if (data.plantId) {
    formData.append("plantId", data.plantId.toString());
  }
  if (data.location) {
    formData.append("location", data.location);
  }
  formData.append("type", data.type);
  if (data.desc) {
    formData.append("desc", data.desc);
  }
  formData.append("reporterName", data.reporterName);
  formData.append("reporterContact", data.reporterContact);
  if (data.images) {
    data.images.forEach((file) => {
      formData.append("images", file);
    });
  }
  // Change request generic type to 'any' to avoid string parsing issues if backend returns object or string
  return request<any, any>({
    url: "/abnormality/report",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}

export function getAbnormalityList(params: AbnormalityQueryParams) {
  return request<any, any>({
    url: "/abnormality/list",
    method: "get",
    params,
  });
}

export function assignAbnormality(id: number, maintainerId: number) {
  return request<any, void>({
    url: "/abnormality/assign",
    method: "post",
    params: { id, maintainerId },
  });
}

export function resolveAbnormality(data: {
  id: number;
  resolution: string;
  materials: string;
  evaluation: string;
  images?: File[];
}) {
  const formData = new FormData();
  formData.append("id", data.id.toString());
  formData.append("resolution", data.resolution);
  formData.append("materials", data.materials);
  formData.append("evaluation", data.evaluation);
  if (data.images) {
    data.images.forEach((file) => {
      formData.append("images", file);
    });
  }
  return request<any, void>({
    url: "/abnormality/resolve",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}

export function markAbnormalityUnresolved(data: {
  id: number;
  reason: string;
  materials: string;
  evaluation: string;
  images?: File[];
}) {
  const formData = new FormData();
  formData.append("id", data.id.toString());
  formData.append("reason", data.reason);
  formData.append("materials", data.materials);
  formData.append("evaluation", data.evaluation);
  if (data.images) {
    data.images.forEach((file) => {
      formData.append("images", file);
    });
  }
  return request<any, void>({
    url: "/abnormality/unresolved",
    method: "post",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
}

export function getMyAbnormalities(params: { page?: number; size?: number }) {
  return request<any, any>({
    url: "/abnormality/my",
    method: "get",
    params,
  });
}
