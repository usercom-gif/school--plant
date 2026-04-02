<template>
  <div class="p-6">
    <div class="mb-6 flex justify-between items-center">
      <h1 class="text-2xl font-bold">成果评比管理</h1>
      <div class="flex gap-4">
        <a-select
          v-model:value="adoptionCycle"
          class="w-48"
          @change="fetchData"
        >
          <a-select-option
            v-for="cycle in cycleOptions"
            :key="cycle.value"
            :value="cycle.value"
          >
            {{ cycle.label }}
          </a-select-option>
        </a-select>
        <a-button type="primary" @click="handleGenerate" :loading="generating">
          一键生成本周期报告
        </a-button>
      </div>
    </div>

    <!-- Statistics Dashboard -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
      <a-card class="shadow-sm rounded-xl border-none">
        <div class="text-gray-500">参与总人数</div>
        <div class="text-4xl font-bold mt-4">{{ stats.totalUsers || 0 }}</div>
      </a-card>
      <a-card class="shadow-sm rounded-xl border-none">
        <div class="text-gray-500">平均综合分</div>
        <div class="text-4xl font-bold mt-4 text-blue-600">
          {{ stats.averageScore || 0 }}
        </div>
      </a-card>
      <a-card class="shadow-sm rounded-xl border-none">
        <div class="text-gray-500 mb-2">成绩分布概览</div>
        <div ref="pieChartRef" style="height: 150px; width: 100%"></div>
      </a-card>
    </div>

    <!-- Outstanding List -->
    <a-card title="优秀养护人公示榜" class="shadow-sm rounded-xl border-none">
      <!-- Mobile List View -->
      <div class="md:hidden">
        <div
          v-for="record in dataSource"
          :key="record.userId"
          class="bg-white p-4 mb-3 rounded-lg border border-gray-100 shadow-sm"
        >
          <div class="flex justify-between items-start mb-2">
            <div>
              <span class="font-bold text-gray-900 block">{{
                record.userRealName || record.userName || record.userId
              }}</span>
              <span class="text-xs text-gray-500">{{ record.studentId }}</span>
            </div>
            <a-tag color="gold" v-if="record.isOutstanding">优秀养护人</a-tag>
          </div>

          <div class="text-sm text-gray-500 mb-1">
            综合评分:
            <span class="font-bold text-blue-600">{{
              record.compositeScore
            }}</span>
          </div>
          <div class="grid grid-cols-2 gap-2 text-xs text-gray-500 mt-2">
            <div>任务完成率: {{ record.taskCompletionRate }}%</div>
            <div>健康分: {{ record.plantHealthScore }}</div>
            <div>认养时长: {{ record.adoptionDurationDays }}天</div>
          </div>
        </div>
      </div>

      <!-- Desktop Table View -->
      <a-table
        class="hidden md:block"
        :dataSource="dataSource"
        :columns="columns"
        :loading="loading"
        rowKey="id"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'isOutstanding'">
            <a-tag color="gold" v-if="record.isOutstanding">优秀养护人</a-tag>
            <span v-else>-</span>
          </template>
          <template v-if="column.key === 'userName'">
            <span>{{
              record.userRealName || record.userName || record.userId
            }}</span>
          </template>
          <template v-if="column.key === 'compositeScore'">
            <span class="font-bold text-blue-600">{{
              record.compositeScore
            }}</span>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, nextTick } from "vue";
import {
  getOutstandingList,
  generateReport,
  getStats,
  type AchievementVO,
} from "@/api/achievement";
import { message } from "ant-design-vue";
import * as echarts from "echarts";

const generateCycleOptions = () => {
  const currentYear = new Date().getFullYear();
  const options = [];
  // 默认生成当前年到2023年的周期 (2023是项目开始年份示例)
  for (let year = currentYear; year >= 2023; year--) {
    options.push({ value: `${year}-Cycle2`, label: `${year} 第二周期` });
    options.push({ value: `${year}-Cycle1`, label: `${year} 第一周期` });
  }
  return options;
};

const cycleOptions = ref(generateCycleOptions());
// 默认选择当前年份的第一周期或第二周期
const currentYear = new Date().getFullYear();
const currentMonth = new Date().getMonth() + 1;
const defaultCycle =
  currentMonth <= 6 ? `${currentYear}-Cycle1` : `${currentYear}-Cycle2`;

const adoptionCycle = ref(defaultCycle);
const loading = ref(false);
const generating = ref(false);
const dataSource = ref<AchievementVO[]>([]);
const stats = ref<any>({});
const pieChartRef = ref<HTMLElement | null>(null);
let chartInstance: echarts.ECharts | null = null;

const columns = [
  { title: "用户", dataIndex: "userRealName", key: "userName" },
  { title: "学号/职工号", dataIndex: "studentId", key: "studentId" },
  {
    title: "综合评分",
    dataIndex: "compositeScore",
    key: "compositeScore",
    sorter: (a: any, b: any) => a.compositeScore - b.compositeScore,
  },
  {
    title: "任务完成率",
    dataIndex: "taskCompletionRate",
    key: "taskCompletionRate",
    customRender: ({ text }: any) => text + "%",
  },
  {
    title: "认养时长(天)",
    dataIndex: "adoptionDurationDays",
    key: "adoptionDurationDays",
  },
  { title: "健康分", dataIndex: "plantHealthScore", key: "plantHealthScore" },
  { title: "荣誉称号", key: "isOutstanding", width: 150 },
];

const fetchData = async () => {
  loading.value = true;
  try {
    const [listRes, statsRes] = await Promise.all([
      getOutstandingList({ adoptionCycle: adoptionCycle.value, size: 100 }),
      getStats(adoptionCycle.value),
    ]);

    // Check if listRes.data is wrapped or direct
    dataSource.value = (listRes as any).records || listRes;
    stats.value = statsRes;

    await nextTick();
    renderChart((statsRes as any).scoreDistribution);
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const renderChart = (distribution: Record<string, number>) => {
  if (!pieChartRef.value) return;

  if (chartInstance) {
    chartInstance.dispose();
  }

  chartInstance = echarts.init(pieChartRef.value);
  const data = distribution
    ? Object.keys(distribution).map((key) => ({
        name: key,
        value: distribution[key],
      }))
    : [];

  chartInstance.setOption({
    tooltip: { trigger: "item" },
    series: [
      {
        name: "成绩分布",
        type: "pie",
        radius: ["40%", "70%"],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: "#fff",
          borderWidth: 2,
        },
        label: { show: false },
        emphasis: {
          label: { show: false },
        },
        labelLine: { show: false },
        data: data,
      },
    ],
  });
};

const handleGenerate = async () => {
  generating.value = true;
  try {
    await generateReport(adoptionCycle.value);
    message.success("报告生成成功");
    fetchData();
  } catch (error) {
    console.error(error);
  } finally {
    generating.value = false;
  }
};

onMounted(() => {
  fetchData();
  window.addEventListener("resize", () => {
    chartInstance?.resize();
  });
});
</script>
