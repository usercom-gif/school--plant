<template>
  <div class="p-6">
    <div class="mb-6 flex justify-between items-center">
      <h1 class="text-2xl font-bold">我的认养成果</h1>
      <a-select v-model:value="adoptionCycle" class="w-48" @change="fetchData">
        <a-select-option
          v-for="cycle in cycleOptions"
          :key="cycle.value"
          :value="cycle.value"
        >
          {{ cycle.label }}
        </a-select-option>
      </a-select>
    </div>

    <a-spin :spinning="loading">
      <div v-if="achievement" class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Score Card -->
        <a-card
          class="shadow-sm rounded-xl border-none bg-gradient-to-br from-blue-50 to-indigo-50"
        >
          <div class="text-center py-8">
            <div class="text-gray-500 mb-2">综合评分</div>
            <div class="text-6xl font-bold text-blue-600">
              {{ achievement.compositeScore || 0 }}
            </div>
            <div class="mt-8 grid grid-cols-3 gap-4 text-center">
              <div class="bg-white p-3 rounded-lg shadow-sm">
                <span class="text-gray-400 block text-xs mb-1">任务完成率</span>
                <span class="font-bold text-lg text-green-600"
                  >{{ achievement.taskCompletionRate }}%</span
                >
              </div>
              <div class="bg-white p-3 rounded-lg shadow-sm">
                <span class="text-gray-400 block text-xs mb-1">总任务数</span>
                <span class="font-bold text-lg text-gray-700">{{
                  achievement.totalTasks
                }}</span>
              </div>
              <div class="bg-white p-3 rounded-lg shadow-sm">
                <span class="text-gray-400 block text-xs mb-1">已完成</span>
                <span class="font-bold text-lg text-blue-600">{{
                  achievement.tasksCompleted
                }}</span>
              </div>
            </div>

            <div class="mt-4 flex justify-center gap-4 text-sm">
              <div class="bg-white px-3 py-1 rounded shadow-sm">
                <span class="text-gray-400 block text-xs">认养时长</span>
                <span class="font-bold text-orange-600"
                  >{{ achievement.adoptionDurationDays }} 天</span
                >
              </div>
              <div class="bg-white px-3 py-1 rounded shadow-sm">
                <span class="text-gray-400 block text-xs">健康分</span>
                <span class="font-bold text-purple-600">{{
                  achievement.plantHealthScore
                }}</span>
              </div>
            </div>
          </div>
        </a-card>

        <!-- Certificate Card -->
        <a-card class="shadow-sm rounded-xl border-none">
          <div
            v-if="achievement.isOutstanding"
            class="text-center py-8 h-full flex flex-col justify-center"
          >
            <TrophyOutlined class="text-6xl text-yellow-400 mb-4 mx-auto" />
            <h3 class="text-xl font-bold text-gray-800">
              恭喜！您获得了“优秀养护人”称号
            </h3>
            <p class="text-gray-500 mt-2 mb-6">您的辛勤付出让校园更美好</p>
            <a-button type="primary" size="large" @click="downloadCertificate">
              <DownloadOutlined /> 下载电子荣誉证书
            </a-button>
          </div>
          <div
            v-else
            class="text-center py-16 text-gray-400 h-full flex flex-col justify-center"
          >
            <SmileOutlined class="text-6xl mb-4 mx-auto text-gray-300" />
            <p class="text-lg">继续加油，争取获得荣誉！</p>
            <p class="text-xs mt-2">完成率达到 100% 即可获得证书</p>
          </div>
        </a-card>
      </div>

      <a-empty v-else description="暂无本周期数据" class="mt-20" />
    </a-spin>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from "vue";
import {
  TrophyOutlined,
  DownloadOutlined,
  SmileOutlined,
} from "@ant-design/icons-vue";
import { getMyAchievement, type AchievementVO } from "@/api/achievement";
import { message } from "ant-design-vue";

const generateCycleOptions = () => {
  const currentYear = new Date().getFullYear();
  const options = [];
  for (let year = currentYear; year >= 2023; year--) {
    options.push({ value: `${year}-Cycle2`, label: `${year} 第二周期` });
    options.push({ value: `${year}-Cycle1`, label: `${year} 第一周期` });
  }
  return options;
};

const cycleOptions = ref(generateCycleOptions());
const currentYear = new Date().getFullYear();
const currentMonth = new Date().getMonth() + 1;
const defaultCycle =
  currentMonth <= 6 ? `${currentYear}-Cycle1` : `${currentYear}-Cycle2`;

const adoptionCycle = ref(defaultCycle);
const loading = ref(false);
const achievement = ref<AchievementVO | null>(null);

const fetchData = async () => {
  loading.value = true;
  try {
    const res: any = await getMyAchievement(adoptionCycle.value);
    achievement.value = res;
  } catch (error) {
    console.error(error);
    achievement.value = null;
  } finally {
    loading.value = false;
  }
};

const downloadCertificate = () => {
  if (achievement.value?.certificateUrl) {
    window.open(achievement.value.certificateUrl, "_blank");
  } else {
    message.warning("证书生成中，请稍后再试");
  }
};

onMounted(() => {
  fetchData();
});
</script>
