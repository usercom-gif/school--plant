import request from "@/utils/request";

export interface SystemNotification {
  id: number;
  userId: number;
  title: string;
  content: string;
  type: string;
  isRead: number;
  createdAt: string;
}

export function getNotificationList(limit = 20) {
  return request<any, SystemNotification[]>({
    url: "/system/notification/list",
    method: "get",
    params: { limit },
  });
}

export function getUnreadCount() {
  return request<any, number>({
    url: "/system/notification/unread-count",
    method: "get",
  });
}

export function markAsRead(id: number) {
  return request<any, void>({
    url: `/system/notification/read/${id}`,
    method: "post",
  });
}

export function markAllAsRead() {
  return request<any, void>({
    url: "/system/notification/read-all",
    method: "post",
  });
}
