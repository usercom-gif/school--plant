import request from "@/utils/request";

export interface LogQueryRequest {
  page: number;
  size: number;
  operatorName?: string;
  module?: string;
  operationType?: string;
  startTime?: string;
  endTime?: string;
}

export interface OperationLog {
  id: number;
  userId: number;
  operatorName: string;
  operatorRole: string;
  module: string;
  operationType: string;
  operationDesc: string;
  operationResult: string;
  errorMsg?: string;
  ipAddress: string;
  executionTime: number;
  relatedId?: string;
  createdAt: string;
}

export const getLogList = (params: LogQueryRequest) => {
  return request.get<any>("/system/log/list", { params });
};

export const getMyLogList = (params: LogQueryRequest) => {
  return request.get<any>("/system/log/my", { params });
};

export const exportLogs = (params: LogQueryRequest) => {
  return request.get("/system/log/export", {
    params,
    responseType: "blob", // Important for file download
  });
};
