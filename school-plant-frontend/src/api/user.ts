import request from '@/utils/request';

export interface UserProfile {
  account: string;
  name: string;
  idNumber: string;
  phone: string;
  email?: string;
  role: string;
  registerTime: string;
  avatarUrl?: string;
  statisticNum: number;
}

export interface UpdateProfileParams {
  realName: string;
  phone: string;
  email: string;
  avatarUrl?: string;
}

export interface UpdatePasswordParams {
  oldPassword?: string;
  newPassword?: string;
  confirmPassword?: string;
}

export function getUserProfile() {
  return request<UserProfile>({
    url: '/user/profile',
    method: 'get',
  });
}

export function updateUserProfile(data: UpdateProfileParams) {
  return request({
    url: '/user/profile',
    method: 'put',
    data,
  });
}

export function updateUserPassword(data: UpdatePasswordParams) {
  return request({
    url: '/user/password',
    method: 'put',
    data,
  });
}

export function getUsersByRole(roleKey: string) {
  return request<any, any[]>({
    url: '/system/user/list-by-role',
    method: 'get',
    params: { roleKey },
  });
}

// 注销账号
export function deregisterAccount() {
  return request({
    url: '/system/user/deregister',
    method: 'delete',
  });
}
