import request from '@/utils/request';

export interface SystemParameter {
  id?: number;
  paramKey: string;
  paramValue: string;
  description: string;
  createdAt?: string;
  updatedAt?: string;
}

// Get parameters with optional keyword
export const getParameterList = (keyword?: string) => {
  return request<any, SystemParameter[]>({
    url: "/system/params/list",
    method: "get",
    params: { keyword },
  });
};

// Update a parameter
export const updateParameter = (paramKey: string, paramValue: string) => {
  return request.post('/system/params/update', {
    key: paramKey,
    value: paramValue
  });
};
