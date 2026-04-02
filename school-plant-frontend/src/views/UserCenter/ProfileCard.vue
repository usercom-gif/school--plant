<template>
  <a-card class="shadow-md rounded-lg overflow-hidden border-0">
    <a-skeleton :loading="loading" avatar active :paragraph="{ rows: 4 }">
      <div v-if="userInfo" class="flex flex-col items-center">
        <!-- Avatar Section -->
        <div class="mb-6 flex flex-col items-center">
          <span class="text-gray-500 mb-2">头像</span>
          <div class="relative">
            <div
              class="w-24 h-24 rounded-full bg-green-100 flex items-center justify-center border-4 border-white shadow-sm overflow-hidden"
            >
              <img
                :src="userInfo.avatarUrl || '/images/default-avatar.png'"
                alt="Avatar"
                class="w-full h-full object-cover"
              />
            </div>
          </div>
        </div>

        <!-- Info List -->
        <div class="w-full max-w-lg space-y-4 px-4">
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><UserOutlined /> 账号</span
            >
            <span class="font-medium text-gray-800">{{
              userInfo.account
            }}</span>
          </div>
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><IdcardOutlined /> 姓名</span
            >
            <span class="font-medium text-gray-800">{{ userInfo.name }}</span>
          </div>
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><NumberOutlined />
              {{ userInfo.role === "普通用户" ? "学号" : "工号" }}</span
            >
            <span class="font-medium text-gray-800">{{
              userInfo.idNumber
            }}</span>
          </div>
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><PhoneOutlined /> 联系方式</span
            >
            <span class="font-medium text-gray-800">{{ userInfo.phone }}</span>
          </div>
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><MailOutlined /> 邮箱</span
            >
            <span class="font-medium text-gray-800">{{
              userInfo.email || "未绑定"
            }}</span>
          </div>
          <div
            class="flex justify-between items-center py-2 border-b border-gray-100"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><CalendarOutlined /> 注册时间</span
            >
            <span class="font-medium text-gray-800">{{
              userInfo.registerTime
            }}</span>
          </div>
          <div
            v-if="userInfo.role === 'USER'"
            class="flex justify-between items-center py-2 cursor-pointer hover:bg-gray-50 transition-colors rounded px-2 -mx-2"
            @click="router.push('/user/my-adoptions')"
          >
            <span class="text-gray-500 flex items-center gap-2"
              ><SafetyCertificateOutlined /> 认养植物数量</span
            >
            <span class="text-xl font-bold text-green-600">{{
              userInfo.statisticNum
            }}</span>
          </div>
          <div v-else class="flex justify-between items-center py-2">
            <span class="text-gray-500 flex items-center gap-2"
              ><SafetyCertificateOutlined />
              {{ getStatLabel(userInfo.role) }}</span
            >
            <span class="text-xl font-bold text-green-600">{{
              userInfo.statisticNum
            }}</span>
          </div>
        </div>
      </div>

      <a-alert v-else-if="error" :message="error" type="error" show-icon>
        <template #action>
          <a @click="fetchProfile">重试</a>
        </template>
      </a-alert>
      <a-empty v-else description="暂无用户信息" />
    </a-skeleton>
  </a-card>
</template>

<script lang="ts" setup>
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import {
  UserOutlined,
  PhoneOutlined,
  SafetyCertificateOutlined,
  CalendarOutlined,
  IdcardOutlined,
  NumberOutlined,
  MailOutlined,
} from "@ant-design/icons-vue";
import { getUserProfile, type UserProfile } from "@/api/user";

const router = useRouter();

const loading = ref(true);
const error = ref<string | null>(null);
const userInfo = ref<UserProfile | null>(null);

const fetchProfile = async () => {
  loading.value = true;
  error.value = null;
  try {
    const res: any = await getUserProfile();
    if (res) {
      userInfo.value = res;
    } else {
      error.value = "未获取到用户信息";
    }
  } catch (err: any) {
    console.error(err);
    error.value = "获取信息失败";
  } finally {
    loading.value = false;
  }
};

const getRoleColor = (role: string) => {
  if (role === "管理员") return "red";
  if (role === "养护员") return "blue";
  return "green";
};

const getStatLabel = (role: string) => {
  if (role === "管理员") return "审核申请数";
  if (role === "养护员") return "处理异常数";
  return "认养植物数量";
};

onMounted(() => {
  fetchProfile();
  window.addEventListener("user-profile-updated", fetchProfile);
});

onUnmounted(() => {
  window.removeEventListener("user-profile-updated", fetchProfile);
});
</script>
