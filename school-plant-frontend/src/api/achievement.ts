import request from "@/utils/request";

export interface AchievementVO {
  id: number;
  userId: number;
  userName?: string;
  userRealName?: string;
  studentId?: string;
  plantName?: string;
  adoptionCycle: string;
  tasksCompleted: number;
  totalTasks: number;
  taskCompletionRate: number;
  adoptionDurationDays: number;
  plantHealthScore: number;
  compositeScore: number;
  isOutstanding: number;
  certificateUrl?: string;
}

export const getMyAchievement = (adoptionCycle: string) => {
  return request.get<AchievementVO>("/achievement/my", {
    params: { adoptionCycle },
  });
};

export const getOutstandingList = (params: any) => {
  return request.get<any>("/achievement/outstanding", { params });
};

export const getStats = (adoptionCycle: string) => {
  return request.get<any>("/achievement/stats", { params: { adoptionCycle } });
};

export const auditAchievement = (id: number, isPass: boolean) => {
  return request.post<any>("/achievement/audit", null, {
    params: { id, isPass },
  });
};

export const generateReport = (adoptionCycle: string) => {
  return request.post("/achievement/generate", null, {
    params: { adoptionCycle },
  });
};
