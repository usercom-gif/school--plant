import request from "@/utils/request";

export interface CareTask {
  id: number;
  plantId: number;
  userId: number; // adopter_id
  taskTemplateId?: number;
  taskType: string;
  taskDescription: string;
  dueDate: string;
  completedDate?: string;
  status: "PENDING" | "COMPLETED" | "OVERDUE";
  imageUrl?: string;

  // VO fields
  plantName?: string;
  userName?: string;
  createdAt?: string;
}

export interface TaskQueryRequest {
  page?: number;
  size?: number;
  userId?: number;
  status?: string;
}

// User APIs
export function getMyTasks(params: {
  page?: number;
  size?: number;
  status?: string;
}) {
  return request<any, any>({
    url: "/task/my-tasks",
    method: "get",
    params,
  });
}

export function completeTask(data: FormData | { id: number; imageUrls: string[] }) {
  if (data instanceof FormData) {
    const id = data.get('id');
    return request<any, void>({
      url: `/task/${id}/complete`,
      method: "post",
      data,
      headers: { 'Content-Type': 'multipart/form-data' }
    });
  }
  return request<any, void>({
    url: "/task/complete",
    method: "post",
    data,
  });
}

export function reportAbnormalityFromTask(id: number, data: FormData) {
  return request<any, string>({
    url: `/task/${id}/report-abnormality`,
    method: "post",
    data,
    headers: { 'Content-Type': 'multipart/form-data' }
  });
}

export interface UserTaskSetting {
  id?: number;
  userId?: number;
  plantId: number;
  taskType: string;
  frequencyDays: number;
  scheduledTime: string; // "13:00:00"
}

export interface UserTaskSettingRequest {
  taskType: string;
  frequencyDays: number;
  scheduledTime: string;
}

export function getTaskSettings(plantId: number) {
  return request<any, UserTaskSetting[]>({
    url: "/task/settings",
    method: "get",
    params: { plantId },
  });
}

export function saveTaskSettings(
  plantId: number,
  settings: UserTaskSettingRequest[],
) {
  return request<any, void>({
    url: "/task/settings",
    method: "post",
    params: { plantId },
    data: settings,
  });
}

// Admin APIs
export function getTaskList(params: TaskQueryRequest) {
  return request<any, any>({
    url: "/task/list",
    method: "get",
    params,
  });
}

export function createTask(data: Partial<CareTask>) {
  return request<any, void>({
    url: "/task/create",
    method: "post",
    data,
  });
}

export function updateTask(data: Partial<CareTask>) {
  return request<any, void>({
    url: "/task/update",
    method: "put",
    data,
  });
}

export function deleteTask(ids: number[]) {
  return request<any, void>({
    url: `/task/${ids.join(",")}`,
    method: "delete",
  });
}
